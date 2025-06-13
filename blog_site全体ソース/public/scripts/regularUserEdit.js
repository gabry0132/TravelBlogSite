window.onload = function () {
    this.document.getElementById("deleteButton").addEventListener("click", executeDeleteForm);
}

function executeDeleteForm(){
    if(confirm("コメントを削除します。よろしいですか。")){
        document.getElementById("delete-form").submit();
    }
}
