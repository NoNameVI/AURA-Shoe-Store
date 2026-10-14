package com.aura.store.controller.management;

import com.aura.store.dto.request.ColorRequest;
import com.aura.store.dto.response.ColorResponse;
import com.aura.store.exception.BusinessException;
import com.aura.store.service.ColorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** Dieu khien trang quan ly danh muc mau. */
@Controller
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('catalog.read') and hasAnyRole('SALES', 'SYSTEM_ADMIN')")
public class ColorManagementController {
    private final ColorService colorService;

    /** Hien danh sach mau va form tao mau moi. */
    @GetMapping("/management/colors")
    public String list(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page, Model model) {
        return render(keyword, page, model);
    }

    /** Hien du lieu mau can sua trong cung trang. */
    @PreAuthorize("hasAuthority('catalog.manage') and hasAnyRole('SALES', 'SYSTEM_ADMIN')")
    @GetMapping("/management/colors/{id}/edit")
    public String edit(@PathVariable Integer id, Model model) {
        ColorResponse color = colorService.get(id);
        ColorRequest form = new ColorRequest();
        form.setColorCode(color.getColorCode());
        form.setColorName(color.getColorName());
        form.setHexCode(color.getHexCode());
        form.setActive(color.isActive());
        model.addAttribute("colorForm", form);
        model.addAttribute("editId", id);
        return render("", 0, model);
    }

    /** Kiem tra form va tao mau. */
    @PreAuthorize("hasAuthority('catalog.manage') and hasAnyRole('SALES', 'SYSTEM_ADMIN')")
    @PostMapping("/management/colors")
    public String create(@Valid @ModelAttribute("colorForm") ColorRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return render("", 0, model);
        }
        try {
            colorService.create(form);
            redirect.addFlashAttribute("success", "Đã thêm màu.");
            return "redirect:/management/colors";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return render("", 0, model);
        }
    }

    /** Kiem tra form va cap nhat mau. */
    @PreAuthorize("hasAuthority('catalog.manage') and hasAnyRole('SALES', 'SYSTEM_ADMIN')")
    @PostMapping("/management/colors/{id}")
    public String update(@PathVariable Integer id, @Valid @ModelAttribute("colorForm") ColorRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        model.addAttribute("editId", id);
        if (result.hasErrors()) {
            return render("", 0, model);
        }
        try {
            colorService.update(id, form);
            redirect.addFlashAttribute("success", "Đã cập nhật màu.");
            return "redirect:/management/colors";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return render("", 0, model);
        }
    }

    /** Xoa mau chua duoc su dung va chuyen ve danh sach. */
    @PreAuthorize("hasAuthority('catalog.manage') and hasAnyRole('SALES', 'SYSTEM_ADMIN')")
    @PostMapping("/management/colors/{id}/delete")
    public String delete(@PathVariable Integer id, RedirectAttributes redirect) {
        try {
            colorService.delete(id);
            redirect.addFlashAttribute("success", "Đã xóa màu.");
        } catch (BusinessException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/management/colors";
    }

    /** Nap danh sach va giu lai form khi validation bao loi. */
    private String render(String keyword, int page, Model model) {
        model.addAttribute("colors", colorService.search(keyword, page));
        model.addAttribute("keyword", keyword);
        if (!model.containsAttribute("colorForm")) {
            model.addAttribute("colorForm", new ColorRequest());
        }
        return "management/catalog/colors";
    }
}
