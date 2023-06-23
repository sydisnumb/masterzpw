// Import our custom CSS
import '../scss/styles.scss'

import * as bootstrap from 'bootstrap'
import logo from '../image/logo.png';
import landingImg from '../image/landing-image.png';

import navbar from '../html/components/navbar.html'
import footer from '../html/components/footer.html'
import features from '../html/components/features.html'
import aboutus from '../html/components/about-us.html'

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
    const navbarDiv = document.getElementById("navbar-home");
    navbarDiv.innerHTML += navbar;
    const navbarLogo = document.getElementById("navbar-logo");
    navbarLogo.src = logo;

    // footer setting
    const footerDiv = document.getElementById("footer");
    footerDiv.innerHTML += footer

}

function loadPage() {
    // landing setting
    const landingDiv = document.getElementById("landing-div");
    landingDiv.style.backgroundImage = `url(${landingImg})`

    // mission setting
    const missionDiv = document.getElementById("mission");
    missionDiv.innerHTML += features


    // features setting


    // about us setting
    const aboutusDiv = document.getElementById("aboutus");
    aboutusDiv.innerHTML += aboutus

}

loadComponents()
loadPage()