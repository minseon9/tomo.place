package dev.ian.mapa.ui.controllers

import SignUpCommand
import dev.ian.mapa.application.services.MemberApplicationService
import dev.ian.mapa.ui.requests.SignUpRequestBody
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/members")
class MemberController(
    private val memberService: MemberApplicationService,
) {
    @PostMapping("/signup")
    fun signUp(
        @RequestBody request: SignUpRequestBody,
    ): ResponseEntity<Void> {
        memberService.signUp(
            SignUpCommand(
                email = request.email,
                password = request.password,
                name = request.name,
            ),
        )
        return ResponseEntity.ok().build()
    }
}
