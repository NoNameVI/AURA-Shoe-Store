package com.aura.store.dto.response;

import java.util.List;

/**
 * Framework-independent pagination response.
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
}

