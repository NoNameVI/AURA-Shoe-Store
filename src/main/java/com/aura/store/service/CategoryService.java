package com.aura.store.service;

import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.response.CategoryResponse;
import java.util.List;
import org.springframework.data.domain.Page;

/**
 * Manages the hierarchical product category tree.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface CategoryService {
    /** Tim danh muc trong trang quan tri. */
    Page<CategoryResponse> search(String keyword, int page);

    /** Lay danh muc dang hoat dong cho form va bo loc. */
    List<CategoryResponse> activeCategories();

    /** Lay moi danh muc cho form chon danh muc cha trong quan tri. */
    List<CategoryResponse> allCategories();

    /** Xem chi tiet danh muc. */
    CategoryResponse get(Integer id);

    /** Tao danh muc moi. */
    CategoryResponse create(CategoryRequest request);

    /** Sua danh muc hien co. */
    CategoryResponse update(Integer id, CategoryRequest request);

    /** Xoa danh muc neu khong con danh muc con hay san pham. */
    void delete(Integer id);
}
