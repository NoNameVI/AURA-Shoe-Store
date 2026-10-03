package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
// TODO: Người phụ trách: Mai Thanh.
public class ProcurementManagementController {

    @GetMapping("/management/suppliers")
    public String supplierListPage() {
        return "management/procurement/suppliers";
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
}

