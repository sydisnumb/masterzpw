let routerfn = require('./router')
// Import our custom CSS
import '../scss/styles.scss'

import profile from '../js/profile.js'

import completeProfile from '../html/pages/complete-profile.html';

import spinner from '../html/components/spinner.html'
import logoImg from '../image/cover.png';

import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    isAuthorized = async () => {
        let authClient = await AuthClient.create();
        return await authClient.isAuthenticated();
    }

    init = async () => {

        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesCompleteProfile)
        });


        let checkbox = document.getElementById("artist-checkbox");
        let submit = document.getElementById("submit-btn");
        
        checkbox.onclick = async () => {
            let merchantIdDiv = document.getElementById("merchantId-div");
            let merchantInput = document.getElementById("merchantid-field")
    
            if (checkbox.checked) {
                merchantIdDiv.style.display = "block";
                merchantInput.disabled = false;
            } else {
                merchantIdDiv.style.display = "none";
                merchantInput.disabled = true;

            }
        };
    
        submit.onclick = async () => {
            submit.disabled = true
            submit.innerHTML = spinner + submit.innerHTML

            let isAuthFlag = await this.isAuthorized()

            if(isAuthFlag) {
                let authClient = await AuthClient.create();
                const identity = authClient.getIdentity();
                const agent = new HttpAgent({identity});
                let act = controller;
                act = createActor(process.env.CONTROLLER_CANISTER_ID, {
                    agent,
                    canisterId: process.env.CONTROLLER_CANISTER_ID,
                });

                let username = document.getElementById("username-field").value;
                let profilePicUrl = (document.getElementById("profilepic-field").value !== "") ? "https://ipfs.io/ipfs/" + document.getElementById("profilepic-field").value : "";
                let merchantId = document.getElementById("merchantid-field").value;

                var callFlag = true;
                if(username === "") {
                    alert("Fill the Username field.")
                    callFlag = false;
                } else if (checkbox.checked &&  merchantId === "") {
                    alert("Fill the Merchant ID field.");
                    callFlag = false;
                }
                
                var res;
                if (callFlag && !checkbox.checked){
                    res = await act.createBuyer(username, profilePicUrl);
                } else if(callFlag && checkbox.checked) {
                    res = await act.createCompany(username, profilePicUrl, merchantId);
                }


                if (callFlag && res) {
                    if (res.Ok) {
                        routerfn.navigateTo('/profile', this.routesCompleteProfile);
                    } else {
                        message = res.Err.Other
                        alert(message)
                    }
                } 
                
                submit.innerHTML = 'Submit'
                submit.disabled = false
            } else {
                this.loadUnauthorized()
            }

            
        }
    }

    constructor(params) {
        super(params);
        this.setTitle("Complete profile - COOL art");

        this.routesCompleteProfile = [
            { path: "/profile", view: profile },
        ]

    }

    async getHtml() {
      return completeProfile;
    }

    async loadPage() {
        super.loadPage();
        this.loadContent()
    }

    async loadContent() {
        let isAuthorizedFlag = await this.isAuthorized()

        if(isAuthorizedFlag){
            let contentDiv = document.getElementById("content-div");
            contentDiv.style.backgroundRepeat = "repeat";
            contentDiv.style.backgroundImage = `url('${logoImg}')`;
            contentDiv.style.backgroundSize = "100px";
    
            let completForm = document.getElementById("complete-form");
            completForm.style.display = "block";
            super.loadContent()
        } else {
            this.loadUnauthorized()
        }
       
       
    }    
}