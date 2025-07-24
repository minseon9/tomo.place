package place.tomo.infra.repositories

import place.tomo.domain.entities.UserEntity
import org.springframework.data.jpa.repository.JpaRepository

interface UserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmail(email: String): UserEntity?

    fun existsByEmail(email: String): Boolean
} 