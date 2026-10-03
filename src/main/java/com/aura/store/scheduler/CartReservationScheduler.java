package com.aura.store.scheduler;

import com.aura.store.service.CartService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Delegates cleanup of expired cart reservations to the shopping service.
 * TODO: Người phụ trách: Thành Tài.
 */
@Component
public class CartReservationScheduler {

    private final CartService cartService;

    public CartReservationScheduler(CartService cartService) {
        this.cartService = cartService;
    }

    @Scheduled(fixedDelayString = "${aura.scheduler.cart-reservation-delay-ms:60000}")
    public void releaseExpiredReservations() {
        cartService.releaseExpiredReservations();
    }
}
