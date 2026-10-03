package com.aura.store.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Minimal JPA skeleton for the inventory_transactions table.
 * Business fields and associations are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức, Mai Thanh.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "inventory_transactions")
public class InventoryTransaction extends CreatedAtEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_transaction_id", nullable = false)
    private Long id;
}

