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
 * Minimal JPA skeleton for the brands table.
 * Business fields and associations are added with the feature implementation.
 * TODO: Người phụ trách: Minh Thức.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "brands")
public class Brand extends TimestampedEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "brand_id", nullable = false)
    private Integer id;

    @Column(name = "brand_name", nullable = false, length = 150)
    private String brandName;

    @Column(name = "slug", nullable = false, length = 160)
    private String slug;

    @Column(name = "description", length = 1000)
    private String description;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;
}

