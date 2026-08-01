package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.UserRegistrationDto;
import com.mciet.complaintportal.entity.User;

import com.mciet.complaintportal.dto.UserResponseDto;
import com.mciet.complaintportal.entity.Role;
import java.util.List;

public interface UserService {
    User registerUser(UserRegistrationDto registrationDto);
    User findByEmail(String email);
    List<UserResponseDto> getAllUsers();
    List<UserResponseDto> getUsersByRole(Role role);
}
