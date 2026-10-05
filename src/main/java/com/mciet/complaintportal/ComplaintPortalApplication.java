package com.mciet.complaintportal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@SpringBootApplication
public class ComplaintPortalApplication extends SpringBootServletInitializer {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public org.springframework.boot.CommandLineRunner dataInitializer(
            com.mciet.complaintportal.repository.UserRepository userRepository,
            com.mciet.complaintportal.repository.ComplaintRepository complaintRepository,
            com.mciet.complaintportal.repository.ComplaintStatusHistoryRepository historyRepository,
            BCryptPasswordEncoder encoder) {
        return args -> {
            if (userRepository.count() == 0) {
                // Seed Admin
                com.mciet.complaintportal.entity.User admin = new com.mciet.complaintportal.entity.User();
                admin.setName("System Admin");
                admin.setEmail("admin@complaintportal.com");
                admin.setPassword(encoder.encode("password123"));
                admin.setRole(com.mciet.complaintportal.entity.Role.ADMIN);
                userRepository.save(admin);

                // Seed Agent
                com.mciet.complaintportal.entity.User agent = new com.mciet.complaintportal.entity.User();
                agent.setName("Support Agent");
                agent.setEmail("agent@complaintportal.com");
                agent.setPassword(encoder.encode("password123"));
                agent.setRole(com.mciet.complaintportal.entity.Role.AGENT);
                agent = userRepository.save(agent);

                // Seed Customer
                com.mciet.complaintportal.entity.User customer = new com.mciet.complaintportal.entity.User();
                customer.setName("John Customer");
                customer.setEmail("customer@complaintportal.com");
                customer.setPassword(encoder.encode("password123"));
                customer.setRole(com.mciet.complaintportal.entity.Role.CUSTOMER);
                customer = userRepository.save(customer);

                // Seed Initial Sample Complaint
                com.mciet.complaintportal.entity.Complaint complaint = new com.mciet.complaintportal.entity.Complaint();
                complaint.setTitle("Broadband Intermittent Connectivity");
                complaint.setDescription("Fiber router loses synchronization every evening between 7 PM and 9 PM.");
                complaint.setCategory("Broadband");
                complaint.setStatus(com.mciet.complaintportal.entity.Status.OPEN);
                complaint.setCustomer(customer);
                complaint.setAssignedAgent(agent);
                com.mciet.complaintportal.entity.Complaint savedComplaint = complaintRepository.save(complaint);

                // Seed Initial History
                com.mciet.complaintportal.entity.ComplaintStatusHistory history = new com.mciet.complaintportal.entity.ComplaintStatusHistory();
                history.setComplaint(savedComplaint);
                history.setStatus(com.mciet.complaintportal.entity.Status.OPEN);
                history.setRemarks("Complaint registered successfully by customer.");
                history.setChangedBy(customer);
                historyRepository.save(history);
            }
        };
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ComplaintPortalApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(ComplaintPortalApplication.class, args);
    }
}
