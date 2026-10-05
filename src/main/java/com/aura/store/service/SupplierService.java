package com.aura.store.service;

import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.dto.response.PageResponse;
import com.aura.store.dto.response.SupplierResponse;
import java.util.List;

/**
 * Manages suppliers and supplier contact information.
 * TODO: Người phụ trách: Mai Thanh.
 */
public interface SupplierService {

    PageResponse<SupplierResponse> search(String keyword, int page);

    List<SupplierResponse> activeSuppliers();

    SupplierResponse get(Integer id);

    SupplierResponse create(SupplierRequest request);

    SupplierResponse update(Integer id, SupplierRequest request);

    SupplierResponse setActive(Integer id, boolean active);
}
