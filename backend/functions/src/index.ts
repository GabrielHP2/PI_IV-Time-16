import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/v2/https";

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});


export const healthCheck = onRequest((_request, response) => {
  response.status(200).send("StreamHub backend funcionando!");
});


export * from "./auth";