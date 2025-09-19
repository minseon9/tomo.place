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
import org.hibernate.type.SqlTypes
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.place.domain.constants.PlaceFolderVisibilityType
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place_folder",
    indexes = [
        Index(name = "idx_place_folder__owner", columnList = "owner_id"),
        Index(name = "idx_place_folder__tags", columnList = "tags"),
        Index(name = "idx_place_folder__deleted", columnList = "deleted_at"),
    ],
)
class PlaceFolderEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(nullable = false, length = 20)
    val defaultName: String,
    @Column(name = "owner_id", nullable = false)
    val ownerId: Long,
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val visibility: PlaceFolderVisibilityType = PlaceFolderVisibilityType.PRIVATE,
    @Column(name = "tags", columnDefinition = "text[]")
    @JdbcTypeCode(SqlTypes.ARRAY)
    val tags: Array<String>? = null,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
) {
    companion object {
        fun create(
            name: String,
            userId: Long,
            visibility: PlaceFolderVisibilityType = PlaceFolderVisibilityType.PRIVATE,
            tags: Array<String>? = null,
        ): PlaceFolderEntity =
            PlaceFolderEntity(
                defaultName = name,
                ownerId = userId,
                visibility = visibility,
                tags = tags,
            )
    }
}
