package com.aura.store.repository;

import com.aura.store.entity.InventoryDocument;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for InventoryDocument.
 * TODO: Người phụ trách: Minh Thức, Thành Tài, Mai Thanh.
 */
public interface InventoryDocumentRepository extends JpaRepository<InventoryDocument, Integer> {
}

