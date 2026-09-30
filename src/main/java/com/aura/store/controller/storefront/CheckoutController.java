package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CheckoutController {

    @GetMapping("/checkout")
    public String checkoutPage() {
        return "storefront/checkout";
    }
}

