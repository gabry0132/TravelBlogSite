window.onload = function(){
    var image = document.getElementById("image").value; //拡張子も含まれます
    if(image != null && image != "" && image != undefined){
        showImage(image);
    }
    var dataContainer = document.getElementById("emails-container");
    if(dataContainer != null && dataContainer != undefined){
        var dataString = dataContainer.dataset.names;
        var mails = dataString.split(",");
        //メールが届くべき名場合だけに送信処理を開始します。そうじゃないとJSエラーが出てしまいます。
        if(mails[0] != "" && mails.length > 1){ //メールが空っぽの時でも長さが1なので長さ≧２かつ空文字チェックで送信すべきかどうか判断します。  
            startSendingEmails(mails);
        }
    }
}

function showImage(image) {
    var source = "images/profile_pictures/";
    var url = source + image;

    imageExists(url, function(exists) {
        if (exists) {
            var wrapper = document.getElementById("image-wrapper");
            wrapper.style.backgroundImage = "url(" + url + ")";
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

function startSendingEmails(mails) {
    //console.log(otp);                             
    var blogTitle = document.getElementById("blogTitle").value;
    for (let i = 0; i < mails.length; i++) {
        const emailAddress = mails[i];
        
        var emailSubject = "最新登録を読みませんか";
        var emailText = "こんにちは！　" + blogTitle + "に新しい記事がアップロードされましたが、読んでみませんか？　https://tinyurl.com/yck585nx ですぐにアクセスできます！";
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
}