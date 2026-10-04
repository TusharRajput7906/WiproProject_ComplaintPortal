package com.mciet.complaintportal.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.ComplaintStatusHistoryResponseDto;
import com.mciet.complaintportal.dto.ResolveRequestDto;
import com.mciet.complaintportal.entity.Status;
import com.mciet.complaintportal.exception.GlobalExceptionHandler;
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

import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
public class AgentControllerTest {

    private MockMvc mockMvc;

    @Mock
    private ComplaintService complaintService;

    @InjectMocks
    private AgentController agentController;

    private ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(agentController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void getComplaintsByAgent_Success() throws Exception {
        ComplaintResponseDto dto = new ComplaintResponseDto();
        dto.setId(10);
        dto.setTitle("Speed Drop");

        when(complaintService.getComplaintsByAgent(2)).thenReturn(List.of(dto));

        mockMvc.perform(get("/api/agent/2/complaints"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].title").value("Speed Drop"));
    }

    @Test
    void resolveComplaint_Success() throws Exception {
        ResolveRequestDto resolveDto = new ResolveRequestDto();
        resolveDto.setRemarks("Replaced router cable.");

        ComplaintResponseDto responseDto = new ComplaintResponseDto();
        responseDto.setId(10);
        responseDto.setStatus(Status.RESOLVED);

        when(complaintService.updateComplaintStatus(10, Status.RESOLVED, "Replaced router cable.", 2))
                .thenReturn(responseDto);

        mockMvc.perform(put("/api/agent/2/complaints/10/resolve")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resolveDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.status").value("RESOLVED"));
    }

    @Test
    void getComplaintHistory_Success() throws Exception {
        ComplaintStatusHistoryResponseDto historyDto = new ComplaintStatusHistoryResponseDto();
        historyDto.setId(1);
        historyDto.setComplaintId(10);
        historyDto.setStatus(Status.RESOLVED);
        historyDto.setRemarks("Fixed");

        when(complaintService.getComplaintHistory(10)).thenReturn(List.of(historyDto));

        mockMvc.perform(get("/api/agent/2/complaints/10/history"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].complaintId").value(10));
    }
}
