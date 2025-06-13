window.onload = function () {
    document.getElementById("reasonForDelete").addEventListener("input", updateCheckboxStatus);
}

function updateCheckboxStatus(){
    var textField = document.getElementById("reasonForDelete");
    var sendMail = document.getElementById("sendMail");
    var checkbox = document.getElementById("mail-send-checkbox");
    if(textField.value == "" || textField.value.length == 0){
        checkbox.checked = false;
        sendMail.value = "false";
    } else {
        checkbox.checked = true;
        sendMail.value = "true";
    }
}