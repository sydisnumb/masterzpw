function checkImageSourceExists(source) {
  return new Promise(function(resolve, reject) {
    var img = new Image();
    
    img.onload = function() {
      resolve(true);
    };
    
    img.onerror = function() {
      resolve(false)
    };
    
    img.src = source;
  });
}



module.exports = {
    checkImageSourceExists: checkImageSourceExists,
}