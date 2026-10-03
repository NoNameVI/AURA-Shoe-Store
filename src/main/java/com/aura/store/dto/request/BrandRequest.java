package com.aura.store.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Input contract for the Brand use case.
 * Fields and validation constraints are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class BrandRequest {
    @NotBlank(message = "Ten thuong hieu khong duoc de trong")
    @Size(max = 150)
    private String brandName;

    @NotBlank(message = "Slug khong duoc de trong")
    @Size(max = 160)
    @Pattern(regexp = "[a-z0-9]+(?:-[a-z0-9]+)*", message = "Slug chi gom chu thuong, so va dau gach ngang")
    private String slug;

    @Size(max = 1000)
    private String description;

    @Size(max = 500)
    @Pattern(regexp = "^$|https?://.+|/images/.+", message = "Logo phai la URL HTTP(S) hoac duong dan /images/")
    private String logoUrl;

    private boolean active = true;
}

