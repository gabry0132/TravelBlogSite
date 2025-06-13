window.onload = function(){
    document.getElementById("username-valid-marker").innerHTML = "";
    document.getElementById("email-valid-marker").innerHTML = "";
    document.getElementById("otp-valid-marker").innerHTML = "";
    document.getElementById("sendOTP").addEventListener("click", handleClick); 
    document.getElementById("sakuseisubmit").addEventListener("click", checkOTP); 
}

//グローバル変数
var otp = "";  
var timerMaxLength = 29; //再送信可までの秒数 
var timeLeft = timerMaxLength;

function handleClick(){
    var usernameMarker = document.getElementById("username-valid-marker");
    var emailMarker = document.getElementById("email-valid-marker");
    usernameMarker.innerHTML = "";
    emailMarker.innerHTML = "";
    var usernames = getUsernames();
    var emails = getEmails();
    if(areInputsValid()){
        generateOTP();
    } else {
        if(document.getElementById("username").value == ""){
            usernameMarker.innerHTML = "入力必須";
        }
        if(document.getElementById("email").value == ""){
            emailMarker.innerHTML = "入力必須";
        } else if (!document.getElementById("email").value.includes('@')){
            emailMarker.innerHTML = "「@」が入力されていません";
        } else if(!usernames.includes(username) || !emails.includes(email)){
            usernameMarker.innerHTML = "どちらかが誤っています。";
            emailMarker.innerHTML = "どちらかが誤っています。";
        }
    }
}

function areInputsValid(){
    var username = document.getElementById("username").value;
    var email = document.getElementById("email").value;
    var usernames = getUsernames();
    var emails = getEmails();
    if(username == "" || email == "" || !email.includes("@")){
        return false;
    }
    if(!usernames.includes(username) || !emails.includes(email)){
        return false;
    }
    return true;
}

function getUsernames(){
    var dataContainer = document.getElementById("usernames-container");
    var dataString = dataContainer.dataset.names;
    var usernames = dataString.split(",");
    return usernames;
}

function getEmails(){
    var dataContainer = document.getElementById("emails-container");
    var dataString = dataContainer.dataset.names;
    var emails = dataString.split(",");
    return emails;
}


//本来はこの処理とその戻り値はデータベース側で行われるようにすると思います。
function generateOTP(){
    otp = "";
    var chars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "0","1","2","3","4","5","6","7","8","9"];
    var index = 0;
    for (let i = 0; i < 6; i++) {
        index = Math.floor(Math.random()*chars.length);
        otp += chars[index];
    }
    startSendingEmail();
    moveTimer();
    document.getElementById("otp").disabled = false;
}

function moveTimer(){
    var button = document.getElementById("sendOTP");
    button.disabled = true;
    var timer = setInterval(function(){
        if(timeLeft <= 0){
            clearInterval(timer);
            button.disabled = false;
            button.innerHTML = "ワンタイムパスワード<br>を再送信する";
        } else {
            button.innerHTML = "後 " + timeLeft + " 秒で<br>再送信できます";
        }
        timeLeft--;
    }, 1000);
    timeLeft = timerMaxLength;
}

function checkOTP(){
    if(document.getElementById("otp").disabled){
        return;
    }
    var inputOTP = document.getElementById("otp").value;
    var otpMarker = document.getElementById("otp-valid-marker");
    var button = document.getElementById("sakuseisubmit");
    if (inputOTP != "" && inputOTP === otp){
        otpMarker.style.color = "green";
        otpMarker.innerHTML = "✔";
        button.innerHTML = "確認済み ✔";
        button.setAttribute("type", "submit");
    } else {
        otpMarker.style.color = "red";
        otpMarker.innerHTML = "✖";
        button.innerHTML = "OTPチェック";
    }
}

function startSendingEmail() {
    //console.log(otp);                                           
    var emailAddress = document.getElementById("email").value;
    var emailSubject = "ワンタイムパスワードの通知";
    var emailText = "パスワードを再設定するためのワンタイムパスワードは　" + otp + "　です。"
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