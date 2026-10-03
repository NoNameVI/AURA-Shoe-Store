package com.aura.store.repository;

import com.aura.store.entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for PurchaseOrder.
 * TODO: Người phụ trách: Minh Thức, Mai Thanh.
 */
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Integer> {
}

