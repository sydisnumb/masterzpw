let utils = require("./utils.js")
let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import createOperaView from '../js/create-opera.js'
import operaView from '../js/opera.js'


import profile from '../html/pages/profile.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'
import newOperaBtnCmp from '../html/components/new-opera-btn.html'
import operaTabs from '../html/components/opera-tabs.html'
import nocontent from '../html/components/no-content.html'
import operaCard from '../html/components/opera-card.html'
import operasRow from '../html/components/operas-row.html'

import defaulUserPic from '../image/user.png'
import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';
import nocontentIcon from '../image/no-content-icon.png'


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    getOwnOperas = async (user, page) => {

        if(!await this.isAuthorized()){
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

        console.log(user)
        var result = await act.getOwnOperas(user.ownerType, page);

        if (result.Ok) {
            return [result.Ok, result.Ok.length!==0]
        } 

        return [null, false]
    }

    getSoldOperas = async (user, page) => {

        if(!await this.isAuthorized()){
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

        console.log(user)
        var result = await act.getSoldOperas(user.ownerType, page);

        if (result.Ok) {
            return [result.Ok, result.Ok.length!==0]
        } 

        return [null, false]
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
            { path: "/feed", view: feedView },
            { path: "/opera/:id", view: operaView }
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

    async loadBuyerPage(buyer){
        this.loadNavbar(buyer)
        this.loadCommonUserInfo(buyer)


        const feed = document.getElementById("feed-a");
        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesProfile)
        }

        const soldnftsDiv = document.getElementById("soldnfts-div");
        soldnftsDiv.style.display = "none";

        this.showOperasSpinner()
        
        this.page = 0
        this.loadMoreOperas(buyer, this.getOwnOperas)  
        

        this.loadFooter()

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

        this.showOperasSpinner()
        
        this.page = 0
        this.loadMoreOperas(company, this.getOwnOperas)

        const operaTab = document.getElementById("own-tab");
        const soldTab = document.getElementById("sold-tab");
        const galleryDiv = document.getElementById("gallery-div");

        operaTab.onclick = async () => {
            
            if(!operaTab.classList.contains("active")){
                this.showOperasSpinner()
                operaTab.classList.add("active")
                soldTab.classList.add('disabled')
                soldTab.classList.remove("active")
                galleryDiv.innerHTML = ""

                
                this.page = 0
                await this.loadMoreOperas(company, this.getOwnOperas)
                soldTab.classList.remove('disabled')

            }
        };

        soldTab.onclick = async () => {     

            if(!soldTab.classList.contains("active")){
                this.showOperasSpinner()
                soldTab.classList.add("active")
                operaTab.classList.add('disabled')
                operaTab.classList.remove("active")
                galleryDiv.innerHTML = ""


                this.page = 0
                await this.loadMoreOperas(company, this.getSoldOperas)
                operaTab.classList.remove('disabled')
            }
        };

        this.loadFooter()

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
        profilePic.src =  user.profilePictureUri


        const username = document.getElementById("username");
        username.textContent = user.username;

        const principal = document.getElementById("principal");
        principal.textContent = user.principal;

        const operaCount = document.getElementById("opera-count");
        operaCount.textContent = user.ownNfts.length;

        const nftsCount = document.getElementById("nfts-count");
        nftsCount.textContent = user.ownNfts.length;

    }

    loadNoOperas(message) {
        const galleryDiv = document.getElementById("gallery-div");
        galleryDiv.innerHTML = nocontent
        galleryDiv.classList.add("py-5")

        const par = document.getElementById("no-content-p");
        par.textContent = "No operas available at the moment!";

        const par1 = document.getElementById("no-content-p1");
        par1.textContent = message;

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon

        this.hideOperasSpinner()
    }

    async loadMoreOperas(user, getOperaFunction) {
        this.isLoading = true
        var [operas, flag] = await getOperaFunction(user, this.page)

        if(!flag) {
            this.loadNoOperas("")
            return
        }
        const galleryDiv = document.getElementById("gallery-div");
        galleryDiv.classList.remove("py-5")

        const newOperas = document.createElement('div');
        
        var i;
        for (i in operas) {
            console.log(i)
            var opera = operas[i]
            var operasRowDiv;

            if (i % 3 == 0) {
                // carichi riga
                operasRowDiv = document.createElement('div');
                operasRowDiv.innerHTML = operasRow
                operasRowDiv.classList.add('row');
                operasRowDiv.classList.add('align-self-center');
                operasRowDiv.classList.add('align-items-center');
                operasRowDiv.classList.add('my-3');
                operasRowDiv.classList.add('no-gutters');
                operasRowDiv.style.height = "300px";

                // Access the desired element within the container
                const col1 = operasRowDiv.querySelector('#col-1');
                col1.classList.add('bg-white')
                col1.innerHTML = operaCard
                this.fill_col(col1, opera);

            } else if (i % 3 == 1) {
                const col2 = operasRowDiv.querySelector('#col-2');
                col2.classList.add('bg-white')
                col2.innerHTML = operaCard
                this.fill_col(col2, opera);
            } else if (i % 3 == 2) {
                const col3 = operasRowDiv.querySelector('#col-3');
                col3.classList.add('bg-white')
                col3.innerHTML = operaCard
                this.fill_col(col3, opera);

                newOperas.innerHTML += operasRowDiv.outerHTML;
            }
        }

        if (i % 3 != 2) {
            newOperas.innerHTML += operasRowDiv.outerHTML;
        }

        galleryDiv.innerHTML += newOperas.innerHTML;

        let anchors = galleryDiv.querySelectorAll('.card-link');
        const self = this

        anchors.forEach(function(anchor) {
            anchor.onclick = async function(event) {
                var operaId = this.id;
                routerfn.navigateTo("/opera/"+operaId, self.routesProfile);
            }
        });

        this.page += 1
        this.hideOperasSpinner()

        this.isLoading = false
    }

    fill_col(coloumn, opera) {
        const anchor = coloumn.querySelectorAll('a')[0];
        anchor.id = opera.id

        const operaPic = coloumn.querySelectorAll('img')[0];
        operaPic.src = opera.pictureUri;

    };

}