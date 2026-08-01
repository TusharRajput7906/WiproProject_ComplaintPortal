package com.mciet.complaintportal.service;

import com.mciet.complaintportal.dto.ComplaintCreateDto;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.entity.Complaint;
import com.mciet.complaintportal.entity.ComplaintStatusHistory;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.entity.Role;
import com.mciet.complaintportal.repository.ComplaintRepository;
import com.mciet.complaintportal.repository.ComplaintStatusHistoryRepository;
import com.mciet.complaintportal.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ComplaintServiceTest {

    @Mock
    private ComplaintRepository complaintRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ComplaintStatusHistoryRepository historyRepository;

    @InjectMocks
    private ComplaintServiceImpl complaintService;

    private User customer;
    private User agent;

    @BeforeEach
    void setUp() {
        customer = new User();
        customer.setId(1);
        customer.setName("John Customer");
        customer.setEmail("john@example.com");
        customer.setRole(Role.CUSTOMER);

        agent = new User();
        agent.setId(2);
        agent.setName("Agent Support");
        agent.setEmail("agent@example.com");
        agent.setRole(Role.AGENT);
    }

    @Test
    void testCreateComplaint_Success() {
        // Arrange
        ComplaintCreateDto createDto = new ComplaintCreateDto();
        createDto.setTitle("Internet Issue");
        createDto.setDescription("Connection is dropping");
        createDto.setCategory("Network");
        createDto.setCustomerId(1);

        Complaint savedComplaint = new Complaint();
        savedComplaint.setId(100);
        savedComplaint.setTitle(createDto.getTitle());
        savedComplaint.setDescription(createDto.getDescription());
        savedComplaint.setCategory(createDto.getCategory());
        savedComplaint.setStatus(Status.OPEN);
        savedComplaint.setCustomer(customer);

        when(userRepository.findById(1)).thenReturn(Optional.of(customer));
        when(complaintRepository.save(any(Complaint.class))).thenReturn(savedComplaint);
        when(historyRepository.save(any(ComplaintStatusHistory.class))).thenReturn(new ComplaintStatusHistory());

        // Act
        ComplaintResponseDto response = complaintService.createComplaint(createDto);

        // Assert
        assertNotNull(response);
        assertEquals(100, response.getId());
        assertEquals("Internet Issue", response.getTitle());
        assertEquals(Status.OPEN, response.getStatus());
        assertEquals(1, response.getCustomerId());
        assertEquals("John Customer", response.getCustomerName());

        verify(userRepository, times(1)).findById(1);
        verify(complaintRepository, times(1)).save(any(Complaint.class));
        verify(historyRepository, times(1)).save(any(ComplaintStatusHistory.class));
    }

    @Test
    void testUpdateComplaintStatus_Success() {
        // Arrange
        Integer complaintId = 100;
        Integer changerUserId = 2; // Changer is agent
        
        Complaint existingComplaint = new Complaint();
        existingComplaint.setId(complaintId);
        existingComplaint.setTitle("Internet Issue");
        existingComplaint.setDescription("Connection is dropping");
        existingComplaint.setCategory("Network");
        existingComplaint.setStatus(Status.OPEN);
        existingComplaint.setCustomer(customer);

        Complaint updatedComplaint = new Complaint();
        updatedComplaint.setId(complaintId);
        updatedComplaint.setTitle("Internet Issue");
        updatedComplaint.setDescription("Connection is dropping");
        updatedComplaint.setCategory("Network");
        updatedComplaint.setStatus(Status.IN_PROGRESS);
        updatedComplaint.setCustomer(customer);
        updatedComplaint.setAssignedAgent(agent);

        when(complaintRepository.findById(complaintId)).thenReturn(Optional.of(existingComplaint));
        when(userRepository.findById(changerUserId)).thenReturn(Optional.of(agent));
        when(complaintRepository.save(any(Complaint.class))).thenReturn(updatedComplaint);
        when(historyRepository.save(any(ComplaintStatusHistory.class))).thenReturn(new ComplaintStatusHistory());

        // Act
        ComplaintResponseDto response = complaintService.updateComplaintStatus(
                complaintId, Status.IN_PROGRESS, "Investigation started.", changerUserId);

        // Assert
        assertNotNull(response);
        assertEquals(complaintId, response.getId());
        assertEquals(Status.IN_PROGRESS, response.getStatus());

        verify(complaintRepository, times(1)).findById(complaintId);
        verify(userRepository, times(1)).findById(changerUserId);
        verify(complaintRepository, times(1)).save(any(Complaint.class));
        verify(historyRepository, times(1)).save(any(ComplaintStatusHistory.class));
    }
}
