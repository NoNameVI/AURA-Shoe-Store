package com.aura.store.repository;

import com.aura.store.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Address.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface AddressRepository extends JpaRepository<Address, Integer> {
}

