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
import spinner from '../html/components/spinner.html'




function loadComponents() {
    // navbar setting
    const navbarDiv = document.getElementById("navbar-home");
    navbarDiv.innerHTML += navbar;
    const navbarLogo = document.getElementById("navbar-logo");
    navbarLogo.src = logo;
    const signupHref = document.getElementById('signup-btn');
    signupHref.href = process.env.II_URL;

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
    let act = controller;
    let authClient = await AuthClient.create();
    var alertDiv = document.getElementById("alert-div");

    signUpBtn.onclick = async () => {
        authClient.login({
            identityProvider: process.env.II_URL,
            onSuccess: () => {
              alertDiv.innerHTML = "Your Internet Identity is successfully registrated! Welcome to COOL ART.";
              alertDiv.className = 'alert-success';
              alertDiv.style.display = "block";

              setTimeout(function() {
                alertDiv.style.display = "none";
              }, 3000);
            },
            onError: () => {
              alertDiv.innerHTML = "Something went wrong! Try again.";
              alertDiv.className = 'alert-danger';
              alertDiv.style.display = "block";

              setTimeout(function() {
                alertDiv.style.display = "none";
              }, 3000);
            }          
          });
    };
  
    logInBtn.onclick = async () => {
        authClient.login({
          identityProvider: process.env.II_URL,
          onSuccess: async () => {
            console.log("go to log in")
            const bodyCont = document.getElementById("body-content")
            bodyCont.style.display = "none";
            document.body.innerHTML +=  spinner;
            const identity = authClient.getIdentity();
            console.log(identity);

            const agent = new HttpAgent({identity});
            act = createActor(process.env.CONTROLLER_CANISTER_ID, {
              agent,
              canisterId: process.env.CONTROLLER_CANISTER_ID,
            });

            let result = await act.login();

            if (result.Err.FirstAccess) {
                console.log("visualizza profilo utente")
                window.location.href = './complete-profile.html';
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