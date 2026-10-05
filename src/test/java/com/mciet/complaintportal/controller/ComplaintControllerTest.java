package com.mciet.complaintportal.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mciet.complaintportal.dto.ComplaintCreateDto;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import com.mciet.complaintportal.dto.StatusUpdateDto;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.exception.GlobalExceptionHandler;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.service.ComplaintService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
public class ComplaintControllerTest {

    private MockMvc mockMvc;

    @Mock
    private ComplaintService complaintService;

    @InjectMocks
    private ComplaintController complaintController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(complaintController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void createComplaint_Success() throws Exception {
        ComplaintCreateDto dto = new ComplaintCreateDto();
        dto.setTitle("Fiber Down");
        dto.setDescription("No optical signal");
        dto.setCategory("Broadband");
        dto.setCustomerId(5);

        ComplaintResponseDto responseDto = new ComplaintResponseDto();
        responseDto.setId(101);
        responseDto.setTitle("Fiber Down");
        responseDto.setDescription("No optical signal");
        responseDto.setCategory("Broadband");
        responseDto.setStatus(Status.OPEN);
        responseDto.setCustomerId(5);
        responseDto.setCustomerName("Alice Customer");
        responseDto.setCreatedAt(LocalDateTime.now());

        when(complaintService.createComplaint(any(ComplaintCreateDto.class))).thenReturn(responseDto);

        mockMvc.perform(post("/api/complaints")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(101))
                .andExpect(jsonPath("$.title").value("Fiber Down"))
                .andExpect(jsonPath("$.status").value("OPEN"));
    }

    @Test
    void getComplaintById_Success() throws Exception {
        ComplaintResponseDto responseDto = new ComplaintResponseDto();
        responseDto.setId(101);
        responseDto.setTitle("Fiber Down");
        responseDto.setStatus(Status.OPEN);

        when(complaintService.getComplaintById(101)).thenReturn(responseDto);

        mockMvc.perform(get("/api/complaints/101"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(101))
                .andExpect(jsonPath("$.title").value("Fiber Down"));
    }

    @Test
    void getComplaintById_NotFound() throws Exception {
        when(complaintService.getComplaintById(999))
                .thenThrow(new ResourceNotFoundException("Complaint not found with ID: 999"));

        mockMvc.perform(get("/api/complaints/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.message").value("Complaint not found with ID: 999"));
    }

    @Test
    void getComplaintsByCustomer_Success() throws Exception {
        ComplaintResponseDto c1 = new ComplaintResponseDto();
        c1.setId(1);
        c1.setTitle("Issue 1");

        when(complaintService.getComplaintsByCustomer(5)).thenReturn(List.of(c1));

        mockMvc.perform(get("/api/complaints/customer/5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].title").value("Issue 1"));
    }

    @Test
    void updateComplaintStatus_Success() throws Exception {
        StatusUpdateDto updateDto = new StatusUpdateDto();
        updateDto.setStatus(Status.RESOLVED);
        updateDto.setRemarks("Issue fixed by rebooting switch.");
        updateDto.setChangedByUserId(2);

        ComplaintResponseDto responseDto = new ComplaintResponseDto();
        responseDto.setId(101);
        responseDto.setStatus(Status.RESOLVED);

        when(complaintService.updateComplaintStatus(eq(101), eq(Status.RESOLVED), eq("Issue fixed by rebooting switch."), eq(2)))
                .thenReturn(responseDto);

        mockMvc.perform(put("/api/complaints/101/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(101))
                .andExpect(jsonPath("$.status").value("RESOLVED"));
    }

    @Test
    void getComplaintHistory_Success() throws Exception {
        ComplaintStatusHistoryResponseDto h = new ComplaintStatusHistoryResponseDto();
        h.setId(1);
        h.setComplaintId(101);
        h.setStatus(Status.OPEN);
        h.setRemarks("Created");

        when(complaintService.getComplaintHistory(101)).thenReturn(List.of(h));

        mockMvc.perform(get("/api/complaints/101/history"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].complaintId").value(101))
                .andExpect(jsonPath("$[0].status").value("OPEN"));
    }
}
