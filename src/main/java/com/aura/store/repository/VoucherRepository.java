package com.aura.store.repository;

import com.aura.store.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Voucher.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface VoucherRepository extends JpaRepository<Voucher, Integer> {
}

