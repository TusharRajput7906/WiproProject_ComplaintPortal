package com.mciet.complaintportal.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mciet.complaintportal.dto.LoginRequestDto;
import com.mciet.complaintportal.dto.UserRegistrationDto;
import com.mciet.complaintportal.entity.Role;
import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.exception.DuplicateEmailException;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
public class AuthControllerTest {

    private MockMvc mockMvc;

    @Mock
    private UserService userService;

    @Mock
    private BCryptPasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthController authController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(authController)
                .setControllerAdvice(new com.mciet.complaintportal.exception.GlobalExceptionHandler())
                .build();
    }

    @Test
    void register_Success() throws Exception {
        UserRegistrationDto dto = new UserRegistrationDto();
        dto.setName("John Customer");
        dto.setEmail("john@example.com");
        dto.setPassword("password123");
        dto.setRole(Role.CUSTOMER);

        User savedUser = new User();
        savedUser.setId(1);
        savedUser.setName("John Customer");
        savedUser.setEmail("john@example.com");
        savedUser.setRole(Role.CUSTOMER);
        savedUser.setCreatedAt(LocalDateTime.now());

        when(userService.registerUser(any(UserRegistrationDto.class))).thenReturn(savedUser);

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.email").value("john@example.com"))
                .andExpect(jsonPath("$.role").value("CUSTOMER"));
    }

    @Test
    void register_DuplicateEmail_Returns409() throws Exception {
        UserRegistrationDto dto = new UserRegistrationDto();
        dto.setName("John Duplicate");
        dto.setEmail("duplicate@example.com");
        dto.setPassword("password123");
        dto.setRole(Role.CUSTOMER);

        when(userService.registerUser(any(UserRegistrationDto.class)))
                .thenThrow(new DuplicateEmailException("Email duplicate@example.com is already registered"));

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("Email duplicate@example.com is already registered"));
    }

    @Test
    void login_Success() throws Exception {
        LoginRequestDto loginDto = new LoginRequestDto();
        loginDto.setEmail("john@example.com");
        loginDto.setPassword("password123");

        User user = new User();
        user.setId(1);
        user.setName("John Customer");
        user.setEmail("john@example.com");
        user.setPassword("encodedPassword");
        user.setRole(Role.CUSTOMER);

        when(userService.findByEmail("john@example.com")).thenReturn(user);
        when(passwordEncoder.matches("password123", "encodedPassword")).thenReturn(true);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1))
                .andExpect(jsonPath("$.name").value("John Customer"))
                .andExpect(jsonPath("$.role").value("CUSTOMER"))
                .andExpect(jsonPath("$.message").value("Login successful"));
    }

    @Test
    void login_InvalidPassword_Returns401() throws Exception {
        LoginRequestDto loginDto = new LoginRequestDto();
        loginDto.setEmail("john@example.com");
        loginDto.setPassword("wrongPassword");

        User user = new User();
        user.setId(1);
        user.setName("John Customer");
        user.setEmail("john@example.com");
        user.setPassword("encodedPassword");
        user.setRole(Role.CUSTOMER);

        when(userService.findByEmail("john@example.com")).thenReturn(user);
        when(passwordEncoder.matches("wrongPassword", "encodedPassword")).thenReturn(false);

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Invalid email or password"));
    }

    @Test
    void login_UserNotFound_Returns401() throws Exception {
        LoginRequestDto loginDto = new LoginRequestDto();
        loginDto.setEmail("unknown@example.com");
        loginDto.setPassword("password123");

        when(userService.findByEmail("unknown@example.com"))
                .thenThrow(new ResourceNotFoundException("User not found"));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginDto)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Invalid email or password"));
    }
}
