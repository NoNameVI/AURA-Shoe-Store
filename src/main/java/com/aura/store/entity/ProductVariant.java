package com.aura.store.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.math.BigDecimal;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Minimal JPA skeleton for the product_variants table.
 * Business fields and associations are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "product_variants")
public class ProductVariant extends TimestampedEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "variant_id", nullable = false)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "sku", nullable = false, length = 100)
    private String sku;

    @Column(name = "color_name", nullable = false, length = 100)
    private String colorName;

    @Column(name = "size_code", nullable = false, length = 10)
    private String sizeCode;

    @Column(name = "sale_price", nullable = false, precision = 18, scale = 2)
    private BigDecimal salePrice;

    @Column(name = "cost_price", nullable = false, precision = 18, scale = 2)
    private BigDecimal costPrice = BigDecimal.ZERO;

    @Column(name = "stock_quantity", nullable = false)
    private long stockQuantity;

    @Column(name = "reserved_quantity", nullable = false)
    private long reservedQuantity;

    // Cot generated boi MySQL; ung dung chi doc, khong ghi de.
    @Column(name = "available_quantity", insertable = false, updatable = false)
    private Long availableQuantity;

    @Column(name = "low_stock_threshold", nullable = false)
    private long lowStockThreshold = 5;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;
}

