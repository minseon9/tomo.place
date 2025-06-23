package dev.ian.mapa.member.application.services

import dev.ian.mapa.member.application.requests.SignUpRequest

class MemberApplicationService {
    private final val domainService = MemberDomainService()

    fun signUp(request: SignUpRequest) {
        // application 로직
        // 예시
        // AuthenticationDomainService.check_email_apporved - 이메일 인증 완료 여부. Redis 사용해도 되겠다 ?
         domainService.create_member(request)

        return
    }
}