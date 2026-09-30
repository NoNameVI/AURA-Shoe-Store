package com.aura.store.repository;

import com.aura.store.entity.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for ProductImage.
 */
public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {
}

