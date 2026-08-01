package com.mciet.complaintportal.repository;

import com.mciet.complaintportal.entity.Complaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ComplaintRepository extends JpaRepository<Complaint, Integer> {
    List<Complaint> findByCustomerId(Integer customerId);
    List<Complaint> findByAssignedAgentId(Integer agentId);
}
