package com.aura.store.controller;

import com.aura.store.controller.auth.AuthController;
import com.aura.store.entity.Account;
import com.aura.store.enums.AccountStatus;
import com.aura.store.enums.AccountType;
import com.aura.store.repository.AccountRepository;
import com.aura.store.repository.RolePermissionRepository;
import com.aura.store.repository.StaffRepository;
import com.aura.store.security.SecurityConfig;
import com.aura.store.service.impl.AuthenticationServiceImpl;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc
@Import({SecurityConfig.class, AuthenticationServiceImpl.class})
class LoginFlowTest {
    private static final String DEMO_HASH = "$2a$12$Toiw/khmFBc5fLtx8Z51L.7hs47m3keA7b3lOk7JmtM6s7fzUz.ly";

    @Autowired
    private MockMvc mockMvc;
    @MockitoBean
    private AccountRepository accountRepository;
    @MockitoBean
    private StaffRepository staffRepository;
    @MockitoBean
    private RolePermissionRepository rolePermissionRepository;

    /** Kiem tra CSRF, dang nhap bang tai khoan demo, quyen catalog va dang xuat. */
    @Test
    void warehouseLoginUsesDatabasePasswordAndPermissions() throws Exception {
        when(accountRepository.findByLoginIdentity("demo.warehouse.creator"))
                .thenReturn(List.of(account(AccountType.STAFF)));
        when(staffRepository.findActiveRoleCode(1)).thenReturn(Optional.of("WAREHOUSE"));
        when(rolePermissionRepository.findActivePermissionKeys("WAREHOUSE"))
                .thenReturn(List.of("catalog.read", "catalog.manage"));

        mockMvc.perform(get("/login")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"_csrf\"")));
        MvcResult result = mockMvc.perform(post("/login").with(csrf())
                        .param("username", "demo.warehouse.creator")
                        .param("password", "your_local_password"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"))
                .andReturn();

        MockHttpSession session = (MockHttpSession) result.getRequest().getSession(false);
        assertNotNull(session);
        SecurityContext context = (SecurityContext) session.getAttribute(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
        assertNotNull(context);
        assertTrue(context.getAuthentication().getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("catalog.manage")));

        mockMvc.perform(post("/logout").session(session).with(csrf()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"));
    }

    /** Kiem tra mat khau sai khong tao phien dang nhap. */
    @Test
    void wrongPasswordReturnsToLogin() throws Exception {
        when(accountRepository.findByLoginIdentity("demo.warehouse.creator"))
                .thenReturn(List.of(account(AccountType.STAFF)));
        when(staffRepository.findActiveRoleCode(1)).thenReturn(Optional.of("WAREHOUSE"));
        when(rolePermissionRepository.findActivePermissionKeys("WAREHOUSE"))
                .thenReturn(List.of("catalog.read"));

        mockMvc.perform(post("/login").with(csrf())
                        .param("username", "demo.warehouse.creator")
                        .param("password", "sai-mat-khau"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/login?error"));
    }

    /** Kiem tra khach hang dang nhap duoc nhung khong vao trang quan tri. */
    @Test
    void customerCannotOpenManagement() throws Exception {
        when(accountRepository.findByLoginIdentity("customer@example.test"))
                .thenReturn(List.of(account(AccountType.CUSTOMER)));
        MvcResult result = mockMvc.perform(post("/login").with(csrf())
                        .param("username", "customer@example.test")
                        .param("password", "your_local_password"))
                .andExpect(status().is3xxRedirection())
                .andReturn();

        mockMvc.perform(get("/management").session((MockHttpSession) result.getRequest().getSession()))
                .andExpect(status().isForbidden());
    }

    /** Tao tai khoan mo phong ban ghi seed cua Flyway. */
    private Account account(AccountType type) {
        Account account = new Account();
        account.setId(1);
        account.setUsername(type == AccountType.STAFF ? "demo.warehouse.creator" : "demo.customer");
        account.setEmail(type == AccountType.STAFF
                ? "warehouse.creator@example.test" : "customer@example.test");
        account.setPasswordHash(DEMO_HASH);
        account.setAccountType(type);
        account.setAccountStatus(AccountStatus.ACTIVE);
        return account;
    }
}
