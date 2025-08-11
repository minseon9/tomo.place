package place.tomo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

// import org.springframework.cloud.openfeign.EnableFeignClients

// @EnableFeignClients
@SpringBootApplication
@ConfigurationPropertiesScan
class TomoApplication

fun main(args: Array<String>) {
    runApplication<TomoApplication>(*args)
}
