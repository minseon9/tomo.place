package dev.ian.mapa.application.services

import dev.ian.mapa.domain.entities.MemberEntity
import dev.ian.mapa.infra.repositories.MemberRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class MemberService(
    private val memberRepository: MemberRepository,
    private val passwordEncoder: PasswordEncoder
) {
    data class SignUpCommand(
        val email: String,
        val password: String,
        val name: String
    )

    data class MemberInfo( val id: Long?,
        val email: String,
        val name: String
    ) {
        companion object {
            fun from(member: MemberEntity) = MemberInfo(
                id = member.id,
                email = member.email,
                name = member.name
            )
        }
    }

    @Transactional
    fun signUp(command: SignUpCommand): MemberInfo {
        if (memberRepository.findByEmail(command.email) != null) {
            throw IllegalArgumentException("이미 존재하는 이메일입니다.")
        }

        val member = MemberEntity(
            email = command.email,
            password = passwordEncoder.encode(command.password),
            name = command.name
        )

        return MemberInfo.from(memberRepository.save(member))
    }

    fun findByEmail(email: String): MemberEntity? {
        return memberRepository.findByEmail(email)
    }
}