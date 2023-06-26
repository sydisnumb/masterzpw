// import Posts from "./assets/js/posts.js";
// import PostView from "./assets/js/post-view.js";
// import Settings from "./assets/js/settings.js";




const pathToRegex = path => new RegExp("^" + path.replace(/\//g, "\\/").replace(/:\w+/g, "(.+)") + "$");

const getParams = match => {
    const values = match.result.slice(1);
    const keys = Array.from(match.route.path.matchAll(/:(\w+)/g)).map(result => result[1]);

    return Object.fromEntries(keys.map((key, i) => {
        return [key, values[i]];
    }));
};

const navigateTo = (url, routes) => {
    history.pushState(null, null, url);
    router(routes);
};

const router = async (routes) => {

    // Test each route for potential match
    const potentialMatches = routes.map(route => {
        return {
            route: route,
            result: location.pathname.match(pathToRegex(route.path))
        };
    });

    let match = potentialMatches.find(potentialMatch => potentialMatch.result !== null);

    if (!match) {
        match = {
            route: routes[0],
            result: [location.pathname]
        };
    }

    const view = new match.route.view(getParams(match));

    document.querySelector("#app").innerHTML = await view.getHtml();
    await view.loadPage()
};


function checkImageSourceExists(source, callback) {
    var img = new Image();
    
    img.onload = function() {
      callback(true);
    };
    
    img.onerror = function() {
      callback(false);
    };
    
    img.src = source;
  }



module.exports = {
    router: router,
    navigateTo: navigateTo
  };

