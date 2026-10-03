package com.aura.store.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.Authentication;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;

/**
 * Kiem tra tai khoan demo voi MySQL that khi bat AURA_RUN_DEMO_LOGIN_IT.
 */
@SpringBootTest
@EnabledIfEnvironmentVariable(named = "AURA_RUN_DEMO_LOGIN_IT", matches = "true")
class DatabaseLoginIntegrationTest {
    @Autowired
    private AuthenticationConfiguration authenticationConfiguration;

    /** Xac thuc tai khoan demo va phan biet quyen kho, ban hang, khach hang. */
    @Test
    void demoAccountsReceiveExpectedCatalogPermissions() throws Exception {
        AuthenticationManager manager = authenticationConfiguration.getAuthenticationManager();
        Authentication warehouse = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.warehouse.creator", "your_local_password"));
        Authentication sales = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.sales", "your_local_password"));
        Authentication customer = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.customer", "your_local_password"));

        assertTrue(warehouse.isAuthenticated());
        assertTrue(warehouse.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.manage")));
        assertTrue(sales.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.read")));
        assertFalse(sales.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.manage")));
        assertFalse(customer.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.read")));
    }
}
