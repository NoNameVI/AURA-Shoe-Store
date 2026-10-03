package com.aura.store.repository;

import com.aura.store.entity.Account;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Account.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface AccountRepository extends JpaRepository<Account, Integer> {
    /** Tim tai khoan theo username hoac email, khong phan biet chu hoa. */
    @Query("select a from Account a where lower(a.username) = lower(:identity) "
            + "or lower(a.email) = lower(:identity)")
    List<Account> findByLoginIdentity(@Param("identity") String identity);
}

