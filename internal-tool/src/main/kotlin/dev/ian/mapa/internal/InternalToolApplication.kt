package dev.ian.mapa.internal

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class InternalToolApplication

fun main(args: Array<String>) {
    runApplication<InternalToolApplication>(*args)
} 