package com.aura.store.dto.response;

import com.aura.store.enums.PublicationStatus;
import java.math.BigDecimal;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

/**
 * Output contract for Product data.
 * Fields are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class ProductResponse {
    private Integer id;
    private String productName;
    private String slug;
    private String styleCode;
    private String description;
    private PublicationStatus publicationStatus;
    private Integer brandId;
    private String brandName;
    private Integer categoryId;
    private String categoryName;
    private BigDecimal lowestPrice;
    private boolean available;
    private String primaryImageUrl;
    private List<ProductVariantResponse> variants = List.of();
    private List<ProductImageResponse> images = List.of();
}

