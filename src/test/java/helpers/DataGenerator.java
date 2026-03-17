package helpers;

import java.util.UUID;

public class DataGenerator {

    public static String uniqueEmail() {
        return "qa_" + UUID.randomUUID().toString().replace("-", "").substring(0, 10) + "@mail.com";
    }

    public static String uniqueName() {
        return "Usuario QA " + UUID.randomUUID().toString().substring(0, 8);
    }

    public static String randomPassword() {
        return "Test1234";
    }
}