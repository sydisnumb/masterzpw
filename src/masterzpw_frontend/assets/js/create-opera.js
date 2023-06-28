let routerfn = require('./router')
// Import our custom CSS
import '../scss/styles.scss'

import profile from '../js/profile.js'

import createOpera from '../html/pages/create-opera.html';

import spinner from '../html/components/spinner.html'
import logoImg from '../image/cover.png';

import { createActor, controller } from "../../../declarations/controller";
import { HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

import AbstractView from "./abstract-view.js";
import opera from './opera';

export default class extends AbstractView {


    init = async () => {

        window.addEventListener("popstate", async () =>{
            routerfn.router(this.routesCompleteProfile)
        });


        let cancel = document.getElementById("cancel-btn");
        let submit = document.getElementById("submit-btn");
        
        cancel.onclick = async () => {
            let res = confirm('Do you want to proceed?');
            if(res) {
                navigateTo("/profile", this.routesCreateOpera)
            }
        };
    
        submit.onclick = async () => {
            submit.disabled = true
            submit.innerHTML = spinner + submit.innerHTML

            if(! await this.isAuthorized()) {
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

            let operaTitle = document.getElementById("title-field").value;
            let operaUrl = (document.getElementById("opera-url").value !== "") ? "https://ipfs.io/ipfs/" + document.getElementById("opera-url").value : "";
            let operaDescription = document.getElementById("description-field").value;
            let operaPrice = document.getElementById("price-field").value;

            if(operaTitle === "" || operaUrl === "" || operaDescription === "" || operaPrice === "") {
                alert("Make sure each field is complete.")
                return
            } else {
                if(isNaN(parseFloat(operaPrice))){
                    alert("Insert a return price.")
                    submit.innerHTML = 'Submit'
                    submit.disabled = false

                    return                    
                }
            
                var res = await act.createNewOpera(operaTitle, operaUrl, operaDescription, parseFloat(operaPrice));

                if(res.Ok){
                    let operaId = res.Ok
                    console.log(res)
                    routerfn.navigateTo("/opera/"+operaId, this.routesCreateOpera)

                } else {
                    alert("Something went wrong. Try again!")

                }
            }
            
            
            submit.innerHTML = 'Submit'
            submit.disabled = false

            
        }
    }

    constructor(params) {
        super(params);
        this.setTitle("Complete profile - COOL art");

        this.routesCreateOpera = [
            { path: "/profile", view: profile },
            { path: "/opera/:id", view: opera },
        ]

    }

    async getHtml() {
      return createOpera;
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

        super.loadContent()
    }    
}