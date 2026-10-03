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
    List<ProductImage> findByProduct_IdOrderByDisplayOrderAscIdAsc(Integer productId);

    /** Kiem tra san pham da co anh dai dien hay chua. */
    boolean existsByProduct_IdAndPrimaryTrue(Integer productId);
}

