package place.tomo.place.infra.repositories

import org.springframework.data.jpa.repository.JpaRepository
import place.tomo.place.domain.entities.PlaceFolderSettingEntity

interface PlaceFolderSettingRepository : JpaRepository<PlaceFolderSettingEntity, Long>
