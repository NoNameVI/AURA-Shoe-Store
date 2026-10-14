package com.aura.store.repository;

import com.aura.store.entity.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/**
 * Persistence gateway for ProductImage.
 * TODO: Người phụ trách: Minh Thức.
 */
public interface ProductImageRepository extends JpaRepository<ProductImage, Integer> {
    /** Lay anh theo thu tu hien thi, sau do theo ID. */
    List<ProductImage> findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(Integer productId);

    /** Lay anh cua mot bien the de bao dam moi bien the chi co mot anh chinh. */
    List<ProductImage> findByVariant_IdOrderByDisplayOrderAscIdAsc(Integer variantId);

    /** Kiem tra san pham da co anh dai dien hay chua. */
    boolean existsByVariant_IdAndPrimaryTrue(Integer variantId);
}

