package com.aura.store.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Input contract for the Product use case.
 * Fields and validation constraints are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductRequest {
    @NotBlank(message = "Ten san pham khong duoc de trong")
    @Size(max = 180)
    private String productName;

    @NotBlank(message = "Slug khong duoc de trong")
    @Size(max = 200)
    @Pattern(regexp = "[a-z0-9]+(?:-[a-z0-9]+)*", message = "Slug chi gom chu thuong, so va dau gach ngang")
    private String slug;

    @Size(max = 100)
    private String styleCode;

    @Size(max = 3000)
    private String description;

    @NotNull(message = "Vui long chon thuong hieu")
    private Integer brandId;

    @NotNull(message = "Vui long chon danh muc")
    private Integer categoryId;
}

