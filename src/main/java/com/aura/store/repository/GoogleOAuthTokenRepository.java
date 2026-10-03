package com.aura.store.repository;

import com.aura.store.entity.GoogleOAuthToken;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for GoogleOAuthToken.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
public interface GoogleOAuthTokenRepository extends JpaRepository<GoogleOAuthToken, Long> {


}

