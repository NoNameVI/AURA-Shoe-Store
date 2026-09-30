package com.aura.store.repository;

import com.aura.store.entity.GoogleOAuthToken;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Persistence gateway for GoogleOAuthToken.
 */
public interface GoogleOAuthTokenRepository extends JpaRepository<GoogleOAuthToken, Long> {
}

