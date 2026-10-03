package com.aura.store.dto.response;

import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for Category data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class CategoryResponse {
    private Integer id;
    private String categoryName;
    private String slug;
    private String description;
    private Integer parentId;
    private String parentName;
    private boolean active;
}

