<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	
%>	
<!DOCTYPE html>
<html>
    <head>
        <title>
            パスワードを更新する
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/updatePass.css">
        <script type="text/javascript" src="scripts/updatePass.js"></script>
    </head>
    <body>
        <h1>
            パスワードを更新する
        </h1>
        <div id="everything-wrapper">
        
            <form action="koushinkanryo.jsp" method="post">
            
                <p class="input-field-intro">現在のパスワード</p>
                <input type="password" name="password" required class="basic-text-field" id="current-pass">
                
                <p class="input-field-intro">新しいパスワード</p>
                <input type="password" name="new-pass" required class="basic-text-field" id="new-pass">
                
                <input type="hidden" name="koushinkanryo-message" value="パスワードを正常に更新しました">
                <input type="hidden" name="koushin-type" value="pass-update">
                
                
                <div id="buttons-wrapper">
                    <a href="homepage.jsp?status=updateCancelled"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" class="basic-submit" disabled id="submitBtn">登録</button>
                </div>
                
            </form>
            
        </div>
    </body>
</html>