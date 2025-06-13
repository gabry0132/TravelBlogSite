<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.time.LocalDate" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");

	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String userPassword = request.getParameter("password");
	String newPassword = request.getParameter("new-pass");
	String mainTitle = request.getParameter("title");
	String mainDesc = request.getParameter("desc");
	String articlesPerPage = request.getParameter("articlesPerPage");
	String image = request.getParameter("image");	//プロフィール写真更新する場合のみ使う！このページの構成を壊すので他の画像のアップロードに使わないで！	
	String previousImage = request.getParameter("previousImage");	//プロフィール写真更新する場合のみ使う。削除すべきな古い画像のパス（拡張子も含めて）です。	
	String isRegistered = request.getParameter("isRegistered");	//ニューズレター登録状況
	String message = request.getParameter("koushinkanryo-message");
	String koushinType = request.getParameter("koushin-type");

	//受信する記事データ
	String mainArticleTitle = request.getParameter("mainTitle");
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
	String mode = request.getParameter("mode");	//addArticle用ですが、mode = edit の場合は古い画像削除するために使います。
	String articleIDModeEdit = request.getParameter("articleIDModeEdit");	//addArticle用ですが、mode = edit の場合は古い画像削除するために使います。
																			//記事削除する場合にも使います。
	//画面用
	boolean hasMailRecipient = false;		//記事追加・更新に使う
	StringBuffer newsletterEmails = new StringBuffer();		//記事追加・更新に使う
	String blogTitle = "";		//記事追加・更新に使う
	String currentDate = LocalDate.now().toString().replace('-', '/');	//結果はyyyy/mm/ddですので長さ10文字固定。
	
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

	boolean isAdmin = false;
	
	//更新件数
	int update_count = 0;
	
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		switch(koushinType){
		
			case "pass-reset":
				
				//SQLステートメントの作成と発行
				sql.append("update users set password= '");
				sql.append(userPassword);
				sql.append("' where username='");
				sql.append(username);
				sql.append("' and email= '");
				sql.append(email);
				sql.append("'");
				//System.out.println(sql.toString());
				update_count = stmt.executeUpdate(sql.toString());
				
				if(update_count == 0){		//更新失敗
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
					
				} 
				
				break;
				
			case "mail-update":
				
				//メールを更新する前に入力したパスワードが正しいかどうかチェックします
				sql.append("select password from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを繰り返し処理で保存する
				if(rs.next()){

					String rsPassword = rs.getString("password");
					
					if(rsPassword.equals(userPassword)){
						
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update users set email= '");
						sql.append(email);
						sql.append("' where userID=");
						sql.append(userID);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
						} 
					} else {
						ermsg = new StringBuffer();
						ermsg.append("パスワードが誤っています");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - UserID does not match");
				}
				
				
				break;
				
			case "pass-update":
				
				//メールを更新する前に入力したパスワードが正しいかどうかチェックします
				sql.append("select email, password from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを保存する
				if(rs.next()){

					email = rs.getString("email");		//ホームページへ戻るために取得します。
					String rsPassword = rs.getString("password");
					
					if(rsPassword.equals(userPassword)){
						
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update users set password='");
						sql.append(newPassword);
						sql.append("' where userID=");
						sql.append(userID);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】Password Update Failure - No Rows Affected");
						} else {
							//更新ができた場合は、ホームページへ戻るためにuserPassword設定します。
							userPassword = newPassword;
						}
					} else {
						ermsg = new StringBuffer();
						ermsg.append("「現在のパスワード」が誤っています");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - UserID does not match");
				}

				break;
				
			case "newsletter-status-update":
				
				//メールを更新する前に入力したパスワードが正しいかどうかチェックします
				sql.append("select email, password from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());

				if(rs.next()){
					
					email = rs.getString("email");
					userPassword = rs.getString("password");
					
					//SQLステートメントの作成と発行
					sql = new StringBuffer();
					
					if(isRegistered.equals("true")){
						sql.append("update users set newsletterFlag = 0 where userID=");
					} else {
						sql.append("update users set newsletterFlag = 1 where userID=");
					}
					sql.append(userID);
					//System.out.println(sql.toString());
					update_count = stmt.executeUpdate(sql.toString());
					
					if(update_count == 0){		//更新失敗
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Newsletter Registration Status Update Failure");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - UserID does not match");
				}
				
				
				break;
				
			case "pfp-update":
					
				//メールを更新する前に入力したパスワードが正しいかどうかチェックします
				sql.append("select password from users where username='");
				sql.append(username);
				sql.append("' and email='");
				sql.append(email);
				sql.append("'");
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを繰り返し処理で保存する
				if(rs.next()){

					String rsPassword = rs.getString("password");
					
					if(rsPassword.equals(userPassword)){
						
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update users set profilePicture='");
						sql.append(image);
						sql.append("' where userID=");
						sql.append(userID);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
						} else {	//更新OK
							
							//古い画像を削除します。
							if(previousImage != null){
								String path = "C:\\java_workspace\\JV16\\blog_site\\public\\images\\profile_pictures\\";
								//String path = "images\\article_pictures\\";
								File previousImageFile = new File(path + previousImage);	//拡張子が含まれています
								
								if(!previousImageFile.delete()){	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
									System.out.println("file "+ previousImage + " could not be deleted");
								}
								
							} else {	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
								System.out.println("previous pfp could not be deleted due to null file name");
							}
						
						}
					} else {
						ermsg = new StringBuffer();
						ermsg.append("パスワードが誤っています");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}

				break;
				
			case "main-title-update":
				
				//管理者のログイン情報を取得する
				sql.append("select email, password, adminFlag from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					email = rs.getString("email");
					userPassword = rs.getString("password");
					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;

						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update utilities set blogTitle='");
						sql.append(mainTitle);
						sql.append("'");
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
						} 
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
						
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}

				break;
				
			case "main-desc-update":
				
				//管理者のログイン情報を取得する
				sql.append("select email, password, adminFlag from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					email = rs.getString("email");
					userPassword = rs.getString("password");
					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;
						
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update utilities set HPDescription='");
						sql.append(mainDesc);
						sql.append("'");
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
						} 
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
					}

					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}

				break;
				
			case "add-article":

				//管理者のログイン情報を取得する
				sql.append("select password, adminFlag from users where username='");
				sql.append(username);
				sql.append("'");
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					userPassword = rs.getString("password");

					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;
	
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("insert into articles (title,subtitle,mainImage,subImage1,subDesc1,paragTitle1,paragText1,subImage2,subDesc2,paragTitle2,paragText2,subImage3,subDesc3,paragTitle3,paragText3,seasonID,prefectureID,uploadDate) values ('");
						sql.append(mainArticleTitle + "','" + subtitle + "','" + mainImage + "','");
						sql.append(subImage1 + "','" + imageDescription1 + "','" + titleParagraph1 + "','" + textParagraph1 + "','");	//管理者が空白スペースを活用することもあるので.trim()を追加しません。
						sql.append(subImage2 + "','" + imageDescription2 + "','" + titleParagraph2 + "','" + textParagraph2 + "','");
						sql.append(subImage3 + "','" + imageDescription3 + "','" + titleParagraph3 + "','" + textParagraph3 + "',");
						sql.append(season + "," + prefecture + ",'" + currentDate + "'");
						sql.append(")");
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	//insert_countの役割で使用します。
						
						if(update_count == 0){		//追加失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Insert Failure - No Rows Added");
						} else {	//追加成功
							
							//メール通知すべきであれば希望者全員に送信します。
							if(sendMail != null){
								if(sendMail.equals("on")){
									
									//希望者のメールアドレスを取得します。
									sql = new StringBuffer();
									sql.append("select email from users where newsletterFlag = 1");
									//System.out.println(sql);
									rs = stmt.executeQuery(sql.toString());
									
									while(rs.next()){
										
										if(!hasMailRecipient){
											hasMailRecipient = true;	//「１人以上の希望者がいる」という意味です。
										} else {
											newsletterEmails.append(",");	//最初の行に先頭の「,」をつけません										
										}
										newsletterEmails.append(rs.getString("email"));
										
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
					
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}

				
				break;
				
			case "update-article":	
				
				//管理者のログイン情報を取得する
				sql.append("select password, adminFlag from users where username='");
				sql.append(username);
				sql.append("'");
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					userPassword = rs.getString("password");

					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;
					
						//問題なく投稿が終わったら、古い画像を削除します。
						sql = new StringBuffer();
						sql.append("select mainImage, subImage1, subImage2, subImage3 from articles where articleID=");
						sql.append(articleIDModeEdit);
						//System.out.println(sql);
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							
							String path = "C:\\java_workspace\\JV16\\blog_site\\public\\images\\article_pictures\\";
							String [] oldImages = { rs.getString("mainImage"), rs.getString("subImage1"), rs.getString("subImage2"), rs.getString("subImage3") };
							
							for(int i = 0; i < oldImages.length; i++){
								if(oldImages[i] != null){
									File previousImageFile = new File(path + oldImages[i]);  //拡張子が含まれています
									if(!previousImageFile.delete()){	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
										System.out.println("file "+ previousImage + " could not be deleted");
									}
								} else {	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
									System.out.println("an old image could not be deleted due to null file name");
								}
							}
							
						}

						//終わったら新しいデータで更新します。
						sql = new StringBuffer();
						sql.append("update articles set title='");
						sql.append(mainArticleTitle);				//管理者が空白スペースを活用することもあるので何も.trim()しません。
						sql.append("', subtitle='");
						sql.append(subtitle);
						sql.append("', mainImage='");
						sql.append(mainImage);
						sql.append("', subImage1='");
						sql.append(subImage1);
						sql.append("', subDesc1='");
						sql.append(imageDescription1);
						sql.append("', paragTitle1='");
						sql.append(titleParagraph1);
						sql.append("', paragText1='");
						sql.append(textParagraph1);
						sql.append("', subImage2='");
						sql.append(subImage2);
						sql.append("', subDesc2='");
						sql.append(imageDescription2);
						sql.append("', paragTitle2='");
						sql.append(titleParagraph2);
						sql.append("', paragText2='");
						sql.append(textParagraph2);
						sql.append("', subImage3='");
						sql.append(subImage3);
						sql.append("', subDesc3='");
						sql.append(imageDescription3);
						sql.append("', paragTitle3='");
						sql.append(titleParagraph3);
						sql.append("', paragText3='");
						sql.append(textParagraph3);
						sql.append("', seasonID=");
						sql.append(season);
						sql.append(", prefectureID=");
						sql.append(prefecture);
						//sql.append(", set uploadDate='");
						//sql.append(currentDate);
						sql.append(" where articleID =");
						sql.append(articleIDModeEdit);
						
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Updated");
						} 
					
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}
				
				break;
				
			case "delete-article":
				
				//管理者のログイン情報を取得する
				sql.append("select email, password, adminFlag from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					email = rs.getString("email");
					userPassword = rs.getString("password");
					
					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;
						
						//最初に古い画像を削除します。
						sql = new StringBuffer();
						sql.append("select mainImage, subImage1, subImage2, subImage3 from articles where articleID=");
						sql.append(articleIDModeEdit);
						//System.out.println(sql);
						rs = stmt.executeQuery(sql.toString());
						if(rs.next()){
							
							String path = "C:\\java_workspace\\JV16\\blog_site\\public\\images\\article_pictures\\";
							String [] oldImages = { rs.getString("mainImage"), rs.getString("subImage1"), rs.getString("subImage2"), rs.getString("subImage3") };
							
							for(int i = 0; i < oldImages.length; i++){
								if(oldImages[i] != null){
									File previousImageFile = new File(path + oldImages[i]);  //拡張子が含まれています
									if(!previousImageFile.delete()){	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
										System.out.println("file "+ previousImage + " could not be deleted");
									}
								} else {	//失敗すればエラー画面を呼びません。ただ画像ファイルが残るだけです。
									System.out.println("an old image could not be deleted due to null file name");
								}
							}
							
						}
						
						//終わったら記事を削除します。記述テーブルに削除するために先ずは交流テーブルに削除しなければなりません。
						sql = new StringBuffer();
						sql.append("delete from interactions where articleID=");
						sql.append(articleIDModeEdit);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	//交流がゼロの可能性があります。エラー画面を呼びません。
						
						//実際の記事削除がここに行います。
						sql = new StringBuffer();
						sql.append("delete from articles where articleID=");
						sql.append(articleIDModeEdit);
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());	
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Delete Failure - No Rows Removed");
						} 
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
					}

				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}
				
				break;
				
			case "articlesPerPage-update":
				
				//管理者のログイン情報を取得する
				sql.append("select email, password, adminFlag from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				if(rs.next()){
					
					email = rs.getString("email");
					userPassword = rs.getString("password");
					//絶対trueですが念のために再確認します。
					if(rs.getString("adminFlag").equals("1")){
						isAdmin = true;
						
						//SQLステートメントの作成と発行
						sql = new StringBuffer();
						sql.append("update utilities set articlesPerPage=");
						sql.append(articlesPerPage);	//input type="number" なので.trim()する必要がないです。空白スペースが入力できません
						//System.out.println(sql.toString());
						update_count = stmt.executeUpdate(sql.toString());
						
						if(update_count == 0){		//更新失敗
							ermsg = new StringBuffer();
							ermsg.append("【SYSERR】General Update Failure - No Rows Affected");
						} 
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Unauthorized access");
					}

					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Update failure - User not found");
				}

				
				break;
				
			default:
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】General Update Failure ");
		}
		
		if(!isAdmin){
		
			//管理者だったらこれで判断で、ホームページへ戻るためのstatusを変更します。
			//SQLステートメントの作成と発行
			sql = new StringBuffer();
			sql.append("select adminFlag from users where userID=");
			sql.append(userID);
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			if(rs.next()){
				if(rs.getString("adminFlag").equals("1")){
					isAdmin = true;
				}
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
            項目更新完了確認ページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/koushinkanryo.css">
        <script type="text/javascript" src="scripts/koushinkanryo.js"></script>
    </head>
    <body>
        <% if(update_count > 0){ %>
        
	        <h1 id="message">
	            <%= message %>
	        </h1>
	        
	        <!-- プロフィール写真を更新した後、表示するために次の<input>タグがあります。他の場合で来ると触ることがないです。 -->
	        <input type="hidden" name="image" id="image" value="<% if(image != null){ %><%= image %><% } %>">
	        
	        <% if(koushinType.equals("pfp-update")){ %>
		        <div id="image-wrapper">
		                    
		        </div>                
	        <% } %>
	        
	        <% if(koushinType.equals("add-article")){ %>
	        	<% if(newsletterEmails != null && sendMail.equals("on")){ %>
					<div id="emails-container" data-names="<%= newsletterEmails.toString() %>"></div>
					<input type="hidden" name="blogTitle" id="blogTitle" value="<%= blogTitle %>">
				<% } %>
	        <% } %>
	        
	        <form action="homepage.jsp" method="post">
	        
	            <input type="hidden" name="email" value="<%= email %>">
	            <input type="hidden" name="password" value="<%= userPassword %>">
	            <input type="hidden" name="status" value="<% if(isAdmin) { %>admin-login<% } else { %>user-standard-login<% } %>"> 
	        	<button type="submit" class="basic-clear">ホームページへ</button>
	        	
	        </form>
        
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