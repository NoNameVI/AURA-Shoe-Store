package com.aura.store.repository;

import com.aura.store.entity.InventoryDocument;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for InventoryDocument.
 */
public interface InventoryDocumentRepository extends JpaRepository<InventoryDocument, Long> {
}

