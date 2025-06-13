window.onload = function () {
    try {        
        const mode = document.getElementById("mode").value;
        if (mode == "edit"){
            setModeAsEdit();
        } else if (mode == "edit-preview"){     //プレビューページから「内容を修正する」を押した場合だけ。記事削除不可能とする
            setSeasonPrefectureSendMail();
        } else {    //mode == "add"はデフォルトにします
            //何もする必要ないです。
        }
        // 残りの文字数を計算するために設定
        document.getElementById("text-paragraph1").addEventListener("input", recalculateRemainingChars);
        document.getElementById("text-paragraph2").addEventListener("input", recalculateRemainingChars);
        document.getElementById("text-paragraph3").addEventListener("input", recalculateRemainingChars);
        // 画像を選んだ時にファイル名を表示するために設定
        document.getElementById("main-image-input").addEventListener("change", displayImageFileNames);
        document.getElementById("input-sub-image1").addEventListener("change", displayImageFileNames);
        document.getElementById("input-sub-image2").addEventListener("change", displayImageFileNames);
        document.getElementById("input-sub-image3").addEventListener("change", displayImageFileNames);
        // page dimmerの初期化    
        document.getElementById("page-dimmer").style.opacity = 0;
        var panels = document.getElementById("hint-text-holder").children; 
        for (let i = 0; i < panels.length; i++) {        
            panels[i].style.opacity = "0";
        }
        // ヒント表示の場合はEscキーで外せるようにしみあす
        document.body.addEventListener('keydown', function(e) {
            if (e.key == "Escape") {
              undoDim();
            }
        });
    } catch (error) {
        window.open("error.jsp?error=" + error, "_self");
    }
}

function setModeAsEdit(){
    setSeasonPrefectureSendMail();
    setDeleteButton();
}

function setSeasonPrefectureSendMail(){
    var seasonHelper = document.getElementById("seasonHelper");
    var prefectureHelper = document.getElementById("prefectureHelper");
    var sendMailHelper = document.getElementById("sendMailHelper");
    if(seasonHelper != null){
        document.getElementById("search-season").value = seasonHelper.value;
    }
    if(prefectureHelper != null){
        document.getElementById("search-prefecture").value = prefectureHelper.value;
    }
    if(sendMailHelper != null){
        document.getElementById("sendMailCheckbox").checked = false;
        if(sendMailHelper.value == "on"){
            document.getElementById("sendMailCheckbox").checked = true;
        }
    }
}

function setDeleteButton(){
    var button = document.getElementById("deleteButton");
    button.style.display = "flex";
    button.addEventListener("click",handleDelete);
}

function handleDelete(){
    if(confirm("記事を削除します。よろしいですか。")){
        document.getElementById("delete-form").submit();
    }
}

function recalculateRemainingChars(){
    var charLimit = 250;
    var remaining = charLimit;
    var spans = document.getElementsByClassName("remaining");
    var textFields = document.getElementsByClassName("paragraph-textArea");
    for (let i = 0; i < spans.length; i++) {
        remaining = charLimit - textFields[i].value.length;
        if(remaining == charLimit){
            spans[i].innerHTML = "";    
        } else {
            spans[i].innerHTML = remaining;
        }
        if(remaining < 0){
            spans[i].style.color = "#f00";
        } else {
            spans[i].style.color = "#000";
        }
    }
}

function displayImageFileNames(){
    var inputs = Array.from(document.getElementsByClassName("paragraph-image-picker"));
    inputs.push(document.getElementById("main-image-input"));
    for (let i = 0; i < inputs.length; i++) {
        if(inputs[i].value){
            inputs[i].style.color = "#000";
        } else {
            inputs[i].style.color = "#f6eeee";
        }
    }
}

function dimScreen(){
    let div = document.getElementById("page-dimmer");
    if(div.style.opacity == "0"){
        div.style.opacity = "1";
        div.style.visibility = "visible";
        showHintPanels();
    }
}

function undoDim(){
    let div = document.getElementById("page-dimmer");
    if(div.style.opacity == "1"){
        div.style.opacity = "0";
        hideHintPanels();
        setTimeout(() => {
            div.style.visibility = "hidden";
        }, 300);
    }
}

function showHintPanels(){
    var panels = document.getElementById("hint-text-holder").children; 
    for (let i = 0; i < panels.length; i++) {        
        if(panels[i].style.opacity == "0"){
            panels[i].style.opacity = "1";
            panels[i].style.visibility = "visible";
        }
    }
}

function hideHintPanels(){
    var panels = document.getElementById("hint-text-holder").children; 
    for (let i = 0; i < panels.length; i++) {
        if(panels[i].style.opacity == "1"){
            panels[i].style.opacity = "0";
            setTimeout(() => {
                panels[i].style.visibility = "hidden";
            }, 300);
        }
    }
}

