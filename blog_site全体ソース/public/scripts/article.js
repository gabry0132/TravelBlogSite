window.onload = function () {
    var isKanrisha = (document.getElementById("isAdmin").value === 'true'); //strict check -> booleanに変換
    document.getElementById("like-animation").addEventListener("click", animateAndRegisterLike);
    document.getElementById("like").addEventListener("click", animateAndRegisterLike);
    document.getElementById("comment-text").addEventListener("input", showCommentValidMarker);
    try {        
        const updateText = document.getElementById("koushin").value;
        if(updateText != "null"){
            displayUpdateDiv(updateText);
        }
        //　ここでコメント投稿ボタンの動きを設定します。
        setLikeButton();
        var images = document.getElementById("imagesData").value.split(",");
        setArticleImages(images);
        setTitleSpace();
        hideEmptyReplies();
        var sendMail = document.getElementById("sendMail").value;
        if(sendMail == "true"){
            sendCommentDeletionMail();
        }
        if(isKanrisha){
            showReplyButtons();
            showKanrishaEditButton();
            hideReactionAndCommentUpload();
            showLikeCount();
        } else {
            hideReplyButtons();
            showCommentValidMarker();
        }
    } catch (error) {
        window.open("error.jsp?error=" + error, "_self");
    }
}

function sendCommentDeletionMail(){
    var emailAddress = document.getElementById("email").value;
    var blogTitle = document.getElementById("blogTitle").value;
    var reasonForDelete = document.getElementById("reasonForDelete").value;
    var deletedComment = document.getElementById("deletedComment").value;
    if(emailAddress == "null" || blogTitle == "null" || reasonForDelete == "null"　|| deletedComment == "null"){
        return;
    }
    var emailSubject = "コメントが削除されました";
    var emailText = "以前に" + blogTitle + "に投稿した次のコメント：「 " + deletedComment + " 」が削除されました。削除理由は：「" + reasonForDelete + "」です。";
    var emailData = {
        recipient: emailAddress,
        subject: emailSubject,
        text: emailText,
    };
    
    //Node.JSのサーバーと繋がってデータを送信する。
    fetch("http://localhost:3000/send-email", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(emailData),
    })
    .then((response) => response.text())
    .then((message) => console.log(message))
    .catch((error) => console.error("Error:", error));
}

function setLikeButton(){
    var video = document.getElementById("like-animation");
    var likeFlag = document.getElementById("likeFlag").value;
    if(likeFlag == "1"){
        video.currentTime = video.duration - 0.1;
        video.play;
    } else if(likeFlag == "0") {
        video.currentTime = 0;
    } else {
        console.log("Incorrect likeFlag with value of " + likeFlag);
    }
}

function showCommentValidMarker(){
    var comment = document.getElementById("comment").value; //DB上にあるコメント(ない可能性もある)
    var commentText = document.getElementById("comment-text").value; //ページ上にユーザーが入力できるTextFieldのことです。
    if(commentText.length == 0){
        document.getElementById("comment-valid-marker").innerHTML = "";
        return
    }
    if(comment != "null" && comment.length != 0){
        document.getElementById("comment-valid-marker").innerHTML = "既にコメントを書きました。また投稿すると上書きされます。";
    }
}

function setArticleImages(images){
    for (let i = 0; i < images.length; i++) {
        if(i == 0){
            setTopImage(images[i]);
        } else {
            setExtraImage(images[i] + "," + i);
        }
        
    }
}

function setTitleSpace(){
    let titleWrappers = document.getElementsByClassName("paragraph-title-th");
    for (let i = 0; i < titleWrappers.length; i++) {
        if(titleWrappers[i].innerHTML == ""){
            titleWrappers[i].style.height = "0px";
        }
    }
}

function setTopImage(image){
    var wrapper = document.getElementById("main-image-wrapper");
    var imgSRC = "images/article_pictures/" + image;
    wrapper.style.backgroundImage = "url(" + imgSRC + ")";
}

function setExtraImage(image){
    var index = Number(image.split(",")[1]);
    image = image.split(",")[0];
    var wrappers = document.getElementsByClassName("extra-image");
    var imgSRC = "images/article_pictures/";
    wrappers[index - 1].style.backgroundImage = "url(" + imgSRC + image + ")";
}

function displayImageDescription(pictureNum){
    var descriptions = document.getElementsByClassName("extra-image-description");
    var text = document.getElementsByClassName("image-description-text");
    for (let i = 0; i < descriptions.length; i++) {
        if(i + 1 == pictureNum){
            text[i].style.display = "flex";
            descriptions[i].style.height = "40px";
        }
        
    }
}

function hideImageDescriptions(){
    var descriptions = document.getElementsByClassName("extra-image-description");
    var text = document.getElementsByClassName("image-description-text");
    for (let i = 0; i < descriptions.length; i++) {
        text[i].style.display = "none";
        descriptions[i].style.height = "0px";
        
    }
}

function animateAndRegisterLike(){
    var likeFlag = document.getElementById("likeFlag").value;
    var video = document.getElementById("like-animation");
    registerToDatabase(likeFlag);
    if(video.currentTime > 0){
        video.currentTime = 0;
        video.pause();
    } else {
        video.play();
    }
}

function registerToDatabase(likeFlag){ 
    var interactionID = document.getElementById("interactionID").value;
    //videoのplay状況に応じてsql文が変わる
    if(likeFlag == "0"){
        targetFlag = 1;
    } else {
        targetFlag = 0;
    }
    var query = "update interactions set likeFlag = " + targetFlag +  "  where interactionID = " + interactionID;
    fetch('http://localhost:3000/run-query', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ query })
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.log(`Error: ${data.error}`);
            } else {
                console.log(data.output);
                document.getElementById("likeFlag").value = targetFlag; //いいね状況をhtmlに送信。
            }
        })
        .catch(error => {
            console.error("Error:", error);
            console.log(`Error: ${error.message}`);
        });

}

function changeOpenArticle(targetArticleID){
    var userID = document.getElementById("userID").value;
    window.open("article.jsp?articleID=" + targetArticleID + "&userID=" + userID, "_self");
}

function hideEmptyReplies(){
    var wrappers = document.getElementsByClassName("author-reply-wrapper");
    var replies = document.getElementsByClassName("author-reply");
    for (let i = 0; i < wrappers.length; i++) {
        if(replies[i].innerHTML != ""){
            wrappers[i].style.display = "block";
        }        
    }

}

function showReplyButtons(){
    var buttons = document.getElementsByClassName("edit-comment");
    for (let i = 0; i < buttons.length; i++) {
        buttons[i].style.display = "flex";
    }
}

function showKanrishaEditButton(){
    var menu = document.getElementById("edit-button");
    menu.style.display = "block";
}

function hideReactionAndCommentUpload(){
    document.getElementById("like-wrapper").style.display = "none";
    document.getElementById("comment-wrapper").style.display = "none";
}

function colorReply(wrapper){
    for (let i = 0; i < wrapper.children.length; i++) {
        if(wrapper.children[i].classList.contains("author-reply-wrapper")){
            wrapper.children[i].style.background = "#e6fc24b7";
        }
    }
}

function removeAllReplyColors(){
    var wrappers = document.getElementsByClassName("author-reply-wrapper");
    for (let i = 0; i < wrappers.length; i++) {
        wrappers[i].style.background = "none";
    }
}

function showLikeCount(){
    document.getElementById("like-counter").style.display = "block";
}

function hideReplyButtons(){
    var buttons = document.getElementsByClassName("reply-comment");
    for (let i = 0; i < buttons.length; i++) {
        buttons[i].style.display = "none";
        
    }
}

function displayUpdateDiv(updateText){
    var div = document.getElementById("koushin-marker");
    var text = document.getElementById("koushin-text");
    div.style.height = "60px";

    text.innerHTML = updateText;
    text.style.display = "flex";
    setTimeout(() => {
        div.style.height = "0px";
        text.style.display = "none";
    }, 2500);
}