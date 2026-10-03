package com.aura.store.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

/**
 * Input contract for the ProductVariant use case.
 * Fields and validation constraints are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductVariantRequest {
    @NotBlank(message = "Mau sac khong duoc de trong")
    @Size(max = 100)
    private String colorName;

    @NotBlank(message = "Kich co khong duoc de trong")
    @Size(max = 10)
    private String sizeCode;

    @NotNull(message = "Gia ban khong duoc de trong")
    @DecimalMin(value = "0.00")
    @Digits(integer = 16, fraction = 2)
    private BigDecimal salePrice;

    @NotNull(message = "Gia von khong duoc de trong")
    @DecimalMin(value = "0.00")
    @Digits(integer = 16, fraction = 2)
    private BigDecimal costPrice;

    @PositiveOrZero
    private long lowStockThreshold = 5;

    private boolean active = true;
}

