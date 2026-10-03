package com.aura.store.repository;

import com.aura.store.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Permission.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface PermissionRepository extends JpaRepository<Permission, String> {
}

