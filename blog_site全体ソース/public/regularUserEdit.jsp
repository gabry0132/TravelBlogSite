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
	String startingComment = "";
	String articleID = "";

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
			
			if(rs.getString("adminFlag").equals("0")){	//一般ユーザーログイン確認済み
				
				//interactionと関わるデータを取得します。
				sql = new StringBuffer();
				sql.append("select articleID, comment from interactions where interactionID=");
				sql.append(interactionID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを保存する
				if(rs.next()){
					
					startingComment = rs.getString("comment");
					articleID = rs.getString("articleID");
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Interaction Data Not Found");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Access Only Granted To Regular Users");
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
            一般ユーザーのコメント編集・削除ページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/regularUserEdit.css">
        <script type="text/javascript" src="scripts/regularUserEdit.js"></script>
    </head>
    <body>
        <div id="everything-wrapper">
            <h1>
            コメントの編集・削除 
            </h1>
            <!-- 最低限のエラー対策としてデフォルトはホームページにしますがJSで戻るようにしています。 -->
            <form action="article.jsp" method="post" id="main-form">
                <p id="intro">
                    文章を入力してください
                </p>
                <textarea name="comment-text" cols="93" rows="7" required maxlength="390"><%= startingComment %></textarea>
                
                <input type="hidden" name="interactionID" id="interactionID" value="<%= interactionID %>">
                <input type="hidden" name="userCommentAction" id="userCommentAction" value="upload">
                <input type="hidden" name="koushin" id="koushin" value="✔　コメントを編集しました">
                
                
                <div id="buttons-wrapper">
                    <a href="article.jsp?articleID=<%= articleID %>" id="return-anchor"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" class="basic-submit" id="submitBtn">編集を登録</button>
                </div>
            </form>
            
           	<!-- ボタンはformの外に置いて、onClick= confirm(deleteOK?)で、OKだったらJSでformをsubmitする。 -->
            <form action="article.jsp" method="post" id="delete-form">
                                
                <input type="hidden" name="interactionID" id="interactionID" value="<%= interactionID %>">
                <input type="hidden" name="userCommentAction" id="userCommentAction" value="delete">
                <input type="hidden" name="koushin" id="koushin" value="✔　コメントを削除しました">
                
            </form>
          	
           	<button type="button" class="basic-delete" id="deleteButton">コメントを削除</button>
           	
        </div>

        
    </body>
</html>