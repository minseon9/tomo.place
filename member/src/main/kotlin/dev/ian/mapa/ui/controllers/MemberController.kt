package dev.ian.mapa.ui.controllers

import dev.ian.mapa.application.services.MemberApplicationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/members")
class MemberController(
    private val memberService: MemberApplicationService,
) {
    @GetMapping("/test")
    fun test(): ResponseEntity<Void> {
        println('a')

        return ResponseEntity.ok().build()
    }
    // 회원 정보 관련 엔드포인트만 남깁니다.
}
