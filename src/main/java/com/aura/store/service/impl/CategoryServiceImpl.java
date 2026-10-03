package com.aura.store.service.impl;

import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.response.CategoryResponse;
import com.aura.store.entity.Category;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.mapper.CategoryMapper;
import com.aura.store.repository.CategoryRepository;
import com.aura.store.repository.ProductRepository;
import com.aura.store.service.CategoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Default implementation shell for CategoryService.
 * TODO: Người phụ trách: Minh Thức.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryServiceImpl implements CategoryService {
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final CategoryMapper categoryMapper;

    /** Tim danh muc va chuyen trang ket qua sang DTO. */
    @Override
    public Page<CategoryResponse> search(String keyword, int page) {
        return categoryRepository.search(keyword == null ? "" : keyword.trim(),
                PageRequest.of(Math.max(0, page), 12, Sort.by("categoryName").ascending()))
                .map(categoryMapper::toResponse);
    }

    /** Lay danh muc dang hoat dong cho form va bo loc. */
    @Override
    public List<CategoryResponse> activeCategories() {
        return categoryRepository.findByActiveTrueOrderByCategoryNameAsc().stream()
                .map(categoryMapper::toResponse).toList();
    }

    /** Lay ca danh muc da tat de form sua khong lam mat gia tri cha hien co. */
    @Override
    public List<CategoryResponse> allCategories() {
        return categoryRepository.findAllByOrderByCategoryNameAsc().stream()
                .map(categoryMapper::toResponse).toList();
    }

    /** Lay mot danh muc theo ID. */
    @Override
    public CategoryResponse get(Integer id) {
        return categoryMapper.toResponse(findCategory(id));
    }

    /** Tao danh muc va lien ket voi danh muc cha hop le. */
    @Override
    @Transactional
    public CategoryResponse create(CategoryRequest request) {
        checkUnique(request, null);
        Category category = categoryMapper.toEntity(request);
        category.setParent(resolveParent(request.getParentId(), null));
        checkActiveParent(category);
        normalize(category);
        return categoryMapper.toResponse(categoryRepository.save(category));
    }

    /** Cap nhat danh muc, chan quan he cha con tao thanh chu trinh. */
    @Override
    @Transactional
    public CategoryResponse update(Integer id, CategoryRequest request) {
        Category category = findCategory(id);
        checkUnique(request, category);
        Category parent = resolveParent(request.getParentId(), id);
        categoryMapper.update(request, category);
        category.setParent(parent);
        checkActiveParent(category);
        normalize(category);
        return categoryMapper.toResponse(categoryRepository.save(category));
    }

    /** Xoa danh muc chi khi khong co danh muc con va san pham. */
    @Override
    @Transactional
    public void delete(Integer id) {
        Category category = findCategory(id);
        if (categoryRepository.existsByParent_Id(id) || productRepository.existsByCategory_Id(id)) {
            throw new BusinessException("Không thể xóa danh mục đang được sử dụng.");
        }
        categoryRepository.delete(category);
    }

    /** Bao loi ro rang khi ID danh muc khong ton tai. */
    private Category findCategory(Integer id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục."));
    }

    /** Duyet len cac cap cha de ngan tu tham chieu va chu trinh. */
    private Category resolveParent(Integer parentId, Integer currentId) {
        if (parentId == null) {
            return null;
        }
        Category parent = findCategory(parentId);
        for (Category node = parent; node != null; node = node.getParent()) {
            if (currentId != null && currentId.equals(node.getId())) {
                throw new BusinessException("Danh mục cha không được tạo chu trình.");
            }
        }
        return parent;
    }

    /** Danh muc dang hoat dong khong duoc nam duoi cha da tat. */
    private void checkActiveParent(Category category) {
        if (category.isActive() && category.getParent() != null && !category.getParent().isActive()) {
            throw new BusinessException("Danh mục cha đã ngừng hoạt động.");
        }
    }

    /** Kiem tra slug duy nhat, bo qua ban ghi hien tai khi cap nhat. */
    private void checkUnique(CategoryRequest request, Category current) {
        if ((current == null || !current.getSlug().equalsIgnoreCase(request.getSlug()))
                && categoryRepository.existsBySlugIgnoreCase(request.getSlug())) {
            throw new BusinessException("Slug danh mục đã tồn tại.");
        }
    }

    /** Chuan hoa chuoi truoc khi luu vao database. */
    private void normalize(Category category) {
        category.setCategoryName(category.getCategoryName().trim());
        category.setSlug(category.getSlug().trim());
        String description = category.getDescription();
        category.setDescription(description == null || description.isBlank() ? null : description.trim());
    }
}

