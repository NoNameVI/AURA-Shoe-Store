package com.aura.store.repository;

import com.aura.store.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Supplier.
 */
public interface SupplierRepository extends JpaRepository<Supplier, Long> {
}

