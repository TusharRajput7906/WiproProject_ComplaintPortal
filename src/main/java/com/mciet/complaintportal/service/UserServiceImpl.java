package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.UserRegistrationDto;
import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.exception.DuplicateEmailException;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.repository.UserRepository;
import com.mciet.complaintportal.repository.ComplaintRepository;
import com.mciet.complaintportal.exception.UserDeletionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mciet.complaintportal.dto.UserResponseDto;
import com.mciet.complaintportal.entity.Role;
import com.mciet.complaintportal.entity.Status;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final ComplaintRepository complaintRepository;

    @Autowired
    public UserServiceImpl(UserRepository userRepository, 
                           BCryptPasswordEncoder passwordEncoder,
                           ComplaintRepository complaintRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.complaintRepository = complaintRepository;
    }

    @Override
    public User registerUser(UserRegistrationDto registrationDto) {
        if (userRepository.findByEmail(registrationDto.getEmail()).isPresent()) {
            throw new DuplicateEmailException("Email " + registrationDto.getEmail() + " is already registered");
        }

        User user = new User();
        user.setName(registrationDto.getName());
        user.setEmail(registrationDto.getEmail());
        user.setPassword(passwordEncoder.encode(registrationDto.getPassword()));
        user.setRole(registrationDto.getRole());

        return userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserResponseDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserResponseDto> getUsersByRole(Role role) {
        return userRepository.findByRole(role).stream()
                .map(this::mapToResponseDto)
                .collect(Collectors.toList());
    }

    private UserResponseDto mapToResponseDto(User user) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    @Override
    public void deleteUser(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));

        List<Status> unresolved = List.of(Status.OPEN, Status.IN_PROGRESS);

        if (complaintRepository.existsByCustomerIdAndStatusIn(userId, unresolved)) {
            throw new UserDeletionException("Cannot delete user: they have unresolved complaints (OPEN or IN_PROGRESS).");
        }

        if (complaintRepository.existsByAssignedAgentIdAndStatusIn(userId, unresolved)) {
            throw new UserDeletionException("Cannot delete user: this agent is currently assigned to unresolved complaints (OPEN or IN_PROGRESS).");
        }

        userRepository.delete(user);
    }
}
