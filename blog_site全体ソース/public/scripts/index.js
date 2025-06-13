window.onload = function(){
    try {        
        document.getElementById("valid-marker").innerHTML = "";
        document.getElementById("username-input").addEventListener("input",checkUsernameAvailability);
        document.getElementById("sakuseisubmit").addEventListener("click",checkUsernameAvailability);
        document.getElementById("email-input").addEventListener("input",checkEmailAvailability);
        document.getElementById("sakuseisubmit").addEventListener("click",checkEmailAvailability);
        //ニューズレター登録ページの動きの準備をします。本来はそのページをロードした瞬間に取得します。
        localStorage.setItem("newsletter-registration","unregistered");
    } catch (error) {
        window.open("error.jsp?error=" + error, "_self");
    }
}

function getUsernames(){
    var dataContainer = document.getElementById("usernames-container");
    var dataString = dataContainer.dataset.names;
    var usernames = dataString.split(",");
    return usernames;
}

function checkUsernameAvailability(){
    //本来はここで重複チェックを行います。プロトタイプには入力値チェックには問題がない限りOK固定にします
    var username = document.getElementById("username-input").value;
    var marker = document.getElementById("valid-marker");
    var button = document.getElementById("sakuseisubmit");
    if (username == ""){
        marker.innerHTML="";
        button.disabled = true;
        return;
    }
    var allowedChars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "0","1","2","3","4","5","6","7","8","9",
        "!","#","$","%","&","-","~","^","|","[","]","{","}",":",";",",","<",">","?","_","*"];
    var allowed = true;
    var invalidChar = "";
    for (let i = 0; i < username.length; i++) {
        if(!allowedChars.includes(username.charAt(i))){
            allowed = false;
            invalidChar = username.charAt(i);
            break;
        }
    }
    if(!allowed){
        marker.style.color = "red";
        marker.innerHTML="「 " + invalidChar + " 」文字が無効です　✖";
        button.disabled = true;
    } else if(existingUsername(username)) {
        marker.style.color = "red";
        marker.innerHTML="このユーザー名は既に存在します　✖";
        button.disabled = true;
    } else {
        marker.style.color = "green";
        marker.innerHTML="有効　✔";
        button.disabled = false;
    }
}

function existingUsername(username){
    var usernameList = getUsernames();
    return usernameList.includes(username);
}

function checkEmailAvailability(){
    var email = document.getElementById("email-input").value;
    var marker = document.getElementById("email-marker");
    var button = document.getElementById("sakuseisubmit");
    if(existingEmail(email)) {
        marker.style.color = "red";
        marker.innerHTML="このアドレスは既に存在します　✖";
        button.disabled = true;
    } else {
        marker.innerHTML="";
        button.disabled = false;
    }
}

function existingEmail(email){
    var emailList = getEmails();
    return emailList.includes(email);
}

function getEmails(){
    var dataContainer = document.getElementById("emails-container");
    var dataString = dataContainer.dataset.names;
    var emails = dataString.split(",");
    return emails;
}

