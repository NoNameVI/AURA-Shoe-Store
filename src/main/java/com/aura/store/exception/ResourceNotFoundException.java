package com.aura.store.exception;

/**
 * Raised when a requested business resource does not exist or is not visible to
 * the current account.
 */
public class ResourceNotFoundException extends BusinessException {

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
