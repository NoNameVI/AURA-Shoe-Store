package com.aura.store.dto.response;

import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for ProductVariant data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductVariantResponse {
    private Integer id;
    private String sku;
    private String colorName;
    private String sizeCode;
    private BigDecimal salePrice;
    private BigDecimal costPrice;
    private long stockQuantity;
    private long reservedQuantity;
    private long availableQuantity;
    private long lowStockThreshold;
    private boolean active;
}

