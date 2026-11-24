// Autor: Gabriel Batista Bastos

import { initializeApp } from "firebase-admin/app";

import { setGlobalOptions } from "firebase-functions";

// Inicializa o Firebase Admin SDK.
// Essa inicialização permite que as Cloud Functions utilizem os serviços
// administrativos do Firebase, como o Firebase Authentication.
initializeApp();

// Define configurações globais aplicadas às Cloud Functions do projeto.
setGlobalOptions({
  // Limita a quantidade máxima de instâncias simultâneas de cada função.
  maxInstances: 10,

  // Define a região onde as Cloud Functions serão executadas.
  // A região southamerica-east1 corresponde a São Paulo.
  region: "southamerica-east1",
});

// Exporta as funções relacionadas à autenticação,
// como cadastro, login e gerenciamento de senhas.
export * from "./auth";

// Exporta as funções responsáveis pelas consultas e operações da API.
export * from "./api";

// Exporta as funções responsáveis pelo gerenciamento da lista de desejos.
export * from "./wishlist";

// Exporta as funções relacionadas ao planejamento de assinaturas.
export * from "./subscription";