import {setGlobalOptions} from "firebase-functions";

import {
  onCall,
  onRequest,
  HttpsError
} from "firebase-functions/v2/https";

import * as net from "node:net";

// Configurações gerais
setGlobalOptions({maxInstances: 10});

// Verifica se o backend está funcionando
export const healthCheck = onRequest((_request, response) => {
  response.status(200).send("StreamHub backend funcionando!");
});

// Testa a comunicação com o servidor Java
export const serverPing = onCall(async () => {

  console.log("[serverPing] Function iniciada!");

  return new Promise((resolve, reject) => {

    const socket = new net.Socket();

    let receivedData = "";
    let finished = false;

    // Trata erros e encerra a comunicação
    const fail = (error: HttpsError) => {

      if (finished) return;

      finished = true;

      console.error("[serverPing] Erro:", error.message);

      socket.destroy();

      reject(error);
    };

    // Tempo máximo de inatividade
    socket.setTimeout(5000);

    socket.on("timeout", () => {

      fail(new HttpsError(
        "deadline-exceeded",
        "O servidor Java demorou para responder."
      ));
    });

    // Trata erros de conexão
    socket.on("error", (error) => {

      fail(new HttpsError(
        "unavailable",
        `Erro na conexão com Java: ${error.message}`
      ));
    });

    // Recebe a resposta do Java
    socket.on("data", (data) => {

      const chunk = data.toString("utf8");

      console.log("[serverPing] Dados recebidos:", chunk);

      receivedData += chunk;

      try {

        const javaResponse = JSON.parse(receivedData);

        if (finished) return;

        finished = true;

        console.log("[serverPing] Resposta JSON:", javaResponse);

        // Encerra a conexão de maneira normal
        socket.end();

        resolve({
          success: true,
          serverResponse: javaResponse
        });

      } catch (error) {

        if (error instanceof SyntaxError) {

          console.log("[serverPing] Aguardando mais dados JSON.");

        } else {

          fail(new HttpsError(
            "internal",
            "Erro ao interpretar a resposta do servidor Java."
          ));
        }
      }
    });

    // Verifica se a conexão foi encerrada
    socket.on("close", () => {

      console.log("[serverPing] Conexão encerrada.");

      if (!finished) {

        fail(new HttpsError(
          "unavailable",
          "O servidor Java encerrou a conexão sem responder."
        ));
      }
    });

    // Conecta ao servidor Java
    socket.connect(8080, "127.0.0.1", () => {

      console.log("[serverPing] Conectado ao Java!");

      const message = JSON.stringify({
        operation: "ping"
      }) + "\n";

      console.log("[serverPing] Enviando:", message);

      socket.write(message, (error) => {

        if (error) {

          fail(new HttpsError(
            "unavailable",
            `Erro ao enviar mensagem: ${error.message}`
          ));

          return;
        }

        console.log("[serverPing] Mensagem enviada!");
      });
    });
  });
});
