package com.aura.store.service;

import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.request.ColorRequest;
import com.aura.store.dto.request.ProductImageRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.entity.Category;
import com.aura.store.entity.Color;
import com.aura.store.entity.Brand;
import com.aura.store.entity.Product;
import com.aura.store.entity.ProductImage;
import com.aura.store.entity.ProductVariant;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.exception.BusinessException;
import com.aura.store.mapper.CategoryMapper;
import com.aura.store.mapper.BrandMapper;
import com.aura.store.mapper.ProductMapper;
import com.aura.store.repository.BrandRepository;
import com.aura.store.repository.CategoryRepository;
import com.aura.store.repository.ColorRepository;
import com.aura.store.repository.ProductImageRepository;
import com.aura.store.repository.ProductRepository;
import com.aura.store.repository.ProductVariantRepository;
import com.aura.store.service.impl.CategoryServiceImpl;
import com.aura.store.service.impl.BrandServiceImpl;
import com.aura.store.service.impl.ColorServiceImpl;
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
    @Mock private ColorRepository colorRepository;
    @Mock private ProductMapper productMapper;
    @Mock private CategoryMapper categoryMapper;
    @Mock private BrandMapper brandMapper;

    private ProductServiceImpl productService;
    private CategoryServiceImpl categoryService;
    private BrandServiceImpl brandService;
    private ColorServiceImpl colorService;

    /** Tao service voi repository gia lap de kiem tra quy tac nghiep vu. */
    @BeforeEach
    void setUp() {
        productService = new ProductServiceImpl(productRepository, variantRepository, imageRepository,
                brandRepository, categoryRepository, colorRepository, productMapper);
        categoryService = new CategoryServiceImpl(categoryRepository, productRepository, categoryMapper);
        brandService = new BrandServiceImpl(brandRepository, productRepository, brandMapper);
        colorService = new ColorServiceImpl(colorRepository, variantRepository);
    }

    /** Slug Category trung khong duoc ghi them ban ghi. */
    @Test
    void createCategoryRejectsDuplicateSlug() {
        CategoryRequest request = new CategoryRequest();
        request.setCategoryName("Giày chạy");
        request.setSlug("running");
        when(categoryRepository.existsBySlugIgnoreCase("running")).thenReturn(true);

        assertThrows(BusinessException.class, () -> categoryService.create(request));
        verify(categoryRepository, never()).save(any());
    }

    /** Slug duoc cat khoang trang truoc khi doi chieu tinh duy nhat. */
    @Test
    void categoryDuplicateCheckUsesTrimmedSlug() {
        CategoryRequest request = new CategoryRequest();
        request.setCategoryName("Giay chay");
        request.setSlug("  running  ");
        when(categoryRepository.existsBySlugIgnoreCase("running")).thenReturn(true);

        assertThrows(BusinessException.class, () -> categoryService.create(request));
        verify(categoryRepository, never()).save(any());
    }

    /** Khong tat danh muc cha khi van con danh muc con hoat dong. */
    @Test
    void categoryCannotDeactivateWithActiveChild() {
        Category category = new Category();
        category.setId(4);
        category.setActive(true);
        when(categoryRepository.findById(4)).thenReturn(Optional.of(category));
        when(categoryRepository.existsByParent_IdAndActiveTrue(4)).thenReturn(true);
        CategoryRequest request = new CategoryRequest();
        request.setActive(false);

        assertThrows(BusinessException.class, () -> categoryService.update(4, request));
        verify(categoryRepository, never()).save(any());
    }

    /** Khong tat danh muc dang chua san pham da cong bo. */
    @Test
    void categoryCannotDeactivateWithPublishedProduct() {
        Category category = new Category();
        category.setId(4);
        category.setActive(true);
        when(categoryRepository.findById(4)).thenReturn(Optional.of(category));
        when(productRepository.existsByCategory_IdAndPublicationStatus(4, PublicationStatus.ACTIVE))
                .thenReturn(true);
        CategoryRequest request = new CategoryRequest();
        request.setActive(false);

        assertThrows(BusinessException.class, () -> categoryService.update(4, request));
        verify(categoryRepository, never()).save(any());
    }

    /** Danh muc dang hoat dong khong duoc gan cha da tat. */
    @Test
    void createActiveCategoryRejectsInactiveParent() {
        CategoryRequest request = new CategoryRequest();
        request.setCategoryName("Giày chạy");
        request.setSlug("running");
        request.setParentId(1);
        Category category = new Category();
        category.setActive(true);
        Category parent = new Category();
        parent.setId(1);
        parent.setActive(false);
        when(categoryMapper.toEntity(request)).thenReturn(category);
        when(categoryRepository.findById(1)).thenReturn(Optional.of(parent));

        assertThrows(BusinessException.class, () -> categoryService.create(request));
        verify(categoryRepository, never()).save(any());
    }

    /** Ten Brand trung khong duoc ghi them ban ghi. */
    @Test
    void createBrandRejectsDuplicateName() {
        BrandRequest request = new BrandRequest();
        request.setBrandName(" AURA ");
        request.setSlug("aura");
        when(brandRepository.existsByBrandNameIgnoreCase("AURA")).thenReturn(true);

        assertThrows(BusinessException.class, () -> brandService.create(request));
        verify(brandRepository, never()).save(any());
    }

    /** Khong tat thuong hieu khi san pham dang hien tren cua hang. */
    @Test
    void brandCannotDeactivateWithPublishedProduct() {
        Brand brand = new Brand();
        brand.setId(3);
        brand.setActive(true);
        when(brandRepository.findById(3)).thenReturn(Optional.of(brand));
        when(productRepository.existsByBrand_IdAndPublicationStatus(3, PublicationStatus.ACTIVE))
                .thenReturn(true);
        BrandRequest request = new BrandRequest();
        request.setActive(false);

        assertThrows(BusinessException.class, () -> brandService.update(3, request));
        verify(brandRepository, never()).save(any());
    }

    /** Product can brand dang hoat dong, khong nhan brand da tat. */
    @Test
    void createProductRejectsInactiveBrand() {
        ProductRequest request = productRequest();
        Product product = new Product();
        Brand brand = new Brand();
        brand.setActive(false);
        when(productMapper.toEntity(request)).thenReturn(product);
        when(brandRepository.findById(3)).thenReturn(Optional.of(brand));

        assertThrows(BusinessException.class, () -> productService.create(request));
        verify(productRepository, never()).save(any());
    }

    /** Slug Product trung duoc chan truoc khi tim brand/category. */
    @Test
    void createProductRejectsDuplicateSlug() {
        ProductRequest request = productRequest();
        when(productRepository.existsBySlugIgnoreCase("giay-thu-nghiem")).thenReturn(true);

        assertThrows(BusinessException.class, () -> productService.create(request));
        verify(productRepository, never()).save(any());
    }

    /** Slug Product co khoang trang van khong duoc trung ban ghi khac. */
    @Test
    void productDuplicateCheckUsesTrimmedSlug() {
        ProductRequest request = productRequest();
        request.setSlug("  giay-thu-nghiem  ");
        when(productRepository.existsBySlugIgnoreCase("giay-thu-nghiem")).thenReturn(true);

        assertThrows(BusinessException.class, () -> productService.create(request));
        verify(productRepository, never()).save(any());
    }

    /** Product moi duoc luu DRAFT ma khong bat buoc co variant trong Iteration 1. */
    @Test
    void createProductWithoutVariantsStaysDraft() {
        ProductRequest request = productRequest();
        Product product = new Product();
        product.setId(42);
        product.setProductName(request.getProductName());
        product.setSlug(request.getSlug());
        Brand brand = new Brand();
        brand.setActive(true);
        Category category = new Category();
        category.setActive(true);
        when(productMapper.toEntity(request)).thenReturn(product);
        when(brandRepository.findById(3)).thenReturn(Optional.of(brand));
        when(categoryRepository.findById(4)).thenReturn(Optional.of(category));
        when(productRepository.save(product)).thenReturn(product);
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());

        productService.create(request);

        assertEquals(PublicationStatus.DRAFT, product.getPublicationStatus());
        verify(productRepository).save(product);
        verify(variantRepository, never()).save(any());
    }

    /** Tao request hop le cho cac kiem tra tao Product. */
    private ProductRequest productRequest() {
        ProductRequest request = new ProductRequest();
        request.setProductName("Giày thử nghiệm");
        request.setSlug("giay-thu-nghiem");
        request.setBrandId(3);
        request.setCategoryId(4);
        return request;
    }

    /** SKU duoc sinh tu product ID, mau va size; gia von mac dinh cho nghiep vu kho. */
    @Test
    void addVariantGeneratesSkuWithoutChangingStock() {
        Product product = new Product();
        product.setId(42);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());
        ProductVariantRequest request = variantRequest();
        when(colorRepository.findById(1)).thenReturn(Optional.of(activeColor()));

        productService.addVariant(42, request);

        ArgumentCaptor<ProductVariant> saved = ArgumentCaptor.forClass(ProductVariant.class);
        verify(variantRepository).save(saved.capture());
        assertEquals("P42-RED-40", saved.getValue().getSku());
        assertEquals(0, saved.getValue().getStockQuantity());
        assertEquals(0, saved.getValue().getReservedQuantity());
        assertEquals(BigDecimal.ZERO, saved.getValue().getCostPrice());
    }

    /** Sua bien the qua catalog khong thay doi gia von da duoc nghiep vu kho ghi. */
    @Test
    void updateVariantPreservesCostPrice() {
        Product product = new Product();
        product.setId(42);
        ProductVariant variant = new ProductVariant();
        variant.setId(7);
        variant.setProduct(product);
        variant.setSku("P42-RED-40");
        variant.setColor(activeColor());
        variant.setSizeCode("40");
        variant.setCostPrice(BigDecimal.valueOf(50));
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(variantRepository.findById(7)).thenReturn(Optional.of(variant));
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());
        when(colorRepository.findById(1)).thenReturn(Optional.of(activeColor()));

        productService.updateVariant(42, 7, variantRequest());

        assertEquals(BigDecimal.valueOf(50), variant.getCostPrice());
        verify(variantRepository).save(variant);
    }

    /** Chan to hop mau va size trung lap tren cung san pham. */
    @Test
    void addVariantRejectsDuplicateDimensions() {
        Product product = new Product();
        product.setId(42);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(colorRepository.findById(1)).thenReturn(Optional.of(activeColor()));
        when(variantRepository.existsByProduct_IdAndColor_IdAndSizeCodeIgnoreCase(
                42, 1, "40")).thenReturn(true);

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
        when(imageRepository.findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(42)).thenReturn(List.of(image));
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
        ProductVariant variant = new ProductVariant();
        variant.setId(7);
        variant.setProduct(product);
        image.setVariant(variant);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(imageRepository.findById(9)).thenReturn(Optional.of(image));
        when(imageRepository.findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(42)).thenReturn(List.of(image));

        assertThrows(BusinessException.class, () -> productService.deleteImage(42, 9));
        verify(imageRepository, never()).delete(any());
    }

    /** Anh moi phai thuoc bien the duoc chon va chi xet anh chinh trong bien the do. */
    @Test
    void addImageUsesSelectedVariant() {
        Product product = new Product();
        product.setId(42);
        ProductVariant variant = new ProductVariant();
        variant.setId(7);
        variant.setProduct(product);
        ProductImageRequest request = new ProductImageRequest();
        request.setVariantId(7);
        request.setImageUrl("/images/demo/shoe-placeholder.svg");
        request.setDisplayOrder(0);
        when(productRepository.findById(42)).thenReturn(Optional.of(product));
        when(variantRepository.findById(7)).thenReturn(Optional.of(variant));
        when(productMapper.toResponse(product)).thenReturn(new ProductResponse());

        productService.addImage(42, request);

        ArgumentCaptor<ProductImage> saved = ArgumentCaptor.forClass(ProductImage.class);
        verify(imageRepository).save(saved.capture());
        assertEquals(variant, saved.getValue().getVariant());
        assertEquals(true, saved.getValue().isPrimary());
    }

    /** Khong doi ma mau dang duoc bien the su dung de tranh thay doi dinh danh SKU. */
    @Test
    void usedColorCannotChangeCode() {
        Color color = activeColor();
        ColorRequest request = new ColorRequest();
        request.setColorCode("NEW-RED");
        request.setColorName("Đỏ");
        request.setActive(true);
        when(colorRepository.findById(1)).thenReturn(Optional.of(color));
        when(variantRepository.existsByColor_Id(1)).thenReturn(true);

        assertThrows(BusinessException.class, () -> colorService.update(1, request));
        verify(colorRepository, never()).save(any());
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
        request.setColorId(1);
        request.setSizeCode("40");
        request.setSalePrice(BigDecimal.valueOf(100));
        request.setLowStockThreshold(5L);
        return request;
    }

    /** Tao mau hoat dong cho cac bai kiem tra bien the. */
    private Color activeColor() {
        Color color = new Color();
        color.setId(1);
        color.setColorCode("RED");
        color.setColorName("Đỏ");
        color.setActive(true);
        return color;
    }
}
