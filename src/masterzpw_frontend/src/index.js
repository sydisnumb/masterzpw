// index.ts
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import {createActor, masterzpw_backend} from "../../declarations/masterzpw_backend";

import { Area } from "./components/common/Area"

let actor = masterzpw_backend;

const loginButton = document.getElementById("loginBtn");
loginButton.onclick = async (e) => {
  e.preventDefault();

  let authClient = await AuthClient.create();

  // start the login process and wait for it to finish
  await new Promise((resolve) => {
    authClient.login({
        identityProvider: process.env.II_URL,
        onSuccess: async () => {
          //await is the first access 
          // if yes render first complete profile
          // if no log in
          console.log(resolve);
          console.log(authClient);
        },
    });
  });

  // At this point we're authenticated, and we can get the identity from the auth client:
  const identity = authClient.getIdentity();
  // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
  const agent = new HttpAgent({identity});
  // Using the interface description of our webapp, we create an actor that we use to call the service methods.
  actor = createActor(process.env.MASTERZPW_BACKEND_CANISTER_ID, {
      agent,
  });

  return false;
};

Area.resolve();


