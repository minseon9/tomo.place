package dev.ian.mapa.infra.repositories.repository

import dev.ian.mapa.domain.entities.MemberEntity
import dev.ian.mapa.infra.repositories.MemberRepository
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface JpaMemberRepository : MemberRepository, JpaRepository<MemberEntity, Long> {
    override fun findByEmail(email: String): MemberEntity?
} 