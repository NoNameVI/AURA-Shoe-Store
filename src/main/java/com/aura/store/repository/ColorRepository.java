package com.aura.store.repository;

import com.aura.store.entity.Color;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Truy cap danh muc mau trong database. */
public interface ColorRepository extends JpaRepository<Color, Integer> {
    /** Tim mau theo ten de quan ly co phan trang. */
    @Query("select c from Color c where :keyword = '' or lower(c.colorName) like lower(concat('%', :keyword, '%'))")
    Page<Color> search(@Param("keyword") String keyword, Pageable pageable);

    /** Lay mau dang hoat dong cho form bien the. */
    List<Color> findByActiveTrueOrderByColorNameAsc();

    /** Chan ten mau bi trung khi tao hoac sua. */
    boolean existsByColorNameIgnoreCase(String colorName);

    /** Chan ma mau bi trung. */
    boolean existsByColorCodeIgnoreCase(String colorCode);
}
