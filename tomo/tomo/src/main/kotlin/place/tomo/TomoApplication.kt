package place.tomo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

@SpringBootApplication
@ConfigurationPropertiesScan
class TomoApplication

fun main(args: Array<String>) {
    runApplication<TomoApplication>(*args)
}
