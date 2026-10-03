package com.aura.store.service;

import com.aura.store.dto.request.ProductImageRequest;
import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.enums.PublicationStatus;
import org.springframework.data.domain.Page;

/**
 * Manages products as catalog aggregates, including variants, images, prices,
 * availability queries, and storefront search.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface ProductService {
    /** Tim san pham cho quan tri, ke ca ban nhap va ban ngung ban. */
    Page<ProductResponse> searchManagement(String keyword, Integer brandId, Integer categoryId,
            PublicationStatus status, int page);

    /** Tim san pham dang cong bo tren storefront. */
    Page<ProductResponse> searchPublished(String keyword, Integer brandId, Integer categoryId, int page);

    /** Xem chi tiet san pham cho quan tri. */
    ProductResponse getManagement(Integer id);

    /** Xem chi tiet san pham dang duoc cong bo. */
    ProductResponse getPublished(Integer id);

    /** Tao san pham o trang thai nhap. */
    ProductResponse create(ProductRequest request);

    /** Sua thong tin co ban cua san pham. */
    ProductResponse update(Integer id, ProductRequest request);

    /** Doi trang thai cong bo cua san pham. */
    ProductResponse changeStatus(Integer id, PublicationStatus status);

    /** Them bien the va tu sinh SKU duy nhat. */
    ProductResponse addVariant(Integer productId, ProductVariantRequest request);

    /** Sua bien the, khong can thiep vao ton kho. */
    ProductResponse updateVariant(Integer productId, Integer variantId, ProductVariantRequest request);

    /** Them anh san pham tu URL da duoc kiem tra. */
    ProductResponse addImage(Integer productId, ProductImageRequest request);

    /** Sua URL, alt text, thu tu va anh dai dien. */
    ProductResponse updateImage(Integer productId, Integer imageId, ProductImageRequest request);

    /** Xoa anh san pham; cac anh con lai giu nguyen thu tu. */
    ProductResponse deleteImage(Integer productId, Integer imageId);
}
