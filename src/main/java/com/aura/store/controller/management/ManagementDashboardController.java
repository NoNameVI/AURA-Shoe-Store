package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ManagementDashboardController {

    @GetMapping("/management")
    public String dashboardPage() {
        return "management/dashboard";
    }
}

