package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
// TODO: Người phụ trách: Khả Nhân, Minh Phát.
public class UserManagementController {

    @GetMapping("/management/customers")
    public String customerListPage() {
        return "management/users/customers";
    }

    @GetMapping("/management/staff")
    public String staffListPage() {
        return "management/users/staff";
    }

    @GetMapping("/management/roles")
    public String rolePermissionPage() {
        return "management/users/roles";
    }
}

