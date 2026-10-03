package com.aura.store.service.impl;

import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.response.BrandResponse;
import com.aura.store.entity.Brand;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.mapper.BrandMapper;
import com.aura.store.repository.BrandRepository;
import com.aura.store.repository.ProductRepository;
import com.aura.store.service.BrandService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Default implementation shell for BrandService.
 * TODO: Người phụ trách: Minh Thức.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BrandServiceImpl implements BrandService {
    private final BrandRepository brandRepository;
    private final ProductRepository productRepository;
    private final BrandMapper brandMapper;

    /** Tim thuong hieu va chuyen trang ket qua sang DTO. */
    @Override
    public Page<BrandResponse> search(String keyword, int page) {
        return brandRepository.search(keyword == null ? "" : keyword.trim(),
                PageRequest.of(Math.max(0, page), 12, Sort.by("brandName").ascending()))
                .map(brandMapper::toResponse);
    }

    /** Lay nhung thuong hieu co the chon khi tao san pham. */
    @Override
    public List<BrandResponse> activeBrands() {
        return brandRepository.findByActiveTrueOrderByBrandNameAsc().stream()
                .map(brandMapper::toResponse).toList();
    }

    /** Lay mot thuong hieu theo ID. */
    @Override
    public BrandResponse get(Integer id) {
        return brandMapper.toResponse(findBrand(id));
    }

    /** Tao thuong hieu sau khi kiem tra rang buoc duy nhat. */
    @Override
    @Transactional
    public BrandResponse create(BrandRequest request) {
        checkUnique(request, null);
        Brand brand = brandMapper.toEntity(request);
        normalize(brand);
        return brandMapper.toResponse(brandRepository.save(brand));
    }

    /** Cap nhat thuong hieu va giu nguyen ID, timestamp. */
    @Override
    @Transactional
    public BrandResponse update(Integer id, BrandRequest request) {
        Brand brand = findBrand(id);
        checkUnique(request, brand);
        brandMapper.update(request, brand);
        normalize(brand);
        return brandMapper.toResponse(brandRepository.save(brand));
    }

    /** Khong xoa thuong hieu neu san pham van tham chieu. */
    @Override
    @Transactional
    public void delete(Integer id) {
        Brand brand = findBrand(id);
        if (productRepository.existsByBrand_Id(id)) {
            throw new BusinessException("Không thể xóa thương hiệu đang có sản phẩm.");
        }
        brandRepository.delete(brand);
    }

    /** Bao loi ro rang khi ID thuong hieu khong ton tai. */
    private Brand findBrand(Integer id) {
        return brandRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thương hiệu."));
    }

    /** Bo qua ban ghi hien tai khi kiem tra ten va slug luc cap nhat. */
    private void checkUnique(BrandRequest request, Brand current) {
        if ((current == null || !current.getSlug().equalsIgnoreCase(request.getSlug()))
                && brandRepository.existsBySlugIgnoreCase(request.getSlug())) {
            throw new BusinessException("Slug thương hiệu đã tồn tại.");
        }
        if ((current == null || !current.getBrandName().equalsIgnoreCase(request.getBrandName().trim()))
                && brandRepository.existsByBrandNameIgnoreCase(request.getBrandName().trim())) {
            throw new BusinessException("Tên thương hiệu đã tồn tại.");
        }
    }

    /** Chuan hoa khoang trang cua cac truong van ban truoc khi luu. */
    private void normalize(Brand brand) {
        brand.setBrandName(brand.getBrandName().trim());
        brand.setSlug(brand.getSlug().trim());
        brand.setDescription(blankToNull(brand.getDescription()));
        brand.setLogoUrl(blankToNull(brand.getLogoUrl()));
    }

    /** Chuyen chuoi rong thanh NULL cho cot tuy chon. */
    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}

