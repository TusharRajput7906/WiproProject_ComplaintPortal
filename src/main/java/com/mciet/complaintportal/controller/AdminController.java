package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.DashboardStatsDto;
import com.mciet.complaintportal.dto.UserResponseDto;
import com.mciet.complaintportal.entity.Role;
import com.mciet.complaintportal.service.ComplaintService;
import com.mciet.complaintportal.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserService userService;
    private final ComplaintService complaintService;

    @Autowired
    public AdminController(UserService userService, ComplaintService complaintService) {
        this.userService = userService;
        this.complaintService = complaintService;
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponseDto>> getAllUsers() {
        List<UserResponseDto> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/users/role/{role}")
    public ResponseEntity<List<UserResponseDto>> getUsersByRole(@PathVariable Role role) {
        List<UserResponseDto> users = userService.getUsersByRole(role);
        return ResponseEntity.ok(users);
    }

    @PutMapping("/complaints/{complaintId}/assign/{agentId}")
    public ResponseEntity<ComplaintResponseDto> assignAgentToComplaint(
            @PathVariable Integer complaintId,
            @PathVariable Integer agentId) {
        ComplaintResponseDto updatedComplaint = complaintService.assignAgentToComplaint(complaintId, agentId);
        return ResponseEntity.ok(updatedComplaint);
    }

    @GetMapping("/complaints")
    public ResponseEntity<List<ComplaintResponseDto>> getAllComplaints() {
        List<ComplaintResponseDto> complaints = complaintService.getAllComplaints();
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/dashboard/stats")
    public ResponseEntity<DashboardStatsDto> getDashboardStats() {
        DashboardStatsDto stats = complaintService.getDashboardStats();
        return ResponseEntity.ok(stats);
    }
}
