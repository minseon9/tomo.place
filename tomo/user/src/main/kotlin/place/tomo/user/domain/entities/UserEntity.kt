package place.tomo.user.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.common.validation.EmailValidation
import place.tomo.user.domain.constant.UserStatus
import place.tomo.user.domain.exception.InvalidEmailException
import place.tomo.user.domain.exception.InvalidUsernameException
import java.time.LocalDateTime
import java.util.UUID

@Entity
@Table(
    name = "users",
    uniqueConstraints = [
        UniqueConstraint(name = "uq_user__email", columnNames = ["email"]),
        UniqueConstraint(name = "uq_user__entity_id", columnNames = ["entity_id"]),
    ],
)
@EntityListeners(AuditingEntityListener::class)
class UserEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "entity_id", nullable = false)
    val entityId: UUID = UUID.randomUUID(),
    @Column(unique = true, nullable = false)
    val email: String,
    @Column(nullable = false)
    var username: String,
    @Column()
    var nickname: String? = null,
    @Enumerated(EnumType.STRING)
    var status: UserStatus = UserStatus.ACTIVATED,
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
            username: String,
        ): UserEntity {
            if (!EmailValidation.isValid(email)) {
                throw InvalidEmailException(email)
            }
            if (username.isBlank()) {
                throw InvalidUsernameException(username)
            }

            return UserEntity(
                email = email,
                username = username,
            )
        }
    }

    fun deactivate() {
        status = UserStatus.DEACTIVATED
        deletedAt = LocalDateTime.now()
    }

    fun isActivated(): Boolean = status == UserStatus.ACTIVATED
}
