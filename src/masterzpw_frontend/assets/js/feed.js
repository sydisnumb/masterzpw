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

let nocontentIcon = "https://ipfs.io/ipfs/QmXPX5UbfuV8PzUdCwYp94p5TTmVSgAUzKiHNdFM75de8d"
let userIcon = 'https://ipfs.io/ipfs/QmVhnFJkhvRpcebhewdknLBtSNsf9YPLLm8vp7M2Ys35rv'
let logo = 'https://ipfs.io/ipfs/QmP5zE9GR4caevBvuFUscoZhg3dApNz2sZoj2UPhFhL6nv';
let icponchainImg = 'https://ipfs.io/ipfs/Qmb8WZ5qoHorgn36B11ogaY1Nw4iH51EEgc7KVX78Rqcz3';


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {

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

        if (result.Ok) {
            if(result.Ok.length===0){
                return [null, false]
            }
            
            return [result.Ok, true]
        } 

        return [null, false]
    }


    init = async () => {

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
        var [operas, flag] = await getOperaFunction(user, -1)

        if(!flag) {
            this.loadNoOperas()
            return
        }
        const galleryDiv = document.getElementById("gallery-div");
        const newOperas = document.createElement('div');
        
        var i;
        for (i in operas) {
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
                col1.classList.add('shadow-sm')
                col1.innerHTML = operaCardFeed
                this.fill_col(col1, opera);

            } else if (i % 3 == 1) {
                const col2 = operasRowDiv.querySelector('#col-2');
                col2.classList.add('bg-white')
                col2.classList.add('shadow-sm')

                col2.innerHTML = operaCardFeed
                this.fill_col(col2, opera);
            } else if (i % 3 == 2) {
                const col3 = operasRowDiv.querySelector('#col-3');
                col3.classList.add('bg-white')
                col3.classList.add('shadow-sm')

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