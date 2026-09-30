package com.aura.store.repository;

import com.aura.store.entity.ShippingMethod;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for ShippingMethod.
 */
public interface ShippingMethodRepository extends JpaRepository<ShippingMethod, Integer> {
}

