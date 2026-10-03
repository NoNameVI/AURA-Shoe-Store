package com.aura.store.controller;

import com.aura.store.controller.management.CatalogManagementController;
import com.aura.store.controller.storefront.HomeController;
import com.aura.store.controller.storefront.ProductController;
import com.aura.store.config.CatalogMethodSecurityConfig;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.dto.response.ProductVariantResponse;
import com.aura.store.dto.response.BrandResponse;
import com.aura.store.dto.response.CategoryResponse;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.service.BrandService;
import com.aura.store.service.CategoryService;
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
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;

@WebMvcTest({CatalogManagementController.class, ProductController.class, HomeController.class})
@AutoConfigureMockMvc
@Import(CatalogMethodSecurityConfig.class)
@WithMockUser(authorities = {"ROLE_WAREHOUSE", "catalog.read", "catalog.manage"})
class CatalogViewTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private BrandService brandService;

    @MockitoBean
    private CategoryService categoryService;

    @MockitoBean
    private ProductService productService;

    /** Kiem tra trang danh sach quan tri duoc render tu DTO, khong can database. */
    @Test
    void managementListsRender() throws Exception {
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        when(categoryService.search(any(), anyInt())).thenReturn(Page.empty());
        when(brandService.activeBrands()).thenReturn(List.of());
        when(categoryService.activeCategories()).thenReturn(List.of());
        when(productService.searchManagement(any(), isNull(), isNull(), isNull(), anyInt()))
                .thenReturn(Page.empty());

        mockMvc.perform(get("/management/brands")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Thêm thương hiệu")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"_csrf\"")));
        mockMvc.perform(get("/management/categories")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Danh mục sản phẩm")));
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
        variant.setSku("P1-DO-40");
        variant.setColorName("Đỏ");
        variant.setSizeCode("40");
        variant.setSalePrice(BigDecimal.valueOf(100));
        variant.setCostPrice(BigDecimal.valueOf(50));
        variant.setActive(true);
        product.setVariants(List.of(variant));
        when(productService.getManagement(1)).thenReturn(product);

        mockMvc.perform(get("/management/products/1")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("P1-DO-40")));
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

    /** Nguoi chi co quyen doc khong duoc thay doi du lieu catalog. */
    @Test
    @WithMockUser(authorities = {"ROLE_SALES", "catalog.read"})
    void readOnlyStaffCannotCreateBrand() throws Exception {
        when(brandService.search(any(), anyInt())).thenReturn(Page.empty());
        mockMvc.perform(get("/management/brands")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.not(
                        org.hamcrest.Matchers.containsString("Thêm thương hiệu"))));
        mockMvc.perform(post("/management/brands")
                        .with(csrf())
                        .param("brandName", "AURA")
                        .param("slug", "aura"))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/management/brands/3/edit")).andExpect(status().isForbidden());
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
