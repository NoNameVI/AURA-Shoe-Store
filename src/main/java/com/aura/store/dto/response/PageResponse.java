package com.aura.store.dto.response;

import java.util.List;

/**
 * Framework-independent pagination response.
 * TODO: Người phụ trách: Minh Thức.
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
}

