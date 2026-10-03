package com.aura.store.controller.management;

import com.aura.store.dto.request.BrandRequest;
import com.aura.store.dto.request.CategoryRequest;
import com.aura.store.dto.request.ProductImageRequest;
import com.aura.store.dto.request.ProductRequest;
import com.aura.store.dto.request.ProductVariantRequest;
import com.aura.store.dto.response.BrandResponse;
import com.aura.store.dto.response.CategoryResponse;
import com.aura.store.dto.response.ProductResponse;
import com.aura.store.enums.PublicationStatus;
import com.aura.store.exception.BusinessException;
import com.aura.store.service.BrandService;
import com.aura.store.service.CategoryService;
import com.aura.store.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
@PreAuthorize("hasAuthority('catalog.read')")
// TODO: Người phụ trách: Minh Thức.
public class CatalogManagementController {
    private final BrandService brandService;
    private final CategoryService categoryService;
    private final ProductService productService;

    /** Hien danh sach san pham voi bo loc va phan trang. */
    @GetMapping("/management/products")
    public String productListPage(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) Integer brandId,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) PublicationStatus status,
            @RequestParam(defaultValue = "0") int page, Model model) {
        model.addAttribute("products", productService.searchManagement(keyword, brandId, categoryId, status, page));
        model.addAttribute("brands", brandService.activeBrands());
        model.addAttribute("categories", categoryService.activeCategories());
        model.addAttribute("statuses", PublicationStatus.values());
        model.addAttribute("keyword", keyword);
        model.addAttribute("brandId", brandId);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("status", status);
        return "management/catalog/products";
    }

    /** Hien form tao san pham moi. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @GetMapping("/management/products/new")
    public String newProductPage(Model model) {
        model.addAttribute("productForm", new ProductRequest());
        return productFormPage(model, null);
    }

    /** Hien form sua thong tin chung cua san pham. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @GetMapping("/management/products/{id}/edit")
    public String editProductPage(@PathVariable Integer id, Model model) {
        model.addAttribute("productForm", productRequestOf(productService.getManagement(id)));
        return productFormPage(model, id);
    }

    /** Tao san pham DRAFT va chuyen den trang quan ly bien the, anh. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products")
    public String createProduct(@Valid @ModelAttribute("productForm") ProductRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return productFormPage(model, null);
        }
        try {
            ProductResponse product = productService.create(form);
            redirect.addFlashAttribute("success", "Đã tạo sản phẩm.");
            return "redirect:/management/products/" + product.getId();
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return productFormPage(model, null);
        }
    }

    /** Luu thong tin chung va giu nguyen bien the, anh, ton kho. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}")
    public String updateProduct(@PathVariable Integer id,
            @Valid @ModelAttribute("productForm") ProductRequest form, BindingResult result,
            Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return productFormPage(model, id);
        }
        try {
            productService.update(id, form);
            redirect.addFlashAttribute("success", "Đã cập nhật sản phẩm.");
            return "redirect:/management/products/" + id;
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return productFormPage(model, id);
        }
    }

    /** Hien chi tiet quan tri voi danh sach bien the va anh. */
    @GetMapping("/management/products/{id}")
    public String productDetailPage(@PathVariable Integer id, Model model) {
        model.addAttribute("product", productService.getManagement(id));
        model.addAttribute("statuses", PublicationStatus.values());
        model.addAttribute("variantForm", new ProductVariantRequest());
        model.addAttribute("imageForm", new ProductImageRequest());
        return "management/catalog/product-detail";
    }

    /** Doi trang thai cong bo theo quy tac nghiep vu trong service. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/status")
    public String changeProductStatus(@PathVariable Integer id,
            @RequestParam PublicationStatus status, RedirectAttributes redirect) {
        try {
            productService.changeStatus(id, status);
            redirect.addFlashAttribute("success", "Đã đổi trạng thái sản phẩm.");
        } catch (BusinessException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/management/products/" + id;
    }

    /** Them bien the vao san pham va sinh SKU tai service. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/variants")
    public String addVariant(@PathVariable Integer id,
            @Valid @ModelAttribute("variantForm") ProductVariantRequest form,
            BindingResult result, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            redirect.addFlashAttribute("error", firstError(result));
        } else {
            try {
                productService.addVariant(id, form);
                redirect.addFlashAttribute("success", "Đã thêm biến thể.");
            } catch (BusinessException exception) {
                redirect.addFlashAttribute("error", exception.getMessage());
            }
        }
        return "redirect:/management/products/" + id;
    }

    /** Sua gia, mau, kich co va trang thai bien the. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/variants/{variantId}")
    public String updateVariant(@PathVariable Integer id, @PathVariable Integer variantId,
            @Valid @ModelAttribute ProductVariantRequest form, BindingResult result,
            RedirectAttributes redirect) {
        if (result.hasErrors()) {
            redirect.addFlashAttribute("error", firstError(result));
        } else {
            try {
                productService.updateVariant(id, variantId, form);
                redirect.addFlashAttribute("success", "Đã cập nhật biến thể.");
            } catch (BusinessException exception) {
                redirect.addFlashAttribute("error", exception.getMessage());
            }
        }
        return "redirect:/management/products/" + id;
    }

    /** Them anh tu URL va cap nhat anh dai dien neu duoc chon. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/images")
    public String addImage(@PathVariable Integer id,
            @Valid @ModelAttribute("imageForm") ProductImageRequest form,
            BindingResult result, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            redirect.addFlashAttribute("error", firstError(result));
        } else {
            try {
                productService.addImage(id, form);
                redirect.addFlashAttribute("success", "Đã thêm ảnh.");
            } catch (BusinessException exception) {
                redirect.addFlashAttribute("error", exception.getMessage());
            }
        }
        return "redirect:/management/products/" + id;
    }

    /** Sua thong tin anh va thay anh dai dien neu duoc chon. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/images/{imageId}")
    public String updateImage(@PathVariable Integer id, @PathVariable Integer imageId,
            @Valid @ModelAttribute ProductImageRequest form, BindingResult result,
            RedirectAttributes redirect) {
        if (result.hasErrors()) {
            redirect.addFlashAttribute("error", firstError(result));
        } else {
            try {
                productService.updateImage(id, imageId, form);
                redirect.addFlashAttribute("success", "Đã cập nhật ảnh.");
            } catch (BusinessException exception) {
                redirect.addFlashAttribute("error", exception.getMessage());
            }
        }
        return "redirect:/management/products/" + id;
    }

    /** Xoa anh va chon anh dai dien thay the neu can. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/products/{id}/images/{imageId}/delete")
    public String deleteImage(@PathVariable Integer id, @PathVariable Integer imageId,
            RedirectAttributes redirect) {
        try {
            productService.deleteImage(id, imageId);
            redirect.addFlashAttribute("success", "Đã xóa ảnh.");
        } catch (BusinessException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/management/products/" + id;
    }

    /** Hien danh sach danh muc va form tao moi. */
    @GetMapping("/management/categories")
    public String categoryListPage(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page, Model model) {
        return renderCategories(keyword, page, model);
    }

    /** Hien form sua danh muc voi du lieu da co. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @GetMapping("/management/categories/{id}/edit")
    public String editCategoryPage(@PathVariable Integer id, Model model) {
        model.addAttribute("categoryForm", categoryRequestOf(categoryService.get(id)));
        model.addAttribute("editId", id);
        return renderCategories("", 0, model);
    }

    /** Tao danh muc sau khi kiem tra validation va chu trinh cha con. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/categories")
    public String createCategory(@Valid @ModelAttribute("categoryForm") CategoryRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return renderCategories("", 0, model);
        }
        try {
            categoryService.create(form);
            redirect.addFlashAttribute("success", "Đã tạo danh mục.");
            return "redirect:/management/categories";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderCategories("", 0, model);
        }
    }

    /** Cap nhat danh muc va giu nguyen lien ket san pham. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/categories/{id}")
    public String updateCategory(@PathVariable Integer id,
            @Valid @ModelAttribute("categoryForm") CategoryRequest form, BindingResult result,
            Model model, RedirectAttributes redirect) {
        model.addAttribute("editId", id);
        if (result.hasErrors()) {
            return renderCategories("", 0, model);
        }
        try {
            categoryService.update(id, form);
            redirect.addFlashAttribute("success", "Đã cập nhật danh mục.");
            return "redirect:/management/categories";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderCategories("", 0, model);
        }
    }

    /** Xoa danh muc neu khong co con hoac san pham. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/categories/{id}/delete")
    public String deleteCategory(@PathVariable Integer id, RedirectAttributes redirect) {
        try {
            categoryService.delete(id);
            redirect.addFlashAttribute("success", "Đã xóa danh mục.");
        } catch (BusinessException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/management/categories";
    }

    /** Hien danh sach thuong hieu va form tao moi. */
    @GetMapping("/management/brands")
    public String brandListPage(@RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page, Model model) {
        return renderBrands(keyword, page, model);
    }

    /** Hien du lieu thuong hieu can sua trong form. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @GetMapping("/management/brands/{id}/edit")
    public String editBrandPage(@PathVariable Integer id, Model model) {
        model.addAttribute("brandForm", brandRequestOf(brandService.get(id)));
        model.addAttribute("editId", id);
        return renderBrands("", 0, model);
    }

    /** Tao thuong hieu moi. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/brands")
    public String createBrand(@Valid @ModelAttribute("brandForm") BrandRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return renderBrands("", 0, model);
        }
        try {
            brandService.create(form);
            redirect.addFlashAttribute("success", "Đã tạo thương hiệu.");
            return "redirect:/management/brands";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderBrands("", 0, model);
        }
    }

    /** Cap nhat thuong hieu theo ID. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/brands/{id}")
    public String updateBrand(@PathVariable Integer id, @Valid @ModelAttribute("brandForm") BrandRequest form,
            BindingResult result, Model model, RedirectAttributes redirect) {
        model.addAttribute("editId", id);
        if (result.hasErrors()) {
            return renderBrands("", 0, model);
        }
        try {
            brandService.update(id, form);
            redirect.addFlashAttribute("success", "Đã cập nhật thương hiệu.");
            return "redirect:/management/brands";
        } catch (BusinessException exception) {
            model.addAttribute("error", exception.getMessage());
            return renderBrands("", 0, model);
        }
    }

    /** Xoa thuong hieu neu khong con san pham tham chieu. */
    @PreAuthorize("hasAuthority('catalog.manage')")
    @PostMapping("/management/brands/{id}/delete")
    public String deleteBrand(@PathVariable Integer id, RedirectAttributes redirect) {
        try {
            brandService.delete(id);
            redirect.addFlashAttribute("success", "Đã xóa thương hiệu.");
        } catch (BusinessException exception) {
            redirect.addFlashAttribute("error", exception.getMessage());
        }
        return "redirect:/management/brands";
    }

    /** Nap du lieu chung cho form san pham. */
    private String productFormPage(Model model, Integer id) {
        model.addAttribute("brands", brandService.activeBrands());
        model.addAttribute("categories", categoryService.activeCategories());
        model.addAttribute("editId", id);
        return "management/catalog/product-form";
    }

    /** Nap danh sach va lua chon danh muc cha, giu form khi co loi. */
    private String renderCategories(String keyword, int page, Model model) {
        model.addAttribute("categories", categoryService.search(keyword, page));
        model.addAttribute("parentOptions", categoryService.allCategories());
        model.addAttribute("keyword", keyword);
        if (!model.containsAttribute("categoryForm")) {
            model.addAttribute("categoryForm", new CategoryRequest());
        }
        return "management/catalog/categories";
    }

    /** Nap danh sach thuong hieu, giu form khi co loi. */
    private String renderBrands(String keyword, int page, Model model) {
        model.addAttribute("brands", brandService.search(keyword, page));
        model.addAttribute("keyword", keyword);
        if (!model.containsAttribute("brandForm")) {
            model.addAttribute("brandForm", new BrandRequest());
        }
        return "management/catalog/brands";
    }

    /** Sao chep DTO hien thi sang DTO form thuong hieu. */
    private BrandRequest brandRequestOf(BrandResponse response) {
        BrandRequest form = new BrandRequest();
        form.setBrandName(response.getBrandName());
        form.setSlug(response.getSlug());
        form.setDescription(response.getDescription());
        form.setLogoUrl(response.getLogoUrl());
        form.setActive(response.isActive());
        return form;
    }

    /** Sao chep DTO hien thi sang DTO form danh muc. */
    private CategoryRequest categoryRequestOf(CategoryResponse response) {
        CategoryRequest form = new CategoryRequest();
        form.setCategoryName(response.getCategoryName());
        form.setSlug(response.getSlug());
        form.setDescription(response.getDescription());
        form.setParentId(response.getParentId());
        form.setActive(response.isActive());
        return form;
    }

    /** Sao chep DTO hien thi sang DTO form san pham. */
    private ProductRequest productRequestOf(ProductResponse response) {
        ProductRequest form = new ProductRequest();
        form.setProductName(response.getProductName());
        form.setSlug(response.getSlug());
        form.setStyleCode(response.getStyleCode());
        form.setDescription(response.getDescription());
        form.setBrandId(response.getBrandId());
        form.setCategoryId(response.getCategoryId());
        return form;
    }

    /** Dua thong bao validation dau tien ve trang chi tiet. */
    private String firstError(BindingResult result) {
        return result.getAllErrors().getFirst().getDefaultMessage();
    }
}

