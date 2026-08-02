package com.mciet.complaintportal.service;

import com.mciet.complaintportal.entity.User;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.exception.UserDeletionException;
import com.mciet.complaintportal.repository.ComplaintRepository;
import com.mciet.complaintportal.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.mciet.complaintportal.entity.Status;
import java.util.Optional;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private ComplaintRepository complaintRepository;

    @Mock
    private BCryptPasswordEncoder passwordEncoder;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void deleteUser_Success() {
        Integer userId = 10;
        User user = new User();
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(complaintRepository.existsByCustomerIdAndStatusIn(eq(userId), anyList())).thenReturn(false);
        when(complaintRepository.existsByAssignedAgentIdAndStatusIn(eq(userId), anyList())).thenReturn(false);

        assertDoesNotThrow(() -> userService.deleteUser(userId));

        verify(userRepository, times(1)).findById(userId);
        verify(complaintRepository, times(1)).existsByCustomerIdAndStatusIn(eq(userId), anyList());
        verify(complaintRepository, times(1)).existsByAssignedAgentIdAndStatusIn(eq(userId), anyList());
        verify(userRepository, times(1)).delete(user);
    }

    @Test
    void deleteUser_NotFound_ThrowsException() {
        Integer userId = 99;

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> userService.deleteUser(userId));

        verify(userRepository, times(1)).findById(userId);
        verify(userRepository, never()).delete(any(User.class));
    }

    @Test
    void deleteUser_CustomerWithComplaints_ThrowsException() {
        Integer userId = 10;
        User user = new User();
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(complaintRepository.existsByCustomerIdAndStatusIn(eq(userId), anyList())).thenReturn(true);

        UserDeletionException exception = assertThrows(UserDeletionException.class, () -> userService.deleteUser(userId));
        assertEquals("Cannot delete user: they have unresolved complaints (OPEN or IN_PROGRESS).", exception.getMessage());

        verify(userRepository, times(1)).findById(userId);
        verify(complaintRepository, times(1)).existsByCustomerIdAndStatusIn(eq(userId), anyList());
        verify(complaintRepository, never()).existsByAssignedAgentIdAndStatusIn(anyInt(), anyList());
        verify(userRepository, never()).delete(any(User.class));
    }

    @Test
    void deleteUser_AgentWithComplaints_ThrowsException() {
        Integer userId = 20;
        User user = new User();
        user.setId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(complaintRepository.existsByCustomerIdAndStatusIn(eq(userId), anyList())).thenReturn(false);
        when(complaintRepository.existsByAssignedAgentIdAndStatusIn(eq(userId), anyList())).thenReturn(true);

        UserDeletionException exception = assertThrows(UserDeletionException.class, () -> userService.deleteUser(userId));
        assertEquals("Cannot delete user: this agent is currently assigned to unresolved complaints (OPEN or IN_PROGRESS).", exception.getMessage());

        verify(userRepository, times(1)).findById(userId);
        verify(complaintRepository, times(1)).existsByCustomerIdAndStatusIn(eq(userId), anyList());
        verify(complaintRepository, times(1)).existsByAssignedAgentIdAndStatusIn(eq(userId), anyList());
        verify(userRepository, never()).delete(any(User.class));
    }
}
