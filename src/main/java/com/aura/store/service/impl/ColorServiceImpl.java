package com.aura.store.service.impl;

import com.aura.store.dto.request.ColorRequest;
import com.aura.store.dto.response.ColorResponse;
import com.aura.store.entity.Color;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.repository.ColorRepository;
import com.aura.store.repository.ProductVariantRepository;
import com.aura.store.service.ColorService;
import com.aura.store.validation.SearchInput;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Xu ly quy tac nghiep vu cho danh muc mau. */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ColorServiceImpl implements ColorService {
    private final ColorRepository colorRepository;
    private final ProductVariantRepository variantRepository;

    /** Tim mau va chuyen ket qua sang DTO hien thi. */
    @Override
    public Page<ColorResponse> search(String keyword, int page) {
        return colorRepository.search(SearchInput.keyword(keyword),
                PageRequest.of(SearchInput.page(page), 12, Sort.by("colorName"))).map(this::toResponse);
    }

    /** Chi dua mau dang hoat dong vao o chon cua form bien the. */
    @Override
    public List<ColorResponse> activeColors() {
        return colorRepository.findByActiveTrueOrderByColorNameAsc().stream().map(this::toResponse).toList();
    }

    /** Lay mau theo ID hoac bao loi khong tim thay. */
    @Override
    public ColorResponse get(Integer id) {
        return toResponse(findColor(id));
    }

    /** Tao mau moi sau khi kiem tra ten khong trung. */
    @Override
    @Transactional
    public ColorResponse create(ColorRequest request) {
        String name = request.getColorName().trim();
        String code = request.getColorCode().trim().toUpperCase(Locale.ROOT);
        if (colorRepository.existsByColorNameIgnoreCase(name)) {
            throw new BusinessException("Tên màu đã tồn tại.");
        }
        if (colorRepository.existsByColorCodeIgnoreCase(code)) {
            throw new BusinessException("Mã màu đã tồn tại.");
        }
        Color color = new Color();
        apply(request, color);
        return toResponse(colorRepository.save(color));
    }

    /** Khong doi ten hay tat mau dang duoc bien the su dung de giu du lieu nhat quan. */
    @Override
    @Transactional
    public ColorResponse update(Integer id, ColorRequest request) {
        Color color = findColor(id);
        String name = request.getColorName().trim();
        String code = request.getColorCode().trim().toUpperCase(Locale.ROOT);
        boolean renamed = !color.getColorName().equalsIgnoreCase(name);
        boolean recoded = !color.getColorCode().equalsIgnoreCase(code);
        if (renamed && colorRepository.existsByColorNameIgnoreCase(name)) {
            throw new BusinessException("Tên màu đã tồn tại.");
        }
        if (recoded && colorRepository.existsByColorCodeIgnoreCase(code)) {
            throw new BusinessException("Mã màu đã tồn tại.");
        }
        if ((renamed || recoded || !request.isActive()) && variantRepository.existsByColor_Id(id)) {
            throw new BusinessException("Màu đang được biến thể sử dụng; không thể đổi tên, đổi mã hoặc tắt.");
        }
        apply(request, color);
        return toResponse(colorRepository.save(color));
    }

    /** Chi xoa mau chua duoc bien the nao tham chieu. */
    @Override
    @Transactional
    public void delete(Integer id) {
        Color color = findColor(id);
        if (variantRepository.existsByColor_Id(id)) {
            throw new BusinessException("Không thể xóa màu đang được biến thể sử dụng.");
        }
        colorRepository.delete(color);
    }

    /** Tim entity mau dung cho thao tac ghi. */
    private Color findColor(Integer id) {
        return colorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy màu."));
    }

    /** Chuan hoa cac truong cua form truoc khi luu. */
    private void apply(ColorRequest request, Color color) {
        color.setColorCode(request.getColorCode().trim().toUpperCase(Locale.ROOT));
        color.setColorName(request.getColorName().trim());
        color.setHexCode(request.getHexCode() == null || request.getHexCode().isBlank()
                ? null : request.getHexCode().trim().toUpperCase());
        color.setActive(request.isActive());
    }

    /** Sao chep entity sang DTO de khong dua JPA entity len view. */
    private ColorResponse toResponse(Color color) {
        ColorResponse response = new ColorResponse();
        response.setId(color.getId());
        response.setColorCode(color.getColorCode());
        response.setColorName(color.getColorName());
        response.setHexCode(color.getHexCode());
        response.setActive(color.isActive());
        return response;
    }
}
