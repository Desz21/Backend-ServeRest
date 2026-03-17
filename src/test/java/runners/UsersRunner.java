package runners;

import com.intuit.karate.junit5.Karate;

public class UsersRunner {

    @Karate.Test
    Karate runAll() {
        return Karate.run("classpath:features/users")
                .relativeTo(getClass());
    }
}