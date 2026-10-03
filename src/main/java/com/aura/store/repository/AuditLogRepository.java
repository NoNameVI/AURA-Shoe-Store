package com.aura.store.repository;

import com.aura.store.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for AuditLog.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}

