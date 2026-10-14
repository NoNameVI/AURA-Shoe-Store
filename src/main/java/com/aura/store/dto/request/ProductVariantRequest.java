package com.aura.store.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Positive;
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
    @NotNull(message = "Vui long chon mau")
    @Positive(message = "Mau khong hop le")
    private Integer colorId;

    @NotBlank(message = "Kich co khong duoc de trong")
    @Size(max = 10)
    private String sizeCode;

    @NotNull(message = "Gia ban khong duoc de trong")
    @DecimalMin(value = "0.00")
    @Digits(integer = 10, fraction = 2, message = "Gia ban toi da 10 chu so nguyen va 2 chu so thap phan")
    private BigDecimal salePrice;

    @NotNull(message = "Vui long nhap nguong sap het")
    @PositiveOrZero(message = "Nguong sap het khong duoc am")
    private Long lowStockThreshold;

    private boolean active = true;
}

