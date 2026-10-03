package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
// TODO: Người phụ trách: Thành Tài.
public class CartController {

    @GetMapping("/cart")
    public String cartPage() {
        return "storefront/cart";
    }
}

