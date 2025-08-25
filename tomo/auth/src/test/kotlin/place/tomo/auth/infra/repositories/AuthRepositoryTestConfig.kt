package place.tomo.auth.infra.repositories

import org.springframework.boot.SpringBootConfiguration
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.boot.autoconfigure.domain.EntityScan
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@SpringBootConfiguration
@EnableJpaRepositories(basePackages = ["place.tomo.auth.infra.repositories"])
@EntityScan(basePackages = ["place.tomo.auth.domain.entities"])
@EnableAutoConfiguration
class AuthRepositoryTestConfig
