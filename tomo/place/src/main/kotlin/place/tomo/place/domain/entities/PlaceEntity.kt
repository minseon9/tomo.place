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
import jakarta.persistence.UniqueConstraint
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import org.locationtech.jts.geom.Point
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import place.tomo.place.domain.constants.PlaceType
import java.time.LocalDateTime
import java.util.UUID

@Entity
@EntityListeners(AuditingEntityListener::class)
@Table(
    name = "place",
    uniqueConstraints = [
        UniqueConstraint(name = "uq_place__entity_id", columnNames = ["entity_id"]),
    ],
    indexes = [
        Index(name = "idx_place__location_gist", columnList = "location"),
        Index(name = "idx_place__type", columnList = "type"),
        Index(name = "idx_place__search_vector", columnList = "search_vector"),
    ],
)
class PlaceEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "entity_id", nullable = false)
    val entityId: UUID,
    @Column(nullable = false)
    val name: String,
    @Column(nullable = false)
    val address: String,
    @Column(name = "address_detail")
    val addressDetail: String? = null,
    @Column(name = "location", columnDefinition = "GEOMETRY(Point, 4326)", nullable = false)
    @JdbcTypeCode(SqlTypes.GEOMETRY)
    val location: Point,
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val type: PlaceType,
    @Column(name = "sub_category")
    val subCategory: String? = null,
    @Column(name = "external_id", nullable = false)
    val externalId: String,
    @Column(name = "search_vector", columnDefinition = "tsvector")
    @JdbcTypeCode(SqlTypes.VARCHAR)
    val searchVector: String? = null,
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
) {
    fun isClosed() = this.deletedAt != null
}
