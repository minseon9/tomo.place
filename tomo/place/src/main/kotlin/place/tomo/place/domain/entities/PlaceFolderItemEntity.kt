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
    name = "place_folder_item",
    uniqueConstraints = [
        UniqueConstraint(name = "uq_place_folder_item__folder_id_place_id", columnNames = ["folder_id", "place_id"]),
    ],
    indexes = [
        Index(name = "idx_place_folder_item__folder_id", columnList = "folder_id"),
        Index(name = "idx_place_folder_item__place_id", columnList = "place_id"),
        Index(name = "idx_place_folder_item__created_by_user_id", columnList = "created_by_user_id"),
        Index(name = "idx_place_folder_item__folder_id_order", columnList = "folder_id, order"),
    ],
)
class PlaceFolderItemEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folder_id", nullable = false)
    val folder: PlaceFolderEntity,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "place_id", nullable = false)
    val place: PlaceEntity,
    @Column(name = "created_by_user_id", nullable = false)
    val createdByUserId: Long,
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
