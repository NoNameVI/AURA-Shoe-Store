package com.aura.store.dto.response;

import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for Brand data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class BrandResponse {
    private Integer id;
    private String brandName;
    private String slug;
    private String description;
    private String logoUrl;
    private boolean active;
}

