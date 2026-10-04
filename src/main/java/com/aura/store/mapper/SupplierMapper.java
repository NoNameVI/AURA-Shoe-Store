package com.aura.store.mapper;

import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.dto.response.SupplierResponse;
import com.aura.store.entity.Supplier;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

/**
 * Mapping contract shell for Supplier.
 * MapStruct methods are added when the related DTO fields are finalized.
 * TODO: Người phụ trách: Minh Thức.
 */
@Mapper(config = AuraMapperConfig.class)
public interface SupplierMapper {

    SupplierResponse toResponse(Supplier supplier);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Supplier toEntity(SupplierRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void update(SupplierRequest request, @MappingTarget Supplier supplier);
}

