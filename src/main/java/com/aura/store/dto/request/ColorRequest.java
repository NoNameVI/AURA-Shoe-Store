package com.aura.store.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/** Du lieu form tao va sua mau trong danh muc. */
@Getter
@Setter
public class ColorRequest {
    @NotBlank(message = "Ma mau khong duoc de trong")
    @Size(max = 12)
    @Pattern(regexp = "[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*", message = "Ma mau chi gom chu, so va dau gach ngang")
    private String colorCode;

    @NotBlank(message = "Ten mau khong duoc de trong")
    @Size(max = 50)
    private String colorName;

    @Pattern(regexp = "^$|#[0-9A-Fa-f]{6}", message = "Ma mau phai co dang #RRGGBB")
    private String hexCode;

    private boolean active = true;
}
