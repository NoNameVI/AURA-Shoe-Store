package com.aura.store.service.impl;

import com.aura.store.entity.Account;
import com.aura.store.enums.AccountStatus;
import com.aura.store.enums.AccountType;
import com.aura.store.repository.AccountRepository;
import com.aura.store.repository.RolePermissionRepository;
import com.aura.store.repository.StaffRepository;
import com.aura.store.service.AuthenticationService;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Default implementation shell for AuthenticationService.
 * TODO: Người phụ trách: Khả Nhân.
 */
@Service
@RequiredArgsConstructor
public class AuthenticationServiceImpl implements AuthenticationService, UserDetailsService {
    private final AccountRepository accountRepository;
    private final StaffRepository staffRepository;
    private final RolePermissionRepository rolePermissionRepository;

    /** Nap tai khoan database cho Spring Security bang username hoac email. */
    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String identity) throws UsernameNotFoundException {
        String normalized = identity == null ? "" : identity.trim();
        if (normalized.isEmpty()) {
            throw new UsernameNotFoundException("Tai khoan khong hop le");
        }

        // Tu choi ten dang nhap trung giua username va email cua hai tai khoan.
        List<Account> matches = accountRepository.findByLoginIdentity(normalized);
        if (matches.size() != 1) {
            throw new UsernameNotFoundException("Khong tim thay tai khoan");
        }
        Account account = matches.getFirst();
        if (account.getDeletedAt() != null || account.isGoogleAuth()
                || account.getPasswordHash() == null || account.getPasswordHash().isBlank()
                || account.getAccountStatus() == null || account.getAccountType() == null) {
            throw new UsernameNotFoundException("Tai khoan khong the dang nhap bang mat khau");
        }

        boolean locked = account.getAccountStatus() == AccountStatus.LOCKED
                || account.getLockedUntil() != null
                && account.getLockedUntil().isAfter(LocalDateTime.now(ZoneOffset.UTC));
        return User.withUsername(account.getUsername())
                .password(account.getPasswordHash())
                .authorities(authoritiesFor(account))
                .disabled(account.getAccountStatus() == AccountStatus.INACTIVE)
                .accountLocked(locked)
                .build();
    }

    /** Lay role va permission dang hoat dong cho nhan vien; khach hang chi co role CUSTOMER. */
    private List<GrantedAuthority> authoritiesFor(Account account) {
        List<GrantedAuthority> authorities = new ArrayList<>();
        if (account.getAccountType() == AccountType.CUSTOMER) {
            authorities.add(new SimpleGrantedAuthority("ROLE_CUSTOMER"));
            return authorities;
        }

        String roleCode = staffRepository.findActiveRoleCode(account.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Nhan vien khong co role dang hoat dong"));
        authorities.add(new SimpleGrantedAuthority("ROLE_" + roleCode));
        rolePermissionRepository.findActivePermissionKeys(roleCode).stream()
                .map(SimpleGrantedAuthority::new)
                .forEach(authorities::add);
        return authorities;
    }
}

