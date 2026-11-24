// Autor: Gabriel Batista Bastos
import { MongoClient, type Db } from "mongodb";
import { defineSecret } from "firebase-functions/params";

// Define o segredo que armazena a URI de conexão com o MongoDB.
// O valor é configurado no ambiente do Firebase, evitando deixar
// as informações de conexão diretamente no código.
export const mongoUri = defineSecret("MONGODB_URI");

// Armazena a Promise de conexão com o MongoDB.
// Isso permite reutilizar a conexão entre diferentes chamadas das Cloud Functions,
// evitando estabelecer uma nova conexão a cada requisição.
let mongoClientPromise: Promise<MongoClient> | undefined;

// Obtém uma conexão ativa com o MongoDB.
async function getMongoClient(): Promise<MongoClient> {

  // Recupera o valor da URI de conexão armazenada no segredo do Firebase.
  const uri = mongoUri.value();

  // Verifica se a URI foi configurada.
  // Caso esteja vazia, interrompe o processo de conexão.
  if (!uri) {
    throw new Error("A URI de conexão do MongoDB não foi configurada.");
  }

  // Verifica se ainda não existe uma Promise de conexão armazenada.
  // Se não existir, cria um novo cliente MongoDB.
  if (!mongoClientPromise) {

    // Configura o cliente MongoDB.
    // maxPoolSize define o número máximo de conexões simultâneas no pool.
    // serverSelectionTimeoutMS define o tempo máximo de espera para selecionar um servidor.
    const client = new MongoClient(uri, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
    });

    // Inicia a conexão com o MongoDB e armazena a Promise.
    // Dessa forma, outras chamadas podem reutilizar a mesma conexão.
    mongoClientPromise = client.connect().catch(async (error: unknown) => {

      // Caso a conexão falhe, limpa a Promise armazenada.
      // Isso permite que uma nova tentativa de conexão seja realizada posteriormente.
      mongoClientPromise = undefined;

      // Fecha o cliente caso tenha ocorrido alguma falha durante a conexão.
      // O catch adicional evita que um erro ao fechar o cliente substitua o erro original.
      await client.close().catch(() => undefined);

      // Propaga o erro original para quem solicitou a conexão.
      throw error;
    });
  }

  // Retorna a conexão estabelecida ou a Promise que está aguardando sua conclusão.
  return mongoClientPromise;
}

// Obtém o banco de dados utilizado pelo projeto StreamHub.
export async function getDatabase(): Promise<Db> {

  // Aguarda a obtenção de uma conexão com o MongoDB.
  const client = await getMongoClient();

  // Seleciona o banco de dados chamado "streamhub".
  // Retorna o objeto Db para que as Cloud Functions possam acessar suas coleções.
  return client.db("streamhub");
}