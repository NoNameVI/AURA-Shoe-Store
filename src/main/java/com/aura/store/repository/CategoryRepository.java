package com.aura.store.repository;

import com.aura.store.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/**
 * Persistence gateway for Category.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface CategoryRepository extends JpaRepository<Category, Integer> {
    /** Tim danh muc theo ten hoac slug, co phan trang. */
    @Query("select c from Category c where :keyword = '' or lower(c.categoryName) like lower(concat('%', :keyword, '%')) or lower(c.slug) like lower(concat('%', :keyword, '%'))")
    Page<Category> search(@Param("keyword") String keyword, Pageable pageable);

    /** Lay danh muc dang hoat dong cho form va bo loc. */
    List<Category> findByActiveTrueOrderByCategoryNameAsc();

    /** Lay tat ca danh muc de giu lua chon cha khi sua ban ghi ngung hoat dong. */
    List<Category> findAllByOrderByCategoryNameAsc();

    /** Kiem tra slug trung lap. */
    boolean existsBySlugIgnoreCase(String slug);

    /** Kiem tra danh muc con truoc khi xoa. */
    boolean existsByParent_Id(Integer parentId);
}

