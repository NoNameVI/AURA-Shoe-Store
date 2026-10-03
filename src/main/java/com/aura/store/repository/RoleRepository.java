package com.aura.store.repository;

import com.aura.store.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Role.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface RoleRepository extends JpaRepository<Role, String> {
}

