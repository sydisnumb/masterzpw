// Import our custom CSS
import '../scss/styles.scss'

import * as bootstrap from 'bootstrap'
import logo from '../image/logo.jpg';
import landingImg from '../image/landing-image.png';

import navbarDiv from '../html/components/navbar.html'
import footerDiv from '../html/components/footer.html'

import { loadScript } from "@paypal/paypal-js";

let paypal;

try {
    paypal = await loadScript({
        clientId: "AfgIZfSAPUK3gDhQO4Ry2mi9uBQNFNNM7l3HEABkaa2u7AeHzSXnhNHsWNsr33NUPwfpleKpxZYJSUTU",
        merchantId: ["LER4HXUKPP66A5"],
    });
} catch (error) {
    console.error("failed to load the PayPal JS SDK script", error);
}

if (paypal) {
    try {
        await paypal.Buttons().render("#paypal-button-container");
    } catch (error) {
        console.error("failed to render the PayPal Buttons", error);
    }
}

function loadComponents() {
    // navbar setting
    const navbar = document.getElementById("navbar-home");
    navbar.innerHTML += navbarDiv;
    const navbarLogo = document.getElementById("navbar-logo");
    navbarLogo.src = logo;

    // footer setting
    const footer = document.getElementById("footer");
    footer.innerHTML += footerDiv

}

function loadPage() {
    const landingDiv = document.getElementById("landing-div");
    landingDiv.style.backgroundImage = `url(${landingImg})`

}

loadComponents()
loadPage()