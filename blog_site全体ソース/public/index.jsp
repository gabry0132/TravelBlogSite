<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//セッション管理：ログアウト処理
	String status = request.getParameter("status");	
	if(status != null){
		if(status.equals("logout")){
			session.removeAttribute("userID");
		}
	}
	String userID = (String) session.getAttribute("userID");
	if(userID != null){
		response.sendRedirect("homepage.jsp");
	}
	
	
	//画面用変数インスタンス変化
	String title = "";

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
	
	//HashMap(1件分のデータを格納する連想配列)
	HashMap<String,String> account = null;
	
	//ArrayList(全ての件数を格納する配列)
	ArrayList<HashMap> users = new ArrayList<HashMap>();

	StringBuffer usernamesStr = null;
	StringBuffer emailsStr = null;
	
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select blogTitle from utilities");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){
			
			title = rs.getString("blogTitle");
			
		}
		
		//アカウント作成用
		//SQLステートメントの作成と発行
		sql = new StringBuffer();
		sql.append("select username, email from users");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを繰り返し処理で保存する
		while(rs.next()){
			
			account = new HashMap<String, String>();
			account.put("username", rs.getString("username"));
			account.put("email", rs.getString("email"));
			
			users.add(account);
			
		}
		
		usernamesStr = new StringBuffer();
		emailsStr = new StringBuffer();
		
		for(int i = 0; i < users.size(); i++){
			usernamesStr.append(users.get(i).get("username"));
			emailsStr.append(users.get(i).get("email"));
			if(i != users.size() - 1){
				usernamesStr.append(",");
				emailsStr.append(",");
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
            ログインページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css">
        <script type="text/javascript" src="scripts/index.js"></script>
    </head>
    <body>
    	<div id="usernames-container" data-names="<%= usernamesStr.toString() %>"></div>
    	<div id="emails-container" data-names="<%= emailsStr.toString() %>"></div>
       	<h1 id="page-main-title"><%= title %>へようこそ！</h1>
        <div id="everything-wrapper">
            <div id="left-wrapper">
                <h2>
                    ログイン
                </h2>
                
                <form action="homepage.jsp" method="post">
                
                    <p class="input-field-intro">メールアドレス又はユーザ名</p>
                    <!-- 本来はメールかユーザー名か、「@」があるかどうかで判断。だからtype="email"にしませんが、nameはmailのままで。 -->
                    <input type="text" name="email" required class="basic-text-field" maxlength="30">

                    <p class="input-field-intro">パスワード</p>
                    <input type="password" name="password" required class="basic-text-field" maxlength="20">

                    <a href="forgotPass.jsp">パスワード忘れた方はこちら→</a>

					<input type="hidden" name="status" value="user-standard-login"> 

                    <div class="buttons-wrapper">
                        <button type="reset" class="basic-clear">クリア</button>
                        <button type="submit" class="basic-submit">ログイン</button>
                    </div>
                    
                </form>
                
                <a href="kanrishaLogin.jsp">管理者はこちらからログインする→</a>
                
            </div>


            <div id="right-wrapper">
                <h2>
                    新規会員登録
                </h2>
                
                <form action="setProfilePicture.jsp" method="post">
                
                    <div class="text-wrapper">
                        <p class="input-field-intro">メールアドレス</p>
                        <span id="email-marker"></span>
                    </div>
                    <input type="email" name="email" id="email-input" required class="basic-text-field" maxlength="60">

                    <div class="text-wrapper">
                        <p class="input-field-intro">ユーザ名</p>
                        <span id="valid-marker">無効　✖</span>
                    </div>
                    <input type="text" name="username" required id="username-input" class="basic-text-field" maxlength="20">

                    <p class="input-field-intro">パスワード</p>
                    <input type="password" name="password" required class="basic-text-field" maxlength="20">
                    
                    <div class="buttons-wrapper">
                        <button type="reset" class="basic-clear">クリア</button>
                        <button type="submit" id="sakuseisubmit" class="basic-submit" disabled>アカウント作成</button>
                    </div>
                </form>
            </div>

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