let routerfn = require("./router.js")

import profileView from '../js/profile.js';
import landingPageView from '../js/landing-page.js';
import feedView from '../js/feed.js'
import operaView from '../js/opera.js'

import feed from '../html/pages/feed.html';
import navbar from '../html/components/navbar-1.html'
import footer from '../html/components/footer-1.html'
import operasRow from '../html/components/operas-row.html'
import operaCard from '../html/components/opera-card.html'
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

    getOperasByPage = async (page) => {

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

        var result = await act.getOperas(page);


        if (result.Ok) {
            console.log(result)
            operas = result.Ok;
            this.page += 1;
            return [operas, true]
        } 

        return [null, false]
    }


    init = async () => {
        
        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesFeed)
        });

        window.addEventListener('scroll', async function() {
            if (!this.isLoading && window.innerHeight + window.scrollY >= document.body.offsetHeight) {
              await loadMoreContent();
            }
        });

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
            alert("Log out avvenuto con successo!")
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
            { path: "/profile/:id", view: operaView}
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

        const navbarDiv = document.getElementById("navbar-div");
        navbarDiv.innerHTML = navbar;

        const togglerIcon = document.getElementById("toggler-icon");
        togglerIcon.src = userIcon;

        const logoFeed = document.getElementById("feed-a");
        logoFeed.src = logo;

        
        const footerDiv = document.getElementById("footer-div");
        footerDiv.innerHTML = footer;

        const icponchain = document.getElementById("icp-onchain");
        icponchain.src = icponchainImg;

        var flag = await this.checkOperas()
        this.page = 0;

        if(!flag) {
            await this.loadNoOperas()
        } else {                
            this.loadMoreOperas()
        }

        super.loadContent()
        
    }

    async loadMoreOperas() {
        this.isLoading = true
        var [operas, flag] = await getOperasByPage(this.page)

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

        this.isLoading = false
    };

    loadNoOperas() {
        const galleryDiv = document.getElementById("gallery-div");
        galleryDiv.innerHTML = nocontent

        const par = document.getElementById("no-content-p");
        par.textContent = "No operas available at the moment!";

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon
    }



    fill_col(coloumn, opera) {
        const anchor = coloumn.querySelectorAll('a')[0];
        anchor.id = opera.id

        const operaPic = coloumn.querySelectorAll('img')[0];
        operaPic.src = opera.pictureUri;

        const title = coloumn.querySelector('#opera-title');
        title.textContent = opera.name

        const description = coloumn.querySelector('#opera-description');
        description.textContent = opera.description

        const nft = coloumn.querySelector('#nft-id');
        nft.textContent = opera.nfts[0]

        const price = coloumn.querySelector('#opera-title');
        price.textContent = opera.name
    };
}