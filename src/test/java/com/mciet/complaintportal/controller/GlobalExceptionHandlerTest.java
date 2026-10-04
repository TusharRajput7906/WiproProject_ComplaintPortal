package com.mciet.complaintportal.controller;

import com.mciet.complaintportal.exception.DuplicateEmailException;
import com.mciet.complaintportal.exception.GlobalExceptionHandler;
import com.mciet.complaintportal.exception.ResourceNotFoundException;
import com.mciet.complaintportal.exception.UserDeletionException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

public class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;

    @RestController
    static class TestController {
        @GetMapping("/test/not-found")
        public void throwNotFound() {
            throw new ResourceNotFoundException("Item not found");
        }

        @GetMapping("/test/duplicate")
        public void throwDuplicate() {
            throw new DuplicateEmailException("Email in use");
        }

        @GetMapping("/test/user-delete")
        public void throwUserDelete() {
            throw new UserDeletionException("Cannot delete user with open tickets");
        }

        @GetMapping("/test/generic-error")
        public void throwGeneric() {
            throw new RuntimeException("Unexpected db failure");
        }
    }

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void testResourceNotFoundException() throws Exception {
        mockMvc.perform(get("/test/not-found"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.error").value("Not Found"))
                .andExpect(jsonPath("$.message").value("Item not found"));
    }

    @Test
    void testDuplicateEmailException() throws Exception {
        mockMvc.perform(get("/test/duplicate"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.error").value("Conflict"))
                .andExpect(jsonPath("$.message").value("Email in use"));
    }

    @Test
    void testUserDeletionException() throws Exception {
        mockMvc.perform(get("/test/user-delete"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.error").value("Bad Request"))
                .andExpect(jsonPath("$.message").value("Cannot delete user with open tickets"));
    }

    @Test
    void testFallbackException() throws Exception {
        mockMvc.perform(get("/test/generic-error"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.status").value(500))
                .andExpect(jsonPath("$.error").value("Internal Server Error"));
    }
}
