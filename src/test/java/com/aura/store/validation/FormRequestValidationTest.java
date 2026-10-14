package com.aura.store.validation;

import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.request.ColorRequest;
import com.aura.store.dto.request.ProductImageRequest;
import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.request.SupplierRequest;
import com.aura.store.exception.BusinessException;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.math.BigDecimal;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Kiem tra hop dong dau vao o ranh gioi DTO truoc khi luu du lieu. */
class FormRequestValidationTest {
    private static ValidatorFactory factory;
    private static Validator validator;

    /** Tao validator giong Bean Validation duoc MVC su dung. */
    @BeforeAll
    static void setUp() {
        factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    /** Giai phong tai nguyen cua validator sau bo test. */
    @AfterAll
    static void tearDown() {
        factory.close();
    }

    /** Danh muc chan ten, slug, cha va mo ta khong hop le. */
    @Test
    void categoryFieldsRejectInvalidValues() {
        CategoryRequest form = category();
        form.setCategoryName(" ");
        assertInvalid(form, "categoryName");
        form.setCategoryName("x".repeat(151));
        assertInvalid(form, "categoryName");
        form.setCategoryName("Giay chay");
        form.setSlug("Bad Slug");
        assertInvalid(form, "slug");
        form.setSlug("running");
        form.setParentId(-1);
        assertInvalid(form, "parentId");
        form.setParentId(null);
        form.setDescription("x".repeat(1001));
        assertInvalid(form, "description");
        form.setDescription("x".repeat(1000));
        assertValid(form);
    }

    /** Thuong hieu chan URL gia va chap nhan URL noi bo hop le. */
    @Test
    void brandLogoRejectsMalformedUrls() {
        BrandRequest form = brand();
        form.setLogoUrl("https://");
        assertInvalid(form, "logoUrl");
        form.setLogoUrl("/images/../secret.png");
        assertInvalid(form, "logoUrl");
        form.setLogoUrl("/images/demo/logo.png");
        assertValid(form);
        form.setLogoUrl(null);
        assertValid(form);
    }

    /** San pham yeu cau ID duong va mo ta khong vuot gioi han. */
    @Test
    void productFieldsRejectInvalidValues() {
        ProductRequest form = product();
        form.setProductName(" ");
        assertInvalid(form, "productName");
        form.setProductName("Giay chay");
        form.setSlug("x".repeat(201));
        assertInvalid(form, "slug");
        form.setSlug("running-shoe");
        form.setBrandId(0);
        assertInvalid(form, "brandId");
        form.setBrandId(3);
        form.setCategoryId(-1);
        assertInvalid(form, "categoryId");
        form.setCategoryId(4);
        form.setStyleCode("x".repeat(101));
        assertInvalid(form, "styleCode");
        form.setStyleCode(null);
        form.setDescription("x".repeat(3001));
        assertInvalid(form, "description");
    }

    /** Gia ban khop DECIMAL(12,2), so thieu va so am deu bi chan. */
    @Test
    void variantPriceAndThresholdMatchDatabase() {
        ProductVariantRequest form = variant();
        form.setSalePrice(new BigDecimal("10000000000.00"));
        assertInvalid(form, "salePrice");
        form.setSalePrice(new BigDecimal("9999999999.99"));
        assertValid(form);
        form.setSalePrice(new BigDecimal("1.001"));
        assertInvalid(form, "salePrice");
        form.setSalePrice(BigDecimal.ZERO);
        form.setLowStockThreshold(null);
        assertInvalid(form, "lowStockThreshold");
        form.setLowStockThreshold(-1L);
        assertInvalid(form, "lowStockThreshold");
        form.setLowStockThreshold(0L);
        assertValid(form);
    }

    /** Anh yeu cau thu tu ro rang va URL hop le. */
    @Test
    void imageFieldsRejectMissingOrderAndBadUrl() {
        ProductImageRequest form = image();
        form.setDisplayOrder(null);
        assertInvalid(form, "displayOrder");
        form.setDisplayOrder(32768);
        assertInvalid(form, "displayOrder");
        form.setDisplayOrder(0);
        form.setImageUrl("http://");
        assertInvalid(form, "imageUrl");
        form.setImageUrl("/images/demo/shoe.png");
        assertValid(form);
    }

    /** Ma mau, ten mau va HEX sai khong duoc ghi. */
    @Test
    void colorFieldsRejectInvalidValues() {
        ColorRequest form = color();
        form.setColorCode("bad code");
        assertInvalid(form, "colorCode");
        form.setColorCode("RED");
        form.setColorName(" ");
        assertInvalid(form, "colorName");
        form.setColorName("Do");
        form.setHexCode("#12ZZZZ");
        assertInvalid(form, "hexCode");
        form.setHexCode("#AABBCC");
        assertValid(form);
    }

    /** Email, so dien thoai va ma so thue duoc kiem tra doc lap. */
    @Test
    void supplierContactFieldsRejectInvalidValues() {
        SupplierRequest form = supplier();
        form.setSupplierCode(" ");
        assertInvalid(form, "supplierCode");
        form.setSupplierCode("SUP-001");
        form.setSupplierName("x".repeat(181));
        assertInvalid(form, "supplierName");
        form.setSupplierName("Supplier");
        form.setEmail("not-an-email");
        assertInvalid(form, "email");
        form.setEmail("x".repeat(250) + "@example.com");
        assertInvalid(form, "email");
        form.setEmail("a@example.com");
        form.setPhone("12345");
        assertInvalid(form, "phone");
        form.setPhone("0901234567");
        assertValid(form);
        form.setPhone("+84901234567");
        assertValid(form);
        form.setTaxCode("123");
        assertInvalid(form, "taxCode");
        form.setTaxCode("0123456789-001");
        assertValid(form);
        form.setEmail(null);
        form.setPhone(null);
        assertValid(form);
    }

    /** Chan truy van qua dai hoac trang qua lon truoc khi goi repository. */
    @Test
    void searchInputsHaveSafeBounds() {
        assertTrue(SearchInput.keyword("  shoes  ").equals("shoes"));
        assertThrows(BusinessException.class, () -> SearchInput.keyword("x".repeat(101)));
        assertTrue(SearchInput.page(-1) == 0);
        assertThrows(BusinessException.class, () -> SearchInput.page(10001));
    }

    /** Tim loi cua dung truong can kiem tra. */
    private void assertInvalid(Object form, String field) {
        assertTrue(validator.validate(form).stream()
                .anyMatch(violation -> violation.getPropertyPath().toString().equals(field)), field);
    }

    /** Xac nhan form hop le khong con loi. */
    private void assertValid(Object form) {
        assertFalse(validator.validate(form).iterator().hasNext());
    }

    /** Tao danh muc hop le cho cac gia tri bien. */
    private CategoryRequest category() {
        CategoryRequest form = new CategoryRequest();
        form.setCategoryName("Giay chay");
        form.setSlug("running");
        return form;
    }

    /** Tao thuong hieu hop le. */
    private BrandRequest brand() {
        BrandRequest form = new BrandRequest();
        form.setBrandName("AURA");
        form.setSlug("aura");
        return form;
    }

    /** Tao san pham hop le. */
    private ProductRequest product() {
        ProductRequest form = new ProductRequest();
        form.setProductName("Giay chay");
        form.setSlug("running-shoe");
        form.setBrandId(3);
        form.setCategoryId(4);
        return form;
    }

    /** Tao bien the hop le. */
    private ProductVariantRequest variant() {
        ProductVariantRequest form = new ProductVariantRequest();
        form.setColorId(1);
        form.setSizeCode("40");
        form.setSalePrice(new BigDecimal("100.00"));
        form.setLowStockThreshold(5L);
        return form;
    }

    /** Tao anh hop le. */
    private ProductImageRequest image() {
        ProductImageRequest form = new ProductImageRequest();
        form.setVariantId(7);
        form.setImageUrl("/images/demo/shoe.png");
        form.setDisplayOrder(0);
        return form;
    }

    /** Tao mau hop le. */
    private ColorRequest color() {
        ColorRequest form = new ColorRequest();
        form.setColorCode("RED");
        form.setColorName("Do");
        return form;
    }

    /** Tao nha cung cap hop le. */
    private SupplierRequest supplier() {
        SupplierRequest form = new SupplierRequest();
        form.setSupplierCode("SUP-001");
        form.setSupplierName("Supplier");
        return form;
    }
}
