package place.tomo.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import place.tomo.domain.constant.OAuthProvider
import java.time.LocalDateTime

/**
 * 소셜 계정 엔티티
 * - 사용자와 소셜 로그인 제공자 간의 연결 정보 관리
 * - 하나의 사용자는 여러 소셜 계정을 연결할 수 있음
 */
@Entity
@Table(
    name = "social_account",
    uniqueConstraints = [
        UniqueConstraint(columnNames = ["provider", "social_id"])
    ]
)
class SocialAccountEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: UserEntity,
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val provider: OAuthProvider,
    
    @Column(name = "social_id", nullable = false)
    val socialId: String,
    
    @Column
    val email: String?,
    
    @Column
    val name: String?,
    
    @Column(name = "profile_image_url")
    val profileImageUrl: String?,
    
    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,
    
    @CreatedDate
    @Column(name = "created_at", nullable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
) {
    companion object {
        fun create(
            user: UserEntity,
            provider: OAuthProvider,
            socialId: String,
            email: String?,
            name: String?,
            profileImageUrl: String?
        ): SocialAccountEntity {
            return SocialAccountEntity(
                user = user,
                provider = provider,
                socialId = socialId,
                email = email,
                name = name,
                profileImageUrl = profileImageUrl
            )
        }
    }
    
    fun deactivate() {
        this.isActive = false
        this.updatedAt = LocalDateTime.now()
    }
} 
