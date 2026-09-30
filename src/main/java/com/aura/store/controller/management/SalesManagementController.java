package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class SalesManagementController {

    @GetMapping("/management/orders")
    public String orderListPage() {
        return "management/sales/orders";
    }

    @GetMapping("/management/orders/{orderId}")
    public String orderDetailPage(@PathVariable Long orderId, Model model) {
        model.addAttribute("orderId", orderId);
        return "management/sales/order-detail";
    }

    @GetMapping("/management/payments")
    public String paymentListPage() {
        return "management/sales/payments";
    }
}

