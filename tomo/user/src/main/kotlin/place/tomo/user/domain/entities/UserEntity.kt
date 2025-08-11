package place.tomo.user.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import place.tomo.user.domain.constant.UserStatus
import place.tomo.common.exception.HttpErrorStatus
import place.tomo.common.exception.HttpException
import java.time.LocalDateTime

@Entity
@Table(name = "users")
class UserEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(unique = true, nullable = false)
    val email: String,
    @Column(nullable = false)
    var password: String,
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
            password: String,
            username: String,
        ): UserEntity {
            if (email.isBlank()) {
                throw HttpException(HttpErrorStatus.BAD_REQUEST, "이메일은 필수입니다.")
            }
            if (password.length < 8) {
                throw HttpException(HttpErrorStatus.BAD_REQUEST, "비밀번호는 8자 이상이어야 합니다.")
            }
            if (username.isBlank()) {
                throw HttpException(HttpErrorStatus.BAD_REQUEST, "이름은 필수입니다.")
            }

            // FIXME: 이메일 인증 같은 프로세스가 없어서 우선 ACTIVATED로 생성
            return UserEntity(email = email, password = password, username = username, status = UserStatus.ACTIVATED)
        }
    }
}
