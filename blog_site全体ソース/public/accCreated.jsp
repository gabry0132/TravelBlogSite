<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String userPassword = request.getParameter("password");
	String image = request.getParameter("image");
	
	//ニューズレター登録画面へ移動するためにユーザーが追加された後に取得する。
	String userID = "";
	
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
	
	//追加件数
	int ins_count = 0;

	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select * from users where username= '");
		sql.append(username);
		sql.append("' and email='");
		sql.append(email);
		sql.append("'");
		//System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを繰り返し処理を表示する
		if(rs.next()){	//存在する（追加NG）
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】User already exists");
		}else{	//存在しない（追加OK）
					
			//SQLステートメントの作成と実行
			sql = new StringBuffer();
			sql.append("insert into users(email,username,password,profilePicture)");
			sql.append("values('");
			sql.append(email.trim());
			sql.append("','");
			sql.append(username.trim());
			sql.append("','");
			sql.append(userPassword.trim());
			sql.append("','");
			sql.append(image);
			sql.append("')");
			
			//System.out.println(sql.toString());
			ins_count = stmt.executeUpdate(sql.toString());
		}
		
		if(ins_count == 0){
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】Insert Failure - Zero rows affected");
		} else {
			sql = new StringBuffer();
			
			//SQLステートメントの作成と発行
			sql.append("select userID from users where username= '");
			sql.append(username);
			sql.append("' and email='");
			sql.append(email);
			sql.append("'");
			//System.out.println(sql.toString());
			rs = stmt.executeQuery(sql.toString());

			if(rs.next()){
				
				userID = rs.getString("userID");
				
				//セッション管理
				session.setMaxInactiveInterval(600);	//10分
				session.setAttribute("userID", userID);
				
			} else {	//発生することがないです。
				
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Unable to retrieve UserID after registration");
				
			}
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
            作成完了
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/accCreated.css">
        <script type="text/javascript" src="scripts/accCreated.js"></script>
    </head>
    <body>
    
    	<% if(ins_count > 0){ %>
	    	
	    	<!-- JSの方で画像を表示するために設定します。 -->
	    	<input type="hidden" name="image" id="image" value="<%= image %>">
	        <h1>
	            アカウントを正常に作成しました！
	        </h1>
	
	        <div id="image-wrapper">
	                    
	        </div>                
	
	        <p>
	            今から最新の記事が投稿された瞬間に通知メール（ニューズレター形）<br>希望の方は次のボタンで設定登録を行うことができます。
	        </p>
	        
	        <div id="buttons">
	            <a href="homepage.jsp?userID=<%= userID %>&status=accCreated" id="toHP">後で設定する<br>（ホームページへ）</a>
	            <a href="newsletterKanri.jsp?userID=<%= userID %>" id="toNL">ニューズレター<br>希望登録する</a>
	        </div>
	         
        <% } else if(ermsg != null){ %>
        	<form method="post" action="error.jsp" id="error-form">
        		<input type="hidden" name="error" value="<%= ermsg %>">
        	</form>
			<script>
		    	document.forms["error-form"].requestSubmit();
			</script>
		<% } %>
        
    </body>
</html>