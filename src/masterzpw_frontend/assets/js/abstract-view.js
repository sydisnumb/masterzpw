import unauthorized from '../html/components/unauthorized.html'

import logoImgPng from '../image/logo.png';

import { AuthClient } from "@dfinity/auth-client";


export default class {
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
        unauthorizedDiv.style.display = "none";
    }
    
    viewUnauthorized(){
        const unauthorizedDiv = document.getElementById("unauthorized-div");
        unauthorizedDiv.style.display = "block";
    }
    
    async loadContent(){
        this.init();
        this.hideUnauthorized()
        this.hideSpinner()
        this.viewApp()
    }

    loadUnauthorized(){
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