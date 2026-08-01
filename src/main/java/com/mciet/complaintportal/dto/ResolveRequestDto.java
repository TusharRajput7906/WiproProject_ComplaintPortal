package com.mciet.complaintportal.dto;

import jakarta.validation.constraints.NotBlank;

public class ResolveRequestDto {

    @NotBlank(message = "Resolution remarks are required")
    private String remarks;

    // Getters and Setters
    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
