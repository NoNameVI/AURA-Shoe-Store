package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
// TODO: Người phụ trách: Thành Tài.
public class CheckoutController {

    @GetMapping("/checkout")
    public String checkoutPage() {
        return "storefront/checkout";
    }
}

