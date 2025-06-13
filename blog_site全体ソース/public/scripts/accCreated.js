window.onload = function () {
    showImage();
}

function showImage() {
    var source = "images/profile_pictures/";
    var image = document.getElementById("image").value; //拡張子も含まれます
    var url = source + image;

    imageExists(url, function(exists) {
        if (exists) {
            var wrapper = document.getElementById("image-wrapper");
            wrapper.style.border = "2px solid #000";
            wrapper.style.backgroundImage = "url(" + url + ")";
        } else {
            setTimeout(showImage, 10000);
        }
    });
}

function imageExists(url, callback) {
    var img = new Image();
    img.onload = function() {
        callback(true); // Image exists
    };
    img.onerror = function() {
        callback(false); // Image does not exist
    };
    img.src = url; // Start loading  image
}
