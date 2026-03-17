package helpers;

import java.util.UUID;
import java.util.Random;

public class DataGenerator {

    // Genera un email único usando UUID para evitar colisiones entre ejecuciones
    public static String uniqueEmail() {
        return "qa_" + UUID.randomUUID().toString().replace("-", "").substring(0, 10) + "@mail.com";
    }

    // Genera un nombre único con UUID para que cada usuario creado sea diferente
    public static String uniqueName() {
        return "Usuario QA " + UUID.randomUUID().toString().substring(0, 8);
    }

    // Genera una contraseña aleatoria combinando letras y números
    // Usar siempre "Test1234" es hardcoding — esto lo hace dinámico
    public static String randomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder("Qa@"); // Prefijo fijo para cumplir complejidad
        for (int i = 0; i < 8; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }
}