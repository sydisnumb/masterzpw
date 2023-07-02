let routerfn = require('./assets/js/router')

import landingPage from "./assets/js/landing-page.js";


let routes = [
    { path: "/", view: landingPage },
]

document.addEventListener("DOMContentLoaded", () => {
    routerfn.router(routes);
});
