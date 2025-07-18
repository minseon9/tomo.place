package dev.ian.mapa.infra.repositories

import dev.ian.mapa.domain.entities.MemberEntity
import org.springframework.data.jpa.repository.JpaRepository

interface MemberRepository : JpaRepository<MemberEntity, Long> {
    fun findByEmail(email: String): MemberEntity?

    fun existsByEmail(email: String): Boolean
}
