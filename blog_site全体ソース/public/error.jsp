<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String error = request.getParameter("error");
	boolean loggedIn = false;
	
	String userID = (String) session.getAttribute("userID");
	if(userID != null) {
		loggedIn = true;
	}
		
%>

<!DOCTYPE html><html>
    <head>
        <title>
            エラーが発生しました
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/errorpage.css">
    </head>
    
    <body>
        <h1>
            エラーが発生しました
        </h1>
        <div id="everything-wrapper">
            <p id="intro">エラー内容</p>

            <p id="description">
				<%= error %>
            </p>
            
        </div>
        
        <!-- indexへ行かせて、セッションが存在する場合は自動的にHPへ移動させる -->
        <form method="post" action="index.jsp" id="error-form">
        	<input type="hidden" name="userID" id="userID" value="<% if(loggedIn){ %> <%= userID %> <% } %>">
        	<input type="hidden" name="status" id="status" value="fromErrorPage">
        	<button type="submit" class="back-button"><% if(loggedIn){ %> ホームページへ <% } else { %> ログインページへ <% } %></button>
        </form>

    </body>
</html>