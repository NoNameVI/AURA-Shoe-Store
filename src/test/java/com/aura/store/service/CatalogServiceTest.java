package com.aura.store.service;

import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.entity.Category;
import com.aura.store.entity.Brand;
import com.aura.store.entity.Product;
import com.aura.store.entity.ProductImage;
import com.aura.store.entity.ProductVariant;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.exception.BusinessException;
import com.aura.store.mapper.CategoryMapper;
import com.aura.store.mapper.ProductMapper;
import com.aura.store.repository.BrandRepository;
import com.aura.store.repository.CategoryRepository;
import com.aura.store.repository.ProductImageRepository;
import com.aura.store.repository.ProductRepository;
import com.aura.store.repository.ProductVariantRepository;
import com.aura.store.service.impl.CategoryServiceImpl;
import com.aura.store.service.impl.ProductServiceImpl;
import java.math.BigDecimal;
import java.util.Optional;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CatalogServiceTest {
    @Mock private ProductRepository productRepository;
    @Mock private ProductVariantRepository variantRepository;
    @Mock private ProductImageRepository imageRepository;
    @Mock private BrandRepository brandRepository;
    @Mock private CategoryRepository categoryRepository;
    @Mock private ProductMapper productMapper;
    @Mock private CategoryMapper categoryMapper;

    private ProductServiceImpl productService;
    private CategoryServiceImpl categoryService;

    /** Tao service voi repository gia lap de kiem tra quy tac nghiep vu. */
    @BeforeEach
    void setUp() {
        productService = new ProductServiceImpl(productRepository, variantRepository, imageRepository,
                brandRepository, categoryRepository, productMapper);
        categoryService = new CategoryServiceImpl(categoryRepository, productRepository, categoryMapper);
    }

    /** SKU duoc sinh tu product ID, mau va size, khong can thiep vao ton kho. */
    @Test
    void addVariantGeneratesSkuWithoutChangingStock() {
        Product product = new Product();
        product.setId(42);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());
        ProductVariantRequest request = variantRequest();

        productService.addVariant(42, request);

        ArgumentCaptor<ProductVariant> saved = ArgumentCaptor.forClass(ProductVariant.class);
        verify(variantRepository).save(saved.capture());
        assertEquals("P42-DO-40", saved.getValue().getSku());
        assertEquals(0, saved.getValue().getStockQuantity());
        assertEquals(0, saved.getValue().getReservedQuantity());
    }

    /** Chan to hop mau va size trung lap tren cung san pham. */
    @Test
    void addVariantRejectsDuplicateDimensions() {
        Product product = new Product();
        product.setId(42);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(variantRepository.existsByProduct_IdAndColorNameIgnoreCaseAndSizeCodeIgnoreCase(
                42, "Đỏ", "40")).thenReturn(true);

        assertThrows(BusinessException.class, () -> productService.addVariant(42, variantRequest()));
        verify(variantRepository, never()).save(any());
    }

    /** Khong cho chuyen danh muc thanh con cua chinh nhanh hien tai. */
    @Test
    void categoryUpdateRejectsCycle() {
        Category parent = new Category();
        parent.setId(1);
        parent.setSlug("parent");
        Category child = new Category();
        child.setId(2);
        child.setParent(parent);
        when(categoryRepository.findById(1)).thenReturn(Optional.of(parent));
        when(categoryRepository.findById(2)).thenReturn(Optional.of(child));
        CategoryRequest request = new CategoryRequest();
        request.setSlug("parent");
        request.setCategoryName("Parent");
        request.setParentId(2);

        assertThrows(BusinessException.class, () -> categoryService.update(1, request));
        verify(categoryRepository, never()).save(any());
    }

    /** Chi cong bo san pham khi co anh va mot bien the con hang. */
    @Test
    void publishingRequiresImageAndAvailableVariant() {
        Product product = new Product();
        product.setId(42);
        Brand brand = new Brand();
        brand.setActive(true);
        Category category = new Category();
        category.setActive(true);
        product.setBrand(brand);
        product.setCategory(category);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));

        assertThrows(BusinessException.class,
                () -> productService.changeStatus(42, PublicationStatus.ACTIVE));

        ProductImage image = new ProductImage();
        when(imageRepository.findByProduct_IdOrderByDisplayOrderAscIdAsc(42)).thenReturn(List.of(image));
        assertThrows(BusinessException.class,
                () -> productService.changeStatus(42, PublicationStatus.ACTIVE));
        verify(productRepository, never()).save(any());
    }

    /** Anh cuoi cua san pham dang cong bo khong duoc xoa. */
    @Test
    void activeProductKeepsAtLeastOneImage() {
        Product product = new Product();
        product.setId(42);
        product.setPublicationStatus(PublicationStatus.ACTIVE);
        ProductImage image = new ProductImage();
        image.setId(9);
        image.setProduct(product);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(imageRepository.findById(9)).thenReturn(Optional.of(image));
        when(imageRepository.findByProduct_IdOrderByDisplayOrderAscIdAsc(42)).thenReturn(List.of(image));

        assertThrows(BusinessException.class, () -> productService.deleteImage(42, 9));
        verify(imageRepository, never()).delete(any());
    }

    /** DTO storefront khong mang gia von va so lieu ton noi bo. */
    @Test
    void storefrontResponseOmitsInternalVariantData() {
        Product product = new Product();
        product.setId(42);
        product.setPublicationStatus(PublicationStatus.ACTIVE);
        Brand brand = new Brand();
        brand.setActive(true);
        Category category = new Category();
        category.setActive(true);
        product.setBrand(brand);
        product.setCategory(category);
        ProductVariant variant = new ProductVariant();
        variant.setActive(true);
        ProductVariantResponse internal = new ProductVariantResponse();
        internal.setActive(true);
        internal.setCostPrice(BigDecimal.valueOf(50));
        internal.setStockQuantity(10);
        internal.setAvailableQuantity(8);
        internal.setSalePrice(BigDecimal.valueOf(100));
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());
        when(variantRepository.findByProduct_IdOrderByIdAsc(42)).thenReturn(List.of(variant));
        when(productMapper.toVariantResponse(variant)).thenReturn(internal);

        ProductVariantResponse publicVariant = productService.getPublished(42).getVariants().getFirst();

        assertNull(publicVariant.getCostPrice());
        assertEquals(0, publicVariant.getStockQuantity());
        assertEquals(8, publicVariant.getAvailableQuantity());
    }

    /** Tao form bien the hop le cho cac bai kiem tra. */
    private ProductVariantRequest variantRequest() {
        ProductVariantRequest request = new ProductVariantRequest();
        request.setColorName("Đỏ");
        request.setSizeCode("40");
        request.setSalePrice(BigDecimal.valueOf(100));
        request.setCostPrice(BigDecimal.valueOf(50));
        return request;
    }
}
