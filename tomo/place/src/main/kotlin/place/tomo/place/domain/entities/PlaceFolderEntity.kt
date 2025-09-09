package place.tomo.place.domain.entities

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
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.annotations.Type
import org.hibernate.type.SqlTypes
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.place.domain.constants.PlaceFolderDisplayType
import place.tomo.place.domain.constants.PlaceFolderVisibilityType
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place_folder",
    indexes = [
        Index(name = "idx_folder_owner", columnList = "owner_id"),
        Index(name = "idx_folder_tags", columnList = "tags"),
        Index(name = "idx_folder_deleted", columnList = "deleted_at"),
    ],
)
class PlaceFolderEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(nullable = false)
    val name: String,
    @Column(name = "owner_id", nullable = false)
    val ownerId: Long,
    @Column(name = "display_type", nullable = false)
    @Enumerated(EnumType.STRING)
    val displayType: PlaceFolderDisplayType,
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val visibility: PlaceFolderVisibilityType = PlaceFolderVisibilityType.PRIVATE,
    @Column(name = "tags", columnDefinition = "text[]")
    @JdbcTypeCode(SqlTypes.ARRAY)
    val tags: Array<String>? = null,
    @Column(name = "order")
    val order: Int = 0,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
)
