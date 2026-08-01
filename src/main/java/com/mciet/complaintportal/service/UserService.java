package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.UserRegistrationDto;
import com.mciet.complaintportal.entity.User;

public interface UserService {
    User registerUser(UserRegistrationDto registrationDto);
    User findByEmail(String email);
}
