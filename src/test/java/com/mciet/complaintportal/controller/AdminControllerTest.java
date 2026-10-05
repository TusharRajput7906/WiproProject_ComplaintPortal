package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.dto.ComplaintResponseDto;
import com.mciet.complaintportal.dto.DashboardStatsDto;
import com.mciet.complaintportal.dto.UserResponseDto;
import com.mciet.complaintportal.entity.Role;
import com.mciet.complaintportal.exception.GlobalExceptionHandler;
import com.mciet.complaintportal.exception.UserDeletionException;
import com.mciet.complaintportal.service.ComplaintService;
import com.mciet.complaintportal.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.HashMap;
import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
public class AdminControllerTest {

    private MockMvc mockMvc;

    @Mock
    private UserService userService;

    @Mock
    private ComplaintService complaintService;

    @InjectMocks
    private AdminController adminController;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(adminController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void getAllUsers_Success() throws Exception {
        UserResponseDto u = new UserResponseDto();
        u.setId(1);
        u.setName("Admin");
        u.setRole(Role.ADMIN);

        when(userService.getAllUsers()).thenReturn(List.of(u));

        mockMvc.perform(get("/api/admin/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].name").value("Admin"));
    }

    @Test
    void getUsersByRole_Success() throws Exception {
        UserResponseDto u = new UserResponseDto();
        u.setId(2);
        u.setName("Agent 1");
        u.setRole(Role.AGENT);

        when(userService.getUsersByRole(Role.AGENT)).thenReturn(List.of(u));

        mockMvc.perform(get("/api/admin/users/role/AGENT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].role").value("AGENT"));
    }

    @Test
    void assignAgentToComplaint_Success() throws Exception {
        ComplaintResponseDto dto = new ComplaintResponseDto();
        dto.setId(10);
        dto.setAssignedAgentId(2);
        dto.setAssignedAgentName("Agent 1");

        when(complaintService.assignAgentToComplaint(10, 2)).thenReturn(dto);

        mockMvc.perform(put("/api/admin/complaints/10/assign/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.assignedAgentId").value(2));
    }

    @Test
    void getDashboardStats_Success() throws Exception {
        DashboardStatsDto stats = new DashboardStatsDto(5, new HashMap<>(), new HashMap<>());
        when(complaintService.getDashboardStats()).thenReturn(stats);

        mockMvc.perform(get("/api/admin/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalComplaints").value(5));
    }

    @Test
    void deleteUser_Success() throws Exception {
        doNothing().when(userService).deleteUser(5);

        mockMvc.perform(delete("/api/admin/users/5"))
                .andExpect(status().isNoContent());

        verify(userService, times(1)).deleteUser(5);
    }

    @Test
    void deleteUser_HasUnresolvedComplaints_ThrowsBadRequest() throws Exception {
        doThrow(new UserDeletionException("Cannot delete user: they have unresolved complaints"))
                .when(userService).deleteUser(5);

        mockMvc.perform(delete("/api/admin/users/5"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Cannot delete user: they have unresolved complaints"));
    }
}
