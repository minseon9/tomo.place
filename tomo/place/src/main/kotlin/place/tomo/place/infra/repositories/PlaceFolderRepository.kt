package place.tomo.place.infra.repositories

import org.springframework.data.jpa.repository.JpaRepository
import place.tomo.place.domain.entities.PlaceFolderEntity

interface PlaceFolderRepository : JpaRepository<PlaceFolderEntity, Long>
