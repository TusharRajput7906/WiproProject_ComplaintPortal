package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.ComplaintCreateDto;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.dto.DashboardStatsDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import java.util.List;

public interface ComplaintService {
    ComplaintResponseDto createComplaint(ComplaintCreateDto createDto);
    ComplaintResponseDto getComplaintById(Integer id);
    List<ComplaintResponseDto> getComplaintsByCustomer(Integer customerId);
    List<ComplaintResponseDto> getComplaintsByAgent(Integer agentId);
    ComplaintResponseDto assignAgentToComplaint(Integer complaintId, Integer agentId);
    ComplaintResponseDto updateComplaintStatus(Integer complaintId, Status newStatus, String remarks, Integer changedByUserId);
    List<ComplaintResponseDto> getAllComplaints();
    DashboardStatsDto getDashboardStats();
    List<ComplaintStatusHistoryResponseDto> getComplaintHistory(Integer complaintId);
}
