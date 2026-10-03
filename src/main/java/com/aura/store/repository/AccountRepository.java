package com.aura.store.repository;

import com.aura.store.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for Account.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface AccountRepository extends JpaRepository<Account, Integer> {
}

