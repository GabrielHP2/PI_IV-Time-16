// Autor: Felipe Cesar Lirani

package test;
 
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import services.LoginService;
import services.RegisterService;
 
public class IntraclassServicesTest {
 
    // =========================================================================
    // CLASSE 1: RegisterService — Particionamento por ATRIBUTOS
    // =========================================================================
 
    @Test
    @DisplayName("RegisterService: todos os atributos válidos deve retornar true e preservar getters")
    void registerAtributosValidos() {
        RegisterService service = new RegisterService(
            "Ana Silva", "ana@streamhub.com", "Senha@123", "(19) 99876-5432"
        );
        assertEquals("Ana Silva", service.getName());
        assertEquals("ana@streamhub.com", service.getEmail());
        assertEquals("Senha@123", service.getPassword());
        assertEquals("(19) 99876-5432", service.getPhoneNumber());
        assertTrue(service.isValid());
    }
 
    @Test
    @DisplayName("RegisterService: atributos nulos ou em branco devem lançar IllegalArgumentException")
    void registerAtributosNulosOuVazios() {
        assertThrows(IllegalArgumentException.class,
            () -> new RegisterService(null, "ana@streamhub.com", "Senha@123", "19998765432"));
        assertThrows(IllegalArgumentException.class,
            () -> new RegisterService("Ana Silva", "   ", "Senha@123", "19998765432"));
        assertThrows(IllegalArgumentException.class,
            () -> new RegisterService("Ana Silva", "ana@streamhub.com", "", "19998765432"));
        assertThrows(IllegalArgumentException.class,
            () -> new RegisterService("Ana Silva", "ana@streamhub.com", "Senha@123", null));
    }
 
    @Test
    @DisplayName("RegisterService: partição de nome inválido (< 2 ou > 100 caracteres)")
    void registerNomeForaDosLimites() {
        RegisterService nomeCurto = new RegisterService(
            "A", "ana@streamhub.com", "Senha@123", "19998765432"
        );
        assertFalse(nomeCurto.isValid());
 
        String nomeLongoStr = "A".repeat(101);
        RegisterService nomeLongo = new RegisterService(
            nomeLongoStr, "ana@streamhub.com", "Senha@123", "19998765432"
        );
        assertFalse(nomeLongo.isValid());
    }
 
    @Test
    @DisplayName("RegisterService: partição de e-mail inválido e anomalia de espaços nas bordas")
    void registerEmailInvalidoEAnomaliaEspacos() {
        RegisterService emailSemArroba = new RegisterService(
            "Ana Silva", "ana.streamhub.com", "Senha@123", "19998765432"
        );
        assertFalse(emailSemArroba.isValid());
 
        // Documenta anomalia: RegisterService não executa trim() no e-mail no construtor
        RegisterService emailComEspacos = new RegisterService(
            "Ana Silva", " ana@streamhub.com ", "Senha@123", "19998765432"
        );
        assertFalse(emailComEspacos.isValid());
    }
 
    @Test
    @DisplayName("RegisterService: partições de senha fraca e telefone fora da faixa (10 a 15 dígitos)")
    void registerSenhaETelefoneInvalidos() {
        RegisterService senhaFraca = new RegisterService(
            "Ana Silva", "ana@streamhub.com", "senha123", "19998765432"
        );
        assertFalse(senhaFraca.isValid());
 
        RegisterService telefoneCurto = new RegisterService(
            "Ana Silva", "ana@streamhub.com", "Senha@123", "1999876"
        );
        assertFalse(telefoneCurto.isValid());
 
        RegisterService telefoneLongo = new RegisterService(
            "Ana Silva", "ana@streamhub.com", "Senha@123", "5519998765432109"
        );
        assertFalse(telefoneLongo.isValid());
    }
 
    // =========================================================================
    // CLASSE 2: LoginService — Particionamento por CATEGORIAS DE MÉTODOS
    // =========================================================================
 
    @Test
    @DisplayName("LoginService [Categoria Construtor]: rejeita e-mail ou senha ausentes")
    void loginCategoriaConstrutor() {
        IllegalArgumentException exEmail = assertThrows(IllegalArgumentException.class,
            () -> new LoginService("   ", "Senha@123"));
        assertEquals("Email is missing", exEmail.getMessage());
 
        IllegalArgumentException exPass = assertThrows(IllegalArgumentException.class,
            () -> new LoginService("ana@streamhub.com", null));
        assertEquals("Password is missing", exPass.getMessage());
    }
 
    @Test
    @DisplayName("LoginService [Categoria Getters]: normaliza e-mail com trim() e mantém senha")
    void loginCategoriaGetters() {
        LoginService service = new LoginService("  ana@streamhub.com  ", "Senha@123");
        assertEquals("ana@streamhub.com", service.getEmail());
        assertEquals("Senha@123", service.getPassword());
    }
 
    @Test
    @DisplayName("LoginService [Categoria Validação]: valida credenciais corretas e rejeita inválidas")
    void loginCategoriaValidacao() {
        assertTrue(new LoginService("ana@streamhub.com", "Senha@123").isValid());
        assertFalse(new LoginService("email-invalido", "Senha@123").isValid());
        assertFalse(new LoginService("ana@streamhub.com", "fraca").isValid());
    }
}