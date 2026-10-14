package com.aura.store.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import com.aura.store.validation.annotation.ValidImageUrl;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Input contract for the ProductImage use case.
 * Fields and validation constraints are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductImageRequest {
    @NotNull(message = "Vui long chon bien the cho anh")
    @Positive(message = "Bien the khong hop le")
    private Integer variantId;

    @NotBlank(message = "URL anh khong duoc de trong")
    @Size(max = 500)
    @ValidImageUrl
    private String imageUrl;

    @Size(max = 255)
    private String altText = "";

    @NotNull(message = "Vui long nhap thu tu anh")
    @PositiveOrZero
    @Max(value = 32767, message = "Thu tu anh khong duoc vuot qua 32767")
    private Integer displayOrder;

    private boolean primary;
}

