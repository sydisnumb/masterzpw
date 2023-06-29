let utils = require("./utils.js")
let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import createOperaView from '../js/create-opera.js'


import profile from '../html/pages/profile.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'
import newOperaBtnCmp from '../html/components/new-opera-btn.html'
import operaTabs from '../html/components/opera-tabs.html'

import defaulUserPic from '../image/user.png'
import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    getOwnOperas = async (user, page) => {

        if(await this.isAuthorized()){
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

        var result = await act.getOwnOperas(user.ownerType, page);

        if (result.Ok) {
            console.log(result)
            operas = result.Ok;
            return [operas, true]
        } 

        return [null, false]
    }

    getSoldOperas = async (pag) => {

    }

    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesProfile)
        });

        let authClient = await AuthClient.create();

        const viewProfile = document.getElementById("profile-a");
        const logout = document.getElementById("logout-a");


        viewProfile.onclick = async () => {
            routerfn.navigateTo("/profile", this.routesProfile)
        }

        logout.onclick = async () => {
            authClient.logout()
            alert("Log out successfull.")
            routerfn.navigateTo("/landing-page", this.routesProfile)
        }
    }


    constructor(params) {
        super(params);
        this.setTitle("Profile - COOL Art");
        this.page=0

        this.routesProfile = [
            { path: "/profile", view: profileView },
            { path: "/landing-page", view: landingPageView },
            { path: "/create-opera", view: createOperaView },
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
        
        if(! await this.isAuthorized()){
            await this.loadUnauthorized()
            return
        }
        var [user, ownerType, flag] = await this.getUser()

        console.log(user, ownerType, flag)

        if(!flag) {
            await this.loadUnauthorized()
            return
        }

        if(ownerType === "buyer"){
            await this.loadBuyerPage(user);
        } else {
            await this.loadCompanyPage(user);
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

        const soldnftsDiv = document.getElementById("soldnfts-div");
        soldnftsDiv.style.display = "none";
      
        const profilePic = document.getElementById("profile-pic");
        await utils.checkImageSourceExists(user.profilePictureUri, function(exists) {
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
        
       

        var [operas, flag] = await getOperas(0)

        if(!flag) {
            // scrivi qualcosa
        } else {
            const galleryDiv = document.getElementById("gallery-div");
            
            this.loadGallery()
            
            galleryDiv
        }
    }

    async loadCompanyPage(company){
        this.loadNavbar()
        this.loadCommonUserInfo(company)

        const soldnftsCount = document.getElementById("soldnfts-count");
        soldnftsCount.textContent = company.soldNfts.length;

        if(document.getElementById("newopera-btn") == undefined){
            const userDiv = document.getElementById("user-div");
            const buttonRow = document.createElement('div')
            buttonRow.classList.add("row")
            buttonRow.classList.add("px-2")
            buttonRow.classList.add("mt-2")
            buttonRow.innerHTML = newOperaBtnCmp;
            userDiv.appendChild(buttonRow)
        }

        const newOperaBtn = document.getElementById("newopera-btn");
        newOperaBtn.onclick = async () => {
            routerfn.navigateTo("/create-opera", this.routesProfile)
        };

        const tabsDiv = document.getElementById("tabs-div");
        tabsDiv.innerHTML = operaTabs;

        this.loadGallery(company, getOwnOperas)

        const operaTab = document.getElementById("opera-tab");
        const soldTab = document.getElementById("sold-tab");


        // operaTab.onclick = async () => {
        //     const ownBtn = document.getElementById("own-tab");
        //     const soldBtn = document.getElementById("sold-tab");
            
        //     if(!ownBtn.classList.contains("active")){ 
        //         ownBtn.classList.add("active")
        //         soldBtn.classList.remove("active")

        //         this.opera = 0
        //         this.loadGallery(company, getOwnOperas)
        //     }
        
        // };

        // soldTab.onclick = async () => {
        //     const soldBtn = document.getElementById("sold-tab");
        //     const ownBtn = document.getElementById("own-tab");
            
        //     if(!soldBtn.classList.contains("active")){ 
        //         soldBtn.classList.add("active")
        //         ownBtn.classList.remove("active")

        //         this.opera = 0
        //         this.loadGallery(company, getSoldOperas)
        //     }
        // };

        this.loadFooter()

    }

    async loadMoreOperas (user, getOperaFunction) {
        this.isLoading = true
        var [operas, flag] = await getOperaFunction(this.page)

        if(flag) {
            const galleryDiv = document.getElementById("gallery-div");
            const newOperas = document.createElement('div');

            var i = 0;

            for (var opera in operas) {
                var operasRowDiv;

                if (i % 3 == 0) {
                    // carichi riga
                    operasRowDiv = document.createElement('div');
                    operasRowDiv.innerHTML = operasRow
                    operasRowDiv.classList.add('row g-2');

                    // Access the desired element within the container
                    const col1 = operasRowDiv.querySelector('#col-1');
                    col1.innerHTML = operaCard

                    this.fill_col(col1, opera);

                } else if (i % 3 == 1) {
                    const col2 = operasRowDiv.querySelector('#col-2');
                    col2.innerHTML = operaCard
 
                    this.fill_col(col2, opera);
                } else if (i % 3 == 2) {
                    const col3 = operasRowDiv.querySelector('#col-3');
                    col3.innerHTML = operaCard
 
                    this.fill_col(col3, opera);
                }

                newOperas.innerHTML += operasRowDiv;

            }

            let anchors = newOperas.getElementsByTagName('a')
            for (var anch in anchors) {
                anch.addEventListener('click', () => {
                    var operaId = this.getAttribute('id');
                    routerfn.navigateTo("/opera/"+operaId, this.routesFeed);
                } );
            }

            galleryDiv.innerHTML += newOperas;
        }

        this.page += 1
        this.isLoading = false
    }

    loadNavbar(){
        const navbarDiv = document.getElementById("navbar-div");
        navbarDiv.innerHTML = navbar;

        const togglerIcon = document.getElementById("toggler-icon");
        togglerIcon.src = userIcon;

        const logoFeed = document.getElementById("feed-a");
        logoFeed.src = logo;

       
    }

    loadFooter(){
        const footerDiv = document.getElementById("footer-div");
        footerDiv.innerHTML = footer;

        const icponchain = document.getElementById("icp-onchain");
        icponchain.src = icponchainImg;
    }

    loadCommonUserInfo(user){

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

    }


}