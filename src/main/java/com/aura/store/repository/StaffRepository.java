package com.aura.store.repository;

import com.aura.store.entity.Staff;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Staff.
 * TODO: Người phụ trách: Minh Phát, Minh Thức.
 */
public interface StaffRepository extends JpaRepository<Staff, Integer> {
    /** Chi nhan role dang hoat dong cua nhan vien. */
    @Query(value = "SELECT s.role_code FROM staffs s JOIN roles r ON r.role_code = s.role_code "
            + "WHERE s.staff_id = :staffId AND r.is_active = TRUE", nativeQuery = true)
    Optional<String> findActiveRoleCode(@Param("staffId") Integer staffId);
}

