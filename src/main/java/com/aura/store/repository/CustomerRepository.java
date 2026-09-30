package com.aura.store.repository;

import com.aura.store.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Customer.
 */
public interface CustomerRepository extends JpaRepository<Customer, Long> {
}

