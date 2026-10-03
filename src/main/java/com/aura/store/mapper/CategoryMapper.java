package com.aura.store.mapper;

import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.response.CategoryResponse;
import com.aura.store.entity.Category;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

/**
 * Mapping contract shell for Category.
 * MapStruct methods are added when the related DTO fields are finalized.
 * TODO: Người phụ trách: Minh Thức.
 */
@Mapper(config = AuraMapperConfig.class)
public interface CategoryMapper {
    /** Chuyen danh muc va thong tin danh muc cha sang DTO. */
    @Mapping(target = "parentId", source = "parent.id")
    @Mapping(target = "parentName", source = "parent.categoryName")
    CategoryResponse toResponse(Category category);

    /** Tao danh muc moi; service se gan danh muc cha sau khi kiem tra. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "parent", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Category toEntity(CategoryRequest request);

    /** Cap nhat cac truong form, giu nguyen ID va timestamp. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "parent", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void update(CategoryRequest request, @MappingTarget Category category);
}

