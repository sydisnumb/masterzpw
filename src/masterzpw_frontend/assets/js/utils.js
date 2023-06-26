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
    checkImageSourceExists: checkImageSourceExists,
}