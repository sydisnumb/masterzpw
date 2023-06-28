

let routerfn = require('./router')

// Import our custom CSS
import '../scss/styles.scss'

import completeProfile from './complete-profile.js'
import profile from './profile.js'
import feedView from '../js/feed.js'


import logo from '../image/logo.png';
import landingImg from '../image/landing-image.png';
import icponchainImg from '../image/icp-onchain.png';

import landingPage from '../html/pages/landing-page.html'
import navbar from '../html/components/navbar.html'
import footer from '../html/components/footer.html'
import landing from '../html/components/landing.html'
import features from '../html/components/features.html'
import aboutus from '../html/components/about-us.html'
import getstarted from '../html/components/get-started.html'


import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { createActor, controller } from "../../../declarations/controller";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    checkFirstLogin = async () => {   
      let act = controller;
      let authClient = await AuthClient.create();
      const identity = authClient.getIdentity();
      const agent = new HttpAgent({identity});

      act = createActor(process.env.CONTROLLER_CANISTER_ID, {
        agent,
        canisterId: process.env.CONTROLLER_CANISTER_ID,
      });

      let result = await act.login();
      
      if (result.Ok) {
        if (result.Ok.Buyer){
          return [false, "buyer"];
        }
        
        return [false, "company"];
      } else if(result.Err.FirstAccess) {
        return true;
      }
    }

    init = async () => {

      window.addEventListener("popstate", async () => {routerfn.router(this.routesLandingPage)});

      const signUpBtn = document.getElementById("signup-btn");
      const logInBtn = document.getElementById("login-btn");

      let authClient = await AuthClient.create();


      signUpBtn.onclick = async () => {
          authClient.login({
              identityProvider: process.env.II_URL,
              onSuccess: () => {
                alert("Your Internet Identity is successfully registrated! Welcome to COOL ART.");
                
              },
              onError: () => {
                alert("Something went wrong! Try again.");
              }          
            });
      };
    
      logInBtn.onclick = async () => {
          authClient.login({
            identityProvider: process.env.II_URL,
            onSuccess: async () => {              
              var [res, ownerType] = await this.checkFirstLogin()

              if (!res) {
                if (ownerType === 'buyer'){
                  routerfn.navigateTo('/feed', this.routesLandingPage)
                  return
                }

                routerfn.navigateTo('/profile', this.routesLandingPage)
                return
              } else  {
                routerfn.navigateTo('/complete-profile', this.routesLandingPage)
              }
            },
            onError: () => {
              console.log("error")
            }          
        });
      };
     
    }

    constructor(params) {
        super(params);
        this.setTitle("Home - COOL art");

        this.routesLandingPage = [
          { path: "/complete-profile", view: completeProfile },
          { path: "/profile", view: profile },
          { path: "/feed", view: feedView}
        ]
    }

    async getHtml() {
      return landingPage
    }

    async loadPage() {
      super.loadPage()
      this.loadContent()
     
    }

    async loadContent(){

      if(await this.isAuthorized()){
        var [res, ownerType] = await this.checkFirstLogin();
        console.log(res)

        if (!res) {
          if (ownerType === 'buyer'){
            routerfn.navigateTo('/feed', this.routesLandingPage)
            return
          }

          routerfn.navigateTo('/profile', this.routesLandingPage)
          return
        } else  {
          routerfn.navigateTo('/complete-profile', this.routesLandingPage)
        }

        return 
      }

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

      super.loadContent()
    }


    
}