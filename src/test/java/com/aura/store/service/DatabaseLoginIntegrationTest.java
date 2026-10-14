package com.aura.store.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductImageResponse;

import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * Kiem tra tai khoan demo voi MySQL that khi bat AURA_RUN_DEMO_LOGIN_IT.
 */
@SpringBootTest
@EnabledIfEnvironmentVariable(named = "AURA_RUN_DEMO_LOGIN_IT", matches = "true")
class DatabaseLoginIntegrationTest {
    @Autowired
    private AuthenticationConfiguration authenticationConfiguration;

    @Autowired
    private ProductService productService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /** Xac thuc tai khoan demo va phan biet quyen kho, ban hang, khach hang. */
    @Test
    void demoAccountsReceiveExpectedCatalogPermissions() throws Exception {
        AuthenticationManager manager = authenticationConfiguration.getAuthenticationManager();
        Authentication warehouse = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.warehouse.creator", "your_local_password"));
        Authentication sales = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.sales", "your_local_password"));
        Authentication admin = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.admin", "your_local_password"));
        Authentication customer = manager.authenticate(
                new UsernamePasswordAuthenticationToken("demo.customer", "your_local_password"));

        assertTrue(warehouse.isAuthenticated());
        assertFalse(warehouse.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.manage")));
        assertTrue(sales.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.read")));
        assertTrue(sales.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.manage")));
        assertTrue(admin.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.read")));
        assertTrue(admin.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.manage")));
        assertFalse(customer.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("catalog.read")));
    }

    /** Tim kiem cong khai khong de lo danh muc da ngung hoat dong. */
    @Test
    @Transactional
    void publicCategorySearchHidesInactiveRows() {
        assertEquals(1, categoryService.searchPublic("demo-running", 0).getTotalElements());
        jdbcTemplate.update("UPDATE category SET is_active = FALSE WHERE slug = 'demo-running'");
        assertEquals(0, categoryService.searchPublic("demo-running", 0).getTotalElements());
        assertEquals(1, categoryService.search("demo-running", 0).getTotalElements());
    }

    /** Doc danh muc mau va anh theo bien the tu MySQL sau khi Flyway hoan tat. */
    @Test
    void demoCatalogLoadsVariantColorsAndImages() {
        ProductResponse product = productService.getManagement(1);

        assertEquals(3, product.getVariants().size());
        assertEquals(6, product.getImages().size());
        assertEquals("GRY", product.getVariants().getFirst().getColorCode());
        assertNotNull(product.getVariants().getFirst().getColorId());
        assertEquals(product.getVariants().getFirst().getId(), product.getImages().getFirst().getVariantId());
        assertNotNull(product.getPrimaryImageUrl());
    }

    /** Kiem tra anh demo khac nhau theo mau giay va file tinh ton tai. */
    @Test
    void demoShoesUseDistinctExistingImages() {
        Set<String> primaryImages = new HashSet<>();
        Set<String> allImageUrls = new HashSet<>();
        int imageRows = 0;

        for (int productId = 1; productId <= 8; productId++) {
            ProductResponse product = productService.getManagement(productId);
            assertTrue(primaryImages.add(product.getPrimaryImageUrl()));
            imageRows += product.getImages().size();
            for (ProductImageResponse image : product.getImages()) {
                allImageUrls.add(image.getImageUrl());
                assertTrue(new ClassPathResource("static" + image.getImageUrl()).exists());
            }
        }

        assertEquals(8, primaryImages.size());
        assertEquals(10, allImageUrls.size());
        assertEquals(30, imageRows);
    }
}
