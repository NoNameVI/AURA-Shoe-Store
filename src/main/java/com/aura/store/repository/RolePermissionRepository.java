package com.aura.store.repository;

import com.aura.store.entity.RolePermission;
import com.aura.store.entity.RolePermissionId;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for RolePermission.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface RolePermissionRepository extends JpaRepository<RolePermission, RolePermissionId> {
}

