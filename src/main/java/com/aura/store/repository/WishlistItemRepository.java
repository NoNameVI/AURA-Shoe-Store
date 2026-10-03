package com.aura.store.repository;

import com.aura.store.entity.WishlistItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for WishlistItem.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface WishlistItemRepository extends JpaRepository<WishlistItem, Long> {
}

