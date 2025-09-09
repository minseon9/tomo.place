package place.tomo.place.domain.constants

data class PlacePermission(
    val grant: Boolean,
    val write: Boolean,
    val read: Boolean,
    val delete: Boolean,
)
