package com.aura.store.controller;

import com.aura.store.config.CatalogMethodSecurityConfig;
import com.aura.store.controller.management.ProcurementManagementController;
import com.aura.store.dto.response.PageResponse;
import com.aura.store.dto.response.SupplierResponse;
import com.aura.store.service.SupplierService;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProcurementManagementController.class)
@AutoConfigureMockMvc
@Import(CatalogMethodSecurityConfig.class)
@WithMockUser(authorities = {"ROLE_WAREHOUSE", "supplier.manage"})
class SupplierManagementViewTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SupplierService supplierService;

    /** Danh sách hiển thị cả nhà cung cấp đang hoạt động và đã ngừng hoạt động. */
    @Test
    void supplierListRendersAllStatuses() throws Exception {
        SupplierResponse active = supplier(1, "SUP-001", true);
        SupplierResponse inactive = supplier(2, "SUP-002", false);
        when(supplierService.search(any(), anyInt()))
                .thenReturn(pageOf(active, inactive));

        mockMvc.perform(get("/management/suppliers"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("SUP-001")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("SUP-002")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Ngừng hoạt động")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"_csrf\"")));
    }

    /** Trang chi tiết điền dữ liệu hiện tại vào form cập nhật. */
    @Test
    void supplierDetailRendersEditForm() throws Exception {
        SupplierResponse supplier = supplier(1, "SUP-001", true);
        when(supplierService.get(1)).thenReturn(supplier);
        when(supplierService.search(any(), anyInt())).thenReturn(pageOf(supplier));

        mockMvc.perform(get("/management/suppliers/1"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Chi tiết / sửa nhà cung cấp")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("value=\"SUP-001\"")));
    }

    /** Form tạo hợp lệ chuyển đến chi tiết của nhà cung cấp vừa tạo. */
    @Test
    void validSupplierFormRedirectsToDetail() throws Exception {
        when(supplierService.create(any())).thenReturn(supplier(7, "SUP-007", true));

        mockMvc.perform(post("/management/suppliers")
                        .with(csrf())
                        .param("supplierCode", "SUP-007")
                        .param("supplierName", "Nhà cung cấp 07")
                        .param("email", "supplier07@example.test")
                        .param("phone", "0901234567")
                        .param("taxCode", "0123456789")
                        .param("active", "true"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/management/suppliers/7"));
    }

    /** Số điện thoại không hợp lệ bị Bean Validation từ chối trước khi gọi service. */
    @Test
    void invalidPhoneReturnsSupplierForm() throws Exception {
        when(supplierService.search(any(), anyInt())).thenReturn(pageOf());

        mockMvc.perform(post("/management/suppliers")
                        .with(csrf())
                        .param("supplierCode", "SUP-007")
                        .param("supplierName", "Nhà cung cấp 07")
                        .param("phone", "12345")
                        .param("active", "true"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Số điện thoại không hợp lệ")));

        verify(supplierService, never()).create(any());
    }

    /** Nhân viên không có supplier.manage không được xem hoặc thay đổi nhà cung cấp. */
    @Test
    @WithMockUser(authorities = {"ROLE_SALES", "catalog.read"})
    void staffWithoutSupplierPermissionIsForbidden() throws Exception {
        mockMvc.perform(get("/management/suppliers")).andExpect(status().isForbidden());
        mockMvc.perform(post("/management/suppliers/1/status")
                        .with(csrf()).param("active", "false"))
                .andExpect(status().isForbidden());
    }

    private SupplierResponse supplier(Integer id, String code, boolean active) {
        SupplierResponse supplier = new SupplierResponse();
        supplier.setId(id);
        supplier.setSupplierCode(code);
        supplier.setSupplierName("Nhà cung cấp " + id);
        supplier.setActive(active);
        supplier.setCreatedAt(LocalDateTime.of(2026, 1, 1, 9, 0));
        supplier.setUpdatedAt(LocalDateTime.of(2026, 1, 2, 9, 0));
        return supplier;
    }

    private PageResponse<SupplierResponse> pageOf(SupplierResponse... suppliers) {
        List<SupplierResponse> content = List.of(suppliers);
        return new PageResponse<>(content, 0, 12, content.size(), content.isEmpty() ? 0 : 1);
    }
}
