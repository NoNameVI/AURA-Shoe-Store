package com.aura.store.controller.management;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
// TODO: Người phụ trách: Thành Tài, Mai Thanh.
public class InventoryManagementController {

    @GetMapping("/management/inventory")
    public String inventoryStatusPage() {
        return "management/inventory/status";
    }

    @GetMapping("/management/inventory/documents")
    public String inventoryDocumentListPage() {
        return "management/inventory/documents";
    }
}

