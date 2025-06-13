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
	int articlesPerPage = 9;

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
		sql.append("select articlesPerPage from utilities");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){

			articlesPerPage = Integer.parseInt(rs.getString("articlesPerPage"));	//数字しか登録できない前提でparseInt()します。
		
		} //問題が発生しないだろうけどディフォルトとして9個でいいと思います。

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
            管理者メニュー
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/kanrishaMenu.css">
    </head>
    <body>
        <h1>
            管理者メニュー
        </h1>
        <div id="everything-wrapper">
            <div id="base-buttons-wrapper">
                <a href="updateMainTitle.jsp?userID=<%=userID%>" class="base-anchor"><button type="button" class="basic-clear">タイトルを更新する</button></a>
                <a href="updateMainDescription.jsp?userID=<%=userID%>" class="base-anchor"><button type="button" class="basic-clear">メイン記述を更新する</button></a>
                <a href="newseletterSubsList.jsp?userID=<%=userID%>" class="base-anchor"><button type="button" class="basic-clear">ニューズレター希望の方一覧</button></a>
            </div>
            <div id="articlesPerPage-selector">
            	<form action="koushinkanryo.jsp" method="post">
            		<input type="hidden" name="userID" value="<%= userID %>">
	                <input type="hidden" name="koushinkanryo-message" value="1ページの記事の数を正常に更新しました">
	                <input type="hidden" name="koushin-type" value="articlesPerPage-update">

                    <p class="input-field-intro">1ページに何件の記事を表示する</p>
                    <div id="updateNum">
	                    <input type="number" name="articlesPerPage" id="articlesPerPageUpdate" required class="basic-text-field" min="1" max="99" value="<%= articlesPerPage %>">
	                    <button type="submit" class="basic-clear">更新</button>
					</div>
            	</form>
            </div>
            <div id="tsuika-button-wrapper">
                <a href="addArticle.jsp?mode=add&userID=<%=userID%>" id="submit-anchor"><button type="button" class="basic-submit">記事を追加する</button></a>
            </div>
            <a href="homepage.jsp?userID=<%= userID %>&status=updateCancelled"><button type="button" class="back-button" id="topmost">前へ</button></a>
        </div>
    </body>
</html>


