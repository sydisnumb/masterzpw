// Import our custom CSS
import '../scss/styles.scss'

import logo from '../image/logo.png';
import landingImg from '../image/landing-image.png';
import icponchainImg from '../image/icp-onchain.png';


import navbar from '../html/components/navbar.html'
import footer from '../html/components/footer.html'
import landing from '../html/components/landing.html'
import features from '../html/components/features.html'
import aboutus from '../html/components/about-us.html'
import getstarted from '../html/components/get-started.html'




function loadComponents() {
    // navbar setting
    const navbarDiv = document.getElementById("navbar-home");
    navbarDiv.innerHTML += navbar;
    const navbarLogo = document.getElementById("navbar-logo");
    navbarLogo.src = logo;

    // footer setting
    const footerDiv = document.getElementById("footer");
    footerDiv.innerHTML += footer
    const icponchain = document.getElementById("icp-onchain");
    icponchain.src = icponchainImg;

}

function loadPage() {
    // landing setting
    const landingDiv = document.getElementById("landing-ext-div");
    landingDiv.innerHTML += landing;
    const pictureLandingImg = document.getElementById("picture-landing");
    pictureLandingImg.src = landingImg;
    const logoLandingDiv = document.getElementById("logo-landing");
    logoLandingDiv.src = logo;

    // mission setting
    const missionDiv = document.getElementById("mission");
    missionDiv.innerHTML += features;

    // get started
    const getstartedDiv = document.getElementById("get-started");
    getstartedDiv.innerHTML += getstarted;
    // about us setting
    const aboutusDiv = document.getElementById("aboutus");
    aboutusDiv.innerHTML += aboutus;

}

loadComponents();
loadPage();





// callback for button

import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { createActor, controller } from "../../../../declarations/controller";

const signUpBtn = document.getElementById("signup-btn");
const logInBtn = document.getElementById("login-btn");



const init = async () => {
    let actor = controller;
    let authClient = await AuthClient.create();

    signUpBtn.onclick = async () => {
        authClient.login({
            identityProvider: process.env.II_URL,
            onSuccess: () => {
              var alertDiv = document.getElementById("successAlert");
              alertDiv.innerHTML = "Your Internet Identity is successfully registrated! Welcome to COOL ART.";
              alertDiv.className = 'alert-success';
              alterObj = alertDiv.alert();
              alertObj.alert('show')

              setTimeout(function() {
                alertObj.close();
              }, 3000);
            },
            onError: () => {
              alertDiv.innerHTML = "Something went wrong! Try again.";
              alertDiv.className = 'alert-danger';
              alterObj = alertDiv.alert();
              alertObj.alert('show');

              setTimeout(function() {
                alertObj.close();
              }, 3000);
            }          
          });
    };
  
    logInBtn.onclick = async () => {
      authClient.login({
        identityProvider: iiUrlEl.value,
        onSuccess: async () => {
          console.log("go to log in")
            // At this point we're authenticated, and we can get the identity from the auth client:
            const identity = authClient.getIdentity();
            const agent = new HttpAgent({identity});
            // Using the interface description of our webapp, we create an actor that we use to call the service methods.
            controller = createActor(process.env.CONTROLLER_CANISTER_ID, {agent});

            let firstAccessFlag = await controller.login(identity);

            if (firstAccessFlag) {
                console.log("pagina di login");
            } else {
                console.log("visualizza profilo utente")
            }
        },
        onError: () => {
          console.log("error")
        }          
      });
    };

    
}

init();