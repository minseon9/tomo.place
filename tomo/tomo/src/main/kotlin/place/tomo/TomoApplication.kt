package place.tomo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class TomoApplication

fun main(args: Array<String>) {
    runApplication<TomoApplication>(*args)
}
