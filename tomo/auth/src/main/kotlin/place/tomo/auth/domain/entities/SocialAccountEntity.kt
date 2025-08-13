package place.tomo.auth.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import org.hibernate.annotations.SQLDelete
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.contract.constant.OIDCProviderType
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "social_account",
    uniqueConstraints = [
        UniqueConstraint(columnNames = ["provider", "social_id"]),
    ],
)
@SQLDelete(sql = "UPDATE social_account SET is_active = false WHERE id = ?")
class SocialAccountEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "user_id", nullable = false)
    val userId: Long,
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val provider: OIDCProviderType,
    @Column(name = "social_id", nullable = false)
    val socialId: String,
    @Column(name = "email", nullable = false)
    val email: String,
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
    var updatedAt: LocalDateTime = LocalDateTime.now(),
) {
    companion object {
        fun create(
            userId: Long,
            provider: OIDCProviderType,
            socialId: String,
            email: String,
            name: String?,
            profileImageUrl: String?,
        ): SocialAccountEntity =
            SocialAccountEntity(
                userId = userId,
                provider = provider,
                socialId = socialId,
                email = email,
                name = name,
                profileImageUrl = profileImageUrl,
            )
    }

    fun deactivate() {
        this.isActive = false
    }

    fun activate() {
        this.isActive = true
    }
}
