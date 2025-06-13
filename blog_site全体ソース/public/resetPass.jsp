<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	//JS側のチェックが多くて、forgotPassから送信されるユーザー名とメールアドレスは正しいという前提で進みます。
	
%>
<!DOCTYPE html>
<html>
    <head>
        <title>
            パスワード再設定する
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/resetPass.css">
        <script type="text/javascript" src="scripts/resetPass.js"></script>
    </head>
    <body>
        <h1>
            新しいパスワードを決めてください
        </h1>
        <div id="everything-wrapper">
            <form action="koushinkanryo.jsp" method="post">
                <p class="input-field-intro">新しいパスワード</p>
                <input type="password" name="password" required class="basic-text-field" id="pass">
                <div id="text-wrapper">
                    <p class="input-field-intro">再入力</p>
                    <span id="valid-marker"></span>
                </div>
                    <input type="password" name="kakuninPass" required class="basic-text-field" id="kakuninPass">
                    
                    <input type="hidden" name="username" value="<%= username %>">
                    <input type="hidden" name="email" value="<%= email %>">
                    <input type="hidden" name="koushinkanryo-message" value="パスワードを正常に再設定しました">
                    <input type="hidden" name="koushin-type" value="pass-reset">
                    
                <div id="buttons-wrapper">
                    <a href="index.jsp"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" class="basic-submit" disabled id="submitBtn">登録</button>
                </div>
            </form>
        </div>
    </body>
</html>