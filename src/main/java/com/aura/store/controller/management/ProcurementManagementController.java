package com.aura.store.controller.management;

import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.dto.response.SupplierResponse;
import com.aura.store.exception.BusinessException;
import com.aura.store.service.SupplierService;
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

@Controller
@RequiredArgsConstructor
// TODO: Người phụ trách: Mai Thanh.
public class ProcurementManagementController {

    private final SupplierService supplierService;

    /** Hiển thị toàn bộ nhà cung cấp, bao gồm bản ghi đã ngừng hoạt động. */
    @PreAuthorize("hasAuthority('supplier.manage')")
    @GetMapping("/management/suppliers")
    public String supplierListPage(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page, Model model) {
        return renderSuppliers(keyword, page, model);
    }

    /** Hiển thị chi tiết nhà cung cấp trong form cập nhật. */
    @PreAuthorize("hasAuthority('supplier.manage')")
    @GetMapping({"/management/suppliers/{id}", "/management/suppliers/{id}/edit"})
    public String supplierDetailPage(@PathVariable Integer id, Model model) {
        SupplierResponse supplier = supplierService.get(id);
        model.addAttribute("supplierForm", supplierRequestOf(supplier));
        model.addAttribute("supplierDetail", supplier);
        model.addAttribute("editId", id);
        return renderSuppliers("", 0, model);
    }

    /** Tạo nhà cung cấp mới từ form quản lý. */
    @PreAuthorize("hasAuthority('supplier.manage')")
    @PostMapping("/management/suppliers")
    public String createSupplier(@Valid @ModelAttribute("supplierForm") SupplierRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return renderSuppliers("", 0, model);
        }
        try {
            SupplierResponse supplier = supplierService.create(form);
            redirect.addFlashAttribute("success", "Đã tạo nhà cung cấp.");
            return "redirect:/management/suppliers/" + supplier.getId();
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderSuppliers("", 0, model);
        }
    }

    /** Cập nhật thông tin nhà cung cấp hiện có. */
    @PreAuthorize("hasAuthority('supplier.manage')")
    @PostMapping("/management/suppliers/{id}")
    public String updateSupplier(@PathVariable Integer id,
            @Valid @ModelAttribute("supplierForm") SupplierRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        model.addAttribute("editId", id);
        if (result.hasErrors()) {
            return renderSuppliers("", 0, model);
        }
        try {
            supplierService.update(id, form);
            redirect.addFlashAttribute("success", "Đã cập nhật nhà cung cấp.");
            return "redirect:/management/suppliers/" + id;
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderSuppliers("", 0, model);
        }
    }

    /** Kích hoạt hoặc ngừng hoạt động nhà cung cấp mà không xóa dữ liệu. */
    @PreAuthorize("hasAuthority('supplier.manage')")
    @PostMapping("/management/suppliers/{id}/status")
    public String changeSupplierStatus(@PathVariable Integer id,
            @RequestParam boolean active, RedirectAttributes redirect) {
        supplierService.setActive(id, active);
        redirect.addFlashAttribute("success",
                active ? "Đã kích hoạt nhà cung cấp." : "Đã ngừng hoạt động nhà cung cấp.");
        return "redirect:/management/suppliers/" + id;
    }

    @GetMapping("/management/purchase-orders")
    public String purchaseOrderListPage() {
        return "management/procurement/purchase-orders";
    }

    @GetMapping("/management/purchase-orders/{purchaseOrderId}")
    public String purchaseOrderDetailPage(
            @PathVariable Integer purchaseOrderId,
            Model model
    ) {
        model.addAttribute("purchaseOrderId", purchaseOrderId);
        return "management/procurement/purchase-order-detail";
    }

    /** Nạp dữ liệu dùng chung cho danh sách và form nhà cung cấp. */
    private String renderSuppliers(String keyword, int page, Model model) {
        model.addAttribute("suppliers", supplierService.search(keyword, page));
        model.addAttribute("keyword", keyword);
        if (!model.containsAttribute("supplierForm")) {
            model.addAttribute("supplierForm", new SupplierRequest());
        }
        return "management/procurement/suppliers";
    }

    private SupplierRequest supplierRequestOf(SupplierResponse response) {
        SupplierRequest form = new SupplierRequest();
        form.setSupplierCode(response.getSupplierCode());
        form.setSupplierName(response.getSupplierName());
        form.setContactName(response.getContactName());
        form.setPhone(response.getPhone());
        form.setEmail(response.getEmail());
        form.setTaxCode(response.getTaxCode());
        form.setAddressText(response.getAddressText());
        form.setActive(response.isActive());
        return form;
    }
}

