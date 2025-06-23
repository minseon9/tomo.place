package dev.ian.mapa.member.api.controllers

import dev.ian.mapa.member.api.requests.SignUpRequestBody
import dev.ian.mapa.member.application.requests.SignUpRequest
import dev.ian.mapa.member.application.services.MemberApplicationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import javax.lang.model.type.NullType


@RestController
class MemberController {
    // TODO: final
    // composition을 항상 사용? 객체 지향 프로그래밍이란 ..
    private final val memberApplicationService = MemberApplicationService()

    @PostMapping("/signup")
    fun signUp(@RequestBody request: SignUpRequestBody):ResponseEntity<NullType> {
        memberApplicationService.signUp(SignUpRequest(
            name=request.name,
            email=request.email,
            password=request.password
        ))

        return ResponseEntity.ok().build()
    }
}