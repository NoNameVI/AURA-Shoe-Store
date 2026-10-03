package com.aura.store.service;

/**
 * Manages shopping-cart items, inventory reservations, and release of expired
 * reservations.
 * TODO: Người phụ trách: Thành Tài.
 */
public interface CartService {

    /**
     * Releases inventory reservations whose expiration time has passed.
     */
    void releaseExpiredReservations();
}
