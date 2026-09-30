package com.aura.store.repository;

import com.aura.store.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Order.
 */
public interface OrderRepository extends JpaRepository<Order, Long> {
}

