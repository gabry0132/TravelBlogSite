window.onload = function () {
    document.getElementById("current-pass").addEventListener("input", checkInputs); 
    document.getElementById("new-pass").addEventListener("input", checkInputs); 
    document.getElementById("submitBtn").addEventListener("click", checkInputs); 
}

function checkInputs(){
    var curPass = document.getElementById("current-pass");
    var newPass = document.getElementById("new-pass");
    var submitBtn = document.getElementById("submitBtn");
    if(curPass.value != "" && newPass.value != ""){
        submitBtn.disabled = false;
    } else {
        submitBtn.disabled = true;
    }
}