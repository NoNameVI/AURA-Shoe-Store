package com.aura.store.service.impl;

import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.dto.response.PageResponse;
import com.aura.store.dto.response.SupplierResponse;
import com.aura.store.entity.Supplier;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.mapper.SupplierMapper;
import com.aura.store.repository.SupplierRepository;
import com.aura.store.service.SupplierService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Default implementation shell for SupplierService.
 * TODO: Người phụ trách: Mai Thanh.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepository supplierRepository;
    private final SupplierMapper supplierMapper;

    /** Tìm kiếm có phân trang; từ khóa rỗng trả toàn bộ nhà cung cấp. */
    @Override
    public PageResponse<SupplierResponse> search(String keyword, int page) {
        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        Page<SupplierResponse> result = supplierRepository.search(normalizedKeyword,
                        PageRequest.of(Math.max(0, page), 12,
                                Sort.by("supplierName").ascending().and(Sort.by("id").ascending())))
                .map(supplierMapper::toResponse);
        return new PageResponse<>(result.getContent(), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    /** Danh sách lựa chọn chỉ gồm nhà cung cấp đang hoạt động. */
    @Override
    public List<SupplierResponse> activeSuppliers() {
        return supplierRepository.findByActiveTrueOrderBySupplierNameAsc().stream()
                .map(supplierMapper::toResponse)
                .toList();
    }

    /** Xem cả nhà cung cấp đang hoạt động và đã ngừng hoạt động. */
    @Override
    public SupplierResponse get(Integer id) {
        return supplierMapper.toResponse(findSupplier(id));
    }

    /** Tạo nhà cung cấp sau khi kiểm tra các khóa nghiệp vụ duy nhất. */
    @Override
    @Transactional
    public SupplierResponse create(SupplierRequest request) {
        normalize(request);
        checkUnique(request, null);
        Supplier supplier = supplierMapper.toEntity(request);
        return supplierMapper.toResponse(supplierRepository.save(supplier));
    }

    /** Cập nhật thông tin nhà cung cấp hiện có. */
    @Override
    @Transactional
    public SupplierResponse update(Integer id, SupplierRequest request) {
        Supplier supplier = findSupplier(id);
        normalize(request);
        checkUnique(request, supplier);
        supplierMapper.update(request, supplier);
        return supplierMapper.toResponse(supplierRepository.save(supplier));
    }

    /** Kích hoạt hoặc ngừng hoạt động mà không xóa lịch sử nhà cung cấp. */
    @Override
    @Transactional
    public SupplierResponse setActive(Integer id, boolean active) {
        Supplier supplier = findSupplier(id);
        supplier.setActive(active);
        return supplierMapper.toResponse(supplierRepository.save(supplier));
    }

    private Supplier findSupplier(Integer id) {
        return supplierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy nhà cung cấp."));
    }

    private void checkUnique(SupplierRequest request, Supplier current) {
        boolean duplicateCode = current == null
                ? supplierRepository.existsBySupplierCodeIgnoreCase(request.getSupplierCode())
                : supplierRepository.existsBySupplierCodeIgnoreCaseAndIdNot(
                        request.getSupplierCode(), current.getId());
        if (duplicateCode) {
            throw new BusinessException("Mã nhà cung cấp đã tồn tại.");
        }

        boolean duplicateTaxCode = request.getTaxCode() != null && (current == null
                ? supplierRepository.existsByTaxCode(request.getTaxCode())
                : supplierRepository.existsByTaxCodeAndIdNot(request.getTaxCode(), current.getId()));
        if (duplicateTaxCode) {
            throw new BusinessException("Mã số thuế đã tồn tại.");
        }
    }

    /** Chuẩn hóa dữ liệu trước khi kiểm tra duy nhất và ánh xạ sang entity. */
    private void normalize(SupplierRequest request) {
        request.setSupplierCode(request.getSupplierCode().trim());
        request.setSupplierName(request.getSupplierName().trim());
        request.setContactName(blankToNull(request.getContactName()));
        request.setPhone(blankToNull(request.getPhone()));
        request.setEmail(blankToNull(request.getEmail()));
        request.setTaxCode(blankToNull(request.getTaxCode()));
        request.setAddressText(blankToNull(request.getAddressText()));
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}

