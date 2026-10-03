package com.aura.store.repository;

import com.aura.store.entity.AfterSalesRequest;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for AfterSalesRequest.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface AfterSalesRequestRepository extends JpaRepository<AfterSalesRequest, Integer> {
}

