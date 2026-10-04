package com.aura.store.dto.response;

import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for Supplier data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class SupplierResponse {
    private Integer id;
    private String supplierCode;
    private String supplierName;
    private String contactName;
    private String phone;
    private String email;
    private String taxCode;
    private String addressText;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

