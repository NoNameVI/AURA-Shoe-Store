package com.aura.store.repository;

import com.aura.store.entity.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for ProductVariant.
 */
public interface ProductVariantRepository extends JpaRepository<ProductVariant, Long> {
}

