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
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** Danh muc mau dung chung cho cac bien the san pham. */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "color")
public class Color extends TimestampedEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "color_id", nullable = false)
    private Integer id;

    @Column(name = "color_code", nullable = false, length = 12)
    private String colorCode;

    @Column(name = "color_name", nullable = false, length = 50)
    private String colorName;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "hex_code", length = 7)
    private String hexCode;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;
}
