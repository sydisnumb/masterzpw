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


import nocontentIcon from '../image/no-content-icon.png'
import userIcon from '../image/user-icon.png'
import logo from '../image/logo.png';
import icponchainImg from '../image/icp-onchain.png';


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
            await this.loadBuyerPage(user)
        }

        super.loadContent()
    }

    async loadBuyerPage(user){
        this.loadNavbar(user)
        const feed = document.getElementById("feed-a");
        feed.onclick = async () => {
            routerfn.navigateTo("/feed", this.routesProfile)
        }

        await this.loadOperaInfo()
        await this.laodPaypalBtn()     
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

    loadNoOperas(div) {
        div.innerHTML = nocontent

        const par = document.getElementById("no-content-p");
        par.textContent = "No opera!";

        const par1 = document.getElementById("no-content-p1");
        par1.textContent = "";

        const nocontentImg = document.getElementById("no-content-img");
        nocontentImg.src = nocontentIcon
    }

    async laodPaypalBtn(company){
        console.log("paypal")
        const operaInfoDiv = document.getElementById("opera-info");
        operaInfoDiv.innerHTML += paypalBtn;
        const self = this;
        const identity = self.authClient.getIdentity();
        const agent = new HttpAgent({identity});
        let act = controller;

        act = createActor(process.env.CONTROLLER_CANISTER_ID, {
            agent,
            canisterId: process.env.CONTROLLER_CANISTER_ID,
        });

        await loadScript({ 
            "client-id": process.env.CLIENT_ID,
            "intent": "mixed"
           // "merchantID": company.banckAddress
        }).then((paypal) => {
            console.log("render")
            let paypal_buttons = paypal.Buttons({
                style: {
                    height: 30,
                    width: 50
                },
                async createOrder() {
                    

                    let result = await act.createOrder("mixed", parseInt(self.params.id));
                },
                async onApprove(data) {
                    let order_id = data.orderID;
                    await act.transferNft();
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