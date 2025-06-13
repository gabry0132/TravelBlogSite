<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
	boolean isRegistered = false;
	
	//ローカルのMySqlに接続する設定
	String user = "root";
	String password = "root";
	String url = "jdbc:mysql://localhost/blog_site";
	String driver = "com.mysql.jdbc.Driver";
	
	//確認メッセージ
	StringBuffer ermsg = null;

	//ヒットフラグ
	int hit_flag = 0;
	
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select newsletterFlag from users where userID=");
		sql.append(userID);
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){
			
			hit_flag = 1;
			
			if(rs.getString("newsletterFlag").equals("1")){
				isRegistered = true;
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
            ニューズレター登録管理
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/newsletterKanri.css">
        <script type="text/javascript" src="scripts/newsletterKanri.js"></script>
    </head>
    <body>
        <h1>
            ニューズレター登録管理
        </h1>
        <div id="everything-wrapper">
            <p id="intro">現在の登録状況：</p>

			<!-- ボタンのBGcolorも設定しているのでJSで全部設定します。 -->
            <p id="description">

            </p>
            
            <form action="koushinkanryo.jsp" method="post">

				<input type="hidden" name="isRegistered" value="<%= isRegistered %>">
		        <input type="hidden" name="koushinkanryo-message" value="<% if(isRegistered){ %>ニューズレターの登録を取り消しました<% } else { %>ニューズレターに登録しました<% } %>">
		        <input type="hidden" name="koushin-type" value="newsletter-status-update">
				
	            <button type="submit" class="basic-submit" disabled id="submitBtn">登録</button>
	            
            </form>
            
        </div>
        <a href="homepage.jsp?status=updateCancelled"><button type="button" class="back-button">前へ</button></a>

    </body>
</html>