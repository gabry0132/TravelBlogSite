<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

%>
<!DOCTYPE html>
<html>
    <head>
        <title>
            管理者ログインページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/kanrishaLogin.css">
    </head>
    <body>
        <h1>
            管理者ログインページ
        </h1>
        <div id="main-login-wrapper">
            <form action="homepage.jsp" method="post">
                <p class="input-field-intro">メールアドレス</p>
                <input type="email" name="email" required class="basic-text-field">

                <p class="input-field-intro">パスワード</p>
                <input type="password" name="password" required class="basic-text-field" id="kakuninPass">
                
                <input type="hidden" name="status" value="admin-login"> 
                
                
                <div id="buttons-wrapper">
                    <button type="reset" class="basic-clear">クリア</button>
                    <button type="submit" class="basic-submit" >登録</button>
                </div>
            </form>
        </div>
        <a href="index.jsp"><button type="button" class="basic-clear">一般者ログインへ戻る</button></a>
    </body>
</html>