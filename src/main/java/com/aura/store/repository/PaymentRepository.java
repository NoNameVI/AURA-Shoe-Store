package com.aura.store.repository;

import com.aura.store.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Payment.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface PaymentRepository extends JpaRepository<Payment, Integer> {
}

