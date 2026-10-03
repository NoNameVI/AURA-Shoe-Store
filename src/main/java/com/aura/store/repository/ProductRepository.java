package com.aura.store.repository;

import com.aura.store.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import com.aura.store.enums.PublicationStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Product.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface ProductRepository extends JpaRepository<Product, Integer> {
    /** Tim san pham quan tri theo tu khoa, nhan hang, danh muc va trang thai. */
    @Query(value = "select p from Product p join fetch p.brand join fetch p.category "
            + "where (:keyword = '' or lower(p.productName) like lower(concat('%', :keyword, '%')) "
            + "or lower(p.slug) like lower(concat('%', :keyword, '%')) "
            + "or lower(p.styleCode) like lower(concat('%', :keyword, '%'))) "
            + "and (:brandId is null or p.brand.id = :brandId) "
            + "and (:categoryId is null or p.category.id = :categoryId) "
            + "and (:status is null or p.publicationStatus = :status)",
            countQuery = "select count(p) from Product p where "
                    + "(:keyword = '' or lower(p.productName) like lower(concat('%', :keyword, '%')) "
                    + "or lower(p.slug) like lower(concat('%', :keyword, '%')) "
                    + "or lower(p.styleCode) like lower(concat('%', :keyword, '%'))) "
                    + "and (:brandId is null or p.brand.id = :brandId) "
                    + "and (:categoryId is null or p.category.id = :categoryId) "
                    + "and (:status is null or p.publicationStatus = :status)")
    Page<Product> search(@Param("keyword") String keyword, @Param("brandId") Integer brandId,
            @Param("categoryId") Integer categoryId, @Param("status") PublicationStatus status,
            Pageable pageable);

    /** Tim san pham duoc cong bo tren storefront. */
    @Query(value = "select p from Product p join fetch p.brand join fetch p.category "
            + "where p.publicationStatus = :activeStatus and p.brand.active = true and p.category.active = true "
            + "and (:keyword = '' or lower(p.productName) like lower(concat('%', :keyword, '%'))) "
            + "and (:brandId is null or p.brand.id = :brandId) "
            + "and (:categoryId is null or p.category.id = :categoryId)",
            countQuery = "select count(p) from Product p where "
                    + "p.publicationStatus = :activeStatus and p.brand.active = true and p.category.active = true "
                    + "and (:keyword = '' or lower(p.productName) like lower(concat('%', :keyword, '%'))) "
                    + "and (:brandId is null or p.brand.id = :brandId) "
                    + "and (:categoryId is null or p.category.id = :categoryId)")
    Page<Product> searchPublished(@Param("activeStatus") PublicationStatus activeStatus,
            @Param("keyword") String keyword, @Param("brandId") Integer brandId,
            @Param("categoryId") Integer categoryId, Pageable pageable);

    /** Kiem tra thuong hieu co san pham tham chieu truoc khi xoa. */
    boolean existsByBrand_Id(Integer brandId);

    /** Kiem tra danh muc co san pham tham chieu truoc khi xoa. */
    boolean existsByCategory_Id(Integer categoryId);

    /** Kiem tra slug san pham trung lap. */
    boolean existsBySlugIgnoreCase(String slug);

    /** Kiem tra ma mau san pham trung lap. */
    boolean existsByStyleCodeIgnoreCase(String styleCode);
}

