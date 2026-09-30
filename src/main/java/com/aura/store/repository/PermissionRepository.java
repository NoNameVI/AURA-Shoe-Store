package com.aura.store.repository;

import com.aura.store.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Permission.
 */
public interface PermissionRepository extends JpaRepository<Permission, String> {
}

