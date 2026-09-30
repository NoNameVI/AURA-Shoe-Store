package com.aura.store.repository;

import com.aura.store.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Category.
 */
public interface CategoryRepository extends JpaRepository<Category, Integer> {
}

