<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	
	//データベースに接続するために使用する変数宣言
	Connection con = null;
	Statement stmt = null;
	StringBuffer sql = null;
	ResultSet rs = null;
	
	//画面用変数インスタンス変化
	String email = "";
	String displayedMail = "";
	
	//ローカルのMySqlに接続する設定
	String user = "root";
	String password = "root";
	String url = "jdbc:mysql://localhost/blog_site";
	String driver = "com.mysql.jdbc.Driver";
	
	//確認メッセージ
	StringBuffer ermsg = null;
	
	//ArrayList(全ての件数を格納する配列)
	ArrayList<String> emailList = new ArrayList<String>();

	//ヒットフラグ
	int hit_flag = 0;
	
	StringBuffer allMails = new StringBuffer();
	
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select userID, email from users");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		while(rs.next()){
			
			if(rs.getString("userID").equals(userID)){
			
				hit_flag = 1;
				
				email = rs.getString("email");
			}
			
			emailList.add(rs.getString("email"));
			
		}

		if(hit_flag == 1){
			//表示するメールのセットアップ
			for(int i = 0; i < 3; i++){
				displayedMail += email.charAt(i);
			}
			displayedMail += "*****";
			for(int i = email.length() - 7; i < email.length(); i++){
				displayedMail += email.charAt(i);
			}
			//全てのメールを送信する準備
			for(int i = 0; i < emailList.size(); i++){
				if(i != 0){
					allMails.append(",");
				}
				allMails.append(emailList.get(i));
			}
		} else {
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】User Fetching Error");
			
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
            メールアドレスを更新する
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/updateMail.css">
        <script type="text/javascript" src="scripts/updateMail.js"></script>
    </head>
    <body>
    	<% if(hit_flag == 1) { %>
	        <h1>
	            メールアドレスを更新する
	        </h1>
	        
	        <div id="emails-container" data-names="<%= allMails.toString() %>"></div>
	        
	        <div id="everything-wrapper">
	        
	            <form action="koushinkanryo.jsp" method="post">
	            
	                <p class="input-field-intro">現在のメールアドレス</p>
	                <input type="text" name="current-mail" disabled class="basic-text-field" id="current-mail" value="<%= displayedMail %>">
	                
                    <div class="text-wrapper">
		                <p class="input-field-intro">新しいメールアドレス</p>
                        <span id="valid-marker"></span>
                    </div>
	                <input type="email" name="email" required class="basic-text-field" id="email">
	                
	                <p class="input-field-intro">パスワード</p>
	                <input type="password" name="password" required class="basic-text-field" id="pass">
	                
	                <input type="hidden" name="koushinkanryo-message" value="メールアドレスを正常に更新しました">
	                <input type="hidden" name="koushin-type" value="mail-update">
	                
	                <div id="buttons-wrapper">
	                    <a href="homepage.jsp?status=updateCancelled"><button type="button" class="basic-clear">キャンセル</button></a>
	                    <button type="submit" class="basic-submit" disabled id="submitBtn">登録</button>
	                </div>
	                
	            </form>
	            
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