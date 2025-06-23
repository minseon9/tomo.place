package dev.ian.mapa.member.application.services

import MemberEntity
import dev.ian.mapa.member.infra.repositories.MemberRepository
import dev.ian.mapa.member.application.requests.SignUpRequest

class MemberDomainService {
    // Composition을 사용할 때, Slave DB를 사용한다면 처리는? 조회할 때 항상 boolean으로 받아야하나 ? Slave 용 repo를 별도로 ?
    private val repository = MemberRepository()


    fun create_member(request: SignUpRequest) {
        val member = repository.findByEmail(request.email)
        if (member != null) {
            throw Exception()
        }

        repository.save(MemberEntity(request.name, request.email, request.password))
        return
    }
}