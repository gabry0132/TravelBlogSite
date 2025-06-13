<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>	<!-- 記事データをJSONにして送信します。StringBufferより速いらしい -->
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>	<!-- JSONのescape charactersを管理してくれるApacheライブラリーです -->
<!-- StringEscapeUtilsを使うために Apache Commons Lang3 ライブラリーもプロジェクトに追加しましたが、直接使わないのでimportしません。-->
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String userEmail = request.getParameter("email");		//一般ユーザーログインからもらう
	String userPassword = request.getParameter("password"); //一般ユーザーログインからもらう
	String status = request.getParameter("status");			//全ての場合にもらう。
	//セッションでもらいます
	String userID = (String) session.getAttribute("userID");	//エラー画面（ログイン済みの場合）からもらう
																// + 項目更新の画面の「キャンセル」ボタンを押した場合に<a>タグに込めて送信
																// + アカウント作成した時に
																// + ソートや検索する時に
	if(status != null){															
		if(!status.equals("user-standard-login") && !status.equals("admin-login") && userID == null){	//一般者ログインと管理者ログインの場合はセッションが存在しないので期待しませんが、それ以外はredirectします。
			response.sendRedirect("index.jsp");
		}
	}
																
	if(status == null){		//セッションが終わってないのでindexから移動させる場合はstatusはnullです
		status = "sessionRedirect";	//userIDしか持っていない場合です。
	}
	
	//ソート(並べ替え)のために受信するデータ
	String sortField = request.getParameter("sort-field");
	String sortKoumoku = request.getParameter("sort-koumoku");
	
	//検索機能の条件
	String startDate = request.getParameter("startDate");					//未選択は空文字
	String endDate = request.getParameter("endDate");						//未選択は空文字
	String searchSeason = request.getParameter("search-season");			//未選択はnull
	String searchPrefecture = request.getParameter("search-prefecture");	//未選択はnull
	String likedCheckbox = request.getParameter("search-liked-checkbox");	//未選択はnull
	
	//画面用変数インスタンス変化
	String title = "";
	String description = "";
	boolean loggedIn = false;	//エラー画面が呼ばれる時にindexへ行くかHPへ行くか判定するための変数
	boolean isAdmin = false;
	Gson gson = new Gson();	//記事データを格納するArrayListを送信するためにGoogleのJSONを使う
	String listJson = "";
	int articlesPerPage = 9; //1ページに何個表示させることを表す。

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
	
	//ヒットフラグ
	int hit_flag = 0;
	
	//HashMap(1件分のデータを格納する連想配列)
	HashMap<String,String> account = null;
	//記事データを格納するマップ
	HashMap<String,String> articleMap = null;

	
	//全ての記事を格納する配列
	ArrayList<HashMap> articlesList = new ArrayList<HashMap>();
	
	try{	//ロードに失敗したときのための例外処理
		
		//オブジェクトの代入
		Class.forName(driver).newInstance();
		con = DriverManager.getConnection(url, user, password);
		stmt = con.createStatement();
		sql = new StringBuffer();
		
		//SQLステートメントの作成と発行
		sql.append("select blogTitle, HPDescription, articlesPerPage from utilities");
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		//取得したデータを保存する
		if(rs.next()){
			
			title = rs.getString("blogTitle");
			description = rs.getString("HPDescription");
			articlesPerPage = Integer.parseInt(rs.getString("articlesPerPage"));	//数字しか登録できない前提でparseInt()します。
			
		}
		
		//statusによって取得するユーザー情報が変わります。
		switch(status){
		
			case "user-standard-login":
				
				//SQLステートメントの作成と発行
				sql = new StringBuffer();
				sql.append("select userID, email, username, password, newsletterFlag from users where adminFlag = 0 and ");
				if(userEmail.contains("@")){
					sql.append("email='");
				} else {
					sql.append("username='");
				}
				//どっちにせよ変数名はmailのままにします。
				sql.append(userEmail);
				sql.append("'");
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを繰り返し処理で保存する
				if(rs.next()){
					
					//ヒットフラグON
					hit_flag = 1;
					
					account = new HashMap<String, String>();
					account.put("userID", rs.getString("userID"));
					account.put("email", rs.getString("email"));
					account.put("username", rs.getString("username"));
					account.put("password", rs.getString("password"));
					account.put("newsletterFlag", rs.getString("newsletterFlag"));		//set bgcolor of anchor in side menu
					
				}
				
				if(hit_flag == 1){	//認証OK

					if(userPassword.equals(account.get("password")) && (userEmail.equals(account.get("email")) || userEmail.equals(account.get("username")))){
						loggedIn = true;
						
						//セッション管理
						session.setMaxInactiveInterval(60000);	//10分
						session.setAttribute("userID", account.get("userID"));
					} else {
						ermsg = new StringBuffer();
						ermsg.append("パスワードが誤っています");
						
					}
					
				} else {	//認証NG
					ermsg = new StringBuffer();
					ermsg.append("ユーザーが見つかりませんでした");
				}

				break;
				
			case "admin-login":

				//SQLステートメントの作成と発行
				sql = new StringBuffer();
				sql.append("select userID, email, username, password, newsletterFlag from users where adminFlag = 1 and email='");
				sql.append(userEmail);
				sql.append("'");
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());

				if(rs.next()){
					
					//ヒットフラグON
					hit_flag = 1;
					
					account = new HashMap<String, String>();
					account.put("userID", rs.getString("userID"));
					account.put("email", rs.getString("email"));
					account.put("username", rs.getString("username"));
					account.put("password", rs.getString("password"));
					account.put("newsletterFlag", rs.getString("newsletterFlag"));		//set bgcolor of anchor in side menu
					
				}
				
				if(hit_flag == 1){	//管理者認証OK

					if(userPassword.equals(account.get("password")) && userEmail.equals(account.get("email"))){
						loggedIn = true;
						isAdmin = true;
						
						//セッション管理
						session.setMaxInactiveInterval(180);	//3分
						session.setAttribute("userID", account.get("userID"));
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("パスワードが誤っています");
					}
					
				} else {	//認証NG
					ermsg = new StringBuffer();
					ermsg.append("メールアドレスが誤っています");
				}
				
				break;
				
			case "fromErrorPage":
			case "updateCancelled":	//色々な画面で「キャンセル」ボタンを押すと絶対ログインしている状態だったらここでHPへ戻る
			case "accCreated":	//アカウント作成した後時にuserIDだけでホームページへ行かせます。
			case "sort":	//HPからHPへ：ソートの場合
			case "search":	//HPからHPへ：検索の場合
			case "returnFromArticle":
			case "sessionRedirect":
				
				//SQLステートメントの作成と発行
				sql = new StringBuffer();
				sql.append("select email, username, password, newsletterFlag, adminFlag from users where userID=");
				sql.append(userID);
				//System.out.println(sql);
				rs = stmt.executeQuery(sql.toString());
				
				//取得したデータを繰り返し処理で保存する
				if(rs.next()){
					
					//ヒットフラグON
					hit_flag = 1;
					
					account = new HashMap<String, String>();
					account.put("userID", userID);
					account.put("email", rs.getString("email"));
					account.put("username", rs.getString("username"));
					account.put("password", rs.getString("password"));
					account.put("adminFlag", rs.getString("adminFlag"));
					account.put("newsletterFlag", rs.getString("newsletterFlag"));		//set bgcolor of anchor in side menu
					
				}
				
				if(hit_flag == 1){	//認証OK
					
					loggedIn = true;
				
					
					if(account.get("adminFlag").equals("1")){
						isAdmin = true;
					}
										
				} else {	//認証NG
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Redirect failure - UserID does not match");
				}

				break;
				
			default:
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Login mode unknown");
				
		}
		
		//記事データを取得します。
		sql = new StringBuffer();
		sql.append("select A.articleID, A.title, A.mainImage, I.interactionID from articles as A left join interactions as I on A.articleID = I.articleID and I.userID=");	//最後に空白スペース！
		sql.append(account.get("userID") + " where 1 = 1 ");	//最後に空白スペース！
		
		if(likedCheckbox != null){	//likedCheckboxはString:"on"になるかnullです。status.equals("search")というチェックは必要ないです。searchの場合以外は絶対受信しないのでnullになります。
			sql.append("and likeFlag = 1 ");	
		} 
		
		if(startDate != null){
			if(!startDate.equals("")){
				sql.append("and uploadDate >='");	
				sql.append(startDate.replace('-','/'));	
				sql.append("' ");	//最後に空白スペース！
			}
		}
			
		if(endDate != null){
			if(!endDate.equals("")){
				sql.append("and uploadDate <='");	
				sql.append(endDate.replace('-','/'));	
				sql.append("' ");	//最後に空白スペース！
			}
		}
		
		if(searchSeason != null){
			sql.append("and seasonID =");	
			sql.append(searchSeason);	
			sql.append(" ");	//最後に空白スペース！
			
		}

		if(searchPrefecture != null){
			sql.append("and prefectureID =");	
			sql.append(searchPrefecture);	
			sql.append(" ");	//最後に空白スペース！
			
		}

		
		if(status.equals("sort") && sortField != null){
			
			switch(sortField){
			
				case "date":				//一番下の項目になるはずなのでソートを選択していない場合は実行する前に設定します。
					sql.append("order by A.articleID ");
				break;
					
				case "season":
					sql.append("order by A.seasonID ");
				break;
				
				case "prefecture":
					sql.append("order by A.prefectureID ");
				break;
			}
			
			sql.append(sortKoumoku);	//ソートのorder byがDESCかASCかここで追加します。
			
		}
		
		//順番の設定。先頭に空白スペースを忘れずに！
		if(sortField == null){
			sql.append(" order by A.articleID desc");	//デフォルトは日付：降順
		}
		
		//System.out.println(sql);
		rs = stmt.executeQuery(sql.toString());
		
		while(rs.next()){
			
			articleMap = new HashMap<String, String>();
			articleMap.put("articleID",rs.getString("articleID"));
			articleMap.put("title",rs.getString("title"));
			articleMap.put("mainImage",rs.getString("mainImage"));
			if(rs.getString("interactionID") != null){
				articleMap.put("interactionID",rs.getString("interactionID"));
			} else {
				articleMap.put("interactionID","notSeen");
			}
			
			articlesList.add(articleMap);
		}
		
		//送信速度のためにStringBufferじゃなくてJSONで送信します。
		listJson = gson.toJson(articlesList);
		//「StringEscapeUtils」よいうApacheライブラリーを使用してJSONをJSが使える形にする
		listJson = org.apache.commons.text.StringEscapeUtils.escapeJson(listJson);
		//System.out.println(listJson);
		
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
            ホームページ
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/homepage.css">
        <script type="text/javascript" src="scripts/homepage.js"></script>
    </head>
    <body>
		<% if(loggedIn){ %>
			
			<!-- ページの表示に必要な項目を設定します。JSで取得されています。 -->
			<input type="hidden" name="newsletterFlag" value="<%= account.get("newsletterFlag") %>">
			<input type="hidden" name="articlesPerPage" id="articlesPerPage" value="<%= articlesPerPage %>">
			<input type="hidden" name="sort-field-helper" id="sort-field-helper" value="<%= sortField %>">
			<input type="hidden" name="sort-koumoku-helper" id="sort-koumoku-helper" value="<%= sortKoumoku %>">
			<!-- 検索条件を設定するためのものです。 -->
			<input type="hidden" name="status-search" id="status-search" value="<%= status %>">
			<input type="hidden" name="search-startDate-helper" id="search-startDate-helper" value="<%= startDate %>">
			<input type="hidden" name="search-endDate-helper" id="search-endDate-helper" value="<%= endDate %>">
			<input type="hidden" name="search-season-helper" id="search-season-helper" value="<%= searchSeason %>">
			<input type="hidden" name="search-prefecture-helper" id="search-prefecture-helper" value="<%= searchPrefecture %>">
			<input type="hidden" name="search-likedCheckbox-helper" id="search-likedCheckbox-helper" value="<%= likedCheckbox %>">
			
			<% if(isAdmin){ %>
			
				<input type="hidden" name="isAdmin" value="true" />
				
			<% } %>
			
	        <div id="page-dimmer">
	
	        </div>
	
	        <nav id="left-side-nav">
	            <div id="sideMenu">
	                <h3>サイドメニュー</h3>
	                <div id="sort-menu">
	                    <h4>並べ替える</h4>
	                    <form action="homepage.jsp" method="post">
	                    	<input type="hidden" name="status" value="sort">
	                        <select name="sort-field" id="sort-field">
	                            <option value="date">投稿日付</option>
	                            <option value="season">季節</option>
	                            <option value="prefecture">都道府県</option>
	                        </select>
	                        <select name="sort-koumoku" id="sort-koumoku">
	                            <option value="desc">降順</option>
	                            <option value="asc">昇順</option>
	                        </select>
	                        <button type="submit" id="sort-submit">適用する</button>
	                    </form>
	                </div>
	                <div id="search-menu">
	                    <h4>検索条件</h4>
	                    <form action="homepage.jsp" method="post" id="search-form">
	                    	<input type="hidden" name="status" value="search">
	                        
	                        <div id="date-section">
	                            <div class="search-top-text">
	                                <p class="search-menu-text">投稿日付</p>
	                                <input type="date" name="startDate" id="startDate">
	                            </div>
	                            <p class="karamade">から</p>
	                            <div class="search-top-text">
	                                <p class="search-menu-text">　　　　</p>
	                                <input type="date" name="endDate" id="endDate">
	                            </div>
	                            <p class="karamade">まで</p>
	                        </div>
	                        <div id="dropdown-menus-wrapper">
	                            <div id="season-section">
	                                <p class="search-menu-text">季節</p>
	                                <select name="search-season" id="search-season">
	                                    <option hidden disabled selected value>未選択</option>
	                                    <option value='1'>夏</option>
	                                    <option value='2'>秋</option>
	                                    <option value='3'>冬</option>
	                                    <option value='4'>春</option>
	                                </select>
	                            </div>
	                            <div id="prefecture-section">
	                                <p class="search-menu-text">都道府県</p>
	                                <select name="search-prefecture" id="search-prefecture">
	                                    <option hidden disabled selected value>未選択</option>
	                                    <option value='1'>北海道</option>
	                                    <option value='2'>青森県</option>
	                                    <option value='3'>岩手県</option>
	                                    <option value='4'>宮城県</option>
	                                    <option value='5'>秋田県</option>
	                                    <option value='6'>山形県</option>
	                                    <option value='7'>福島県</option>
	                                    <option value='8'>茨城県</option>
	                                    <option value='9'>栃木県</option>
	                                    <option value='10'>群馬県</option>
	                                    <option value='11'>埼玉県</option>
	                                    <option value='12'>千葉県</option>
	                                    <option value='13'>東京都</option>
	                                    <option value='14'>神奈川県</option>
	                                    <option value='15'>新潟県</option>
	                                    <option value='16'>富山県</option>
	                                    <option value='17'>石川県</option>
	                                    <option value='18'>福井県</option>
	                                    <option value='19'>山梨県</option>
	                                    <option value='20'>長野県</option>
	                                    <option value='21'>岐阜県</option>
	                                    <option value='22'>静岡県</option>
	                                    <option value='23'>愛知県</option>
	                                    <option value='24'>三重県</option>
	                                    <option value='25'>滋賀県</option>
	                                    <option value='26'>京都府</option>
	                                    <option value='27'>大阪府</option>
	                                    <option value='28'>兵庫県</option>
	                                    <option value='29'>奈良県</option>
	                                    <option value='30'>和歌山県</option>
	                                    <option value='31'>鳥取県</option>
	                                    <option value='32'>島根県</option>
	                                    <option value='33'>岡山県</option>
	                                    <option value='34'>広島県</option>
	                                    <option value='35'>山口県</option>
	                                    <option value='36'>徳島県</option>
	                                    <option value='37'>香川県</option>
	                                    <option value='38'>愛媛県</option>
	                                    <option value='39'>高知県</option>
	                                    <option value='40'>福岡県</option>
	                                    <option value='41'>佐賀県</option>
	                                    <option value='42'>長崎県</option>
	                                    <option value='43'>熊本県</option>
	                                    <option value='44'>大分県</option>
	                                    <option value='45'>宮崎県</option>
	                                    <option value='46'>鹿児島県</option>
	                                    <option value='47'>沖縄県</option>
	                                </select>
	                            </div>
	                        </div>
	                        <% if(!isAdmin){ %>
		                        <div id="like-checkbox">
		                            <input type="checkbox" name="search-liked-checkbox" id="search-liked-checkbox">
		                            <p class="search-menu-text">「いいね！」を付けた記事のみ</p>
		                        </div>
	                        <% } %>
	                        <div id="search-buttons-holder">
	                            <button type="button" class="basic-clear" id="search-reset-button">リセット</button>
	                            <button type="submit" id="search-submit">この条件で検索</button>
	                        </div>
	                    </form>
	                </div>
	
	                <div id="external-links">
	                    <h4>アカウント設定</h4>
	                    <table>
	                        <tr>
	                            <td colspan="2">
	                                <a href="updateMail.jsp" class="simple-link">メールアドレスを変更する</a>
	                                <a href="updatePass.jsp" class="simple-link">パスワードを変更する</a>
	                                <a href="newsletterKanri.jsp" class="simple-link" id="newsletter-link">ニューズレター登録管理</a>
	                            </td>
	                        </tr>
	                        <tr>
	                            <td>
	                                <a href="updateProfilePicture.jsp?" class="simple-link">プロフィール写真を変更する</a>
	                            </td>
	                            <td id="logout-wrapper">
	                            	<form action="index.jsp" method="post" id="logout-wrapper-form">
	                            		<input type="hidden" name="status" value="logout">
	                            		<button type="submit" id="logout">ログアウト</button>
	                            	</form>
	                            </td>
	                        </tr>
	                    </table>
	                </div>
	
	            </div>
	            <div id="hitboxes">
	                <div id="enter-hitbox" onmouseenter="dimScreen()"></div>
	            </div>
	        </nav>
	        <div id="exit-hitbox" onmouseenter="undoDim()"></div>
	
	
	        <div id="body-megawrapper">
	
	            <h1>
	                <%= title %>
	            </h1>
	            
	            <p id="top-description">
	            	<% if(articlesList.size() == 0){ %>
	            		該当する記事が見つけられませんでした。<br><br>検索条件を再設定してください。
	            	<% } else { %>
	            		<%= description %>
	            	<% } %>
	            </p>
	            
	            <% if(status.equals("sort") || status.equals("search")){ %>
		            <div id="search-explanation-container">
		            	<% if(status.equals("search")){ %>
		            		<p id="search-explanation"></p>
		            	<% } %>
		            </div>
	            <% } %>

				<!-- 実際の記事の表示を行う。 -->

	            <div id="article-holder">
	
	                <% for(int i = 0; i < articlesPerPage; i++){ %>
		                <div class="article" id="container<%= (i + 1) %>" onclick="openArticlePage(<%= (i + 1) %>)">
		                    <div class="img-holder">
	                        	<div class="unread-header"><p class="new-text">NEW!!</p></div>
		                    </div>
		                    <div class="title-holder">
		                        
		                    </div>
		                </div>
	                <% } %>
	
	            </div>

				<!-- 記事をページに分けるためにページ数を求めて、その索引を作ります。最初に表示するページはいつも1番目だとします。 -->
				<!-- 1つしかなければ表示しないようにします。 -->
	            <div id="page-selector">
	            	<% int articlesLeft = articlesList.size(); %>
	            	<% for(int i = 0; articlesLeft > 0; i++){ %>
                		<span class="<% if(i == 0){ %>current-selected<% } else { %>page-count<% } %>" onclick="imageLoader(<%= (i + 1) %>)"><%= (i + 1) %></span>
	            		<% articlesLeft -= articlesPerPage; %>
	                <% } %>
	            </div>
	
	        </div>
	        <!-- 本来は管理者ログインの場合のみ表示されます -->
	        <a href="kanrishaMenu.jsp"><button type="button" class="kanrisha-menu">管理者メニュー</button></a>
	        
	        <script>
				var dataString = "<%= listJson %>";
	        </script>
	        
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