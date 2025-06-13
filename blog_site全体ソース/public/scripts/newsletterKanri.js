window.onload = function () {
    var description = document.getElementById("description");
    var registered = document.getElementsByName("isRegistered")[0].value;
    console.log(registered);
    var button = document.getElementById("submitBtn");
    if(registered == "true"){
        description.innerHTML = "ニューズレター希望、登録済み"; 
        button.style.backgroundColor = "#fff";
        button.innerHTML = "登録を取り消し";
    } else if(registered == "false") {
        description.innerHTML = "ニューズレターに登録していません"; 
        button.style.backgroundColor = "#c1e5f5";
        button.innerHTML = "ニューズレターに登録する";
    }
    button.disabled = false;
}