package com.aura.store.controller.storefront;

import com.aura.store.service.BrandService;
import com.aura.store.service.CategoryService;
import com.aura.store.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
// TODO: Người phụ trách: Minh Thức.
public class ProductController {
    private final ProductService productService;
    private final BrandService brandService;
    private final CategoryService categoryService;

    /** Hien san pham da cong bo voi tim kiem, bo loc va phan trang. */
    @GetMapping("/products")
    public String productListPage(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) Integer brandId,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("products", productService.searchPublished(keyword, brandId, categoryId, page));
        model.addAttribute("brands", brandService.activeBrands());
        model.addAttribute("categories", categoryService.activeCategories());
        model.addAttribute("keyword", keyword);
        model.addAttribute("brandId", brandId);
        model.addAttribute("categoryId", categoryId);
        return "storefront/products/list";
    }

    /** Chi cho phep xem chi tiet san pham dang cong bo. */
    @GetMapping("/products/{productId}")
    public String productDetailPage(@PathVariable Integer productId, Model model) {
        model.addAttribute("product", productService.getPublished(productId));
        return "storefront/products/detail";
    }
}

