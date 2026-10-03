package com.aura.store.repository;

import com.aura.store.entity.RolePermission;
import com.aura.store.entity.RolePermissionId;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for RolePermission.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface RolePermissionRepository extends JpaRepository<RolePermission, RolePermissionId> {
    /** Bo qua permission da tat khi nap authority cho phien dang nhap. */
    @Query(value = "SELECT rp.permission_key FROM role_permissions rp "
            + "JOIN permissions p ON p.permission_key = rp.permission_key "
            + "WHERE rp.role_code = :roleCode AND p.is_active = TRUE", nativeQuery = true)
    List<String> findActivePermissionKeys(@Param("roleCode") String roleCode);
}

