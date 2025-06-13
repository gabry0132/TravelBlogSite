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
	
	//ArrayList(全ての対象のユーザーを格納する配列)
	ArrayList<String> users = new ArrayList<String>();
	int counter = 0;	//表示用
	
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
		sql.append("select username from users where newsletterFlag = 1");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		while(rs.next()){
			
			users.add(rs.getString("username"));
			
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
            ニューズレター希望の方一覧
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/newseletterSubsList.css">
    </head>
    <body>

        <div id="everything-wrapper">

            <h1>
            ニューズレター希望の方一覧 
            </h1>

            <div id="text-wrapper">
                <p class="intro">希望の方一覧：</p>
                <p class="right-intro">合計：<span id="subsNum"><%= users.size() %></span>名</p>
            </div>
			<!-- 20 rows 3 columns -->
            <div id="table-wrapper">
                <table>
                	<% for(int i = 0; i < 20; i++){ %>
	                    <tr>
	                		<% for(int j = 0; j < 3; j++){ %>
	                        	<td>
	                        		<% if(counter < users.size()){ %>
	                        			<%= users.get(counter) %>
	                        		<% } %>
	                        	</td>
	                        <% counter++; } %>
                    <% } %>
                </table>

            </div>

            <a href="homepage.jsp?status=updateCancelled"><button type="button" class="back-button">ホームページへ</button></a>

        </div>

    </body>
</html>