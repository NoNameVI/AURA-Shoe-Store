package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PromotionManagementController {

    @GetMapping("/management/vouchers")
    public String voucherListPage() {
        return "management/settings/vouchers";
    }

    @GetMapping("/management/shipping-methods")
    public String shippingMethodListPage() {
        return "management/settings/shipping-methods";
    }
}

