// index.ts
import { Actor, HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import idlFactory from "./did";
import type { _SERVICE } from "./did";

const init = async () => {
  console.log(process.env.CANISTER_ID);
  let iiUrl = "https://identity.ic0.app/";;

  if (process.env.DFX_NETWORK !== "ic") {
    iiUrl = "https://identity.ic0.app/";
  }

  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient);
    console.log("logged in");
  }
  

  const loginButton = document.getElementById(
    "loginButton"
  ) as HTMLButtonElement;
  loginButton.onclick = async () => {
    await authClient.login({
      identityProvider: iiUrl,
      onSuccess: async () => {
        handleAuthenticated(authClient);
      },
    });
  };
};

async function handleAuthenticated(authClient: AuthClient) {
  const identity = await authClient.getIdentity();

  const agent = new HttpAgent({ identity });
  console.log(process.env.CANISTER_ID);
  const whoami_actor = Actor.createActor<_SERVICE>(idlFactory, {
    agent,
    canisterId: "bd3sg-teaaa-aaaaa-qaaba-cai",
  });
  // renderLoggedIn(whoami_actor, authClient);
  console.log("to log in");
  console.log(whoami_actor);
}

init();