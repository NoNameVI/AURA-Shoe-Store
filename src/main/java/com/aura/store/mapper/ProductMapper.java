package com.aura.store.mapper;

import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.response.ProductImageResponse;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.entity.Product;
import com.aura.store.entity.ProductImage;
import com.aura.store.entity.ProductVariant;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

/**
 * Mapping contract shell for Product.
 * MapStruct methods are added when the related DTO fields are finalized.
 * TODO: Người phụ trách: Minh Thức.
 */
@Mapper(config = AuraMapperConfig.class)
public interface ProductMapper {
    /** Chuyen thong tin san pham; service bo sung gia, anh va danh sach bien the. */
    @Mapping(target = "brandId", source = "brand.id")
    @Mapping(target = "brandName", source = "brand.brandName")
    @Mapping(target = "categoryId", source = "category.id")
    @Mapping(target = "categoryName", source = "category.categoryName")
    @Mapping(target = "lowestPrice", ignore = true)
    @Mapping(target = "available", ignore = true)
    @Mapping(target = "primaryImageUrl", ignore = true)
    @Mapping(target = "variants", ignore = true)
    @Mapping(target = "images", ignore = true)
    ProductResponse toResponse(Product product);

    /** Tao entity san pham; service gan brand, category va trang thai. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "brand", ignore = true)
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "publicationStatus", ignore = true)
    @Mapping(target = "archivedAt", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Product toEntity(ProductRequest request);

    /** Cap nhat thong tin co ban, khong sua trang thai tai day. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "brand", ignore = true)
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "publicationStatus", ignore = true)
    @Mapping(target = "archivedAt", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void update(ProductRequest request, @MappingTarget Product product);

    /** Chuyen bien the sang DTO, tinh ton kha dung tu ton va luong giu. */
    @Mapping(target = "availableQuantity",
            expression = "java(variant.getStockQuantity() - variant.getReservedQuantity())")
    ProductVariantResponse toVariantResponse(ProductVariant variant);

    /** Chuyen anh san pham sang DTO. */
    ProductImageResponse toImageResponse(ProductImage image);
}

