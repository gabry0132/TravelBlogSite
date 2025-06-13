<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String interactionID = request.getParameter("interactionID");
	String currentUserID = (String) session.getAttribute("userID");
	if(currentUserID == null) response.sendRedirect("index.jsp");
	
	//画面用変数インスタンス変化
	String comment = "";
	String articleID = "";
	String adminReply = "";

	//データベースに接続するために使用する変数宣言
	Connection con = null;
	Statement stmt = null;
	StringBuffer sql = null;
	ResultSet rs = null;
	
	//ローカルのMySqlに接続する設定
	String user = "root";
	String password = "root";
	String url = "jdbc:mysql://localhost/blog_site";
	String driver = "com.mysql.jdbc.Driver";
	
	//確認メッセージ
	StringBuffer ermsg = null;
		
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select adminFlag from users where userID=");
		sql.append(currentUserID);
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){
			
			if(rs.getString("adminFlag").equals("1")){	//管理者ログイン確認済み
				
				//interactionと関わるデータを取得します。
				sql = new StringBuffer();
				sql.append("select articleID, comment, adminReply from interactions where interactionID=");
				sql.append(interactionID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを保存する
				if(rs.next()){
					
					comment = rs.getString("comment");
					articleID = rs.getString("articleID");
					adminReply = rs.getString("adminReply");
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Interaction Data Not Found");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Access Not Granted");
			}
			
		} else {
			ermsg = new StringBuffer();
			ermsg.append("ユーザーが見つかりませんでした");
		}

	}catch(ClassNotFoundException e){
		ermsg = new StringBuffer();
		ermsg.append(e.getMessage());
	}catch(SQLException e){
		ermsg = new StringBuffer();
		ermsg.append(e.getMessage());
	}catch(Exception e){
		ermsg = new StringBuffer();
		ermsg.append(e.getMessage());
	}
	finally{
		try{
			if(rs != null){
				rs.close();		
			}
			if(stmt != null){
				stmt.close();		
			}
			if(con != null){
				con.close();		
			}
		}catch(SQLException e){
			ermsg = new StringBuffer();
			ermsg.append(e.getMessage());
		}
	}
%>

<!DOCTYPE html>
<html>
    <head>
        <title>
            管理者のコメント返事ページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/replyComment.css">
        <script type="text/javascript" src="scripts/replyComment.js"></script>
    </head>
    <body>

        <div id="everything-wrapper">
            <h1>
            コメントに返事する 
            </h1>
            <!-- 最低限のエラー対策としてデフォルトはホームページにしますがJSで戻るようにしています。 -->
            <!-- getの取り扱いしているのにpostを使わないと動かないです。本来はちゃんと<input type="hidden">を使います。 -->
            <form action="article.jsp" method="post" id="main-form">
                <p class="intro">対象のコメント</p>
                <textarea name="existing-comment" cols="93" rows="7" disabled><%= comment %></textarea>
                
                <p class="intro">返事を入力してください</p>
                <textarea name="reply-text" id="reply-text" cols="93" rows="7" required maxlength="390"><% if(adminReply != null){ %><%= adminReply %><% } %></textarea>
                
                <input type="hidden" name="interactionID" id="interactionID" value="<%= interactionID %>">
                <input type="hidden" name="replyAction" id="replyAction" value="upload">
                <input type="hidden" name="koushin" id="koushin" value="✔　返事を投稿しました">
                
                <div id="buttons-wrapper">
                    <a href="article.jsp?articleID=<%= articleID %>&userID=<%= currentUserID %>" id="return-anchor"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="sumbit" class="basic-submit" id="submitButton">返事を投稿</button>
                </div>
            </form>
            
            <% if(adminReply != null){ %>	<!-- 返事がなければ「返事を削除」ボタンを表示しません。 -->
            
            	<!-- ボタンはformの外に置いて、onClick= confirm(deleteOK?)で、OKだったらJSでformをsubmitする。 -->
	            <form action="article.jsp" method="post" id="delete-form">
	                                
	                <input type="hidden" name="interactionID" id="interactionID" value="<%= interactionID %>">
	                <input type="hidden" name="replyAction" id="replyAction" value="delete">
	                <input type="hidden" name="koushin" id="koushin" value="✔　返事を削除しました">
	                
	            </form>
	            
	            <button type="button" class="basic-delete" id="deleteButton">返事を削除</button>
	            
            <% } %>
            
        </div>

		<% if(ermsg != null){ %>
        	<form method="post" action="error.jsp" id="error-form">
        		<input type="hidden" name="error" value="<%= ermsg %>">
        	</form>
			<script>
		    	document.forms["error-form"].requestSubmit();
			</script>
		<% } %>
		
    </body>
</html>