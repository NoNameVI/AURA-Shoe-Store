package com.aura.store.repository;

import com.aura.store.entity.Brand;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Brand.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface BrandRepository extends JpaRepository<Brand, Integer> {
    /** Tim thuong hieu theo ten hoac slug, co phan trang. */
    @Query("select b from Brand b where :keyword = '' or lower(b.brandName) like lower(concat('%', :keyword, '%')) or lower(b.slug) like lower(concat('%', :keyword, '%'))")
    Page<Brand> search(@Param("keyword") String keyword, Pageable pageable);

    /** Lay thuong hieu dang hoat dong cho form va bo loc. */
    List<Brand> findByActiveTrueOrderByBrandNameAsc();

    /** Kiem tra slug trung lap. */
    boolean existsBySlugIgnoreCase(String slug);

    /** Kiem tra ten trung lap. */
    boolean existsByBrandNameIgnoreCase(String brandName);
}

