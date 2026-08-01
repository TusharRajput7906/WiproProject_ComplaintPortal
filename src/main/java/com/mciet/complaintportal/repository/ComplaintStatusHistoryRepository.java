package com.mciet.complaintportal.repository;

import com.mciet.complaintportal.entity.ComplaintStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ComplaintStatusHistoryRepository extends JpaRepository<ComplaintStatusHistory, Integer> {
    List<ComplaintStatusHistory> findByComplaintIdOrderByChangedAtDesc(Integer complaintId);
}
