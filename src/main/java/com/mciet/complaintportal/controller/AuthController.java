package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.dto.LoginRequestDto;
import com.mciet.complaintportal.dto.LoginResponseDto;
import com.mciet.complaintportal.dto.UserRegistrationDto;
import com.mciet.complaintportal.dto.UserResponseDto;
import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    public AuthController(UserService userService, BCryptPasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponseDto> register(@Valid @RequestBody UserRegistrationDto registrationDto) {
        User registeredUser = userService.registerUser(registrationDto);
        return new ResponseEntity<>(mapToUserResponse(registeredUser), HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@Valid @RequestBody LoginRequestDto loginDto) {
        try {
            User user = userService.findByEmail(loginDto.getEmail());
            if (passwordEncoder.matches(loginDto.getPassword(), user.getPassword())) {
                LoginResponseDto response = new LoginResponseDto(
                        user.getId(),
                        user.getName(),
                        user.getRole(),
                        "Login successful"
                );
                return ResponseEntity.ok(response);
            }
        } catch (ResourceNotFoundException e) {
            // Drop through to unauthorized response
        }

        LoginResponseDto errorResponse = new LoginResponseDto(
                null,
                null,
                null,
                "Invalid email or password"
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
    }

    private UserResponseDto mapToUserResponse(User user) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }
}
