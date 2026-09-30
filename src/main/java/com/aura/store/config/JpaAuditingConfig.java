package com.aura.store.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Enables automatic population of entity creation and modification timestamps.
 */
@Configuration
@EnableJpaAuditing
public class JpaAuditingConfig {
}

