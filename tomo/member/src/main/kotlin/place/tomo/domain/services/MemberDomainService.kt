package place.tomo.domain.services

import place.tomo.domain.entities.MemberEntity
import place.tomo.infra.repositories.MemberRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class MemberDomainService(
    private val memberRepository: MemberRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    fun findByEmail(email: String): MemberEntity? {
        val member = memberRepository.findByEmail(email) ?: return null

        return member
    }

    fun createMember(
        email: String,
        rawPassword: String,
        name: String,
    ): MemberEntity {
        if (memberRepository.findByEmail(email) != null) {
            throw IllegalArgumentException("이미 존재하는 이메일입니다.")
        }

        val encodedPassword = passwordEncoder.encode(rawPassword)

        val memberEntity = MemberEntity.create(email, encodedPassword, name)
        memberRepository.save(memberEntity)

        return memberEntity
    }
}
