package com.aura.store.repository;

import com.aura.store.entity.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for ProductVariant.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface ProductVariantRepository extends JpaRepository<ProductVariant, Integer> {
}

