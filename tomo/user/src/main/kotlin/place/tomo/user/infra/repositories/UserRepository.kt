package place.tomo.user.infra.repositories

import org.springframework.data.jpa.repository.JpaRepository
import place.tomo.user.domain.entities.UserEntity
import java.util.UUID

interface UserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmailAndDeletedAtIsNull(email: String): UserEntity?

    fun findByEntityIdAndDeletedAtIsNull(entityId: UUID): UserEntity?

    fun findByEmail(email: String): UserEntity?

    fun existsByEntityIdAndDeletedAtIsNull(entityId: UUID): Boolean
}
