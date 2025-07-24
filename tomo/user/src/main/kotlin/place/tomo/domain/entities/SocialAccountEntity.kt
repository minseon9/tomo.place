package place.tomo.domain.entities

import place.tomo.domain.constant.OAuthProvider
import jakarta.persistence.*
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
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
    
    @Column(name = "user_id", nullable = false)
    val userId: Long,
    
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
            userId: Long,
            provider: OAuthProvider,
            socialId: String,
            email: String?,
            name: String?,
            profileImageUrl: String?
        ): SocialAccountEntity {
            return SocialAccountEntity(
                userId = userId,
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