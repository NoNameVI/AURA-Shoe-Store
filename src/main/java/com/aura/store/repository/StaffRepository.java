package com.aura.store.repository;

import com.aura.store.entity.Staff;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Staff.
 */
public interface StaffRepository extends JpaRepository<Staff, Long> {
}

