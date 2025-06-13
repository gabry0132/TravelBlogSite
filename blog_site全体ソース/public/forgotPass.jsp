<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
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
            パスワードを忘れたページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/forgotPass.css">
        <script type="text/javascript" src="scripts/forgotPass.js"></script>
		<script src="https://smtpjs.com/v3/smtp.js"></script>
    </head>
    <body>
       	<div id="usernames-container" data-names="<%= usernamesStr.toString() %>"></div>
    	<div id="emails-container" data-names="<%= emailsStr.toString() %>"></div>
        <h1>
            パスワードを再設定する
        </h1>
        <form action="resetPass.jsp" method="post">

            <div class="text-wrapper">
                <p class="input-field-intro">ユーザ名</p>
                <span id="username-valid-marker"></span>
            </div>
            <input type="text" name="username" id="username" class="basic-text-field">

            <div class="text-wrapper">
                <p class="input-field-intro">メールアドレス</p>
                <span id="email-valid-marker"></span>
            </div>
            <input type="email" name="email" id="email" class="basic-text-field">

            <button type="button" id="sendOTP">ワンタイムパスワード<br>を送信する</button>

            <div class="text-wrapper">
                <p class="input-field-intro">ワンタイムパスワードを入力してください</p>
                <span id="otp-valid-marker"></span>
            </div>
            <input type="text" name="otp" id="otp" class="basic-text-field" disabled>

            <div class="buttons-wrapper">
                <a id="cancel" href="index.jsp">キャンセル</a>
                <button type="button" id="sakuseisubmit" class="basic-submit">OTPチェック</button>
            </div>

        </form>
    </body>
</html>