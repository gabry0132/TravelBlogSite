<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	
	//画面用
	String image = "";
	String email = "";
	String username = "";
	
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
		sql.append("select email, username, profilePicture from users where userID= ");
		sql.append(userID);
		//System.out.println(sql.toString());
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){
			
			image = rs.getString("profilePicture");	//ファイル名+拡張子です。
			email = rs.getString("email");
			username = rs.getString("username");

		}else{
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】User fetching failure - no results for UserID");
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
            プロフィール写真更新
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/updateProfilePicture.css">
        <script type="text/javascript" src="scripts/updateProfilePicture.js"></script>
    </head>
    <body>
    
        <h1>
            プロフィール写真を更新する
        </h1>
        <div id="everything-wrapper">
        	
        	<form action="/JV16/servlet/FileUpload" method="post" enctype="multipart/form-data">
	        	
	        	<table>
	        		<tr>
	        			<td>
	        			
	        				<div id="left">
	        				
				                <h3>現在の写真</h3>
				                
				                <div id="image-wrapper">
									<p id="display-error">
									
									</p>
				                </div>			                
	        				
	        				</div>
	        				
	        			</td>
	        			<td>

				            <div id="right">
				            
					            <p id="picture-instructions">対象は真ん中にいるアスペクト比1:1の画像が望ましいです。</p>
				                <input type="file" name="file" id="image-picker" accept=".jpg, .png" required>

			                    <p class="input-field-intro">パスワード</p>
			                    <input type="password" name="password" required class="basic-text-field" maxlength="20">

				            </div>
				                
	        			</td>
	        		</tr>
	        	
	        	</table>

				<!-- JSで使う上で更新が完了した場合に古い画像を削除するために送信します -->
				<input type="hidden" name="previousImage" id="image" value="<%= image %>">
				
				<!-- 送信して受取ります。 -->
                <input type="hidden" name="username" value="<%= username %>">
                <input type="hidden" name="email" value="<%= email %>">
				<input type="hidden" name="status" value="profilePictureUpdate">
                <input type="hidden" name="koushinkanryo-message" value="プロフィール写真を正常に変更しました">
                <input type="hidden" name="koushin-type" value="pfp-update">
				

                <div id="buttons-wrapper">
                    <a href="homepage.jsp?status=updateCancelled"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" class="basic-submit" id="submitBtn">変更</button>
                </div>
	        	
        	</form>
            
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