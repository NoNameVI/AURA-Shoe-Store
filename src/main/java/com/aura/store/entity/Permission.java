package com.aura.store.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Minimal JPA skeleton for the permissions table.
 * Business fields and associations are added with the feature implementation.
 * TODO: Người phụ trách: Khả Nhân, Minh Thức.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "permissions")
public class Permission extends TimestampedEntity {

    @Id
    @Column(name = "permission_key", nullable = false)
    private String id;
}

