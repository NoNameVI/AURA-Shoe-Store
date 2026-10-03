package com.aura.store.mapper;

import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.response.BrandResponse;
import com.aura.store.entity.Brand;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

/**
 * Mapping contract shell for Brand.
 * MapStruct methods are added when the related DTO fields are finalized.
 * TODO: Người phụ trách: Minh Thức.
 */
@Mapper(config = AuraMapperConfig.class)
public interface BrandMapper {
    /** Chuyen entity thuong hieu sang du lieu hien thi. */
    BrandResponse toResponse(Brand brand);

    /** Tao entity moi tu form; ID va timestamp do persistence quan ly. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Brand toEntity(BrandRequest request);

    /** Cap nhat cac truong duoc phep sua tren entity hien co. */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void update(BrandRequest request, @MappingTarget Brand brand);
}

