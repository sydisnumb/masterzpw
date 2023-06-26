let utils = require("./utils.js")
let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'

import profile from '../html/pages/profile.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'

import defaulUserPic from '../image/user.png'
import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';



import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    isAuthorized = async () => {
        let authClient = await AuthClient.create();
        return await authClient.isAuthenticated();
    }

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

    getOpera = async (page) => {

        if(await this.isAuthorized()){
            this.loadUnauthorized()
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

        var result = await act.getOperas(page);


        if (result.Ok) {
            console.log(result)
            operas = result.Ok;
            return [operas, true]
        } 

        return [null, false]
    }


    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesProfile)
        });

        let authClient = await AuthClient.create();

        const feed = document.getElementById("feed-a");
        const viewProfile = document.getElementById("profile-a");
        const logout = document.getElementById("logout-a");

        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesProfile)
        }

        viewProfile.onclick = async () => {
            routerfn.navigateTo("/profile", this.routesProfile)
        }

        logout.onclick = async () => {
            authClient.logout()
            routerfn.navigateTo("/landing-page", this.routesProfile)
        }
    }


    constructor(params) {
        super(params);
        this.setTitle("Profile - COOL Art");

        this.routesProfile = [
            { path: "/profile", view: profileView },
            { path: "/landing-page", view: landingPageView },
            { path: "/feed", view: feedView }
        ]
    }

    async getHtml() {
        return profile;
    }

    async loadPage() {
        super.loadPage();
        this.loadContent()
    }

    async loadContent() {
        
        if(await this.isAuthorized()){
            var [user, ownerType, flag] = await this.getUser()

            console.log(user, ownerType, flag)

            if(!flag) {
                this.loadUnauthorized()
                return
            }

            const navbarDiv = document.getElementById("navbar-div");
            navbarDiv.innerHTML = navbar;

            const togglerIcon = document.getElementById("toggler-icon");
            togglerIcon.src = userIcon;

            const logoFeed = document.getElementById("feed-a");
            logoFeed.src = logo;

            const profilePic = document.getElementById("profile-pic");
            utils.checkImageSourceExists(user.profilePictureUri, function(exists) {
                profilePic.src = (exists) ? user.profilePictureUri : defaulUserPic
            })

            const username = document.getElementById("username");
            username.textContent = user.username;

            const principal = document.getElementById("principal");
            principal.textContent = user.principal;

            const operaCount = document.getElementById("opera-count");
            operaCount.textContent = user.ownNfts.length;

            const nftsCount = document.getElementById("nfts-count");
            nftsCount.textContent = user.ownNfts.length;

            const usernameDesc = document.getElementById("username-span");
            usernameDesc.textContent = user.username;
            
            const footerDiv = document.getElementById("footer-div");
            footerDiv.innerHTML = footer;

            const icponchain = document.getElementById("icp-onchain");
            icponchain.src = icponchainImg;

            var [operas, flag] = await getOperas(0)

            if(!flag) {
                // scrivi qualcosa
            } else {
                const galleryDiv = document.getElementById("gallery-div");
                
                this.loadGallery()
               
                galleryDiv
            }

            super.loadContent()
        } else {
            this.loadUnauthorized()
        }
    }

    loadGallery () {
        for (var opera in operas) {

        }
    }
}