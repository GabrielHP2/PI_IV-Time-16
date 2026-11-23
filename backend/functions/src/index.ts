import { initializeApp } from "firebase-admin/app";

import {setGlobalOptions} from "firebase-functions";

initializeApp();

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./auth";
export * from "./api";
export * from "./subscription";
export * from "./wishlist";