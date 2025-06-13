window.onload = function(){
    showImage();
}

function showImage() {
    var source = "images/profile_pictures/";
    var image = document.getElementById("image").value; //拡張子も含まれます
    var url = source + image;
    var wrapper = document.getElementById("image-wrapper");

    imageExists(url, function(exists) {
        if (exists) {
            wrapper.style.border = "2px solid #000";
            wrapper.style.backgroundImage = "url(" + url + ")";
        } else {
            var errorMsg = document.getElementById("display-error");
            wrapper.style.border = "none";
            errorMsg.innerHTML = "プロフィール写真が<br>見つかりませんでした";  //consoleにエラーが見えますが大した事がないです。
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
