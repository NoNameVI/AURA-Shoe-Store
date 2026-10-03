package com.aura.store.repository;

import com.aura.store.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Product.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface ProductRepository extends JpaRepository<Product, Long> {
}

