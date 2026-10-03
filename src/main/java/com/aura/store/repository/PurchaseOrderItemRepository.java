package com.aura.store.repository;

import com.aura.store.entity.PurchaseOrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for PurchaseOrderItem.
 * TODO: Người phụ trách: Minh Thức, Mai Thanh.
 */
public interface PurchaseOrderItemRepository extends JpaRepository<PurchaseOrderItem, Long> {
}

