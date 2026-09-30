package com.aura.store.repository;

import com.aura.store.entity.Brand;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Brand.
 */
public interface BrandRepository extends JpaRepository<Brand, Integer> {
}

