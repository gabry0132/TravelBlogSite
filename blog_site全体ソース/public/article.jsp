<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.swing.plaf.multi.MultiSliderUI"%>
<%@ page import="java.time.LocalDate" %>
<%

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信	
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");

	String articleID = request.getParameter("articleID");
	String koushin = request.getParameter("koushin");	//コメントや返事を投稿・編集・削除の場合
	String comment = request.getParameter("comment-text");	//コメント投稿の場合 + ユーザーが自分のコメントを編集する場合(同じ処理です)
	String replyAction = request.getParameter("replyAction");	//返事を投稿・編集・削除の場合
	String adminReplyToUpload = request.getParameter("reply-text");	//返事を投稿・編集・削除の場合
	String interactionIDToChange = request.getParameter("interactionID");	//現在のではない、updateすべきなのです。コメントや返事を投稿・編集・削除の場合
	String deleteCommentRequest = request.getParameter("deleteCommentRequest");	//コメント削除の場合
	String sendMail = request.getParameter("sendMail");	//コメント削除の場合
	String reasonForDelete = request.getParameter("reasonForDelete");	//コメント削除の場合
	String userCommentAction = request.getParameter("userCommentAction");	//一般ユーザーが自分のコメントを編集・削除する場合

	
	//画面用
	boolean loggedIn = false;
	boolean isAdmin = false;
	String previousArticleID = articleID;	//初期値はarticleIDと同じにします。上書きされなかったら<a>タグを設定しないように。articleIDがnullの場合は後で値を設定しています。
	String nextArticleID = articleID;
	HashMap<String,String> interactionData = null;
	HashMap<String,String> commentData = null;
	ArrayList<HashMap> commentsList = new ArrayList<HashMap>();
	String email = ""; 	//管理者がコメントを削除した時にメール通知すべきであればこの変数にメールアドレスを保存します。
	String blogTitle = "";	//コメント削除通知メールに使います。
	String deletedComment = "";
	String likeCounter = "";
	String title = "";
	String mainImage = "";
	String subtitle = "";
	String subImage1 = "";
	String imageDescription1 = "";
	String titleParagraph1 = "";
	String textParagraph1 = "";
	String subImage2 = "";
	String imageDescription2 = "";
	String titleParagraph2 = "";
	String textParagraph2 = "";
	String subImage3 = "";
	String imageDescription3 = "";
	String titleParagraph3 = "";
	String textParagraph3 = "";
	String uploadDate = "";
	
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
	
		if(replyAction != null){
			
			//interactionIDToChangeを持っているのでarticleIDを求めて、updateやdeleteをしに行きます。
			sql = new StringBuffer();
			sql.append("select articleID from interactions where interactionID=");
			sql.append(interactionIDToChange);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				
				articleID = rs.getString("articleID");	//これでupdateやdelete処理が終わったら普通の流れで記事が表示される。

				int update_count = 0;
				
				switch(replyAction){
					
					case "delete":
						
						sql = new StringBuffer();
						sql.append("update interactions set adminReply = null where interactionID=");
						sql.append(interactionIDToChange);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//追加失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】Delete Failure - Unable to set reply as null");
						} 
						
					break;
					
					case "upload":
						
						sql = new StringBuffer();
						sql.append("update interactions set adminReply ='");
						sql.append(adminReplyToUpload.trim());
						sql.append("' where interactionID=");
						sql.append(interactionIDToChange);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//追加失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】Update Failure - Unable to register reply");
						} 

						
					break;
					
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Interaction Data Not Found");

			}

		}
		
		if(userCommentAction != null){
			
			//interactionIDToChangeを持っているのでarticleIDを求めて、updateやdeleteをしに行きます。
			sql = new StringBuffer();
			sql.append("select articleID from interactions where interactionID=");
			sql.append(interactionIDToChange);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				
				articleID = rs.getString("articleID");	//これでupdateやdelete処理が終わったら普通の流れで記事が表示される。

				int update_count = 0;
				
				switch(userCommentAction){
					
					case "delete":
						
						sql = new StringBuffer();
						sql.append("update interactions set comment = null, adminReply = null, commentUploadDate = null where interactionID=");
						sql.append(interactionIDToChange);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//追加失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】Delete Failure - Unable to delete fields");
						} 
						
					break;
					
					case "upload":
						
						//普通にコメントを投稿する処理を使います。
						// Ctrl + F「コメント投稿すべきであればここで行います」で見えます。途中で邪魔するものがありません。
						
					break;
					
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Interaction Data Not Found");

			}

		}

		
		
		if(deleteCommentRequest != null){
			
			//interactionIDToChangeを持っているのでarticleIDを求めて、updateやdeleteをしに行きます。
			sql = new StringBuffer();
			sql.append("select articleID, comment from interactions where interactionID=");	//コメントはメールに表示するために取得します。
			sql.append(interactionIDToChange);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				
				articleID = rs.getString("articleID");	//これでupdateやdelete処理が終わったら普通の流れで記事が表示される。
				deletedComment = rs.getString("comment");

				int update_count = 0;
				
				switch(deleteCommentRequest){
					
					case "delete":
						
						sql = new StringBuffer();
						sql.append("update interactions set comment = null, adminReply = null, commentUploadDate = null where interactionID=");
						sql.append(interactionIDToChange);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//追加失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】Delete Failure - Unable to delete fields");
						} else {
							//メール通知すべきであれば希望者全員に送信します。
							if(sendMail != null){
								if(sendMail.equals("true")){
									
									//希望者のメールアドレスを取得します。
									sql = new StringBuffer();
									sql.append("select email from users inner join interactions on users.userID = interactions.userID where interactionID=");
									sql.append(interactionIDToChange);
									//System.out.println(sql);
									rs = stmt.executeQuery(sql.toString());
									
									if(rs.next()){
										
										email = rs.getString("email");
										
									} else {
										ermsg = new StringBuffer();
										ermsg.append("【SYSERR】User email not found");										
									}
									
									//メールに入れるためにブログのメインタイトルを取得します。
									sql = new StringBuffer();
									sql.append("select blogTitle from utilities");
									//System.out.println(sql);
									rs = stmt.executeQuery(sql.toString());
									
									if(rs.next()){
										
										blogTitle = rs.getString("blogTitle");
										
									} else {
										ermsg = new StringBuffer();
										ermsg.append("【SYSERR】Blog Title Not Found");
									}
	
								}
							}

						}
						
					break;
					
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Interaction Data Not Found");
			}

		}
		
		//交流のチェックを行う。最初にクリックしている場合にテーブルに行を作ります。
		sql = new StringBuffer();
		sql.append("select adminFlag from users where userID=");
		sql.append(userID);
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		if(rs.next()){	//取得OK
			
			loggedIn = true;
			
			if(rs.getString("adminFlag").equals("1")){
				isAdmin = true;
			}
			
			//交流のチェックを行う。最初にクリックしている場合にテーブルに行を作ります。
			sql = new StringBuffer();
			sql.append("select count(interactionID) as interactionExists from interactions where userID=");
			sql.append(userID);
			sql.append(" and articleID=");
			sql.append(articleID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			//取得したデータを繰り返し処理で保存する
			if(rs.next()){
				
				if(rs.getString("interactionExists").equals("0")){	//交流が存在しない：「ユーザーがこの記事を読んだことがない」ので「読んだことがある」に変換
					
					int insert_count = 0;
					
					sql = new StringBuffer();
					sql.append("insert into interactions (userID,articleID) values(");
					sql.append(userID.trim() + "," + articleID.trim());
					sql.append(")");
					//System.out.println(sql.toString());
					insert_count = stmt.executeUpdate(sql.toString());	
					
					if(insert_count == 0){		//追加失敗
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】General Insert Failure - Unable to add new interaction");
					}
					
				}
				
				//コメント投稿すべきであればここで行います。
				if(koushin != null && comment != null){
					
					int update_count = 0;
					String currentDate = LocalDate.now().toString().replace('-', '/');
					
					sql = new StringBuffer();
					sql.append("update interactions set comment='");
					sql.append(comment.trim());
					sql.append("', commentUploadDate ='");
					sql.append(currentDate);
					sql.append("' where userID=");
					sql.append(userID);
					sql.append(" and articleID=");
					sql.append(articleID);
					//System.out.println(sql.toString());
					update_count = stmt.executeUpdate(sql.toString());	
					
					if(update_count == 0){		//追加失敗
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】General Insert Failure - Unable to register comment");
					}
				}
				
				//この時点で絶対交流データがありますので取得します。
				sql = new StringBuffer();
				sql.append("select interactionID, userID, articleID, likeFlag, comment, adminReply from interactions where userID=");
				sql.append(userID);
				sql.append(" and articleID=");
				sql.append(articleID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					interactionData = new HashMap<String,String>();
					
					interactionData.put("interactionID", rs.getString("interactionID"));
					interactionData.put("userID", rs.getString("userID"));
					interactionData.put("articleID", rs.getString("articleID"));
					interactionData.put("likeFlag", rs.getString("likeFlag"));
					interactionData.put("comment", rs.getString("comment"));		//デフォルトはStringじゃなくて、nullです
					interactionData.put("adminReply", rs.getString("adminReply"));	//デフォルトはStringじゃなくて、nullです
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Data Retrieval Failure");
			}
			
			//流行チェックが終わったら記事データを取得します。
			sql = new StringBuffer();
			sql.append("select title,subtitle,mainImage,subImage1,subDesc1,paragTitle1,paragText1,subImage2,subDesc2,paragTitle2,paragText2,subImage3,subDesc3,paragTitle3,paragText3,uploadDate from articles where articleID=");
			sql.append(articleID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());

			if(rs.next()){
				
				title = rs.getString("title");               
				mainImage = rs.getString("mainImage");
				subtitle = rs.getString("subtitle");
				subImage1 = rs.getString("subImage1");
				imageDescription1 = rs.getString("subDesc1");
				titleParagraph1 = rs.getString("paragTitle1");
				textParagraph1 = rs.getString("paragText1");
				subImage2 = rs.getString("subImage2");
				imageDescription2 = rs.getString("subDesc2");
				titleParagraph2 = rs.getString("paragTitle2");
				textParagraph2 = rs.getString("paragText2");
				subImage3 = rs.getString("subImage3");
				imageDescription3 = rs.getString("subDesc3");
				titleParagraph3 = rs.getString("paragTitle3");   
				textParagraph3 = rs.getString("paragText3");
				uploadDate = rs.getString("uploadDate").replace('-','/');
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Article Not Found");
			}
			
			//前の記事と後の記事へ行く<a>タグを設定するために現在のarticleIDの1つ前と1つ後のarticleIDを取得します。
			previousArticleID = articleID;	//一番上に設定すればarticleIDじゃなくてinteractionIDが来るときにnullのままでダメです。
			nextArticleID = articleID;

			//前の記事
			sql = new StringBuffer();
			sql.append("select MAX(articleID) as previousArticleID from articles where articleID<");
			sql.append(articleID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				
				if(rs.getString("previousArticleID") != null){
					previousArticleID = rs.getString("previousArticleID");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Previous Article Info Not Found");
			}
			
			//後の記事
			sql = new StringBuffer();
			sql.append("select MIN(articleID) as nextArticleID from articles where articleID>");
			sql.append(articleID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				
				if(rs.getString("nextArticleID") != null){
					nextArticleID = rs.getString("nextArticleID");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Previous Article Info Not Found");
			}

			//「いいね！」ボタンを押した人数を求める
			sql = new StringBuffer();
			sql.append("select COUNT(userID) as counter from interactions where likeFlag = 1 and articleID=");
			sql.append(articleID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());

			if(rs.next()){
				
				likeCounter = rs.getString("counter");
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Number of reactions not found");
			}

			//全てのコメントと関わる情報を取得します。	
			sql = new StringBuffer();
			sql.append("select interactions.interactionID, profilePicture, username, comment, adminReply from users inner join interactions on users.userID = interactions.userID where comment is not null and articleID =");
			sql.append(articleID);
			sql.append(" order by commentUploadDate desc");
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());

			while(rs.next()){   //コメントがない場合は「emptyset」が戻りますのでwhileに入りません。コメントのリストがsize() = 0だという意味です。
				
				commentData = new HashMap<String,String>();
				commentData.put("interactionID", rs.getString("interactionID"));
				commentData.put("profilePicture", rs.getString("profilePicture"));
				commentData.put("username", rs.getString("username"));
				commentData.put("comment", rs.getString("comment"));
				commentData.put("adminReply", rs.getString("adminReply"));
				commentsList.add(commentData);
				
			} 
			
		} else {	//取得NG
			ermsg = new StringBuffer();
			ermsg.append("記事を見るためにログインしてください");
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
            記事詳細ページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/article.css">
        <script type="text/javascript" src="scripts/article.js"></script>

    </head>
    <body>
    
    	<% if(loggedIn && interactionData != null){ %>
	    	
	    	<!-- 更新や削除があった場合にJSが動きます -->
	    	<input type="hidden" name="sendMail" id="sendMail" value="<%= sendMail %>">
	    	<input type="hidden" name="email" id="email" value="<%= email %>">
	    	<input type="hidden" name="blogTitle" id="blogTitle" value="<%= blogTitle %>">
	    	<input type="hidden" name="reasonForDelete" id="reasonForDelete" value="<%= reasonForDelete %>">
	    	<input type="hidden" name="deletedComment" id="deletedComment" value="<%= deletedComment %>">
	    	
	    	<input type="hidden" name="koushin" id="koushin" value="<%= koushin %>">
	    	<% if(interactionData != null){ %>
		    	<input type="hidden" name="interactionID" id="interactionID" value="<%= interactionData.get("interactionID") %>">
		    	<input type="hidden" name="userID" id="userID" value="<%= interactionData.get("userID") %>">
		    	<input type="hidden" name="articleID" id="articleID" value="<%= interactionData.get("articleID") %>">
		    	<input type="hidden" name="likeFlag" id="likeFlag" value="<%= interactionData.get("likeFlag") %>">	<!-- ユーザーが「いいね！」ボタンを押したら、DBに登録して、新しい値はこの<input>に上書きして保存します。 -->
		    	<input type="hidden" name="comment" id="comment" value="<%= interactionData.get("comment") %>">
		    	<input type="hidden" name="adminReply" id="adminReply" value="<%= interactionData.get("adminReply") %>">
	    	<% } %>
	    	<input type="hidden" name="isAdmin" id="isAdmin" value="<%= isAdmin %>">
	    	<input type="hidden" name="imagesData" id="imagesData" value="<%= mainImage + "," + subImage1 + "," + subImage2 + "," + subImage3 %>">
	    
	        <h1 id="main-title">
	            <%= title %>
	        </h1>
	
	        <div id="koushin-marker">
	            <p id="koushin-text">
	                ✔　更新を正常に完了しました
	            </p>
	        </div>
	
	        <div id="everything-wrapper">
	
	            <div class="previous-next-holder">
                	<p class="previous" onclick="changeOpenArticle(<%= previousArticleID %>)"><% if(!previousArticleID.equals(articleID)){ %>＜前の記事<% } %></p>
                	<p class="next" onclick="changeOpenArticle(<%= nextArticleID %>)"><% if(!nextArticleID.equals(articleID)){ %>次の記事＞<% } %></p>
	            </div>
	
	            <div id="all-images-wrapper">
	
	                <div id="main-image-wrapper">
	
	                </div>
	
	                <h2 id="article-subtitle">
	                    <%= subtitle %>
	                </h2>
	
	    
	                <div id="paragraphs-wrapper">
	
	                    <table class="paragraph" id="paragraph-container1" onmouseenter="displayImageDescription(1)" onmouseleave="hideImageDescriptions()">
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
	                    
	                    <table class="paragraph" id="paragraph-container2" onmouseenter="displayImageDescription(2)" onmouseleave="hideImageDescriptions()">
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
	                    
	                    <table class="paragraph" id="paragraph-container3" onmouseenter="displayImageDescription(3)" onmouseleave="hideImageDescriptions()">
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
	            
	            <div id="iploadDate-wrapper">
	            	<p id="uploadDate">投稿日付：<%= uploadDate %></p>
	            </div>
	
	            <div id="like-wrapper">
	                <video id="like-animation" src="images/like-animation.mp4" width="81" height="73" preload="auto">♡</video>
	                <p id="like">いいね！</p>
	            </div>
	            
	            <div id="like-counter">	
	                <p class="section-intro" id="like-count">「いいね！」を付けた方：<%= likeCounter %>人</p>
	            </div>
	
	            <div id="comment-wrapper">	
	            	<div id="comment-intro-text-wrapper">
		                <p class="section-intro">コメントを追加する:</p>
						<span id="comment-valid-marker"></span>	            	
	            	</div>
	
	                <form action="article.jsp" method="post" id="comment-form">
	                	<% if(interactionData != null){ %>
	           	        	<input type="hidden" name="userID" id="userID" value="<%= interactionData.get("userID") %>">
		                	<input type="hidden" name="articleID" id="articleID" value="<%= interactionData.get("articleID") %>">
	                	<% } %>
	                	<input type="hidden" name="koushin" id="koushin" value="✔　コメントを投稿しました">
	                    <textarea name="comment-text" id="comment-text" class="comment-textarea" cols="93" rows="7" required maxlength="390"></textarea>
	                    <div id="buttons-wrapper">
	                        <button type="reset" class="basic-clear">クリア</button>
	                        <button type="submit" class="basic-submit"  id="submitBtn">投稿</button>
	                    </div>
	                </form>
	            </div>
	
	            <div id="all-comments-wrapper">
	
	                <p class="section-intro">コメント一覧</p>

					<% if(commentsList.size() == 0){ %>
	                	<p id="no-comments">コメントがありません。</p>
	                <% } %>
	                
	
					<% for(int i = 0; i < commentsList.size(); i++){ %>
		                <div class="user-comment-wrapper" onmouseenter="colorReply(this)" onmouseleave="removeAllReplyColors()">
		                    <div class="text-wrapper">
		                        <div class="pfp-name-wrapper">
		                        	<img src="images/profile_pictures/<%= commentsList.get(i).get("profilePicture") %>" class="pfp" width="30px" height="30px" alt="ユーザーのプロフィール写真">
		                            <p class="username"><%= commentsList.get(i).get("username") %></p>
		                        </div>
		                        <div class="comment-anchors-wrapper">
		                        	<!-- 次の2つの<a>タグに送信しているのは「対象のコメントのinteractionID」と「現在ログインしているuserID」です。管理者ログインの場合は直接関係なくて大丈夫です。 -->
		                        	<!-- interactionsDataだと言っても、今現在のセッションのログイン済みのuserIDのことです。要注意です。 -->
		                        	<% if(isAdmin == true){ %>
		                            	<a class="comment-reply-anchor" href="replyComment.jsp?interactionID=<%= commentsList.get(i).get("interactionID") %>"><button type="button" class="reply-comment">返事</button></a>  <!-- 本来は自分のだけが表示されます -->
		                            <% } %>
		                            <!-- 自分のコメントだけを編集・削除させます。 -->
		                            <% if(isAdmin == true || commentsList.get(i).get("interactionID").equals(interactionData.get("interactionID"))){ %>
		                            	<a class="comment-edit-anchor" href="<% if(isAdmin == true){ %>kanrishaEdit<% } else { %>regularUserEdit<% } %>.jsp?interactionID=<%= commentsList.get(i).get("interactionID") %>"><button type="button" class="edit-comment"><% if(isAdmin == true){ %>削除<% } else { %>編集・削除<% } %></button></a>  <!-- 本来は自分のだけが表示されます -->
		                        	<% } %>
		                        </div>
		                    </div>
		                    <p class="user-comment">
		                        <%= commentsList.get(i).get("comment") %>
		                    </p>
		                    <div class="author-reply-wrapper">
		                        <p class="author-reply"><% if(commentsList.get(i).get("adminReply") != null){ %>著者返事：<%= commentsList.get(i).get("adminReply") %><% } %></p>
		                    </div>
		                </div>
	                <% } %>
	
	            </div>
	
	            <div class="previous-next-holder">
                	<p class="previous" onclick="changeOpenArticle(<%= previousArticleID %>)"><% if(!previousArticleID.equals(articleID)){ %>＜前の記事<% } %></p>
                	<p class="next" onclick="changeOpenArticle(<%= nextArticleID %>)"><% if(!nextArticleID.equals(articleID)){ %>次の記事＞<% } %></p>
	            </div>
	
	        </div>
	        <form action="homepage.jsp" method="post">
	        	
	        	<input type="hidden" name="userID" id="userID" value="<% if(interactionData != null){ %><%= interactionData.get("userID") %><% } %>">
	        	<input type="hidden" name="status" id="status" value="returnFromArticle">
	        	<button type="submit" class="back-button" id="topmost">前へ</button>
	        </form>		
	        <form action="homepage.jsp" method="post" id="bottommost-form">
   	        	<input type="hidden" name="userID" id="userID" value="<% if(interactionData != null){ %><%= interactionData.get("userID") %><% } %>">
	        	<input type="hidden" name="status" id="status" value="returnFromArticle">
	        	<button type="submit" class="back-button" id="bottommost">ホームページへ</button>
	        </form>
	        <a href="addArticle.jsp?mode=edit&articleID=<%= interactionData.get("articleID") %>" id="edit-article"><button type="button" id="edit-button">編集・削除</button></a>					<!-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< -->
	        
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