package place.tomo.common.exception

class HttpException(
    val status: HttpErrorStatus,
    override val message: String,
    val errorCode: String? = null,
    cause: Throwable? = null,
) : RuntimeException(message, cause)
