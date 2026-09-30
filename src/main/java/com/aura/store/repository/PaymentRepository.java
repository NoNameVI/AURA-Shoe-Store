package com.aura.store.repository;

import com.aura.store.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Payment.
 */
public interface PaymentRepository extends JpaRepository<Payment, Long> {
}

