package com.aura.store.repository;

import com.aura.store.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for OrderItem.
 */
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
}

