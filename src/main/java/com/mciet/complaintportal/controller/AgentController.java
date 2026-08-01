package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import com.mciet.complaintportal.dto.ResolveRequestDto;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.service.ComplaintService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agent")
public class AgentController {

    private final ComplaintService complaintService;

    @Autowired
    public AgentController(ComplaintService complaintService) {
        this.complaintService = complaintService;
    }

    @GetMapping("/{agentId}/complaints")
    public ResponseEntity<List<ComplaintResponseDto>> getComplaintsByAgent(@PathVariable Integer agentId) {
        List<ComplaintResponseDto> complaints = complaintService.getComplaintsByAgent(agentId);
        return ResponseEntity.ok(complaints);
    }

    @PutMapping("/{agentId}/complaints/{complaintId}/resolve")
    public ResponseEntity<ComplaintResponseDto> resolveComplaint(
            @PathVariable Integer agentId,
            @PathVariable Integer complaintId,
            @Valid @RequestBody ResolveRequestDto resolveDto) {
        ComplaintResponseDto resolvedComplaint = complaintService.updateComplaintStatus(
                complaintId,
                Status.RESOLVED,
                resolveDto.getRemarks(),
                agentId
        );
        return ResponseEntity.ok(resolvedComplaint);
    }

    @GetMapping("/{agentId}/complaints/{complaintId}/history")
    public ResponseEntity<List<ComplaintStatusHistoryResponseDto>> getComplaintHistory(
            @PathVariable Integer agentId,
            @PathVariable Integer complaintId) {
        List<ComplaintStatusHistoryResponseDto> history = complaintService.getComplaintHistory(complaintId);
        return ResponseEntity.ok(history);
    }
}
