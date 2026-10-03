package com.aura.store.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

/**
 * Bat kiem tra permission tai controller catalog. Authority duoc cap boi
 * luong xac thuc va bang role_permissions cua he thong.
 */
@Configuration
@EnableMethodSecurity
public class CatalogMethodSecurityConfig {
}
