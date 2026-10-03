package com.aura.store.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
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
    @NotBlank(message = "URL anh khong duoc de trong")
    @Size(max = 500)
    @Pattern(regexp = "https?://.+|/images/.+", message = "Anh phai la URL HTTP(S) hoac duong dan /images/")
    private String imageUrl;

    @Size(max = 255)
    private String altText = "";

    @PositiveOrZero
    @Max(value = 32767, message = "Thu tu anh khong duoc vuot qua 32767")
    private int displayOrder;

    private boolean primary;
}

