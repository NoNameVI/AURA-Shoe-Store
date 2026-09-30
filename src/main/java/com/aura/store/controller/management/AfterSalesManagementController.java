package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class AfterSalesManagementController {

    @GetMapping("/management/after-sales")
    public String requestListPage() {
        return "management/after-sales/list";
    }

    @GetMapping("/management/after-sales/{requestId}")
    public String requestDetailPage(@PathVariable Long requestId, Model model) {
        model.addAttribute("requestId", requestId);
        return "management/after-sales/detail";
    }
}

