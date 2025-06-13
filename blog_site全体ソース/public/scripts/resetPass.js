window.onload = function () {
    document.getElementById("kakuninPass").addEventListener("input", checkInputs); 
    document.getElementById("pass").addEventListener("input", checkInputs); 
    document.getElementById("submitBtn").addEventListener("click", checkInputs); 
}

function checkInputs(){
    var pass = document.getElementById("pass");
    var kakuninPass = document.getElementById("kakuninPass");
    var marker = document.getElementById("valid-marker");
    var submitBtn = document.getElementById("submitBtn");
    if(pass.value == "" || kakuninPass.value == ""){
        marker.innerHTML = "";
        submitBtn.disabled = true;
        return;
    }
    if(pass.value == kakuninPass.value){
        marker.style.color = "green";
        marker.innerHTML = "✔";
        submitBtn.disabled = false;
    } else {
        marker.style.color = "red";
        marker.innerHTML = "✖";
        submitBtn.disabled = true;
    }
}