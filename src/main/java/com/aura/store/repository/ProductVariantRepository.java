package com.aura.store.repository;

import com.aura.store.entity.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/**
 * Persistence gateway for ProductVariant.
 * TODO: Người phụ trách: Minh Thức, Thành Tài.
 */
public interface ProductVariantRepository extends JpaRepository<ProductVariant, Integer> {
    /** Lay bien the theo san pham de hien thi va quan ly. */
    List<ProductVariant> findByProduct_IdOrderByIdAsc(Integer productId);

    /** Kiem tra SKU duoc sinh khong bi trung. */
    boolean existsBySkuIgnoreCase(String sku);

    /** Kiem tra to hop mau va size tren cung san pham. */
    boolean existsByProduct_IdAndColor_IdAndSizeCodeIgnoreCase(
            Integer productId, Integer colorId, String sizeCode);

    /** Kiem tra mau da duoc mot bien the su dung. */
    boolean existsByColor_Id(Integer colorId);
}

