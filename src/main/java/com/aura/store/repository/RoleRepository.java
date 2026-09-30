package com.aura.store.repository;

import com.aura.store.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Role.
 */
public interface RoleRepository extends JpaRepository<Role, String> {
}

