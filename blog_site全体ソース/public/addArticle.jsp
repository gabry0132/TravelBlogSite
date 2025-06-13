<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<% 

	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");
	
	//入力データ受信
	String userID = (String) session.getAttribute("userID");
	if(userID == null) response.sendRedirect("index.jsp");
	
	String mode = request.getParameter("mode");
	String articleID = request.getParameter("articleID");	//mode = editのみ
	
	//editモードやedit-previewモードに使う記事データ
	String username = request.getParameter("username");
	String email = request.getParameter("email");
	String mainTitle = request.getParameter("mainTitle");
	String mainImage = request.getParameter("mainImage");		//プレビューから来た瞬間に画像を削除しに行く為に持ってきます。formに設定しません。
	String season = request.getParameter("season");
	String prefecture = request.getParameter("prefecture");
	String subtitle = request.getParameter("subtitle");
	String subImage1 = request.getParameter("subImage1");		//プレビューから来た瞬間に画像を削除しに行く為に持ってきます。formに設定しません。
	String imageDescription1 = request.getParameter("imageDescription1");
	String titleParagraph1 = request.getParameter("titleParagraph1");
	String textParagraph1 = request.getParameter("textParagraph1");
	String subImage2 = request.getParameter("subImage2");		//プレビューから来た瞬間に画像を削除しに行く為に持ってきます。formに設定しません。
	String imageDescription2 = request.getParameter("imageDescription2");
	String titleParagraph2 = request.getParameter("titleParagraph2");
	String textParagraph2 = request.getParameter("textParagraph2");
	String subImage3 = request.getParameter("subImage3");		//プレビューから来た瞬間に画像を削除しに行く為に持ってきます。formに設定しません。
	String imageDescription3 = request.getParameter("imageDescription3");
	String titleParagraph3 = request.getParameter("titleParagraph3");
	String textParagraph3 = request.getParameter("textParagraph3");
	String sendMail = request.getParameter("sendMail");
	String addFlag = request.getParameter("addFlag");
		
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
		
		switch(mode){
		
		case "add":
			
			addFlag = "true";
			
			//SQLステートメントの作成と発行
			sql.append("select userID, username, email from users where adminFlag=1");
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			//取得したデータを保存する
			if(rs.next()){
				
				String rsUserID = rs.getString("userID");
				
				if(rsUserID.equals(userID)){
					
					username = rs.getString("username");
					email = rs.getString("email");
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Authority revoked - Admin required");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Data Failure - Admin non existent");
			}
					
			break;
			
		case "edit":
			
			if(addFlag == null){			
				addFlag = "false";
			}//elseもらった。その場合は貰ったままでいい。
			
			//SQLステートメントの作成と発行
			sql.append("select userID, username, email from users where adminFlag=1");
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			//取得したデータを保存する
			if(rs.next()){
				
				String rsUserID = rs.getString("userID");
				
				if(rsUserID.equals(userID)){
					
					username = rs.getString("username");
					email = rs.getString("email");
					
					//対処の記事の全ての項目を取得します。
					sql = new StringBuffer();
					sql.append("select title, subtitle, subDesc1, paragTitle1, paragText1, subDesc2, paragTitle2, paragText2, subDesc3, paragTitle3, paragText3, seasonID, prefectureID from articles where articleID=");
					sql.append(articleID);
					//System.out.println(sql);
					rs = stmt.executeQuery(sql.toString());

					if(rs.next()){
						
						//画像は設定しません。登録の直前に削除します。
						mainTitle = rs.getString("title");
						subtitle = rs.getString("subtitle");
						imageDescription1 = rs.getString("subDesc1");
						titleParagraph1 = rs.getString("paragTitle1");
						textParagraph1 = rs.getString("paragText1");
						imageDescription2 = rs.getString("subDesc2");
						titleParagraph2 = rs.getString("paragTitle2");
						textParagraph2 = rs.getString("paragText2");
						imageDescription3 = rs.getString("subDesc3");
						titleParagraph3 = rs.getString("paragTitle3");
						textParagraph3 = rs.getString("paragText3");
						season = rs.getString("seasonID");
						prefecture = rs.getString("prefectureID");
						
					} else {
						ermsg = new StringBuffer();
						ermsg.append("【SYSERR】Article Data Not Found");
						
					}
					
				} else {
					ermsg = new StringBuffer();
					ermsg.append("【SYSERR】Authority revoked - Admin required");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Data Failure - Admin non existent");
			}
			
			break;
			
		case "edit-preview":
			
			if(addFlag == null){			
				addFlag = "false";
			}//elseもらった。その場合は貰ったままでいい。
			
			//SQLステートメントの作成と発行
			sql.append("select userID from users where adminFlag=1 and username='");	//emailも持っています
			sql.append(username);
			sql.append("'");
			//System.out.println(sql);
			rs = stmt.executeQuery(sql.toString());
			
			//取得したデータを保存する
			if(rs.next()){
				
				userID = rs.getString("userID");
				
				//プレビューするためにアップロードした画像を削除しに行く
				String path = "C:\\java_workspace\\JV16\\blog_site\\public\\images\\article_pictures\\";
				//String path = "images\\article_pictures\\";
				File mainImageFile = new File(path + mainImage);	//全ての画像の変数に拡張子が含まれています
				File subImage1File = new File(path + subImage1);	
				File subImage2File = new File(path + subImage2);	
				File subImage3File = new File(path + subImage3);	
				
				if(!mainImageFile.delete()){
					System.out.println("file "+ mainImage + " could not be deleted");
				}
				if(!subImage1File.delete()){
					System.out.println("file "+ subImage1File + " could not be deleted");
				}
				if(!subImage2File.delete()){
					System.out.println("file "+ subImage2File + " could not be deleted");
				}
				if(!subImage3File.delete()){
					System.out.println("file "+ subImage3File + " could not be deleted");
				}
				
			} else {
				ermsg = new StringBuffer();
				ermsg.append("【SYSERR】Data Failure - Admin not found");
			}
			
			break;
			
		default:
			
			addFlag = "false";
				
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
            <% if(!mode.equals("add")){ %>記事を編集・削除する<% } else { %>記事を追加する<% } %>
        </title>
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/addArticle.css">
        <script type="text/javascript" src="scripts/addArticle.js"></script>
    </head>
    <body>

        <div id="page-dimmer" onclick="undoDim()">

        </div>

        <div id="help-wrapper" onmouseenter="dimScreen()" onclick="undoDim()">
            <img src="images/help-icon.png" width="50" height="50" alt="ヒント">
        </div>

        <div id="hint-text-holder">
            <div id="main-title-hint">
                <p>長さ制限：10文字まで</p>
            </div>
            <div id="main-image-hint">
                <p>アス比１:１<br>画像解像度400x400以上<br>上の2割にテキストがない画像<br>選択可拡張子： jpg, png, heif</p>
            </div>
            <div id="subtitle-hint">
                <p>長さ制限：17文字まで</p>
            </div>
            <div id="extra-images-hint">
                <p>アス比１:１<br>画像解像度300x300以上<br>下の2割にテキストがない画像<br>選択可拡張子： jpg, png, heif</p>
            </div>
            <div id="description-title-hint">
                <p>長さ制限：20文字まで<br>ですが、全角文字で書くと<br>17文字を超えたら改行</p>
            </div>
            <div id="paragraph-hint">
                <p>長さ制限：250文字まで<br>改行を表示するために<br> &lt;br&gt; の追加で調整できます。<br>次のページのプレビューを<br>使用して調整してください。</p>
            </div>
            <div id="empty-space-hint">
                <p>タイトルがない段落は<br>タイトル用の隙間がなくなります。<br>ですが、レイアウトを調整する<br>ために隙間が欲しい場合は<br>タイトルを " " 空白スペース<br>にしてください。</p>
            </div>
        </div>

        <div id="everything-wrapper">

            <h1><% if(!mode.equals("add")){ %>記事を編集・削除する<% } else { %>記事を追加する<% } %></h1>

            <form action="/JV16/servlet/FileUpload" method="post" enctype="multipart/form-data">
            
                <div id="main-title-wrapper">
                    <p class="input-field-intro">記事タイトル：</p>
                    <input type="text" class="basic-text-field" name="main-title" id="main-title-input" maxlength="10" required value="<% if(mainTitle != null){ %><%= mainTitle %><% } %>">
                </div>

                <div id="main-image-wrapper">
                    <p class="file-input-field-intro" >メイン画像選択</p>
                    <input type="file" class="image-picker" name="main-image" id="main-image-input" accept=".jpg, .png" required>
                </div>

                <div id="dropdown-menus-wrapper">
                
                	<% if(season != null){ %>		<!-- これでJSの方で季節と都道府県の設定を行う -->
                		<input type="hidden" name="seasonHelper" id="seasonHelper" value="<%= season %>">
                	<% } %>
                	<% if(prefecture != null){ %>
                		<input type="hidden" name="prefectureHelper" id="prefectureHelper" value="<%= prefecture %>">
                	<% } %>

                    <div id="season-section">
                        <select name="season" id="search-season" required>
                            <option hidden disabled selected value>季節</option>
                            <option value='1'>夏</option>
                            <option value='2'>秋</option>
                            <option value='3'>冬</option>
                            <option value='4'>春</option>
                        </select>
                    </div>
                    <div id="prefecture-section">
                        <select name="prefecture" id="search-prefecture" required>
                            <option hidden disabled selected value>都道府県</option>
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

                <div id="subtitle-wrapper">
                    <p class="input-field-intro">記事サブタイトル：</p>
                    <input type="text" class="basic-text-field" name="subtitle" id="subtitle-input" maxlength="17" required value="<% if(subtitle != null){ %><%= subtitle %><% } %>">
                </div>

                <div id="article-body-builder">

                    <div class="paragraph-builder" id="paragraph-builder1">
                        <div class="left">
                            <div class="paragraph-photo-selector">
                                <p class="paragraph-photo-selector-intro">サブ画像１</p>
                                <input type="file" class="paragraph-image-picker" name="sub-image1" id="input-sub-image1" accept=".jpg, .png" required>
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">　サブ画像１記述：</p>
                                <input type="text" class="paragraph-text-field" name="image-description1" maxlength="20" required value="<% if(imageDescription1 != null){ %><%= imageDescription1 %><% } %>">
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">第１段落タイトル：</p>
                                <input type="text" class="paragraph-text-field" name="title-paragraph1" maxlength="20" placeholder="（任意）" value="<% if(titleParagraph1 != null){ %><%= titleParagraph1 %><% } %>">
                            </div>
                        </div>
                        <div class="right">
                            <div class="text-holder">
                                <p class="paragraph-text-input-field-intro">第１段落：</p>
                                <span class="remaining" id="charsLeftCount1"></span>
                            </div>
                            <textarea name="text-paragraph1" id="text-paragraph1" class="paragraph-textArea" cols="40" rows="6" maxlength="250" required><% if(textParagraph1 != null){ %><%= textParagraph1 %><% } %></textarea>
                        </div>
                    </div>

                    <div class="paragraph-builder" id="paragraph-builder2">
                        <div class="left">
                            <div class="paragraph-photo-selector">
                                <p class="paragraph-photo-selector-intro">サブ画像２</p>
                                <input type="file" class="paragraph-image-picker" name="sub-image2" id="input-sub-image2" accept=".jpg, .png" required>
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">　サブ画像２記述：</p>
                                <input type="text" class="paragraph-text-field" name="image-description2" maxlength="20" required value="<% if(imageDescription2 != null){ %><%= imageDescription2 %><% } %>">
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">第２段落タイトル：</p>
                                <input type="text" class="paragraph-text-field" name="title-paragraph2" maxlength="20" placeholder="（任意）" value="<% if(titleParagraph2 != null){ %><%= titleParagraph2 %><% } %>">
                            </div>
                        </div>
                        <div class="right">
                            <div class="text-holder">
                                <p class="paragraph-text-input-field-intro">第２段落：</p>
                                <span class="remaining" id="charsLeftCount2"></span>
                            </div>
                            <textarea name="text-paragraph2" id="text-paragraph2" class="paragraph-textArea" cols="40" rows="6" maxlength="250" required><% if(textParagraph2 != null){ %><%= textParagraph2 %><% } %></textarea>
                        </div>
                    </div>

                    <div class="paragraph-builder" id="paragraph-builder3">
                        <div class="left">
                            <div class="paragraph-photo-selector">
                                <p class="paragraph-photo-selector-intro">サブ画像３</p>
                                <input type="file" class="paragraph-image-picker" name="sub-image3" id="input-sub-image3" accept=".jpg, .png" required>
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">　サブ画像３記述：</p>
                                <input type="text" class="paragraph-text-field" name="image-description3" maxlength="20" required value="<% if(imageDescription3 != null){ %><%= imageDescription3 %><% } %>">
                            </div>
                            <div class="paragraph-input-wrapper">
                                <p class="paragraph-input-field-intro">第３段落タイトル：</p>
                                <input type="text" class="paragraph-text-field" name="title-paragraph3" maxlength="20" placeholder="（任意）" value="<% if(titleParagraph3 != null){ %><%= titleParagraph3 %><% } %>">
                            </div>
                        </div>
                        <div class="right">
                            <div class="text-holder">
                                <p class="paragraph-text-input-field-intro">第３段落：</p>
                                <span class="remaining" id="charsLeftCount3"></span>
                            </div>
                            <textarea name="text-paragraph3" id="text-paragraph3" class="paragraph-textArea" cols="40" rows="6" maxlength="250" required><% if(textParagraph3 != null){ %><%= textParagraph3 %><% } %></textarea>
                        </div>
                    </div>

                </div>
					
				<% if(sendMail != null){ %>
					<input type="hidden" name="sendMailHelper" id="sendMailHelper" value="<%= sendMail %>">
				<% } %>

				<!-- mode = edit の場合はメール通知させません。 -->
                <div id="checkbox-wrapper">
                    <input type="checkbox" name="sendMail" id="sendMailCheckbox" <% if(addFlag.equals("false")){ %>disabled<% } %>>
                    <p class="input-field-intro">メールで通知する</p>
                </div>

                <!-- 次のページに直接使いませんがその後の投稿完了メッセージに使いますのでその時まで持っていきます -->
                <input type="hidden" name="addFlag" id="addFlag" value="<%=addFlag%>">
                <input type="hidden" name="username" value="<%=username%>">
                <input type="hidden" name="email" value="<%=email%>">
                <input type="hidden" name="mode" id="mode" value="<%=mode%>"> <!-- JS用 -->
                <input type="hidden" name="articleIDModeEdit" id="articleIDModeEdit" value="<%=articleID%>"> <!-- mode = edit のみ使用 -->
				<input type="hidden" name="status" value="toPreview"> <!-- koushinkanryo-messageとkoushin-typeはプレビューページで設定します。 -->
				
                <div id="buttons-wrapper">
                    <a href="homepage.jsp?userID=<%= userID %>&status=updateCancelled" id="return-anchor"><button type="button" class="basic-clear">キャンセル</button></a>
                    <button type="submit" id="sakuseisubmit" class="basic-submit">プレビューへ進む</button>
                </div>

            </form>
                
            <!-- ボタンはformの外に置いて、onClick= confirm(deleteOK?)で、OKだったらJSでformをsubmitする。 -->
            <form action="koushinkanryo.jsp" method="post" id="delete-form">
                                
                <input type="hidden" name="userID" id="userID" value="<%= userID %>">
                <input type="hidden" name="articleIDModeEdit" id="articleIDModeEdit" value="<%= articleID %>">
                <input type="hidden" name="koushin-type" id="koushin-type" value="delete-article">
                <input type="hidden" name="koushinkanryo-message" id="koushinkanryo-message" value="記事を正常に削除しました">
                
            </form>
            
            <button type="button" class="basic-delete" id="deleteButton">記事削除</button>
            

        </div>

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