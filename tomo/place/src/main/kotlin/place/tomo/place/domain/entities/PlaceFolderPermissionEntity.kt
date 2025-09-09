package place.tomo.place.domain.entities

import com.vladmihalcea.hibernate.type.json.JsonBinaryType
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
import jakarta.persistence.UniqueConstraint
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.annotations.Type
import org.hibernate.type.SqlTypes
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.place.domain.constants.PlacePermissionType
import java.time.LocalDateTime

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place_folder_permission",
    indexes = [
        Index(name = "idx_permission_user_folder", columnList = "user_id, place_folder_id"),
        Index(name = "idx_permission_folder", columnList = "place_folder_id"),
        Index(name = "idx_permission_user", columnList = "user_id"),
        Index(name = "idx_permission_type", columnList = "permissions"),
    ],
    uniqueConstraints = [
        UniqueConstraint(columnNames = ["user_id", "place_folder_id"]),
    ],
)
class PlaceFolderPermissionEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "user_id", nullable = false)
    val userId: Long,
    @Column(name = "place_folder_id", nullable = false)
    val placeFolderId: Long,
    @Column(name = "granted_by", nullable = false)
    val grantedBy: Long,
    @Type(JsonBinaryType::class)
    @Column(columnDefinition = "jsonb", nullable = false)
    val permissions: Map<PlacePermissionType, Boolean>,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
)
