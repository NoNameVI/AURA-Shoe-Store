package com.aura.store.controller.auth;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Authentication and account-recovery pages.
 * TODO: Người phụ trách: Khả Nhân.
 */
@Controller
public class AuthController {

    /** Hien form dang nhap; Spring Security xu ly POST /login. */
    @GetMapping("/login")
    public String loginPage() {
        return "auth/login";
    }

    /** Hien trang dang ky, phan xu ly se duoc bo sung rieng. */
    @GetMapping("/register")
    public String registrationPage() {
        return "auth/register";
    }

    /** Hien trang khoi phuc mat khau, phan xu ly se duoc bo sung rieng. */
    @GetMapping("/forgot-password")
    public String forgotPasswordPage() {
        return "auth/forgot-password";
    }
}

