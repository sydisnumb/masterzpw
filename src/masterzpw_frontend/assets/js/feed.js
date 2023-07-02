let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import operaView from '../js/opera.js'

import feed from '../html/pages/feed.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'
import operasRow from '../html/components/operas-row.html'
import operaCardFeed from '../html/components/opera-card-feed.html'
import nocontent from '../html/components/no-content.html'

import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';
import nocontentIcon from '../image/no-content-icon.png'


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

    checkOperas = async () => { 

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

        let res = await act.checkOperas();
        return res;
    }

    getOperasByPage = async (user, page) => {
        let authClient = await AuthClient.create();

        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });

        var result = await act.getOperas(page);

        console.log(result)
        if (result.Ok) {
            if(result.Ok.length===0){
                return [null, false]
            }
            
            return [result.Ok, true]
        } 

        return [null, false]
    }


    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesFeed)
        });

        // window.addEventListener('scroll', async function() {
        //     if (!this.isLoading && window.innerHeight + window.scrollY >= document.body.offsetHeight) {
        //       await loadMoreContent();
        //     }
        // });

        let authClient = await AuthClient.create();

        const feed = document.getElementById("feed-a");
        const viewProfile = document.getElementById("profile-a");
        const logout = document.getElementById("logout-a");

        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesFeed)
        }

        viewProfile.onclick = async () => {
            routerfn.navigateTo("/profile", this.routesFeed)
        }

        logout.onclick = async () => {
            authClient.logout()
            alert("Log out successfull.")
            routerfn.navigateTo("/landing-page", this.routesFeed)
        }
    }


    constructor(params) {
        super(params);
        this.setTitle("Feed - COOL Art");

        this.page=0;

        this.routesFeed = [
            { path: "/profile", view: profileView },
            { path: "/landing-page", view: landingPageView },
            { path: "/feed", view: feedView },
            { path: "/opera/:id", view: operaView}
        ]
    }

    async getHtml() {
        return feed;
    }

    async loadPage() {
        super.loadPage();
        this.loadContent()
    }

    async loadContent() {
        
        if(!await this.isAuthorized()){ 
            await this.loadUnauthorized();
            return
        }

        this.loadNavbar()
        this.loadFooter()

        this.page = 0;
        this.showOperasSpinner();
        this.loadMoreOperas(null, this.getOperasByPage, this.routesFeed)

        super.loadContent()
    }

    async loadMoreOperas(user, getOperaFunction, routes) {
        this.isLoading = true
        var [operas, flag] = await getOperaFunction(user, this.page)

        if(!flag) {
            this.loadNoOperas()
            return
        }
        const galleryDiv = document.getElementById("gallery-div");
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
                col1.innerHTML = operaCardFeed
                this.fill_col(col1, opera);

            } else if (i % 3 == 1) {
                const col2 = operasRowDiv.querySelector('#col-2');
                col2.classList.add('bg-white')
                col2.innerHTML = operaCardFeed
                this.fill_col(col2, opera);
            } else if (i % 3 == 2) {
                const col3 = operasRowDiv.querySelector('#col-3');
                col3.classList.add('bg-white')
                col3.innerHTML = operaCardFeed
                this.fill_col(col3, opera);

                newOperas.innerHTML += operasRowDiv.outerHTML;
            }
        }

        if (i % 3 != 2) {
            newOperas.innerHTML += operasRowDiv.outerHTML;
        }

        galleryDiv.innerHTML += newOperas.innerHTML;

        let anchors = galleryDiv.querySelectorAll('.card-link');
        var self = this

        anchors.forEach(function(anchor) {
            anchor.onclick = async function(event) {
                var operaId = this.id;
                routerfn.navigateTo("/opera/"+operaId, self.routesFeed);
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

    loadNoOperas() {
        const galleryDiv = document.getElementById("gallery-div");
        galleryDiv.innerHTML = nocontent


        const par = document.getElementById("no-content-p");
        par.textContent = "No operas available at the moment!";

        const par1 = document.getElementById("no-content-p1");
        par1.textContent = "Visit your profile";

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon

        this.hideOperasSpinner()
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
}