package com.aura.store.repository;

import com.aura.store.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for CartItem.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
}

