<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	
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
            タイトル更新
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/updateMainTitle.css">
    </head>
    <body>

        <div id="everything-wrapper">
            <h1>
            タイトル更新 
            </h1>
            <!-- 最低限のエラー対策としてデフォルトはホームページにしますがJSで戻るようにしています。 -->
            <form action="koushinkanryo.jsp" method="post" id="main-form">
                <p class="intro">現在のタイトル</p>
                <textarea name="existing-title" cols="93" rows="3" disabled><% if(title != null){ %> <%= title %> <% } %></textarea>
                
                <p class="intro">タイトルを入力</p>
                <textarea name="title" cols="93" rows="3" required maxlength="20"></textarea>
                
                <input type="hidden" name="koushinkanryo-message" value="メインタイトルを正常に更新しました">
                <input type="hidden" name="koushin-type" value="main-title-update">
                
                <div id="buttons-wrapper">
                    <a href="homepage.jsp?status=updateCancelled" id="return-anchor"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" id="sakuseisubmit" class="basic-submit">投稿</button>
                </div>
            </form>
        </div>

    </body>
</html>