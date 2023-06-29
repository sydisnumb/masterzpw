import unauthorized from '../html/components/unauthorized.html'

import logoImgPng from '../image/logo.png';

import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";


export default class {

    getUser = async () => {
        let authClient = await AuthClient.create();

        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });

        var result = await act.getBuyer();
        var ownerType = null;
        var user;

        if (result.Ok) {
            console.log(result)
            ownerType = result.Ok.ownerType;
            user = result.Ok;
        } else {
            result = await act.getCompany();
            if (result.Ok) {
                ownerType = result.Ok.ownerType;
                user = result.Ok

            } else {
                return [null, null, false]
            }
        }

        return [user, ownerType, true]
    }

    constructor(params) {
        this.params = params;
    }

    isAuthorized = async () => {
        let authClient = await AuthClient.create();
        return await authClient.isAuthenticated();
    }

    setTitle(title) {
        document.title = title;
    }

    async getHtml() {
        return "";
    }

    async loadPage() {
        this.hideApp()
        this.hideUnauthorized()
        this.viewSpinner()
    }

    viewSpinner(){
        const spinner = document.getElementById("loadingSpinner")
        spinner.style.display = 'block';
    }

    hideSpinner(){
        const spinner = document.getElementById("loadingSpinner")
        spinner.style.display = 'none';
    }

    hideApp(){
        const app = document.getElementById("app");
        app.style.display = "none";
    }

    viewApp(){
        const app = document.getElementById("app");
        app.style.display = "block";
    }

    hideUnauthorized(){
        let unauthorizedDiv = document.getElementById("unauthorized-div");
        unauthorizedDiv.classList.remove('d-flex');
        unauthorizedDiv.style.display = "none";
    }
    
    viewUnauthorized(){
        const unauthorizedDiv = document.getElementById("unauthorized-div");
        authorizedDiv.classList.remove('d-flex');
        unauthorizedDiv.style.display = "block";
    }
    
    async loadContent(){
        this.init();
        this.hideUnauthorized()
        this.hideSpinner()
        this.viewApp()
    }

    async loadUnauthorized(){
        this.hideApp()
        this.hideUnauthorized()
        this.viewSpinner()
       
        let unauthorizedDiv = document.getElementById("unauthorized-div");
        unauthorizedDiv.innerHTML = unauthorized;
        let logo = document.getElementById("logo-unauthorized");
        logo.src = logoImgPng;
        
        this.hideSpinner()
        this.viewUnauthorized()
    }
}