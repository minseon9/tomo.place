package place.tomo.user.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Embeddable
import jakarta.persistence.Embedded
import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.common.validation.EmailValidation
import place.tomo.user.domain.constant.UserStatus
import place.tomo.user.domain.exception.InvalidEmailException
import place.tomo.user.domain.exception.InvalidUsernameException
import java.time.LocalDateTime

@Embeddable
class HashedPassword(
    @Column(name = "password", nullable = false, length = 100)
    val value: String,
) {
    override fun toString(): String = "********"
}

@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener::class)
class UserEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(unique = true, nullable = false)
    val email: String,
    @Embedded
    var password: HashedPassword,
    @Column(nullable = false)
    var username: String,
    @Column()
    var nickname: String? = null,
    @Enumerated(EnumType.STRING)
    var status: UserStatus = UserStatus.STANDBY,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    val updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
) {
    companion object {
        fun create(
            email: String,
            password: HashedPassword,
            username: String,
            status: UserStatus = UserStatus.ACTIVATED, // FIXME: 이메일 인증 같은 프로세스가 없어서 우선 ACTIVATED로 생성
        ): UserEntity {
            if (!EmailValidation.isValid(email)) {
                throw InvalidEmailException(email)
            }
            if (username.isBlank()) {
                throw InvalidUsernameException(username)
            }

            return UserEntity(
                email = email,
                password = password,
                username = username,
                status = status,
            )
        }
    }
}
