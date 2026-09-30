package com.aura.store.repository;

import com.aura.store.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Product.
 */
public interface ProductRepository extends JpaRepository<Product, Long> {
}

