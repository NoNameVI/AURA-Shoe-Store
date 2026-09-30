package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ReportingManagementController {

    @GetMapping("/management/reports")
    public String reportDashboardPage() {
        return "management/reports/dashboard";
    }
}

