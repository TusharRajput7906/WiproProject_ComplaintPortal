package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.ComplaintCreateDto;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.entity.Complaint;
import com.mciet.complaintportal.entity.ComplaintStatusHistory;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.repository.ComplaintRepository;
import com.mciet.complaintportal.repository.ComplaintStatusHistoryRepository;
import com.mciet.complaintportal.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mciet.complaintportal.dto.DashboardStatsDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import com.mciet.complaintportal.entity.Role;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@Service
@Transactional
public class ComplaintServiceImpl implements ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final UserRepository userRepository;
    private final ComplaintStatusHistoryRepository historyRepository;

    @Autowired
    public ComplaintServiceImpl(ComplaintRepository complaintRepository,
                                UserRepository userRepository,
                                ComplaintStatusHistoryRepository historyRepository) {
        this.complaintRepository = complaintRepository;
        this.userRepository = userRepository;
        this.historyRepository = historyRepository;
    }

    @Override
    public ComplaintResponseDto createComplaint(ComplaintCreateDto createDto) {
        User customer = userRepository.findById(createDto.getCustomerId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with ID: " + createDto.getCustomerId()));

        Complaint complaint = new Complaint();
        complaint.setTitle(createDto.getTitle());
        complaint.setDescription(createDto.getDescription());
        complaint.setCategory(createDto.getCategory());
        complaint.setStatus(Status.OPEN);
        complaint.setCustomer(customer);

        Complaint savedComplaint = complaintRepository.save(complaint);

        // Save initial history row
        ComplaintStatusHistory history = new ComplaintStatusHistory();
        history.setComplaint(savedComplaint);
        history.setStatus(Status.OPEN);
        history.setRemarks("Complaint registered successfully by customer.");
        history.setChangedBy(customer);
        historyRepository.save(history);

        return mapToDto(savedComplaint);
    }

    @Override
    @Transactional(readOnly = true)
    public ComplaintResponseDto getComplaintById(Integer id) {
        Complaint complaint = complaintRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found with ID: " + id));
        return mapToDto(complaint);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ComplaintResponseDto> getComplaintsByCustomer(Integer customerId) {
        return complaintRepository.findByCustomerId(customerId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ComplaintResponseDto> getComplaintsByAgent(Integer agentId) {
        return complaintRepository.findByAssignedAgentId(agentId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Override
    public ComplaintResponseDto assignAgentToComplaint(Integer complaintId, Integer agentId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found with ID: " + complaintId));

        User agent = userRepository.findById(agentId)
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with ID: " + agentId));

        complaint.setAssignedAgent(agent);
        Complaint saved = complaintRepository.save(complaint);
        return mapToDto(saved);
    }

    @Override
    public ComplaintResponseDto updateComplaintStatus(Integer complaintId, Status newStatus, String remarks, Integer changedByUserId) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found with ID: " + complaintId));

        User changer = userRepository.findById(changedByUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + changedByUserId));

        complaint.setStatus(newStatus);
        Complaint savedComplaint = complaintRepository.save(complaint);

        // Log status change history
        ComplaintStatusHistory history = new ComplaintStatusHistory();
        history.setComplaint(savedComplaint);
        history.setStatus(newStatus);
        history.setRemarks(remarks);
        history.setChangedBy(changer);
        historyRepository.save(history);

        return mapToDto(savedComplaint);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ComplaintResponseDto> getAllComplaints() {
        return complaintRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public DashboardStatsDto getDashboardStats() {
        long totalComplaints = complaintRepository.count();

        Map<String, Long> complaintsByStatus = new HashMap<>();
        for (Status s : Status.values()) {
            complaintsByStatus.put(s.name(), complaintRepository.countByStatus(s));
        }

        Map<String, Long> usersByRole = new HashMap<>();
        for (Role r : Role.values()) {
            usersByRole.put(r.name(), userRepository.countByRole(r));
        }

        return new DashboardStatsDto(totalComplaints, complaintsByStatus, usersByRole);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ComplaintStatusHistoryResponseDto> getComplaintHistory(Integer complaintId) {
        if (!complaintRepository.existsById(complaintId)) {
            throw new ResourceNotFoundException("Complaint not found with ID: " + complaintId);
        }

        return historyRepository.findByComplaintIdOrderByChangedAtDesc(complaintId).stream()
                .map(h -> {
                    ComplaintStatusHistoryResponseDto dto = new ComplaintStatusHistoryResponseDto();
                    dto.setId(h.getId());
                    dto.setComplaintId(h.getComplaint().getId());
                    dto.setStatus(h.getStatus());
                    dto.setRemarks(h.getRemarks());
                    if (h.getChangedBy() != null) {
                        dto.setChangedByUserId(h.getChangedBy().getId());
                        dto.setChangedByUserName(h.getChangedBy().getName());
                    }
                    dto.setChangedAt(h.getChangedAt());
                    return dto;
                })
                .collect(Collectors.toList());
    }


    private ComplaintResponseDto mapToDto(Complaint complaint) {
        ComplaintResponseDto dto = new ComplaintResponseDto();
        dto.setId(complaint.getId());
        dto.setTitle(complaint.getTitle());
        dto.setDescription(complaint.getDescription());
        dto.setCategory(complaint.getCategory());
        dto.setStatus(complaint.getStatus());
        if (complaint.getCustomer() != null) {
            dto.setCustomerId(complaint.getCustomer().getId());
            dto.setCustomerName(complaint.getCustomer().getName());
        }
        if (complaint.getAssignedAgent() != null) {
            dto.setAssignedAgentId(complaint.getAssignedAgent().getId());
            dto.setAssignedAgentName(complaint.getAssignedAgent().getName());
        }
        dto.setCreatedAt(complaint.getCreatedAt());
        dto.setUpdatedAt(complaint.getUpdatedAt());
        return dto;
    }
}
