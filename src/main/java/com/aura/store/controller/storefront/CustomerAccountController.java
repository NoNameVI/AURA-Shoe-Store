package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CustomerAccountController {

    @GetMapping("/account/profile")
    public String profilePage() {
        return "storefront/account/profile";
    }

    @GetMapping("/account/addresses")
    public String addressListPage() {
        return "storefront/account/addresses";
    }
}

