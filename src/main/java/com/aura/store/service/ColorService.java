package com.aura.store.service;

import com.aura.store.dto.request.ColorRequest;
import com.aura.store.dto.response.ColorResponse;
import java.util.List;
import org.springframework.data.domain.Page;

/** Quan ly danh muc mau co the chon cho bien the. */
public interface ColorService {
    /** Tim mau trong trang quan tri. */
    Page<ColorResponse> search(String keyword, int page);

    /** Lay mau dang hoat dong cho form bien the. */
    List<ColorResponse> activeColors();

    /** Lay mot mau theo ID. */
    ColorResponse get(Integer id);

    /** Tao mau moi. */
    ColorResponse create(ColorRequest request);

    /** Sua mau chua duoc bien the tham chieu, hoac doi trang thai. */
    ColorResponse update(Integer id, ColorRequest request);

    /** Xoa mau neu chua co bien the tham chieu. */
    void delete(Integer id);
}
