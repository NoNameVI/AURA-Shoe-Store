package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CatalogManagementController {

    @GetMapping("/management/products")
    public String productListPage() {
        return "management/catalog/products";
    }

    @GetMapping("/management/categories")
    public String categoryListPage() {
        return "management/catalog/categories";
    }

    @GetMapping("/management/brands")
    public String brandListPage() {
        return "management/catalog/brands";
    }
}

