package com.aura.store.repository;

import com.aura.store.entity.OrderStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for OrderStatusHistory.
 */
public interface OrderStatusHistoryRepository extends JpaRepository<OrderStatusHistory, Long> {
}

