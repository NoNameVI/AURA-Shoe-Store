package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
// TODO: Người phụ trách: Minh Phát, Thành Tài.
public class CustomerOrderController {

    @GetMapping("/account/orders")
    public String orderListPage() {
        return "storefront/orders/list";
    }

    @GetMapping("/account/orders/{orderId}")
    public String orderDetailPage(@PathVariable Integer orderId, Model model) {
        model.addAttribute("orderId", orderId);
        return "storefront/orders/detail";
    }
}

