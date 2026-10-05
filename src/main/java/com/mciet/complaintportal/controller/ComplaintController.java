package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.dto.ComplaintCreateDto;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import com.mciet.complaintportal.dto.StatusUpdateDto;
import com.mciet.complaintportal.service.ComplaintService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/complaints")
public class ComplaintController {

    private final ComplaintService complaintService;

    @Autowired
    public ComplaintController(ComplaintService complaintService) {
        this.complaintService = complaintService;
    }

    @PostMapping
    public ResponseEntity<ComplaintResponseDto> createComplaint(@Valid @RequestBody ComplaintCreateDto createDto) {
        ComplaintResponseDto responseDto = complaintService.createComplaint(createDto);
        return new ResponseEntity<>(responseDto, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ComplaintResponseDto> getComplaintById(@PathVariable Integer id) {
        ComplaintResponseDto responseDto = complaintService.getComplaintById(id);
        return ResponseEntity.ok(responseDto);
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<List<ComplaintStatusHistoryResponseDto>> getComplaintHistory(@PathVariable Integer id) {
        List<ComplaintStatusHistoryResponseDto> history = complaintService.getComplaintHistory(id);
        return ResponseEntity.ok(history);
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<ComplaintResponseDto>> getComplaintsByCustomer(@PathVariable Integer customerId) {
        List<ComplaintResponseDto> complaints = complaintService.getComplaintsByCustomer(customerId);
        return ResponseEntity.ok(complaints);
    }

    @GetMapping("/agent/{agentId}")
    public ResponseEntity<List<ComplaintResponseDto>> getComplaintsByAgent(@PathVariable Integer agentId) {
        List<ComplaintResponseDto> complaints = complaintService.getComplaintsByAgent(agentId);
        return ResponseEntity.ok(complaints);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ComplaintResponseDto> updateComplaintStatus(
            @PathVariable Integer id,
            @Valid @RequestBody StatusUpdateDto updateDto) {
        ComplaintResponseDto responseDto = complaintService.updateComplaintStatus(
                id,
                updateDto.getStatus(),
                updateDto.getRemarks(),
                updateDto.getChangedByUserId()
        );
        return ResponseEntity.ok(responseDto);
    }
}
