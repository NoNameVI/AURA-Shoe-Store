package com.aura.store.controller.storefront;

import com.aura.store.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** Hien danh muc cong khai de khach tim va xem nhom san pham. */
@Controller
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService categoryService;

    /** Tim va phan trang danh muc dang hoat dong cho moi nguoi truy cap. */
    @GetMapping("/categories")
    public String list(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("categories", categoryService.searchPublic(keyword, page));
        model.addAttribute("keyword", keyword);
        return "storefront/categories/list";
    }
}
