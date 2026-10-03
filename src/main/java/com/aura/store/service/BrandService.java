package com.aura.store.service;

import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.response.BrandResponse;
import java.util.List;
import org.springframework.data.domain.Page;

/**
 * Manages product brands used by the catalog.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface BrandService {
    /** Tim thuong hieu trong trang quan tri. */
    Page<BrandResponse> search(String keyword, int page);

    /** Lay thuong hieu dang hoat dong cho form va bo loc. */
    List<BrandResponse> activeBrands();

    /** Xem chi tiet thuong hieu. */
    BrandResponse get(Integer id);

    /** Tao thuong hieu moi. */
    BrandResponse create(BrandRequest request);

    /** Sua thuong hieu hien co. */
    BrandResponse update(Integer id, BrandRequest request);

    /** Xoa thuong hieu neu khong con san pham tham chieu. */
    void delete(Integer id);
}
