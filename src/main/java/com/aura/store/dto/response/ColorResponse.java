package com.aura.store.dto.response;

import lombok.Getter;
import lombok.Setter;

/** Du lieu mau hien thi trong danh sach va o chon bien the. */
@Getter
@Setter
public class ColorResponse {
    private Integer id;
    private String colorCode;
    private String colorName;
    private String hexCode;
    private boolean active;
}
