window.onload = function () {
    try {
        var map = getImageFileNames();
        setImages(map);
        setTitleSpace();
    } catch (error) {
        window.open("error.jsp?error=" + error, "_self");
    }
}

function getImageFileNames(){
    var map = {};
    map["mainImage"] = document.getElementById("mainImagePath").value;
    map["subImage1"] = document.getElementById("subImage1Path").value;
    map["subImage2"] = document.getElementById("subImage2Path").value;
    map["subImage3"] = document.getElementById("subImage3Path").value;
    return map;
}

function setTitleSpace(){
    let titleWrappers = document.getElementsByClassName("paragraph-title-th");
    for (let i = 0; i < titleWrappers.length; i++) {
        if(titleWrappers[i].innerHTML == ""){
            titleWrappers[i].style.height = "0px";
        }
    }
}

function setImages(map){
    document.getElementById("main-image-wrapper").style.backgroundImage = "url(images/article_pictures/"+map["mainImage"]+")";
    var extraImages = document.getElementsByClassName("extra-image");
    for (let i = 0; i < 3; i++) {
        extraImages[i].style.backgroundImage = "url(images/article_pictures/" + map["subImage" + (i + 1)] + ")";
    }
}
