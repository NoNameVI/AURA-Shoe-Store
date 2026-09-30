package com.aura.store.repository;

import com.aura.store.entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for PurchaseOrder.
 */
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {
}

