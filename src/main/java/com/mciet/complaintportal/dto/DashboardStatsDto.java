package com.mciet.complaintportal.dto;

import java.util.Map;

public class DashboardStatsDto {

    private long totalComplaints;
    private Map<String, Long> complaintsByStatus;
    private Map<String, Long> usersByRole;

    public DashboardStatsDto() {}

    public DashboardStatsDto(long totalComplaints, Map<String, Long> complaintsByStatus, Map<String, Long> usersByRole) {
        this.totalComplaints = totalComplaints;
        this.complaintsByStatus = complaintsByStatus;
        this.usersByRole = usersByRole;
    }

    // Getters and Setters
    public long getTotalComplaints() {
        return totalComplaints;
    }

    public void setTotalComplaints(long totalComplaints) {
        this.totalComplaints = totalComplaints;
    }

    public Map<String, Long> getComplaintsByStatus() {
        return complaintsByStatus;
    }

    public void setComplaintsByStatus(Map<String, Long> complaintsByStatus) {
        this.complaintsByStatus = complaintsByStatus;
    }

    public Map<String, Long> getUsersByRole() {
        return usersByRole;
    }

    public void setUsersByRole(Map<String, Long> usersByRole) {
        this.usersByRole = usersByRole;
    }
}
