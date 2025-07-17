package dev.ian.mapa.domain.entities

import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id

@Entity
class MemberEntity(
    val email: String,
    var password: String,
    var name: String,
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
) {
    companion object {
        fun create(
            email: String,
            password: String,
            name: String,
        ): MemberEntity {
            require(email.isNotBlank()) { "이메일은 필수입니다." }
            require(password.length >= 8) { "비밀번호는 8자 이상이어야 합니다." }
            require(name.isNotBlank()) { "이름은 필수입니다." }

            return MemberEntity(email, password, name)
        }
    }
}
