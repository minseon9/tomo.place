package dev.ian.mapa.member.infra.repositories

import MemberEntity
import RepositoryInterface

class MemberRepository: RepositoryInterface<MemberEntity> {
    override var entities: ArrayList<MemberEntity> = arrayListOf()

    fun findByEmail(email: String): MemberEntity? {
        return entities.find { it.email == email }
    }
}
