package com.aura.store.repository;

import com.aura.store.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for OrderItem.
 * TODO: Người phụ trách: Minh Phát, Minh Thức.
 */
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
}

