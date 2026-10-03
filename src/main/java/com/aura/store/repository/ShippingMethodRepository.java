package com.aura.store.repository;

import com.aura.store.entity.ShippingMethod;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for ShippingMethod.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface ShippingMethodRepository extends JpaRepository<ShippingMethod, Integer> {
}

