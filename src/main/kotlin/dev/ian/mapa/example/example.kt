// package는 어떤 역할?
package dev.ian.mapa.example

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController


@RestController
class ExampleApi  {

    @GetMapping("/")
    fun example(): String {
        return "Example"
    }

}