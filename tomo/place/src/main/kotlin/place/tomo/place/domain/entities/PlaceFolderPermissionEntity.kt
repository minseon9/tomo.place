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
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.place.domain.constants.PlacePermission
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place_folder_permission",
    uniqueConstraints = [
        UniqueConstraint(name = "uq_place_folder_permission__user_id_place_folder_id", columnNames = ["user_id", "folder_id"]),
    ],
    indexes = [
        Index(name = "idx_place_folder_permission__user_id__folder_id", columnList = "user_id, folder_id"),
        Index(name = "idx_place_folder_permission__folder_id", columnList = "folder_id"),
        Index(name = "idx_place_folder_permission__user_id", columnList = "user_id"),
        Index(name = "idx_place_folder_permission__type", columnList = "permissions"),
    ],
)
class PlaceFolderPermissionEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "user_id", nullable = false)
    val userId: Long,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folder_id", nullable = false)
    val folder: PlaceFolderEntity,
    @Column(name = "granted_by", nullable = false)
    val grantedBy: Long,
    @Column(columnDefinition = "jsonb", nullable = false)
    @JdbcTypeCode(SqlTypes.JSON)
    val permissions: PlacePermission,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
)
