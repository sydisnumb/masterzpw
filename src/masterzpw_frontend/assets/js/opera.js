let utils = require("./utils.js")
let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import createOperaView from '../js/create-opera.js'


import opera from '../html/pages/opera.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'
import nocontent from '../html/components/no-content.html'


import nocontentIcon from '../image/no-content-icon.png'
import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {


    getOpera = async (operaId) => {


        if(! await this.isAuthorized()){
            await this.loadUnauthorized()
            return
        }

        let authClient = await AuthClient.create();

        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });

        var result = await act.getOpera(parseInt(operaId));

        if(result.Ok){
            return [result.Ok, true]
        }
        
        return [null, false]
    }


    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesProfile)
        });
    }


    constructor(params) {
        super(params);
        this.setTitle("Opera - COOL Art");

        this.routesOpera = [
            { path: "/profile", view: profileView },
            { path: "/landing-page", view: landingPageView },
            { path: "/create-opera", view: createOperaView },
            { path: "/feed", view: feedView }
        ]
    }

    async getHtml() {
        return opera;
    }

    async loadPage() {
        super.loadPage();
        this.loadContent()
    }

    async loadContent() {
        
        if(! await this.isAuthorized()){
            await this.loadUnauthorized()
            return
        }

        let [user, ownerType] = await this.getUser()

        if(ownerType==="company"){
            await this.loadCompanyPage()
        } else {
            await this.loadBuyerPage()
        }

        super.loadContent()
    }

    async loadBuyerPage(){
        this.loadNavbar(company)
        this.loadFooter()

        const feed = document.getElementById("feed-a");

        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesProfile)
        }

    }

    async loadCompanyPage(company){
        this.loadNavbar()
        await this.loadOperaInfo()
        this.loadFooter()
    }

    loadNavbar(){
        const navbarDiv = document.getElementById("navbar-div");
        navbarDiv.innerHTML = navbar;

        const togglerIcon = document.getElementById("toggler-icon");
        togglerIcon.src = userIcon;

        const logoFeed = document.getElementById("feed-a");
        logoFeed.src = logo;

       

        const viewProfile = document.getElementById("profile-a");
        const logout = document.getElementById("logout-a");


        viewProfile.onclick = async () => {
            routerfn.navigateTo("/profile", this.routesOpera)
        }

        logout.onclick = async () => {
            authClient.logout()
            routerfn.navigateTo("/landing-page", this.routesOpera)
        }
    }

    loadFooter(){
        const footerDiv = document.getElementById("footer-div");
        footerDiv.innerHTML = footer;

        const icponchain = document.getElementById("icp-onchain");
        icponchain.src = icponchainImg;
    }

    async loadOperaInfo(){
        var [opera, flag] = await this.getOpera(this.params.id)
        const contentDiv = document.getElementById("content-id");

        console.log(opera)

        if(!flag){
            this.loadNoOperas(contentDiv)
            return
        } 

        const operaImg = document.getElementById("opera-img");
        operaImg.src = opera.pictureUri

        const title = document.getElementById("title");
        title.textContent = opera.name

        const description = document.getElementById("description");
        description.textContent = opera.description

        const price = document.getElementById("price");
        price.textContent = opera.price + " Euro"
        
    }


    loadNoOperas(div) {
        div.innerHTML = nocontent

        const par = document.getElementById("no-content-p");
        par.textContent = "No operas available at the moment!";

        const par1 = document.getElementById("no-content-p1");
        par1.textContent = "";

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon
    }
}