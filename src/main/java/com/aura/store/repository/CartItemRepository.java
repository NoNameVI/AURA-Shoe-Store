package com.aura.store.repository;

import com.aura.store.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for CartItem.
 */
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
}

