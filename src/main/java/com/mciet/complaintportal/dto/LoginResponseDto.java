package com.mciet.complaintportal.dto;

import com.mciet.complaintportal.entity.Role;

public class LoginResponseDto {

    private Integer userId;
    private String name;
    private Role role;
    private String message;

    public LoginResponseDto() {}

    public LoginResponseDto(Integer userId, String name, Role role, String message) {
        this.userId = userId;
        this.name = name;
        this.role = role;
        this.message = message;
    }

    // Getters and Setters
    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
