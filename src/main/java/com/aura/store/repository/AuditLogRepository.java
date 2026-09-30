package com.aura.store.repository;

import com.aura.store.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for AuditLog.
 */
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}

