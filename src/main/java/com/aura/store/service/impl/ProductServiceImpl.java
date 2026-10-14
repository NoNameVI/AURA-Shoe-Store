package com.aura.store.service.impl;

import com.aura.store.dto.request.ProductImageRequest;
import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.response.ProductImageResponse;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.entity.Brand;
import com.aura.store.entity.Category;
import com.aura.store.entity.Color;
import com.aura.store.entity.Product;
import com.aura.store.entity.ProductImage;
import com.aura.store.entity.ProductVariant;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.exception.BusinessException;
import com.aura.store.exception.ResourceNotFoundException;
import com.aura.store.mapper.ProductMapper;
import com.aura.store.repository.BrandRepository;
import com.aura.store.repository.CategoryRepository;
import com.aura.store.repository.ColorRepository;
import com.aura.store.repository.ProductImageRepository;
import com.aura.store.repository.ProductRepository;
import com.aura.store.repository.ProductVariantRepository;
import com.aura.store.service.ProductService;
import com.aura.store.validation.SearchInput;
import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Default implementation shell for ProductService.
 * TODO: Người phụ trách: Minh Thức.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {
    private final ProductRepository productRepository;
    private final ProductVariantRepository variantRepository;
    private final ProductImageRepository imageRepository;
    private final BrandRepository brandRepository;
    private final CategoryRepository categoryRepository;
    private final ColorRepository colorRepository;
    private final ProductMapper productMapper;

    /** Tim san pham trong quan tri va bo sung du lieu gia, anh, bien the. */
    @Override
    public Page<ProductResponse> searchManagement(String keyword, Integer brandId, Integer categoryId,
            PublicationStatus status, int page) {
        return productRepository.search(cleanKeyword(keyword), brandId, categoryId, status, pageRequest(page))
                .map(this::toResponse);
    }

    /** Chi dua san pham da cong bo va co brand/category dang hoat dong len storefront. */
    @Override
    public Page<ProductResponse> searchPublished(String keyword, Integer brandId, Integer categoryId, int page) {
        return productRepository.searchPublished(PublicationStatus.ACTIVE, cleanKeyword(keyword),
                brandId, categoryId, pageRequest(page)).map(this::toPublicResponse);
    }

    /** Lay chi tiet san pham cho trang quan tri. */
    @Override
    public ProductResponse getManagement(Integer id) {
        return toResponse(findProduct(id));
    }

    /** Khong de storefront truy cap san pham chua cong bo. */
    @Override
    public ProductResponse getPublished(Integer id) {
        Product product = findProduct(id);
        if (product.getPublicationStatus() != PublicationStatus.ACTIVE
                || !product.getBrand().isActive() || !product.getCategory().isActive()) {
            throw new ResourceNotFoundException("Không tìm thấy sản phẩm.");
        }
        return toPublicResponse(product);
    }

    /** Tao san pham o trang thai DRAFT; ton kho duoc quan ly boi module Inventory. */
    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        checkUnique(request, null);
        Product product = productMapper.toEntity(request);
        product.setBrand(findBrand(request.getBrandId()));
        product.setCategory(findCategory(request.getCategoryId()));
        product.setPublicationStatus(PublicationStatus.DRAFT);
        normalize(product);
        return toResponse(productRepository.save(product));
    }

    /** Sua thong tin chung; khong sua gia va ton kho cua bien the tai day. */
    @Override
    @Transactional
    public ProductResponse update(Integer id, ProductRequest request) {
        Product product = findProduct(id);
        checkUnique(request, product);
        productMapper.update(request, product);
        product.setBrand(findBrand(request.getBrandId()));
        product.setCategory(findCategory(request.getCategoryId()));
        normalize(product);
        return toResponse(productRepository.save(product));
    }

    /** Kiem tra dieu kien cong bo de khong dua ban nhap thieu du lieu len cua hang. */
    @Override
    @Transactional
    public ProductResponse changeStatus(Integer id, PublicationStatus status) {
        Product product = findProduct(id);
        if (status == null) {
            throw new BusinessException("Vui lòng chọn trạng thái sản phẩm.");
        }
        if (status == PublicationStatus.ACTIVE) {
            if (!product.getBrand().isActive() || !product.getCategory().isActive()) {
                throw new BusinessException("Thương hiệu và danh mục phải đang hoạt động.");
            }
            if (imageRepository.findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(id).isEmpty()) {
                throw new BusinessException("Sản phẩm cần có ảnh trước khi công bố.");
            }
            boolean sellable = variantRepository.findByProduct_IdOrderByIdAsc(id).stream()
                    .anyMatch(v -> v.isActive() && v.getStockQuantity() > v.getReservedQuantity());
            if (!sellable) {
                throw new BusinessException("Sản phẩm cần có biến thể còn hàng trước khi công bố.");
            }
        }
        product.setPublicationStatus(status);
        product.setArchivedAt(status == PublicationStatus.ARCHIVED ? LocalDateTime.now() : null);
        return toResponse(productRepository.save(product));
    }

    /** Tao SKU tu ID san pham, mau va size; khong cho sua ton kho va gia von trong luong catalog. */
    @Override
    @Transactional
    public ProductResponse addVariant(Integer productId, ProductVariantRequest request) {
        Product product = findProduct(productId);
        Color selectedColor = findActiveColor(request.getColorId());
        String size = request.getSizeCode().trim();
        checkVariantDimensions(productId, selectedColor.getId(), size, null);
        String sku = skuFor(productId, selectedColor.getColorCode(), size);
        if (variantRepository.existsBySkuIgnoreCase(sku)) {
            throw new BusinessException("SKU được sinh đã tồn tại; hãy chọn màu/size khác.");
        }
        ProductVariant variant = new ProductVariant();
        variant.setProduct(product);
        applyVariantRequest(variant, request, selectedColor, sku);
        variantRepository.save(variant);
        return toResponse(product);
    }

    /** Cap nhat bien the dung san pham, giu nguyen ton, hang dang giu va gia von. */
    @Override
    @Transactional
    public ProductResponse updateVariant(Integer productId, Integer variantId, ProductVariantRequest request) {
        Product product = findProduct(productId);
        ProductVariant variant = findVariant(productId, variantId);
        Color selectedColor = findActiveColor(request.getColorId());
        String size = request.getSizeCode().trim();
        checkVariantDimensions(productId, selectedColor.getId(), size, variant);
        String sku = skuFor(productId, selectedColor.getColorCode(), size);
        if (!variant.getSku().equalsIgnoreCase(sku) && variantRepository.existsBySkuIgnoreCase(sku)) {
            throw new BusinessException("SKU được sinh đã tồn tại; hãy chọn màu/size khác.");
        }
        if (!request.isActive() && variant.getReservedQuantity() > 0) {
            throw new BusinessException("Không thể tắt biến thể đang có hàng được giữ trong giỏ.");
        }
        applyVariantRequest(variant, request, selectedColor, sku);
        variantRepository.save(variant);
        return toResponse(product);
    }

    /** Them anh cho bien the, moi bien the chi co mot anh dai dien. */
    @Override
    @Transactional
    public ProductResponse addImage(Integer productId, ProductImageRequest request) {
        Product product = findProduct(productId);
        ProductVariant variant = findVariant(productId, request.getVariantId());
        boolean primary = request.isPrimary() || !imageRepository.existsByVariant_IdAndPrimaryTrue(variant.getId());
        if (primary) {
            clearPrimaryImages(variant.getId());
        }
        ProductImage image = new ProductImage();
        image.setVariant(variant);
        image.setImageUrl(request.getImageUrl().trim());
        image.setAltText(request.getAltText() == null ? "" : request.getAltText().trim());
        image.setDisplayOrder(request.getDisplayOrder());
        image.setPrimary(primary);
        imageRepository.save(image);
        return toResponse(product);
    }

    /** Sua anh va flush anh dai dien cu truoc khi chon anh moi. */
    @Override
    @Transactional
    public ProductResponse updateImage(Integer productId, Integer imageId, ProductImageRequest request) {
        Product product = findProduct(productId);
        ProductImage image = findImage(productId, imageId);
        if (!image.getVariant().getId().equals(request.getVariantId())) {
            throw new BusinessException("Không thể chuyển ảnh sang biến thể khác; hãy thêm ảnh mới.");
        }
        if (request.isPrimary() && !image.isPrimary()) {
            clearPrimaryImages(image.getVariant().getId());
            image.setPrimary(true);
        }
        // Bo checkbox tren anh dai dien khong duoc de san pham khong co anh dai dien.
        image.setImageUrl(request.getImageUrl().trim());
        image.setAltText(request.getAltText() == null ? "" : request.getAltText().trim());
        image.setDisplayOrder(request.getDisplayOrder());
        imageRepository.save(image);
        return toResponse(product);
    }

    /** Xoa anh va gan anh con lai lam dai dien neu can. */
    @Override
    @Transactional
    public ProductResponse deleteImage(Integer productId, Integer imageId) {
        Product product = findProduct(productId);
        ProductImage image = findImage(productId, imageId);
        if (product.getPublicationStatus() == PublicationStatus.ACTIVE
                && imageRepository.findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(productId).size() == 1) {
            throw new BusinessException("Không thể xóa ảnh cuối của sản phẩm đang công bố.");
        }
        Integer variantId = image.getVariant().getId();
        boolean wasPrimary = image.isPrimary();
        imageRepository.delete(image);
        imageRepository.flush();
        if (wasPrimary) {
            List<ProductImage> remaining = imageRepository.findByVariant_IdOrderByDisplayOrderAscIdAsc(variantId);
            if (!remaining.isEmpty()) {
                remaining.getFirst().setPrimary(true);
                imageRepository.save(remaining.getFirst());
            }
        }
        return toResponse(product);
    }

    /** Lay product theo ID hoac bao loi 404. */
    private Product findProduct(Integer id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sản phẩm."));
    }

    /** Kiem tra bien the thuoc dung san pham truoc khi sua. */
    private ProductVariant findVariant(Integer productId, Integer variantId) {
        return variantRepository.findById(variantId)
                .filter(variant -> variant.getProduct().getId().equals(productId))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy biến thể sản phẩm."));
    }

    /** Chi cho phep chon mau dang hoat dong trong danh muc. */
    private Color findActiveColor(Integer id) {
        Color color = colorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy màu."));
        if (!color.isActive()) {
            throw new BusinessException("Màu đã ngừng hoạt động.");
        }
        return color;
    }

    /** Kiem tra anh thuoc dung san pham truoc khi sua hoac xoa. */
    private ProductImage findImage(Integer productId, Integer imageId) {
        return imageRepository.findById(imageId)
                .filter(image -> image.getVariant().getProduct().getId().equals(productId))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ảnh sản phẩm."));
    }

    /** Chi cho phep brand dang hoat dong duoc gan cho san pham. */
    private Brand findBrand(Integer id) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thương hiệu."));
        if (!brand.isActive()) {
            throw new BusinessException("Thương hiệu đã ngừng hoạt động.");
        }
        return brand;
    }

    /** Chi cho phep category dang hoat dong duoc gan cho san pham. */
    private Category findCategory(Integer id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục."));
        if (!category.isActive()) {
            throw new BusinessException("Danh mục đã ngừng hoạt động.");
        }
        return category;
    }

    /** Kiem tra slug va style code, bo qua gia tri cua chinh san pham khi sua. */
    private void checkUnique(ProductRequest request, Product current) {
        String slug = request.getSlug().trim();
        if ((current == null || !current.getSlug().equalsIgnoreCase(slug))
                && productRepository.existsBySlugIgnoreCase(slug)) {
            throw new BusinessException("Slug sản phẩm đã tồn tại.");
        }
        String style = request.getStyleCode() == null ? "" : request.getStyleCode().trim();
        if (!style.isEmpty() && (current == null || current.getStyleCode() == null
                || !current.getStyleCode().equalsIgnoreCase(style))
                && productRepository.existsByStyleCodeIgnoreCase(style)) {
            throw new BusinessException("Mã mẫu sản phẩm đã tồn tại.");
        }
    }

    /** Bien the chi duoc co mot to hop mau va size trong mot san pham. */
    private void checkVariantDimensions(Integer productId, Integer colorId, String size, ProductVariant current) {
        if (current != null && current.getColor().getId().equals(colorId)
                && current.getSizeCode().equalsIgnoreCase(size)) {
            return;
        }
        if (variantRepository.existsByProduct_IdAndColor_IdAndSizeCodeIgnoreCase(
                productId, colorId, size)) {
            throw new BusinessException("Tổ hợp màu và kích cỡ đã tồn tại.");
        }
    }

    /** Sinh SKU on dinh tu khoa chinh va kich thuoc, tranh phu thuoc ten mau co dau. */
    private String skuFor(Integer productId, String color, String size) {
        String raw = "P" + productId + "-" + slugToken(color) + "-" + slugToken(size);
        if (raw.length() > 100) {
            throw new BusinessException("Màu và kích cỡ quá dài để sinh SKU.");
        }
        return raw;
    }

    /** Bo dau va ky tu dac biet de SKU chi chua chu, so va dau gach ngang. */
    private String slugToken(String value) {
        String ascii = Normalizer.normalize(value.replace('đ', 'd').replace('Đ', 'D'),
                Normalizer.Form.NFD).replaceAll("\\p{M}+", "");
        String token = ascii.toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9]+", "-")
                .replaceAll("^-|-$", "");
        if (token.isEmpty()) {
            throw new BusinessException("Màu hoặc kích cỡ không thể dùng để sinh SKU.");
        }
        return token;
    }

    /** Ghi cac truong catalog cua bien the, khong sua so luong ton va gia von. */
    private void applyVariantRequest(ProductVariant variant, ProductVariantRequest request, Color color, String sku) {
        variant.setSku(sku);
        variant.setColor(color);
        variant.setSizeCode(request.getSizeCode().trim());
        variant.setSalePrice(request.getSalePrice());
        variant.setLowStockThreshold(request.getLowStockThreshold());
        variant.setActive(request.isActive());
    }

    /** Go bo anh dai dien cu truoc khi ghi anh moi de tranh UNIQUE conflict. */
    private void clearPrimaryImages(Integer variantId) {
        List<ProductImage> images = imageRepository.findByVariant_IdOrderByDisplayOrderAscIdAsc(variantId);
        for (ProductImage image : images) {
            if (image.isPrimary()) {
                image.setPrimary(false);
            }
        }
        imageRepository.saveAllAndFlush(images);
    }

    /** Gom cac thanh phan catalog thanh DTO dung chung cho view. */
    private ProductResponse toResponse(Product product) {
        ProductResponse response = productMapper.toResponse(product);
        List<ProductVariantResponse> variants = variantRepository.findByProduct_IdOrderByIdAsc(product.getId())
                .stream().map(productMapper::toVariantResponse).toList();
        List<ProductImageResponse> images = imageRepository.findByVariant_Product_IdOrderByVariant_IdAscDisplayOrderAscIdAsc(
                product.getId()).stream().map(productMapper::toImageResponse).toList();
        response.setVariants(variants);
        response.setImages(images);
        response.setLowestPrice(variants.stream().filter(ProductVariantResponse::isActive)
                .map(ProductVariantResponse::getSalePrice).min(java.math.BigDecimal::compareTo).orElse(null));
        response.setAvailable(product.getPublicationStatus() == PublicationStatus.ACTIVE
                && variants.stream().anyMatch(v -> v.isActive() && v.getAvailableQuantity() > 0));
        response.setPrimaryImageUrl(images.stream().filter(ProductImageResponse::isPrimary)
                .map(ProductImageResponse::getImageUrl).findFirst().orElse(null));
        return response;
    }

    /** Loai gia von, ton noi bo va bien the da tat khoi DTO cua storefront. */
    private ProductResponse toPublicResponse(Product product) {
        ProductResponse response = toResponse(product);
        List<ProductVariantResponse> publicVariants = response.getVariants().stream()
                .filter(ProductVariantResponse::isActive)
                .map(variant -> {
                    ProductVariantResponse publicVariant = new ProductVariantResponse();
                    publicVariant.setId(variant.getId());
                    publicVariant.setSku(variant.getSku());
                    publicVariant.setColorId(variant.getColorId());
                    publicVariant.setColorCode(variant.getColorCode());
                    publicVariant.setColorName(variant.getColorName());
                    publicVariant.setSizeCode(variant.getSizeCode());
                    publicVariant.setSalePrice(variant.getSalePrice());
                    publicVariant.setAvailableQuantity(variant.getAvailableQuantity());
                    publicVariant.setActive(true);
                    return publicVariant;
                }).toList();
        response.setVariants(publicVariants);
        Set<Integer> visibleVariantIds = publicVariants.stream()
                .map(ProductVariantResponse::getId).collect(Collectors.toSet());
        List<ProductImageResponse> publicImages = response.getImages().stream()
                .filter(image -> visibleVariantIds.contains(image.getVariantId())).toList();
        response.setImages(publicImages);
        response.setPrimaryImageUrl(publicImages.stream().filter(ProductImageResponse::isPrimary)
                .map(ProductImageResponse::getImageUrl).findFirst().orElse(null));
        return response;
    }

    /** Chuan hoa truong van ban tuy chon truoc khi luu. */
    private void normalize(Product product) {
        product.setProductName(product.getProductName().trim());
        product.setSlug(product.getSlug().trim());
        product.setStyleCode(blankToNull(product.getStyleCode()));
        product.setDescription(blankToNull(product.getDescription()));
    }

    /** Chuyen chuoi rong thanh NULL. */
    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    /** Chuan hoa tu khoa tim kiem, tranh NULL trong JPQL. */
    private String cleanKeyword(String keyword) {
        return SearchInput.keyword(keyword);
    }

    /** Khong cho page am va gioi han moi trang 12 san pham. */
    private PageRequest pageRequest(int page) {
        return PageRequest.of(SearchInput.page(page), 12, Sort.by("id").descending());
    }
}

