let utils = require("./utils.js")
let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import createOperaView from '../js/create-opera.js'


import opera from '../html/pages/opera.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'



import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {


    getOpera = async () => {

        if(await this.isAuthorized()){
            await this.loadUnauthorized()
            return
        }

        return [null, false]
    }


    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesProfile)
        });

        let authClient = await AuthClient.create();

       
       
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

        await this.loadCompanyPage()

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
        this.loadCommonUserInfo(company)
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
            routerfn.navigateTo("/profile", this.routesProfile)
        }

        logout.onclick = async () => {
            authClient.logout()
            routerfn.navigateTo("/landing-page", this.routesProfile)
        }
    }

    loadFooter(){
        const footerDiv = document.getElementById("footer-div");
        footerDiv.innerHTML = footer;

        const icponchain = document.getElementById("icp-onchain");
        icponchain.src = icponchainImg;
    }

    loadCommonUserInfo(user){


    }

    loadGallery () {
        
    }
}