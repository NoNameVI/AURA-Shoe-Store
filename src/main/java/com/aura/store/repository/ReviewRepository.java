package com.aura.store.repository;

import com.aura.store.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Review.
 */
public interface ReviewRepository extends JpaRepository<Review, Long> {
}

