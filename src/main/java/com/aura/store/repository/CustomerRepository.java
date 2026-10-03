package com.aura.store.repository;

import com.aura.store.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Customer.
 * TODO: Người phụ trách: Minh Phát, Minh Thức.
 */
public interface CustomerRepository extends JpaRepository<Customer, Long> {
}

