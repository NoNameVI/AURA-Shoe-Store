package com.aura.store.dto.request;

import com.aura.store.validation.annotation.ValidPhoneNumber;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Input contract for the Supplier use case.
 * Fields and validation constraints are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
public class SupplierRequest {

    @NotBlank(message = "Mã nhà cung cấp không được để trống")
    @Size(max = 50, message = "Mã nhà cung cấp không được vượt quá 50 ký tự")
    private String supplierCode;

    @NotBlank(message = "Tên nhà cung cấp không được để trống")
    @Size(max = 180, message = "Tên nhà cung cấp không được vượt quá 180 ký tự")
    private String supplierName;

    @Size(max = 150, message = "Tên người liên hệ không được vượt quá 150 ký tự")
    private String contactName;

    @Size(max = 20, message = "Số điện thoại không được vượt quá 20 ký tự")
    @ValidPhoneNumber
    private String phone;

    @Size(max = 255, message = "Email không được vượt quá 255 ký tự")
    @Email(message = "Email không hợp lệ")
    private String email;

    @Size(max = 20, message = "Mã số thuế không được vượt quá 20 ký tự")
    @Pattern(regexp = "^$|^[0-9]{10}(-[0-9]{3})?$", message = "Mã số thuế phải có 10 chữ số hoặc 10 chữ số-3 chữ số")
    private String taxCode;

    @Size(max = 500, message = "Địa chỉ không được vượt quá 500 ký tự")
    private String addressText;

    private boolean active = true;

    /** Chuẩn hóa ô điện thoại tùy chọn trước khi Bean Validation chạy. */
    public void setPhone(String phone) {
        this.phone = phone == null || phone.isBlank() ? null : phone.trim();
    }
}

