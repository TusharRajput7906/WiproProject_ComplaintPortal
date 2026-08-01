package com.mciet.complaintportal.repository;

import com.mciet.complaintportal.entity.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.mciet.complaintportal.entity.Status;
import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Integer> {
    List<Complaint> findByCustomerId(Integer customerId);
    List<Complaint> findByAssignedAgentId(Integer agentId);
    long countByStatus(Status status);
}
