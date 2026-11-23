
import { MongoClient, type Db } from "mongodb";
import { defineSecret } from "firebase-functions/params";

export const mongoUri = defineSecret("MONGODB_URI");

let mongoClientPromise: Promise<MongoClient> | undefined;

async function getMongoClient(): Promise<MongoClient> {
  const uri = mongoUri.value();

  if (!uri) {
    throw new Error("A URI de conexão do MongoDB não foi configurada.");
  }

  if (!mongoClientPromise) {
    const client = new MongoClient(uri, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
    });

    mongoClientPromise = client.connect().catch(async (error: unknown) => {
      mongoClientPromise = undefined;
      await client.close().catch(() => undefined);
      throw error;
    });
  }

  return mongoClientPromise;
}

export async function getDatabase(): Promise<Db> {
  const client = await getMongoClient();

  return client.db("streamhub");
}
