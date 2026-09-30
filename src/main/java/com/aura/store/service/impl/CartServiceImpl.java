package com.aura.store.service.impl;

import com.aura.store.service.CartService;
import org.springframework.stereotype.Service;

/**
 * Default implementation shell for CartService.
 */
@Service
public class CartServiceImpl implements CartService {

    @Override
    public void releaseExpiredReservations() {
        // Implemented together with cart persistence and reservation locking.
    }
}

