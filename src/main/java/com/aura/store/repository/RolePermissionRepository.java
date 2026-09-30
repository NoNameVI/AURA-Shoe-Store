package com.aura.store.repository;

import com.aura.store.entity.RolePermission;
import com.aura.store.entity.RolePermissionId;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for RolePermission.
 */
public interface RolePermissionRepository extends JpaRepository<RolePermission, RolePermissionId> {
}

