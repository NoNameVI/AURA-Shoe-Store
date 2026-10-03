package com.aura.store.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Central HTTP security configuration. Permission-specific rules are added with
 * each management feature.
 * TODO: Người phụ trách: Khả Nhân.
 */
@Configuration
public class SecurityConfig {

    /** Bao ve trang noi bo va su dung form dang nhap voi tai khoan database. */
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(
                                "/", "/products/**", "/login", "/register",
                                "/forgot-password", "/css/**", "/js/**",
                                "/images/**", "/actuator/health", "/error/**")
                        .permitAll()
                        .requestMatchers("/management/**")
                        .hasAnyRole("SALES", "WAREHOUSE", "SYSTEM_ADMIN")
                        .requestMatchers("/account/**", "/cart/**", "/wishlist/**", "/checkout/**")
                        .authenticated()
                        .anyRequest()
                        .permitAll())
                .formLogin(form -> form
                        .loginPage("/login")
                        .defaultSuccessUrl("/", false)
                        .permitAll())
                .logout(logout -> logout
                        .logoutSuccessUrl("/")
                        .permitAll());

        return http.build();
    }

    /** So sanh mat khau da bam BCrypt trong bang accounts. */
    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
