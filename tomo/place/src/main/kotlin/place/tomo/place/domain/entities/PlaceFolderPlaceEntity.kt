package place.tomo.place.domain.entities

import jakarta.persistence.Column
import jakarta.persistence.Entity
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
import java.time.LocalDateTime

@Entity
@Table(
    name = "place_folder_item",
    indexes = [
        Index(name = "idx_folder_item_folder", columnList = "folder_id"),
        Index(name = "idx_folder_item_place", columnList = "place_id"),
        Index(name = "idx_folder_item_user", columnList = "created_by_user_id"),
        Index(name = "idx_folder_item_order", columnList = "folder_id, order"),
    ],
    uniqueConstraints = [
        UniqueConstraint(columnNames = ["folder_id", "place_id"]),
    ],
)
class PlaceFolderPlaceEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folder_id", nullable = false)
    val folder: PlaceFolderEntity,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "place_id", nullable = false)
    val place: PlaceEntity,
    @Column(name = "created_by_user_id", nullable = false)
    val created_by_user_id: Long,
    @Column()
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
