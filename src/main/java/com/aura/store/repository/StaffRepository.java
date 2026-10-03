package com.aura.store.repository;

import com.aura.store.entity.Staff;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Staff.
 * TODO: Người phụ trách: Minh Phát, Minh Thức.
 */
public interface StaffRepository extends JpaRepository<Staff, Integer> {
}

