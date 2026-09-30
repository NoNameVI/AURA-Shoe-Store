package com.aura.store.controller.storefront;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class ProductController {

    @GetMapping("/products")
    public String productListPage() {
        return "storefront/products/list";
    }

    @GetMapping("/products/{productId}")
    public String productDetailPage(@PathVariable Long productId, Model model) {
        model.addAttribute("productId", productId);
        return "storefront/products/detail";
    }
}

