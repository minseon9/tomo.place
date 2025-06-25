package dev.ian.mapa.controller

import dev.ian.mapa.application.requests.SignUpRequest
import dev.ian.mapa.application.services.MemberService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/members")
class MemberController(
    private val memberService: MemberService
) {
    @PostMapping("/sign-up")
    fun signUp(@RequestBody request: SignUpRequest): ResponseEntity<MemberService.MemberInfo> {
        val command = MemberService.SignUpCommand(
            email = request.email,
            password = request.password,
            name = request.name
        )

        return ResponseEntity.ok(memberService.signUp(command))
    }
} 