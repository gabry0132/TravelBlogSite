<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String password = request.getParameter("password");
	
%>

<!DOCTYPE html>
<html>
    <head>
        <title>
            プロフィール写真設定
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/setProfilePicture.css">
        <script type="text/javascript" src="scripts/setProfilePicture.js"></script>
    </head>
    <body>
        <h1>
            プロフィール写真を設定する
        </h1>
        <div id="everything-wrapper">
            <p id="picture-instructions">アスペクト比1:1で対象は真ん中にいる画像が望ましいです。<br>必要であればログインがした後、ホームページからプロフィール写真を更新できます。</p>
            
            <!-- servletを使って画像を保存します。その後、自動的にaccCreated.jspへ移動させます。 -->
            <form action="/JV16/servlet/FileUpload" method="post" enctype="multipart/form-data">
            
                <input type="file" name="file" id="image-picker" accept=".jpg, .png" required>
                
                <input type="hidden" name="username" value="<%= username %>">
                <input type="hidden" name="email" value="<%= email %>">
                <input type="hidden" name="password" value="<%= password %>">
                <input type="hidden" name="status" value="profilePicture">
                
                <div id="buttons-wrapper">
                    <button type="button" class="basic-clear" onclick="goBack()">キャンセル</button>
                    <button type="submit" class="basic-submit" id="submitBtn">作成完了</button>
                </div>
                
            </form>
            
        </div>
    </body>
</html>