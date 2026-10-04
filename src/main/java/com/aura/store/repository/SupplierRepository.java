package com.aura.store.repository;

import com.aura.store.entity.Supplier;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Supplier.
 * TODO: Người phụ trách: Minh Thức, Mai Thanh.
 */
public interface SupplierRepository extends JpaRepository<Supplier, Integer> {

    /** Tìm nhà cung cấp theo các thông tin thường dùng trên màn hình quản lý. */
    @Query("select s from Supplier s where :keyword = '' "
            + "or lower(s.supplierCode) like lower(concat('%', :keyword, '%')) "
            + "or lower(s.supplierName) like lower(concat('%', :keyword, '%')) "
            + "or lower(coalesce(s.contactName, '')) like lower(concat('%', :keyword, '%')) "
            + "or lower(coalesce(s.phone, '')) like lower(concat('%', :keyword, '%')) "
            + "or lower(coalesce(s.email, '')) like lower(concat('%', :keyword, '%')) "
            + "or lower(coalesce(s.taxCode, '')) like lower(concat('%', :keyword, '%'))")
    Page<Supplier> search(@Param("keyword") String keyword, Pageable pageable);

    /** Chỉ trả nhà cung cấp đang hoạt động cho các nghiệp vụ chọn nhà cung cấp. */
    List<Supplier> findByActiveTrueOrderBySupplierNameAsc();

    boolean existsBySupplierCodeIgnoreCase(String supplierCode);

    boolean existsBySupplierCodeIgnoreCaseAndIdNot(String supplierCode, Integer id);

    boolean existsByTaxCode(String taxCode);

    boolean existsByTaxCodeAndIdNot(String taxCode, Integer id);
}

