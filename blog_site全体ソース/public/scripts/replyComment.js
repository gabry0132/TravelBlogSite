window.addEventListener("load", function ()  {
    this.document.getElementById("deleteButton").addEventListener("click", executeDeleteForm);
});

function executeDeleteForm(){
    if(confirm("返事を削除します。よろしいですか。")){
        document.getElementById("delete-form").submit();
    }
}
