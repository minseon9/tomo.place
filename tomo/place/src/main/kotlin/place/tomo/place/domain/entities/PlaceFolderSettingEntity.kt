package place.tomo.place.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place_folder_setting",
    uniqueConstraints = [
        UniqueConstraint(name = "uq_place_folder_setting__user_id_folder_id", columnNames = ["user_id", "folder_id"]),
    ],
    indexes = [
        Index(name = "idx_place_folder_setting__user_id_folder_id", columnList = "user_id, folder_id"),
    ],
)
class PlaceFolderSettingEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "user_id", nullable = false)
    val userId: Long,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folder_id", nullable = false)
    val folder: PlaceFolderEntity,
    @Column(nullable = false, length = 20)
    val name: String,
    @Column(nullable = false)
    val iconColor: String,
    @Column(name = "is_display_stored_place", nullable = false)
    val isDisplayStoredPlace: Boolean,
    @Column(name = "is_display_visited_place", nullable = false)
    val isDisplayVisitedPlace: Boolean,
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
            userId: Long,
            folder: PlaceFolderEntity,
            name: String,
            iconColor: String,
            isDisplayStoredPlace: Boolean,
            isDisplayVisitedPlace: Boolean,
        ): PlaceFolderSettingEntity =
            PlaceFolderSettingEntity(
                userId = userId,
                folder = folder,
                name = name,
                iconColor = iconColor,
                isDisplayStoredPlace = isDisplayStoredPlace,
                isDisplayVisitedPlace = isDisplayVisitedPlace,
            )
    }
}
