package com.aura.store.controller;

import com.aura.store.controller.management.CatalogManagementController;
import com.aura.store.controller.management.ColorManagementController;
import com.aura.store.controller.storefront.HomeController;
import com.aura.store.controller.storefront.CategoryController;
import com.aura.store.controller.storefront.ProductController;
import com.aura.store.config.CatalogMethodSecurityConfig;
import com.aura.store.security.SecurityConfig;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.dto.response.BrandResponse;
import com.aura.store.dto.response.CategoryResponse;
import com.aura.store.dto.response.ColorResponse;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.service.BrandService;
import com.aura.store.service.CategoryService;
import com.aura.store.service.ColorService;
import com.aura.store.service.ProductService;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.security.test.context.support.WithAnonymousUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;

@WebMvcTest({CatalogManagementController.class, ColorManagementController.class,
        ProductController.class, CategoryController.class, HomeController.class})
@AutoConfigureMockMvc
@Import({CatalogMethodSecurityConfig.class, SecurityConfig.class})
@WithMockUser(authorities = {"ROLE_SALES", "catalog.read", "catalog.manage"})
class CatalogViewTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private BrandService brandService;

    @MockitoBean
    private CategoryService categoryService;

    @MockitoBean
    private ProductService productService;

    @MockitoBean
    private ColorService colorService;

    /** Kiem tra trang danh sach quan tri duoc render tu DTO, khong can database. */
    @Test
    void managementListsRender() throws Exception {
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        when(colorService.search(any(), anyInt())).thenReturn(Page.empty());
        when(brandService.activeBrands()).thenReturn(List.of());
        when(categoryService.activeCategories()).thenReturn(List.of());
        when(productService.searchManagement(any(), isNull(), isNull(), isNull(), anyInt()))
                .thenReturn(Page.empty());

        mockMvc.perform(get("/management/brands")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Thêm thương hiệu")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"_csrf\"")));
        mockMvc.perform(get("/management/categories")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Danh mục sản phẩm")));
        mockMvc.perform(get("/management/colors")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"colorCode\"")));
        mockMvc.perform(get("/management/products")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Thêm sản phẩm")));
        mockMvc.perform(get("/management/products/new")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Tạo sản phẩm")));
    }

    /** Kiem tra trang chi tiet va form bien the co the render khi co du lieu. */
    @Test
    void managementProductDetailRendersVariantForm() throws Exception {
        ProductResponse product = product();
        ProductVariantResponse variant = new ProductVariantResponse();
        variant.setId(7);
        variant.setColorId(1);
        variant.setSku("P1-DO-40");
        variant.setColorName("Đỏ");
        variant.setSizeCode("40");
        variant.setSalePrice(BigDecimal.valueOf(100));
        variant.setCostPrice(BigDecimal.valueOf(50));
        variant.setActive(true);
        product.setVariants(List.of(variant));
        when(productService.getManagement(1)).thenReturn(product);
        ColorResponse color = new ColorResponse();
        color.setId(1);
        color.setColorCode("RED");
        color.setColorName("Đỏ");
        color.setActive(true);
        when(colorService.activeColors()).thenReturn(List.of(color));

        mockMvc.perform(get("/management/products/1")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("P1-DO-40")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"colorId\"")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"variantId\"")))
                .andExpect(content().string(org.hamcrest.Matchers.not(
                        org.hamcrest.Matchers.containsString("name=\"costPrice\""))));
    }

    /** Kiem tra cac form sua render dung du lieu da luu. */
    @Test
    void editFormsRender() throws Exception {
        BrandResponse brand = new BrandResponse();
        brand.setId(3);
        brand.setBrandName("AURA");
        brand.setSlug("aura");
        CategoryResponse category = new CategoryResponse();
        category.setId(4);
        category.setCategoryName("Giày chạy");
        category.setSlug("giay-chay");
        when(brandService.get(3)).thenReturn(brand);
        when(categoryService.get(4)).thenReturn(category);
        when(productService.getManagement(1)).thenReturn(product());
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        when(brandService.activeBrands()).thenReturn(List.of(brand));
        when(categoryService.activeCategories()).thenReturn(List.of(category));
        when(categoryService.allCategories()).thenReturn(List.of(category));

        mockMvc.perform(get("/management/brands/3/edit")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("aura")));
        mockMvc.perform(get("/management/categories/4/edit")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("giay-chay")));
        mockMvc.perform(get("/management/products/1/edit")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("giay-thu-nghiem")));
    }

    /** Kiem tra storefront chi hien thi san pham DTO do service cung cap. */
    @Test
    void storefrontPagesRender() throws Exception {
        ProductResponse publicProduct = product();
        ProductVariantResponse publicVariant = new ProductVariantResponse();
        publicVariant.setSku("P1-DO-40");
        publicVariant.setSizeCode("40");
        publicVariant.setColorName("Đỏ");
        publicVariant.setSalePrice(BigDecimal.valueOf(100));
        publicVariant.setAvailableQuantity(3);
        publicVariant.setActive(true);
        publicProduct.setVariants(List.of(publicVariant));
        publicProduct.setLowestPrice(BigDecimal.valueOf(100));
        when(productService.searchPublished(any(), isNull(), isNull(), anyInt()))
                .thenReturn(new PageImpl<>(List.of(publicProduct)));
        when(brandService.activeBrands()).thenReturn(List.of());
        when(categoryService.activeCategories()).thenReturn(List.of());
        when(productService.getPublished(1)).thenReturn(publicProduct);

        mockMvc.perform(get("/")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Mỗi bước đi")));
        mockMvc.perform(get("/products")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Khám phá giày")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Từ 100 ₫")));
        mockMvc.perform(get("/products/1")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Giày thử nghiệm")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("shop-size-option")));
    }

    /** Kho chi xem Category/Brand, khong duoc tao hay vao quan tri Product. */
    @Test
    @WithMockUser(authorities = {"ROLE_WAREHOUSE", "catalog.read"})
    void warehouseCanReadCategoriesAndBrandsButCannotManageProducts() throws Exception {
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(get("/management/brands")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.not(
                        org.hamcrest.Matchers.containsString("Thêm thương hiệu"))));
        mockMvc.perform(get("/management/categories")).andExpect(status().isOk());
        mockMvc.perform(get("/management/products")).andExpect(status().isForbidden());
        mockMvc.perform(post("/management/brands")
                        .with(csrf())
                        .param("brandName", "AURA")
                        .param("slug", "aura"))
                .andExpect(status().isForbidden());
        mockMvc.perform(post("/management/categories").with(csrf())
                        .param("categoryName", "Giày chạy").param("slug", "running"))
                .andExpect(status().isForbidden());
        mockMvc.perform(post("/management/products").with(csrf())
                        .param("productName", "Giày thử nghiệm")
                        .param("slug", "giay-thu-nghiem")
                        .param("brandId", "3").param("categoryId", "4"))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/management/brands/3/edit")).andExpect(status().isForbidden());
    }

    /** System Admin duoc tao Category, Brand va Product theo ma tran quyen. */
    @Test
    @WithMockUser(authorities = {"ROLE_SYSTEM_ADMIN", "catalog.read", "catalog.manage"})
    void systemAdminCanCreateCatalogRecords() throws Exception {
        when(productService.create(any())).thenReturn(product());
        mockMvc.perform(post("/management/categories").with(csrf())
                        .param("categoryName", "Giày chạy").param("slug", "running"))
                .andExpect(status().is3xxRedirection());
        mockMvc.perform(post("/management/brands").with(csrf())
                        .param("brandName", "AURA").param("slug", "aura"))
                .andExpect(status().is3xxRedirection());
        mockMvc.perform(post("/management/products").with(csrf())
                        .param("productName", "Giày thử nghiệm")
                        .param("slug", "giay-thu-nghiem")
                        .param("brandId", "3").param("categoryId", "4"))
                .andExpect(status().is3xxRedirection());
    }

    /** Khach chua dang nhap co the tim va xem danh muc cong khai. */
    @Test
    @WithAnonymousUser
    void guestCanSearchPublicCategories() throws Exception {
        CategoryResponse category = new CategoryResponse();
        category.setId(4);
        category.setCategoryName("Giày chạy bộ");
        category.setSlug("running");
        category.setActive(true);
        when(categoryService.searchPublic("run", 0)).thenReturn(new PageImpl<>(List.of(category)));

        mockMvc.perform(get("/categories").param("keyword", "run"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Giày chạy bộ")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("/products?categoryId=4")));
    }

    /** DTO Category chan ten rong va slug sai truoc khi goi service. */
    @Test
    void invalidCategoryFormDoesNotSave() throws Exception {
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(post("/management/categories").with(csrf())
                        .param("categoryName", "   ").param("slug", "Bad Slug"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Ten danh muc khong duoc de trong")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Slug chi gom")));
        verify(categoryService, never()).create(any());
    }

    /** Loi do dai mo ta Category phai hien tai truong nhap. */
    @Test
    void invalidCategoryDescriptionIsVisible() throws Exception {
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(post("/management/categories").with(csrf())
                        .param("categoryName", "Giày chạy")
                        .param("slug", "running")
                        .param("description", "x".repeat(1001)))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("field-error")));
        verify(categoryService, never()).create(any());
    }

    /** Loi do dai mo ta Brand phai hien tren form, khong luu du lieu. */
    @Test
    void invalidBrandDescriptionIsVisible() throws Exception {
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(post("/management/brands").with(csrf())
                        .param("brandName", "AURA")
                        .param("slug", "aura")
                        .param("logoUrl", "ftp://invalid")
                        .param("description", "x".repeat(1001)))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Logo phai la URL")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("field-error")));
        verify(brandService, never()).create(any());
    }

    /** Form Product yeu cau brand/category va slug hop le; loi hien tai view. */
    @Test
    void invalidProductFormDoesNotSave() throws Exception {
        when(brandService.activeBrands()).thenReturn(List.of());
        when(categoryService.activeCategories()).thenReturn(List.of());
        mockMvc.perform(post("/management/products").with(csrf())
                        .param("productName", "Giày thử nghiệm")
                        .param("slug", "Sai Slug"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Vui long chon thuong hieu")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Vui long chon danh muc")));
        verify(productService, never()).create(any());
    }

    /** Kiem tra form tao san pham hop le di qua DTO va chuyen den trang chi tiet. */
    @Test
    void validProductFormRedirectsToDetail() throws Exception {
        when(productService.create(any())).thenReturn(product());

        mockMvc.perform(post("/management/products")
                        .with(csrf())
                        .param("productName", "Giày thử nghiệm")
                        .param("slug", "giay-thu-nghiem")
                        .param("brandId", "3")
                        .param("categoryId", "4"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/management/products/1"));
    }

    /** Gia ban vuot DECIMAL(12,2) khong duoc luu va van giu loi tren form. */
    @Test
    void invalidVariantRetainsFormErrorsAfterRedirect() throws Exception {
        MvcResult result = mockMvc.perform(post("/management/products/1/variants")
                        .with(csrf())
                        .param("colorId", "1")
                        .param("sizeCode", "40")
                        .param("salePrice", "10000000000.00")
                        .param("lowStockThreshold", "5"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/management/products/1"))
                .andReturn();
        verify(productService, never()).addVariant(any(), any());

        when(productService.getManagement(1)).thenReturn(product());
        when(colorService.activeColors()).thenReturn(List.of());
        mockMvc.perform(get("/management/products/1").flashAttrs(result.getFlashMap()))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Gia ban toi da 10 chu so")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("value=\"10000000000.00\"")));
    }

    /** URL anh gia khong duoc luu va thong bao xuat hien lai sau redirect. */
    @Test
    void invalidImageRetainsFormErrorsAfterRedirect() throws Exception {
        MvcResult result = mockMvc.perform(post("/management/products/1/images")
                        .with(csrf())
                        .param("variantId", "7")
                        .param("imageUrl", "/images/../secret.png")
                        .param("displayOrder", "0"))
                .andExpect(status().is3xxRedirection())
                .andReturn();
        verify(productService, never()).addImage(any(), any());

        when(productService.getManagement(1)).thenReturn(product());
        when(colorService.activeColors()).thenReturn(List.of());
        mockMvc.perform(get("/management/products/1").flashAttrs(result.getFlashMap()))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Anh phai la URL HTTP(S) hop le")));
    }

    /** Trang thai khong nam trong enum phai tra 400 thay vi 500. */
    @Test
    void invalidPublicationStatusReturnsBadRequest() throws Exception {
        mockMvc.perform(post("/management/products/1/status").with(csrf())
                        .param("status", "UNKNOWN"))
                .andExpect(status().isBadRequest());
        verify(productService, never()).changeStatus(any(), any());
    }

    /** Ma mau sai bi chan tai controller truoc khi goi service. */
    @Test
    void invalidColorFormDoesNotSave() throws Exception {
        when(colorService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(post("/management/colors").with(csrf())
                        .param("colorCode", "bad code")
                        .param("colorName", "Do")
                        .param("hexCode", "#GGGGGG"))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Ma mau chi gom")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("#RRGGBB")));
        verify(colorService, never()).create(any());
    }

    /** Trang khong phai so duoc tra 400 co thong bao ro rang. */
    @Test
    void invalidPageParameterReturnsBadRequest() throws Exception {
        mockMvc.perform(get("/categories").param("page", "abc"))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Tham so gui len khong hop le")));
    }

    /** Tao DTO toi thieu de kiem tra viec ket noi model voi view. */
    private ProductResponse product() {
        ProductResponse product = new ProductResponse();
        product.setId(1);
        product.setProductName("Giày thử nghiệm");
        product.setBrandName("AURA");
        product.setCategoryName("Giày chạy");
        product.setSlug("giay-thu-nghiem");
        product.setPublicationStatus(PublicationStatus.ACTIVE);
        return product;
    }
}
