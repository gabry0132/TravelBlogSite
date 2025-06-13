window.onload = function () {
    document.getElementById("email").addEventListener("input", checkInputs); 
    document.getElementById("pass").addEventListener("input", checkInputs); 
    document.getElementById("submitBtn").addEventListener("click", checkInputs); 
}

function checkInputs(){
    var email = document.getElementById("email");
    var pass = document.getElementById("pass");
    var submitBtn = document.getElementById("submitBtn");
    var marker = document.getElementById("valid-marker");
    console.log(marker);
    if(existingEmail(email.value)) {
        console.log("exists")
        marker.style.color = "red";
        marker.innerHTML="既に存在します　✖";
        submitBtn.disabled = true;
    } else {
        marker.innerHTML="";
        if((email.value != "" && email.value.includes("@")) && pass.value != ""){
            submitBtn.disabled = false;
        } else {
            submitBtn.disabled = true;
        }
    }    
}

function existingEmail(email){
    var emailList = getEmails();
    console.log(emailList)
    console.log(email)
    return emailList.includes(email);
}

function getEmails(){
    var dataContainer = document.getElementById("emails-container");
    var dataString = dataContainer.dataset.names;
    var emails = dataString.split(",");
    return emails;
}