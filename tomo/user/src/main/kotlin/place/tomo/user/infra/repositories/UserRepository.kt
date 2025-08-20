package place.tomo.user.infra.repositories

import org.springframework.data.jpa.repository.JpaRepository
import place.tomo.user.domain.entities.UserEntity

interface UserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmailAndDeletedAtIsNull(email: String): UserEntity?

    fun findByEmail(email: String): UserEntity?

    fun existsByEmail(email: String): Boolean
}
