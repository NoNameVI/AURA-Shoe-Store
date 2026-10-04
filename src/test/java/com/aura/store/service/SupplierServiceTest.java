package com.aura.store.service;

import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.dto.response.SupplierResponse;
import com.aura.store.entity.Supplier;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.mapper.SupplierMapper;
import com.aura.store.repository.SupplierRepository;
import com.aura.store.service.impl.SupplierServiceImpl;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SupplierServiceTest {

    @Mock private SupplierRepository supplierRepository;
    @Mock private SupplierMapper supplierMapper;

    private SupplierServiceImpl supplierService;

    @BeforeEach
    void setUp() {
        supplierService = new SupplierServiceImpl(supplierRepository, supplierMapper);
    }

    /** Tiêu chí trống phải được chuẩn hóa thành chuỗi rỗng để trả toàn bộ danh sách. */
    @Test
    void blankSearchUsesEmptyKeyword() {
        when(supplierRepository.search(eq(""), any(Pageable.class))).thenReturn(Page.empty());

        supplierService.search("   ", -2);

        ArgumentCaptor<Pageable> pageable = ArgumentCaptor.forClass(Pageable.class);
        verify(supplierRepository).search(eq(""), pageable.capture());
        assertEquals(0, pageable.getValue().getPageNumber());
    }

    /** Từ chối tạo mới khi mã nhà cung cấp đã tồn tại. */
    @Test
    void createRejectsDuplicateSupplierCode() {
        SupplierRequest request = validRequest();
        when(supplierRepository.existsBySupplierCodeIgnoreCase("SUP-001")).thenReturn(true);

        assertThrows(BusinessException.class, () -> supplierService.create(request));

        verify(supplierRepository, never()).save(any());
    }

    /** Chuỗi tùy chọn rỗng được lưu thành null và dữ liệu bắt buộc được cắt khoảng trắng. */
    @Test
    void createNormalizesSupplierData() {
        SupplierRequest request = validRequest();
        request.setSupplierCode("  SUP-001  ");
        request.setSupplierName("  Nhà cung cấp 01  ");
        request.setContactName("   ");
        Supplier entity = new Supplier();
        SupplierResponse response = new SupplierResponse();
        when(supplierMapper.toEntity(request)).thenReturn(entity);
        when(supplierRepository.save(entity)).thenReturn(entity);
        when(supplierMapper.toResponse(entity)).thenReturn(response);

        supplierService.create(request);

        assertEquals("SUP-001", request.getSupplierCode());
        assertEquals("Nhà cung cấp 01", request.getSupplierName());
        assertNull(request.getContactName());
        verify(supplierRepository).save(entity);
    }

    /** Mã số thuế khác với bản ghi hiện tại vẫn phải giữ tính duy nhất. */
    @Test
    void updateRejectsDuplicateTaxCode() {
        Supplier current = new Supplier();
        current.setId(1);
        current.setSupplierCode("SUP-001");
        current.setTaxCode("0123456789");
        SupplierRequest request = validRequest();
        request.setTaxCode("9876543210");
        when(supplierRepository.findById(1)).thenReturn(Optional.of(current));
        when(supplierRepository.existsByTaxCodeAndIdNot("9876543210", 1)).thenReturn(true);

        assertThrows(BusinessException.class, () -> supplierService.update(1, request));

        verify(supplierMapper, never()).update(any(), any());
        verify(supplierRepository, never()).save(any());
    }

    /** Kiểm tra trùng khi cập nhật phải loại chính ID của nhà cung cấp hiện tại. */
    @Test
    void updateUniquenessQueriesExcludeCurrentSupplierId() {
        Supplier current = new Supplier();
        current.setId(1);
        current.setSupplierCode("SUP-001");
        SupplierRequest request = validRequest();
        SupplierResponse response = new SupplierResponse();
        when(supplierRepository.findById(1)).thenReturn(Optional.of(current));
        when(supplierRepository.save(current)).thenReturn(current);
        when(supplierMapper.toResponse(current)).thenReturn(response);

        supplierService.update(1, request);

        verify(supplierRepository).existsBySupplierCodeIgnoreCaseAndIdNot("SUP-001", 1);
        verify(supplierRepository, never()).existsBySupplierCodeIgnoreCase("SUP-001");
    }

    /** Ngừng hoạt động chỉ cập nhật trạng thái, không xóa nhà cung cấp. */
    @Test
    void deactivateDoesNotDeleteSupplier() {
        Supplier supplier = new Supplier();
        supplier.setId(1);
        supplier.setActive(true);
        when(supplierRepository.findById(1)).thenReturn(Optional.of(supplier));
        when(supplierRepository.save(supplier)).thenReturn(supplier);
        when(supplierMapper.toResponse(supplier)).thenReturn(new SupplierResponse());

        supplierService.setActive(1, false);

        assertFalse(supplier.isActive());
        verify(supplierRepository).save(supplier);
        verify(supplierRepository, never()).delete(any());
    }

    /** ID không tồn tại phải dùng exception chung dành cho tài nguyên bị thiếu. */
    @Test
    void getMissingSupplierThrowsResourceNotFound() {
        when(supplierRepository.findById(99)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> supplierService.get(99));
    }

    private SupplierRequest validRequest() {
        SupplierRequest request = new SupplierRequest();
        request.setSupplierCode("SUP-001");
        request.setSupplierName("Nhà cung cấp 01");
        request.setActive(true);
        return request;
    }
}
