package com.aura.store.repository;

import com.aura.store.entity.InventoryTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for InventoryTransaction.
 * TODO: Người phụ trách: Minh Phát, Minh Thức, Thành Tài, Mai Thanh.
 */
public interface InventoryTransactionRepository extends JpaRepository<InventoryTransaction, Long> {
}

