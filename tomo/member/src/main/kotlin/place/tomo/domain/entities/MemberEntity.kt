package place.tomo.domain.entities

import place.tomo.domain.constant.MemberStatus
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
import java.time.LocalDateTime

/*
도메인 모델 (Entity)
- 기본적인 정책을 가지고 수행. 해당 모델로서 검증할 수 있는 영역에 대한 검증 수행
 */
@Entity
@Table(name = "member")
class MemberEntity(
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
    var status: MemberStatus = MemberStatus.STANDBY,
    @CreatedDate
    @Column(name = "created_at", nullable = false)
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
        ): MemberEntity {
            require(email.isNotBlank()) { "이메일은 필수입니다." }
            require(password.length >= 8) { "비밀번호는 8자 이상이어야 합니다." }
            require(username.isNotBlank()) { "이름은 필수입니다." }

            // FIXME: 이메일 인증 같은 프로세스가 없어서 우선 ACTIVATED로 생성
            return MemberEntity(email = email, password = password, username = username, status = MemberStatus.ACTIVATED)
        }
    }
}
