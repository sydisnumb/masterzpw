let routerfn = require('./assets/js/router')

import landingPage from "./assets/js/landing-page.js";


let routes = [
    { path: "/", view: landingPage },
]

window.addEventListener("popstate", async () =>{
    routerfn.router(routes)
});


document.addEventListener("DOMContentLoaded", () => {
    routerfn.router(routes);
});
