package com.aura.store.service;

import com.aura.store.entity.Account;
import com.aura.store.enums.AccountStatus;
import com.aura.store.enums.AccountType;
import com.aura.store.repository.AccountRepository;
import com.aura.store.repository.RolePermissionRepository;
import com.aura.store.repository.StaffRepository;
import com.aura.store.service.impl.AuthenticationServiceImpl;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthenticationServiceTest {
    @Mock
    private AccountRepository accountRepository;
    @Mock
    private StaffRepository staffRepository;
    @Mock
    private RolePermissionRepository rolePermissionRepository;
    @InjectMocks
    private AuthenticationServiceImpl authenticationService;

    /** Kiem tra nhan vien nhan role va permission dang hoat dong. */
    @Test
    void warehouseGetsCatalogPermissions() {
        Account account = account(AccountType.STAFF);
        when(accountRepository.findByLoginIdentity("demo.warehouse.creator"))
                .thenReturn(List.of(account));
        when(staffRepository.findActiveRoleCode(1)).thenReturn(Optional.of("WAREHOUSE"));
        when(rolePermissionRepository.findActivePermissionKeys("WAREHOUSE"))
                .thenReturn(List.of("catalog.read", "catalog.manage"));

        UserDetails user = authenticationService.loadUserByUsername(" demo.warehouse.creator ");

        assertTrue(user.isEnabled());
        assertTrue(user.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_WAREHOUSE")));
        assertTrue(user.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("catalog.manage")));
        verify(accountRepository).findByLoginIdentity("demo.warehouse.creator");
    }

    /** Kiem tra khach hang khong duoc cap permission quan tri. */
    @Test
    void customerHasNoCatalogPermission() {
        when(accountRepository.findByLoginIdentity("demo.customer"))
                .thenReturn(List.of(account(AccountType.CUSTOMER)));

        UserDetails user = authenticationService.loadUserByUsername("demo.customer");

        assertTrue(user.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_CUSTOMER")));
        assertFalse(user.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("catalog.read")));
    }

    /** Kiem tra tai khoan da tat va dang khoa khong duoc xac thuc. */
    @Test
    void disabledAndLockedAccountsAreRejectedByUserDetails() {
        Account inactive = account(AccountType.CUSTOMER);
        inactive.setAccountStatus(AccountStatus.INACTIVE);
        when(accountRepository.findByLoginIdentity("inactive")).thenReturn(List.of(inactive));
        assertFalse(authenticationService.loadUserByUsername("inactive").isEnabled());

        Account locked = account(AccountType.CUSTOMER);
        locked.setLockedUntil(LocalDateTime.now(ZoneOffset.UTC).plusMinutes(10));
        when(accountRepository.findByLoginIdentity("locked")).thenReturn(List.of(locked));
        assertFalse(authenticationService.loadUserByUsername("locked").isAccountNonLocked());
    }

    /** Kiem tra tai khoan xoa mem va tai khoan Google khong dung form mat khau. */
    @Test
    void deletedAndGoogleOnlyAccountsCannotUsePasswordLogin() {
        Account deleted = account(AccountType.CUSTOMER);
        deleted.setDeletedAt(LocalDateTime.now(ZoneOffset.UTC));
        when(accountRepository.findByLoginIdentity("deleted")).thenReturn(List.of(deleted));
        assertThrows(UsernameNotFoundException.class,
                () -> authenticationService.loadUserByUsername("deleted"));

        Account google = account(AccountType.CUSTOMER);
        google.setGoogleAuth(true);
        when(accountRepository.findByLoginIdentity("google")).thenReturn(List.of(google));
        assertThrows(UsernameNotFoundException.class,
                () -> authenticationService.loadUserByUsername("google"));
    }

    /** Tao tai khoan toi thieu de kiem tra quy tac dang nhap. */
    private Account account(AccountType type) {
        Account account = new Account();
        account.setId(1);
        account.setUsername("demo.warehouse.creator");
        account.setEmail("warehouse.creator@example.test");
        account.setPasswordHash("$2a$12$demo-hash");
        account.setAccountStatus(AccountStatus.ACTIVE);
        account.setAccountType(type);
        return account;
    }
}
