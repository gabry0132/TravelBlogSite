<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %><% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String mainTitle = request.getParameter("mainTitle");
	String mainImage = request.getParameter("mainImage");
	String season = request.getParameter("season");
	String prefecture = request.getParameter("prefecture");
	String subtitle = request.getParameter("subtitle");
	String subImage1 = request.getParameter("subImage1");
	String imageDescription1 = request.getParameter("imageDescription1");
	String titleParagraph1 = request.getParameter("titleParagraph1");
	String textParagraph1 = request.getParameter("textParagraph1");
	String subImage2 = request.getParameter("subImage2");
	String imageDescription2 = request.getParameter("imageDescription2");
	String titleParagraph2 = request.getParameter("titleParagraph2");
	String textParagraph2 = request.getParameter("textParagraph2");
	String subImage3 = request.getParameter("subImage3");
	String imageDescription3 = request.getParameter("imageDescription3");
	String titleParagraph3 = request.getParameter("titleParagraph3");
	String textParagraph3 = request.getParameter("textParagraph3");
	String sendMail = request.getParameter("sendMail");
	String addFlag = request.getParameter("addFlag");
	String mode = request.getParameter("mode");
	String articleIDModeEdit = request.getParameter("articleIDModeEdit");	//mode = edit のみ使用
	
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	//画面用
	String seasonName = "";
	String prefectureName = "";
		
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
		
		//季節を検索する
		sql = new StringBuffer();
		sql.append("select seasonName from seasons where seasonID=");
		sql.append(season);
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		if(rs.next()){
			
			seasonName = rs.getString("seasonName");
			
		} else {
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】Incongruent Season Value");
		}
		
		//都道府県を検索する
		sql = new StringBuffer();
		sql.append("select prefectureName from prefectures where prefectureID=");
		sql.append(prefecture);
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		if(rs.next()){
			
			prefectureName = rs.getString("prefectureName");
			
		} else {
			ermsg = new StringBuffer();
			ermsg.append("【SYSERR】Incongruent Prefecture Value");
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
            プレビューページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/preview.css">
        <script type="text/javascript" src="scripts/preview.js"></script>

    </head>
    <body>
        <h1>
            プレビューページ
        </h1>

        <div id="preview-wrapper">

            <div id="everything-wrapper">

                <div id="main-title-wrapper">
					<%= mainTitle %>
                </div>

                <div id="all-images-wrapper">

                    <div id="main-image-wrapper">

                    </div>

                    <h2 id="article-subtitle">
                        <%= subtitle %>
                    </h2>

        
                    <div id="paragraphs-wrapper">

                        <table class="paragraph" id="paragraph-container1">
                            <tr>
                                <th rowspan="2" class="image-th">
                                    <div class="extra-image" id="extra-image-container1">
                                        
                                        <div class="extra-image-description">
                                            <p class="image-description-text">
                                                <%= imageDescription1 %>
                                            </p>
                                        </div>
                                    </div>
                                </th>
                                <th class="paragraph-title-th"><%= titleParagraph1 %></th>
                            </tr>
                            <tr>
                                <td class="paragraph-text"><%= textParagraph1 %></td>
                            </tr>
                        </table>
                        
                        <table class="paragraph" id="paragraph-container2">
                            <tr>
                                <th class="paragraph-title-th"><%= titleParagraph2 %></th>
                                <th rowspan="2" class="image-th">
                                    <div class="extra-image" id="extra-image-container2">
                                        
                                        <div class="extra-image-description">
                                            <p class="image-description-text">
                                                <%= imageDescription2 %>
                                            </p>
                                        </div>
                                    </div>
                                </th>
                            </tr>
                            <tr>
                                <td class="paragraph-text"><%= textParagraph2 %></td>
                            </tr>
                        </table>
                        
                        <table class="paragraph" id="paragraph-container3">
                            <tr>
                                <th rowspan="2" class="image-th">
                                    <div class="extra-image" id="extra-image-container3">
                                        
                                        <div class="extra-image-description">
                                            <p class="image-description-text">
                                                <%= imageDescription3 %>
                                            </p>
                                        </div>
                                    </div>
                                </th>
                                <th class="paragraph-title-th"><%= titleParagraph3 %></th>
                            </tr>
                            <tr>
                                <td class="paragraph-text"><%= textParagraph3 %></td>
                            </tr>
                        </table>

                    </div>
                    
                </div>

            </div>

            <div id="text-wrapper">
                <p class="input-field-intro" id="prefecture-append">都道府県：　<%= prefectureName %></p>
                <p class="input-field-intro" id="season-append">季節：　<%= seasonName %></p>
                <p class="input-field-intro" id="mail-append">メール通知：　<% if(sendMail != null){ if(sendMail.equals("on")){ %>✔<% } else { %>✖<% } } else { %>✖<% } %></p>
            </div>


        </div>


        <div class="buttons-wrapper">
            
	        <form action="addArticle.jsp" method="post" id="return-form">
		        
		        <input type="hidden" name="username" value="<%=username%>">
		        <input type="hidden" name="email" value="<%=email%>">
		        <input type="hidden" name="mainTitle" value="<%=mainTitle%>">
		        <input type="hidden" name="mainImage" id="mainImage" value="<%=mainImage%>">	<!-- 画像削除するためだけです。表示しません -->
		        <input type="hidden" name="season" value="<%=season%>">
		        <input type="hidden" name="prefecture" value="<%=prefecture%>">
		        <input type="hidden" name="subtitle" value="<%=subtitle%>">
		        <input type="hidden" name="subImage1" id="subImage1" value="<%=subImage1%>">	<!-- 画像削除するためだけです。表示しません -->
		        <input type="hidden" name="imageDescription1" value="<%=imageDescription1%>">
		        <input type="hidden" name="titleParagraph1" value="<%=titleParagraph1%>">
		        <input type="hidden" name="textParagraph1" value="<%=textParagraph1%>">
		        <input type="hidden" name="subImage2" id="subImage2" value="<%=subImage2%>">	<!-- 画像削除するためだけです。表示しません -->
		        <input type="hidden" name="imageDescription2" value="<%=imageDescription2%>">
		        <input type="hidden" name="titleParagraph2" value="<%=titleParagraph2%>">
		        <input type="hidden" name="textParagraph2" value="<%=textParagraph2%>">
		        <input type="hidden" name="subImage3" id="subImage3" value="<%=subImage3%>">	<!-- 画像削除するためだけです。表示しません -->
		        <input type="hidden" name="imageDescription3" value="<%=imageDescription3%>">
		        <input type="hidden" name="titleParagraph3" value="<%=titleParagraph3%>">
		        <input type="hidden" name="textParagraph3" value="<%=textParagraph3%>">
		        <input type="hidden" name="sendMail" value="<% if(sendMail != null){ if(sendMail.equals("on")){ %>✔<% } else { %>✖<% } } else { %>✖<% } %>">	<!-- nullの可能性があるので手で設定する -->
		        <input type="hidden" name="addFlag" id="add-flag" value="<%=addFlag%>">
		        <input type="hidden" name="mode" id="mode" value="edit-preview"> <!-- JS用 -->
	            <input type="hidden" name="articleID" id="articleID" value="<%=articleIDModeEdit%>"> <!-- mode = edit のみ使用 -->
	        
            	<button type="submit" class="basic-clear">内容を修正する</button>
            	
			</form>
           
            <form action="/JV16/servlet/FileUpload" method="post" id="update-form" enctype="multipart/form-data"> <!-- enctype使わなくてもFileUploadで期待しています -->
            
		        <input type="hidden" name="username" value="<%=username%>">
		        <input type="hidden" name="email" value="<%=email%>">
		        <input type="hidden" name="main-title" value="<%=mainTitle%>">
		        <input type="hidden" name="mainImageStr" id="mainImagePath" value="<%=mainImage%>"> <!-- パスだけを送信します。ファイルを再コピーする必要がないのでただ登録します。IDはJSで表示のために使う -->
		        <input type="hidden" name="season" value="<%=season%>">
		        <input type="hidden" name="prefecture" value="<%=prefecture%>">
		        <input type="hidden" name="subtitle" value="<%=subtitle%>">
		        <input type="hidden" name="subImage1Str" id="subImage1Path" value="<%=subImage1%>"> <!-- パスだけを送信します。ファイルを再コピーする必要がないのでただ登録します。IDはJSで表示のために使う -->
		        <input type="hidden" name="image-description1" value="<%=imageDescription1%>">
		        <input type="hidden" name="title-paragraph1" value="<%=titleParagraph1%>">
		        <input type="hidden" name="text-paragraph1" value="<%=textParagraph1%>">
		        <input type="hidden" name="subImage2Str" id="subImage2Path" value="<%=subImage2%>"> <!-- パスだけを送信します。ファイルを再コピーする必要がないのでただ登録します。IDはJSで表示のために使う -->
		        <input type="hidden" name="image-description2" value="<%=imageDescription2%>">
		        <input type="hidden" name="title-paragraph2" value="<%=titleParagraph2%>">
		        <input type="hidden" name="text-paragraph2" value="<%=textParagraph2%>">
		        <input type="hidden" name="subImage3Str" id="subImage3Path" value="<%=subImage3%>"> <!-- パスだけを送信します。ファイルを再コピーする必要がないのでただ登録します。IDはJSで表示のために使う -->
		        <input type="hidden" name="image-description3" value="<%=imageDescription3%>">
		        <input type="hidden" name="title-paragraph3" value="<%=titleParagraph3%>">
		        <input type="hidden" name="text-paragraph3" value="<%=textParagraph3%>">
		        <input type="hidden" name="sendMail" value="<%=sendMail%>">	<!-- onじゃなければoffです。FileUploadで管理しています。-->
		        <input type="hidden" name="addFlag" id="add-flag" value="<%=addFlag%>">
		        <input type="hidden" name="mode" id="mode" value="<%=mode%>"> <!-- JS用 -->
		        <input type="hidden" name="articleIDModeEdit" id="articleIDModeEdit" value="<%=articleIDModeEdit%>"> <!-- mode = edit のみ使用 -->
				<input type="hidden" name="status" value="toUpload"> 
		        <input type="hidden" name="koushinkanryo-message" value="<% if(addFlag != null){ if(addFlag.equals("true")){ %>記事を正常に追加しました<% }else{ %>記事を正常に編集しました<% } } else { %>記事データを正常に投稿しました<% } %>">
		        <input type="hidden" name="koushin-type" value="<% if(addFlag != null){ if(addFlag.equals("true")){ %>add-article<% }else{ %>update-article<% } } else { %>update-article<% } %>">
                
                <button type="submit" class="basic-submit">この内容で投稿</button>
                
            </form>
            
        </div>

		<form action="homepage.jsp" method="post" id="cancel-form">
		
    	    <input type="hidden" name="status" value="updateCancelled">
			<!-- previewするためにアップロードした画像はキャンセルボタンを押すと削除されません。残ります。 -->
	       	<button type="submit" class="back-button" id="bottommost">キャンセル</button>

		</form>
		
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