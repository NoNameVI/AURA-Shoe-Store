package com.aura.store.repository;

import com.aura.store.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Voucher.
 */
public interface VoucherRepository extends JpaRepository<Voucher, Long> {
}

