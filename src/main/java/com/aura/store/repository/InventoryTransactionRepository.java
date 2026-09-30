package com.aura.store.repository;

import com.aura.store.entity.InventoryTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for InventoryTransaction.
 */
public interface InventoryTransactionRepository extends JpaRepository<InventoryTransaction, Long> {
}

