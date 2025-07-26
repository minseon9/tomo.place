package place.tomo.ui.controllers

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import place.tomo.common.resolvers.usercontext.CurrentUser
import place.tomo.ui.responses.LinkedSocialAccountsResponseBody
import place.tomo.ui.responses.SocialAccountResponseBody

@RestController
@RequestMapping("/api/users")
class UserController(
    // FIXME: user 조회에서 처리하도록 수정
//    @GetMapping("/social-accounts")
//    fun getLinkedSocialAccounts(
//@CurrentUser userContext: UserContext,
//): ResponseEntity<LinkedSocialAccountsResponseBody> {
//    val socialAccounts = authService.getLinkedSocialAccounts(userContext.userId)
//    val response =
//        _root_ide_package_.place.tomo.ui.responses.LinkedSocialAccountsResponseBody(
//            accounts =
//                socialAccounts.map {
//                    _root_ide_package_.place.tomo.ui.responses.SocialAccountResponseBody(
//                        provider = it.provider,
//                        email = it.email,
//                        name = it.name,
//                        profileImageUrl = it.profileImageUrl,
//                        isActive = it.isActive,
//                    )
//                },
//        )
//
//    return _root_ide_package_.org.springframework.http.ResponseEntity.ok(response)
//}
)
