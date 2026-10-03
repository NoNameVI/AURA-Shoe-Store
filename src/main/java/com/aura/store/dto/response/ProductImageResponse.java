package com.aura.store.dto.response;

import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for ProductImage data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductImageResponse {
    private Integer id;
    private String imageUrl;
    private String altText;
    private int displayOrder;
    private boolean primary;
}

