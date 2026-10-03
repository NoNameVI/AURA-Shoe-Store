package com.aura.store.controller.storefront;

import com.aura.store.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class HomeController {
    private final ProductService productService;

    /** Hien mot vai san pham da cong bo tren trang chu cua cua hang. */
    @GetMapping("/")
    public String homePage(Model model) {
        model.addAttribute("featuredProducts", productService.searchPublished("", null, null, 0)
                .getContent().stream().limit(4).toList());
        return "storefront/home";
    }
}

