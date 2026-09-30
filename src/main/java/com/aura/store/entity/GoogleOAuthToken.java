package com.aura.store.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Minimal JPA skeleton for the google_oauth_tokens table.
 * Business fields and associations are added with the feature implementation.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "google_oauth_tokens")
public class GoogleOAuthToken extends TimestampedEntity {

    @Id
    @Column(name = "account_id", nullable = false)
    private Long id;
}

