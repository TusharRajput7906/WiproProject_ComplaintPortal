package com.mciet.complaintportal.dto;

import com.mciet.complaintportal.entity.Status;
import jakarta.validation.constraints.NotNull;

public class StatusUpdateDto {

    @NotNull(message = "Status is required")
    private Status status;

    private String remarks;

    @NotNull(message = "changedByUserId is required")
    private Integer changedByUserId;

    // Getters and Setters
    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public Integer getChangedByUserId() {
        return changedByUserId;
    }

    public void setChangedByUserId(Integer changedByUserId) {
        this.changedByUserId = changedByUserId;
    }
}
