document.addEventListener("DOMContentLoaded", function(){
    try{
        document.getElementById("page-dimmer").addEventListener("click", undoDim); 
        document.getElementById("page-dimmer").style.opacity = 0;
        document.getElementById("search-reset-button").addEventListener("click", resetSearchParameters); 
        if(isAdmin()){
            displayKanrishaMenu();
        }
        displayDropdownMenuAsReceived();
        var status = document.getElementById("status-search").value;
        if(status == "search"){
            setSearchParameters();
        } else {
            setEndDate();
        }
        imageLoader(1);
        setNewsletterBGColor();
    } catch (error) {
        window.open("error.jsp?error=" + error, "_self");
    }
});

function getArticlesData(){
    var parsedData = JSON.parse(dataString);
    var articlesArray = parsedData.map(obj => {
        return new Map(Object.entries(obj));
    });
    return articlesArray;
}

function imageLoader(selectedPage){
    cleanPage();
    var articlesArray = getArticlesData();  //実際の記事データ
    var totalArticles = articlesArray.length;                                              
    var articlesPerPage = Number(document.getElementById("articlesPerPage").value);         
    var lastPage = Math.floor((totalArticles / articlesPerPage) + 1);                  
    var articles = document.getElementsByClassName("article");                      
    var imgHolders = document.getElementsByClassName("img-holder");                 
    var titleHolder = document.getElementsByClassName("title-holder");              
    var unreadHeaderHolder = document.getElementsByClassName("unread-header");              
    var imgSRC = "images/article_pictures/";
    var start = (selectedPage - 1) * articlesPerPage;              
    var end = articlesPerPage * (selectedPage - 1) + articlesPerPage;   
    if(selectedPage == lastPage){
        end = totalArticles;
    }
    var divIndex = 0;
    for (let i = start; i < end; i++) {
        articles[divIndex].style.display = "block";
        imgHolders[divIndex].style.backgroundImage = "url(" + imgSRC + articlesArray[i].get("mainImage") + ")";
        titleHolder[divIndex].innerHTML = articlesArray[i].get("title");  
        if(articlesArray[i].get("interactionID") != "notSeen" || isAdmin() === true){ //管理者であればunreadHeaderHolderが存在しません。
            unreadHeaderHolder[divIndex].style.display = "none";
        }
        divIndex++;
    }
    modifyActive(selectedPage);
}

function setNewsletterBGColor(){
    var newsletterFlag = document.getElementsByName("newsletterFlag")[0].value;
    var anchor = document.getElementById("newsletter-link");
    if(newsletterFlag == 0){
        anchor.style.backgroundImage = "linear-gradient(#73d645, #73d645)";
    } else {
        anchor.style.backgroundImage = "linear-gradient(#c1e5f5, #c1e5f5)";
    }
}

function setSearchParameters(){
    var startDate = document.getElementById("search-startDate-helper").value;
    var endDate = document.getElementById("search-endDate-helper").value;
    var season = document.getElementById("search-season-helper").value;
    var prefecture = document.getElementById("search-prefecture-helper").value;
    var likedCheckbox = document.getElementById("search-likedCheckbox-helper").value;

    var searchExplanation = document.getElementById("search-explanation");
    searchExplanation.innerHTML = "検索条件："

    //最初の行がサイドメニュー、2行目がメイン画面での表示の設定です。
    if(startDate != ""){
        console.log("entered in startDate")
        document.getElementById("startDate").value = startDate;
        searchExplanation.innerHTML += startDate + "から ";
    }
    if(endDate != ""){
        console.log("entered in endDate")
        document.getElementById("endDate").value = endDate;
        searchExplanation.innerHTML += endDate + "まで、";
    }
    if(season != "null"){
        console.log("entered in season")
        document.getElementById("search-season").value = season;
        searchExplanation.innerHTML += getSeasonFromID(season) + "、";
    }
    if(prefecture != "null"){
        console.log("entered in prefecture")
        document.getElementById("search-prefecture").value = prefecture;
        searchExplanation.innerHTML += getPrefectureFromID(prefecture) + "、";
    }
    if(likedCheckbox != "null"){
        console.log("entered in likedCheckbox")
        document.getElementById("search-liked-checkbox").checked = true;
        searchExplanation.innerHTML += "「いいね！」付け";
    }

    if(searchExplanation.innerHTML.endsWith("、")){
        console.log("deleting last comma")
        searchExplanation.innerHTML = searchExplanation.innerHTML.substring(0, searchExplanation.innerHTML.length - 1);
    }
}

function resetSearchParameters(){
    document.getElementById("search-form").reset();
    setEndDate();
}

function setEndDate(){
    const date = new Date();
    var year = date.getFullYear();
    var month = "0" + (date.getMonth() + 1);
    if(month.length >= 3) month = month.substring(1);
    var day = "0" + date.getDate();
    if(day.length >= 3) day = day.substring(1);
    document.getElementById("endDate").value = year + "-" + month + "-" + day;
}

function cleanPage(){
    var articles = document.getElementsByClassName("article");
    var articlesPerPage = Number(document.getElementById("articlesPerPage").value);        
    for (let i = 0; i < articlesPerPage; i++) {
        articles[i].style.display = "none";
    }
}

function isAdmin(){
    var input = document.getElementsByName("isAdmin")[0];
    if(input == null) return false;
    return true;
}

function displayKanrishaMenu(){
    document.getElementsByClassName("kanrisha-menu")[0].style.display = "block";
}

function modifyActive(selectedPage){
    var spans = document.getElementById("page-selector").children;
    if(spans.length == 1){  //１つしかなければページ選択の所に何も表示しません
        spans[0].style.display = "none";
    } else {
        for (let i = 0; i < spans.length; i++) {
            if(i == selectedPage - 1){
                spans[i].classList.remove("page-count");
                spans[i].classList.add("current-selected");
            } else if(spans[i].classList.contains("current-selected")){
                spans[i].classList.remove("current-selected");
                spans[i].classList.add("page-count");
            }
        }
    }
}

function dimScreen(){
    let div = document.getElementById("page-dimmer");
    if(div.style.opacity == "0"){
        div.style.opacity = "1";
        div.style.visibility = "visible";
        document.getElementById("exit-hitbox").style.zIndex = 5;
        openSideMenu();
    }
}

function undoDim(){
    let div = document.getElementById("page-dimmer");
    if(div.style.opacity == "1"){
        div.style.opacity = "0";
        document.getElementById("exit-hitbox").style.zIndex = -1;
        closeSideMenu();
        setTimeout(() => {
            div.style.visibility = "hidden";
        }, 300);    //homepage.cssのbody div#page-dimmerのtransitionと同じ値にする
    }
}

function openSideMenu(){
    document.getElementById("left-side-nav").style.transform = "translate(450%, 0)";
    document.getElementById("exit-hitbox").style.transform = "translate(150%, 0)";
}

function closeSideMenu(){
    document.getElementById("left-side-nav").style.transform = "translate(0, 0)";
    document.getElementById("exit-hitbox").style.transform = "translate(0, 0)";
}

function openArticlePage(containerNum){
    //var userID = document.getElementsByName("userID")[0].value;
    var selectedPage = 0;
    var selectors = document.getElementById("page-selector").children;
    for (let i = 0; i < selectors.length; i++) {
        selectedPage++;
        if(selectors[i].classList.contains("current-selected")){
            break;
        }
    }
    var articlesPerPage = Number(document.getElementById("articlesPerPage").value);         
    var articlesArray = getArticlesData();  //実際の記事データ
    var wrapperNum = articlesPerPage * (selectedPage - 1) + containerNum;
    var articleID = articlesArray[wrapperNum - 1].get("articleID");
    window.open("article.jsp?articleID=" + articleID, "_self");
}

function displayDropdownMenuAsReceived(){
    var fieldValue = document.getElementById("sort-field-helper").value;
    var koumokuValue = document.getElementById("sort-koumoku-helper").value;
    if(
        (fieldValue == null || fieldValue == undefined || fieldValue == "null") && 
        (koumokuValue == null || koumokuValue == undefined || koumokuValue == "null")
      ){
        return;
    }
    var fieldSelect = document.getElementById("sort-field");
    var koumokuSelect = document.getElementById("sort-koumoku");
    fieldSelect.value = fieldValue;
    koumokuSelect.value = koumokuValue;
}

function getSeasonFromID(value){
    var season = "";
    switch(value){
        case "1":
            season = "夏";
            break;
        case "2":
            season = "秋";
            break;
        case "3":
            season = "冬";
            break;
        case "4":
            season = "春";
            break;
        default:
            season = "error";
    }
    return season;
}

function getPrefectureFromID(value){
    var prefecture = "";
    switch (value) {
        case "1":
            prefecture = "北海道";
            break;
        case "2":
            prefecture = "青森県";
            break;
        case "3":
            prefecture = "岩手県";
            break;
        case "4":
            prefecture = "宮城県";
            break;
        case "5":
            prefecture = "秋田県";
            break;
        case "6":
            prefecture = "山形県";
            break;
        case "7":
            prefecture = "福島県";
            break;
        case "8":
            prefecture = "茨城県";
            break;
        case "9":
            prefecture = "栃木県";
            break;
        case "10":
            prefecture = "群馬県";
            break;
        case "11":
            prefecture = "埼玉県";
            break;
        case "12":
            prefecture = "千葉県";
            break;
        case "13":
            prefecture = "東京都";
            break;
        case "14":
            prefecture = "神奈川県";
            break;
        case "15":
            prefecture = "新潟県";
            break;
        case "16":
            prefecture = "富山県";
            break;
        case "17":
            prefecture = "石川県";
            break;
        case "18":
            prefecture = "福井県";
            break;
        case "19":
            prefecture = "山梨県";
            break;
        case "20":
            prefecture = "長野県";
            break;
        case "21":
            prefecture = "岐阜県";
            break;
        case "22":
            prefecture = "静岡県";
            break;
        case "23":
            prefecture = "愛知県";
            break;
        case "24":
            prefecture = "三重県";
            break;
        case "25":
            prefecture = "滋賀県";
            break;
        case "26":
            prefecture = "京都府";
            break;
        case "27":
            prefecture = "大阪府";
            break;
        case "28":
            prefecture = "兵庫県";
            break;
        case "29":
            prefecture = "奈良県";
            break;
        case "30":
            prefecture = "和歌山県";
            break;
        case "31":
            prefecture = "鳥取県";
            break;
        case "32":
            prefecture = "島根県";
            break;
        case "33":
            prefecture = "岡山県";
            break;
        case "34":
            prefecture = "広島県";
            break;
        case "35":
            prefecture = "山口県";
            break;
        case "36":
            prefecture = "徳島県";
            break;
        case "37":
            prefecture = "香川県";
            break;
        case "38":
            prefecture = "愛媛県";
            break;
        case "39":
            prefecture = "高知県";
            break;
        case "40":
            prefecture = "福岡県";
            break;
        case "41":
            prefecture = "佐賀県";
            break;
        case "42":
            prefecture = "長崎県";
            break;
        case "43":
            prefecture = "熊本県";
            break;
        case "44":
            prefecture = "大分県";
            break;
        case "45":
            prefecture = "宮崎県";
            break;
        case "46":
            prefecture = "鹿児島県";
            break;
        case "47":
            prefecture = "沖縄県";
            break;
        default:
            prefecture = "error";
            break;
    }
    return prefecture;
}
