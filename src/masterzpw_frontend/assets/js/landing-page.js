

let routerfn = require('./router')

// Import our custom CSS
import '../scss/styles.scss'

import completeProfile from './complete-profile.js'
import profile from './profile.js'
import feedView from '../js/feed.js'


let landingImg = 'https://ipfs.io/ipfs/QmPG8vWa8wUhftHASBsY6YSFdnuoWsmRZtgQFvFoasmJGC?filename=landing-image.png'
let logo = 'https://ipfs.io/ipfs/QmP5zE9GR4caevBvuFUscoZhg3dApNz2sZoj2UPhFhL6nv';
let icponchainImg = 'https://ipfs.io/ipfs/Qmb8WZ5qoHorgn36B11ogaY1Nw4iH51EEgc7KVX78Rqcz3';


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
        return [true, null];
      }
    }

    init = async () => {

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

      window.addEventListener("hashchange", function (){
        var contentDiv = document.getElementById("app");
        contentDiv.innerHTML = this.loadPage()
      });
     
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

      await this.loadNavbar()
      await this.loadFooter()


      // landing setting
      const landingDiv = document.getElementById("landing-ext-div");
      landingDiv.innerHTML += landing;
      const pictureLandingImg = document.getElementById("picture-landing");
      pictureLandingImg.src = landingImg;
      const logoLandingDiv = document.getElementById("logo-landing");
      logoLandingDiv.src = logo;


      const getStartedBtn = document.getElementById("getstarted-btn")
      getStartedBtn.onclick = async (event) => {
        event.preventDefault();
        const getstartedDiv = document.getElementById('get-started');
        getstartedDiv.scrollIntoView({ behavior: 'smooth' });
       }

      // mission setting
      const missionDiv = document.getElementById("mission");
      missionDiv.innerHTML += features;

      // get started
      const getstartedDiv = document.getElementById("get-started");
      getstartedDiv.innerHTML += getstarted;
      // about us setting
      const aboutusDiv = document.getElementById("about-us");
      aboutusDiv.innerHTML += aboutus;

      super.loadContent()
    }

    async loadNavbar() {
       // navbar setting
       const navbarDiv = document.getElementById("navbar-home");
       console.log(navbarDiv)
       navbarDiv.innerHTML = navbar;
       const navbarLogo = document.getElementById("navbar-logo");
       navbarLogo.src = logo;
       const signupHref = document.getElementById('signup-btn');
       signupHref.href = process.env.II_URL;

       const missionLink = document.getElementById("inshort-a")
       missionLink.onclick = async (event) => {
        event.preventDefault();
        const missionDiv = document.getElementById('mission');
        missionDiv.scrollIntoView({ behavior: 'smooth' });
       }

       const getStartedink = document.getElementById("getstarted-a")
       getStartedink.onclick = async (event) => {
        event.preventDefault();
        const getstartedDiv = document.getElementById('get-started');
        getstartedDiv.scrollIntoView({ behavior: 'smooth' });
       }

       const aboutusLink = document.getElementById("aboutus-a")
       aboutusLink.onclick = async (event) => {
        event.preventDefault();
        const aboutusDiv = document.getElementById('about-us');
        aboutusDiv.scrollIntoView({ behavior: 'smooth' });
       }
    }

    async loadFooter() {
       // footer setting
       const footerDiv = document.getElementById("footer");
       footerDiv.innerHTML += footer
       const icponchain = document.getElementById("icp-onchain");
       icponchain.src = icponchainImg;
 
    }

    
}