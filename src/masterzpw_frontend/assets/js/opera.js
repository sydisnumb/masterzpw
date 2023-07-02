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
import paypalBtn from '../html/components/paypal-btn.html'
import alertSold from '../html/components/opera-not-available.html'


let nocontentIcon = "https://ipfs.io/ipfs/QmXPX5UbfuV8PzUdCwYp94p5TTmVSgAUzKiHNdFM75de8d"
let userIcon = 'https://ipfs.io/ipfs/QmVhnFJkhvRpcebhewdknLBtSNsf9YPLLm8vp7M2Ys35rv'
let logo = 'https://ipfs.io/ipfs/QmP5zE9GR4caevBvuFUscoZhg3dApNz2sZoj2UPhFhL6nv';
let icponchainImg = 'https://ipfs.io/ipfs/Qmb8WZ5qoHorgn36B11ogaY1Nw4iH51EEgc7KVX78Rqcz3';


import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { loadScript } from "@paypal/paypal-js";

import AbstractView from "./abstract-view.js";

export default class extends AbstractView {


    getOpera = async (operaId) => {

        console.log(parseInt(operaId))
        if(! await this.isAuthorized() || isNaN(parseInt(operaId))){
            await this.loadUnauthorized()
            return [null, false]
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


    getCompanyByOperaId = async (operaId) => {
        if(! await this.isAuthorized() || isNaN(parseInt(operaId))){
            await this.loadUnauthorized()
            return [null, false];
        }

        let authClient = await AuthClient.create();

        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });

        let result = await act.getCompanyByOperaId(parseInt(operaId));
        console.log(result);

        if(result.Ok !== undefined) {
            return [result.Ok, true];
        } else if (result.Err != undefined) {
            return [null, false];
        }

        return result[null, false];
    }

    init = async () => { }

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
            await this.loadBuyerPage(user)
        }

        super.loadContent()
    }

    async loadBuyerPage(user){
        this.loadNavbar(user)
        const feed = document.getElementById("feed-a");
        let self = this
        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesOpera)
        }

        let opera = await this.loadOperaInfo();
        await this.laodPaypalBtn(user, opera);    
        this.loadFooter()
    }

    async loadCompanyPage(){
        this.loadNavbar()
        await this.loadOperaInfo()
        this.loadFooter()
    }

    
    async loadOperaInfo(){
        var [opera, flag] = await this.getOpera(this.params.id)
        const contentDiv = document.getElementById("content-id");

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
        price.textContent = "€ "+opera.price

        return opera
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
            let authClient = await AuthClient.create();
            authClient.logout()
            alert("Logout done!")
            routerfn.navigateTo("/landing-page", this.routesOpera)
        }
    }

    loadFooter(){
        const footerDiv = document.getElementById("footer-div");
        footerDiv.innerHTML = footer;

        const icponchain = document.getElementById("icp-onchain");
        icponchain.src = icponchainImg;
    }

    loadNoOperas(div) {
        div.innerHTML = nocontent

        const par = document.getElementById("no-content-p");
        par.textContent = "No opera!";

        const par1 = document.getElementById("no-content-p1");
        par1.textContent = "";

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon
    }

    async laodPaypalBtn(buyer, opera){
        const operaInfoDiv = document.getElementById("opera-info");
        operaInfoDiv.innerHTML += paypalBtn;

        var [company, flag] = await this.getCompanyByOperaId(this.params.id);

        let authClient = await AuthClient.create();

        const identity = authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });
        //console.log(await this.getCompanyByOperaId(this.params.id))

        if(!flag){
            const operaInfoDiv = document.getElementById("opera-info");
            operaInfoDiv.innerHTML += alertSold;
            return;
        }

        const self = this;
        await loadScript({ 
            "client-id": "Adw2he4D9i1mo8tGN_hkKLy4r2GLajai_aAOP3kfGi6_PuFdaxmRT_Ivm2NVEX3bb4jEQLUPH5-Wp-3W",
            "currency": "EUR",
            "merchant-id": company.banckAddress
        }).then((paypal) => {
            let paypal_buttons = paypal.Buttons({
                style: {
                    height: 30,
                    width: 50
                },
                async createOrder() {
                    let result = await act.createOrder("CAPTURE", parseInt(opera.price));
                    return JSON.parse(result).id;
                },
                async onApprove(data) {
                    console.log(data);
                    let order_id = data.orderID;
                    let resp = await act.completeOrder("CAPTURE", order_id, company.principal, buyer.principal, opera.nfts[0]);
                    console.log(resp);
                    routerfn.navigateTo("/profile", self.routesOpera);
                },
                onCancel: function(data) {
                    confirm("Do want to confirm?")
                    
                    if (result) {
                        paypal_buttons.close();
                    }
                },
                onError: function(err) {
                    console.log(err);
                    alert("Somthing went wrong. Try again!");
                }
              }).render('#paypal-button-container');
            })
            .catch((err) => {
                console.error("failed to load the PayPal JS SDK script", err);
            });
    }
}