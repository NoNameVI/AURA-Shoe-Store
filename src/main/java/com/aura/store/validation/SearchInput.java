package com.aura.store.validation;

import com.aura.store.exception.BusinessException;

/** Gioi han dau vao tim kiem truoc khi tao truy van phan trang. */
public final class SearchInput {
    private static final int MAX_KEYWORD_LENGTH = 100;
    private static final int MAX_PAGE = 10000;

    private SearchInput() {
    }

    /** Loai khoang trang va chan tu khoa qua dai. */
    public static String keyword(String value) {
        String normalized = value == null ? "" : value.trim();
        if (normalized.length() > MAX_KEYWORD_LENGTH) {
            throw new BusinessException("Tu khoa tim kiem toi da 100 ky tu.");
        }
        return normalized;
    }

    /** Dua trang am ve 0 va chan trang vuot gioi han. */
    public static int page(int value) {
        if (value > MAX_PAGE) {
            throw new BusinessException("So trang vuot gioi han cho phep.");
        }
        return Math.max(0, value);
    }
}
