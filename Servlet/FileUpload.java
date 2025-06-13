import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(urlPatterns= {"/servlet/FileUpload"})
@MultipartConfig
public class FileUpload extends HttpServlet{
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		PrintWriter out;
		req.setCharacterEncoding("UTF-8");
		res.setContentType("text/html;charset=UTF-8");
		out = res.getWriter();
		
		//このページで使うパラメータ
		String status = req.getParameter("status");
		
		//次のページまで持っていくパラメータ
		String username = req.getParameter("username");
		String email = req.getParameter("email");
		String addFlag = req.getParameter("addFlag");	//addArticleから
		String mode = req.getParameter("mode");			//addArticleから
		String articleIDModeEdit = req.getParameter("articleIDModeEdit"); //古い画像を削除するために送信。
		
		//画像更新するページから
		Part filePart = req.getPart("file"); // Retrieves <input type="file" name="file">
		String previousImage = req.getParameter("previousImage");	//削除するために送信します。ファイル名+拡張子です。
		String password = req.getParameter("password");		
		String koushinkanryoMessage = req.getParameter("koushinkanryo-message");		
		String koushinkanryoType = req.getParameter("koushin-type");
		
		//status=toUploadの場合のみ
		String mainImageStr = req.getParameter("mainImageStr");
		String subImage1Str = req.getParameter("subImage1Str");
		String subImage2Str = req.getParameter("subImage2Str");
		String subImage3Str = req.getParameter("subImage3Str");
		
		//記事データ
		String mainTitle = req.getParameter("main-title");
		Part mainImageFilePart = req.getPart("main-image");
		String season = req.getParameter("season");
		String prefecture = req.getParameter("prefecture");
		String subtitle = req.getParameter("subtitle");
		Part subImage1FilePart = req.getPart("sub-image1");
		String imageDescription1 = req.getParameter("image-description1");
		String titleParagraph1 = req.getParameter("title-paragraph1");
		String textParagraph1 = req.getParameter("text-paragraph1");
		Part subImage2FilePart = req.getPart("sub-image2");
		String imageDescription2 = req.getParameter("image-description2");
		String titleParagraph2 = req.getParameter("title-paragraph2");
		String textParagraph2 = req.getParameter("text-paragraph2");
		Part subImage3FilePart = req.getPart("sub-image3");
		String imageDescription3 = req.getParameter("image-description3");
		String titleParagraph3 = req.getParameter("title-paragraph3");
		String textParagraph3 = req.getParameter("text-paragraph3");
		String sendMail = req.getParameter("sendMail");		//✔："on"	×：null

		ArrayList<String> list = new ArrayList<String>();
		ArrayList<InputStream> fileContents = new ArrayList<InputStream>();
		
		//createTempFileは「RANDOM.nextLong()」でtempファイルを作成します。ほとんど拡張子を含めて24文字の長さがファイル名.length()に追加。
		//対応するより、安定のためにデータベース側のusersテーブルのprofilePictureをnvarchar(100)にしました。
		File uploads = null;
		
		if(status.equals("toPreview")) {
			//色々な画像の準備処理を一気に行う。
			String mainImageFileName = Paths.get(mainImageFilePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.
			InputStream mainImageFileContent = mainImageFilePart.getInputStream();
			String subImage1FileName = Paths.get(subImage1FilePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.
			InputStream subImage1FileContent = subImage1FilePart.getInputStream();
			String subImage2FileName = Paths.get(subImage2FilePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.
			InputStream subImage2FileContent = subImage2FilePart.getInputStream();
			String subImage3FileName = Paths.get(subImage3FilePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.
			InputStream subImage3FileContent = subImage3FilePart.getInputStream();
			//画像とインプットストリームの配列を設定する
			list.add(mainImageFileName);
			list.add(subImage1FileName);
			list.add(subImage2FileName);
			list.add(subImage3FileName);
			fileContents.add(mainImageFileContent);
			fileContents.add(subImage1FileContent);
			fileContents.add(subImage2FileContent);
			fileContents.add(subImage3FileContent);
			uploads = new File("C:\\java_workspace\\JV16\\blog_site\\public\\images\\article_pictures");
			
		}else if(status.equals("toUpload")) {			
			
			//何もしません。処理がないことに要注意。
			
		} else {
			//画像とインプットストリームの配列を設定する
			String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString(); // MSIE fix.
			InputStream fileContent = filePart.getInputStream();
			list.add(fileName);
			fileContents.add(fileContent);
			uploads = new File("C:\\java_workspace\\JV16\\blog_site\\public\\images\\profile_pictures");
		}
		
		String baseFileName = "";
		String result = "";
		String ext = "";
		String image = "";
		
		for(int i = 0; i < list.size(); i++) {		//list.size() = fileContents.size()。toUploadの場合は入らない
			result = getFileNameAndExt(list.get(i));
			baseFileName = result.split("\\?")[0];
			ext = result.split("\\?")[1];
			//自分で拡張子を見て最後の文字が数値だったらそれを+1すると考えましたがxxx19.jpgのコピーはxxx110になるのでめんどい。tempFileに任せます。
			File file = File.createTempFile(baseFileName, ext, uploads);
			Files.copy(fileContents.get(i), file.toPath(), StandardCopyOption.REPLACE_EXISTING);
			image += file.getName()+"?";
		}
		
		StringBuffer sb = new StringBuffer();

		if(status.equals("toPreview") || status.equals("toUpload")) {
		
			sb.append("<html><body>");
			
			sb.append("<h1>画像を読込み中...</h1>");	
			
			if(status.equals("toPreview")) {	    	
				sb.append("<form id=\"redirect-form\" method=\"post\" action=\"http://localhost:8080/JV16/blog_site/public/preview.jsp\">");	    
			} else if(status.equals("toUpload")){
				sb.append("<form id=\"redirect-form\" method=\"post\" action=\"http://localhost:8080/JV16/blog_site/public/koushinkanryo.jsp\">");	    
			}
			sb.append("<input type=\"hidden\" name=\"username\" value=\"");	    //共通項目
			sb.append(username);	    	    
			sb.append("\">");	    
			sb.append("<input type=\"hidden\" name=\"email\" value=\"");	    //共通項目    
			sb.append(email);	    	    
			sb.append("\">");	    
			sb.append("<input type=\"hidden\" name=\"addFlag\" value=\"");	    //共通項目	    
			sb.append(addFlag);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"mode\" value=\"");	    	//共通項目	    
			sb.append(mode);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"articleIDModeEdit\" value=\"");	    	//mode = edit のみ使用	    
			sb.append(articleIDModeEdit);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"mainTitle\" value=\"");	//共通項目	    
			sb.append(mainTitle);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"mainImage\" value=\"");	//共通項目	
			if(status.equals("toPreview")) {	    	
				sb.append(image.split("\\?")[0]);	  //toPreviewの場合は「アップロードしたところの画像」という意味です。  	    
			} else if(status.equals("toUpload")){
				sb.append(mainImageStr);			  //toUploadの場合は「問題がなかったのでそのファイル名のStr」という意味です。
			}
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"season\" value=\"");	    //共通項目	    
			sb.append(season);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"prefecture\" value=\"");	//共通項目	    
			sb.append(prefecture);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"subtitle\" value=\"");	    //共通項目	    
			sb.append(subtitle);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"subImage1\" value=\"");	//共通項目	    
			if(status.equals("toPreview")) {	    	
				sb.append(image.split("\\?")[1]);	    	    
			} else if(status.equals("toUpload")){
				sb.append(subImage1Str);
			}
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"imageDescription1\" value=\"");	//共通項目	    
			sb.append(imageDescription1);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"titleParagraph1\" value=\"");	    //共通項目	    
			sb.append(titleParagraph1);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"textParagraph1\" value=\"");	    //共通項目	    
			sb.append(textParagraph1);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"subImage2\" value=\"");	    	//共通項目	    
			if(status.equals("toPreview")) {	    	
				sb.append(image.split("\\?")[2]);	    	    
			} else if(status.equals("toUpload")){
				sb.append(subImage2Str);
			}
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"imageDescription2\" value=\"");	//共通項目	    
			sb.append(imageDescription2);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"titleParagraph2\" value=\"");	    //共通項目	    
			sb.append(titleParagraph2);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"textParagraph2\" value=\"");	    //共通項目	    
			sb.append(textParagraph2);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"subImage3\" value=\"");	    	//共通項目	    
			if(status.equals("toPreview")) {	    	
				sb.append(image.split("\\?")[3]);	    	    
			} else if(status.equals("toUpload")){
				sb.append(subImage3Str);
			}
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"imageDescription3\" value=\"");	//共通項目	    
			sb.append(imageDescription3);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"titleParagraph3\" value=\"");	    //共通項目	    
			sb.append(titleParagraph3);	    	    
			sb.append("\">");	
			sb.append("<input type=\"hidden\" name=\"textParagraph3\" value=\"");	    //共通項目	    
			sb.append(textParagraph3);	    	    
			sb.append("\">");	
			if(sendMail != null) {
				if(sendMail.equals("on")){
					sb.append("<input type=\"hidden\" name=\"sendMail\" value=\"on\">");	//共通項目	  
				} else {	//sendMail.equals("off")
					sb.append("<input type=\"hidden\" name=\"sendMail\" value=\"off\">");	//共通項目	 
				}
			} else {	
				sb.append("<input type=\"hidden\" name=\"sendMail\" value=\"off\">");	//共通項目	    
			}

			if(status.equals("toUpload")) {
				sb.append("<input type=\"hidden\" name=\"koushinkanryo-message\" value=\"");	    //プロフィール写真更新のみ	    
				sb.append(koushinkanryoMessage);	    	    
				sb.append("\">");	
				sb.append("<input type=\"hidden\" name=\"koushin-type\" value=\"");	    //プロフィール写真更新のみ
				sb.append(koushinkanryoType);	    	    
				sb.append("\">");	
			}
			sb.append("</form>");	   
			
			sb.append("<script>");	    
			sb.append("document.forms[\"redirect-form\"].requestSubmit();");	    
			sb.append("</script>");	    
			
			sb.append("</body></html>");
		
		} else {	//ただのプロフィール写真の設定/更新
			
			sb.append("<html><body>");
			
			sb.append("<h1>画像を読込み中...</h1>");	
			
			if(status.equals("profilePicture")) {	    	
				sb.append("<form id=\"redirect-form\" method=\"post\" action=\"http://localhost:8080/JV16/blog_site/public/accCreated.jsp\">");	    
			} else if(status.equals("profilePictureUpdate")){
				sb.append("<form id=\"redirect-form\" method=\"post\" action=\"http://localhost:8080/JV16/blog_site/public/koushinkanryo.jsp\">");	    
			}
			sb.append("<input type=\"hidden\" name=\"username\" value=\"");	    //共通項目
			sb.append(username);	    	    
			sb.append("\">");	    
			sb.append("<input type=\"hidden\" name=\"email\" value=\"");	    //共通項目    
			sb.append(email);	    	    
			sb.append("\">");	    
			sb.append("<input type=\"hidden\" name=\"password\" value=\"");	    //共通項目
			sb.append(password);	    	    
			sb.append("\">");	    
			sb.append("<input type=\"hidden\" name=\"image\" value=\"");	    //共通項目	    
			sb.append(image.split("\\?")[0]);	    	    
			sb.append("\">");	
			if(status.equals("profilePictureUpdate")) {
				sb.append("<input type=\"hidden\" name=\"previousImage\" value=\"");	    //プロフィール写真更新のみ
				sb.append(previousImage);	    	    
				sb.append("\">");	
				sb.append("<input type=\"hidden\" name=\"koushinkanryo-message\" value=\"");	    //プロフィール写真更新のみ	    
				sb.append(koushinkanryoMessage);	    	    
				sb.append("\">");	
				sb.append("<input type=\"hidden\" name=\"koushin-type\" value=\"");	    //プロフィール写真更新のみ
				sb.append(koushinkanryoType);	    	    
				sb.append("\">");	
			}
			sb.append("</form>");	   
			
			sb.append("<script>");	    
			sb.append("document.forms[\"redirect-form\"].requestSubmit();");	    
			sb.append("</script>");	    
			
			sb.append("</body></html>");
			
		}
		
		out.println(sb.toString());
		
	}

	private String getFileNameAndExt(String fileName) {
		
		//拡張子を一旦消します。そうしないとcreateTempFile()が「xxx.偽物拡張子yyyyyyyyyyy.拡張子」の形に保存してしまいます。
		int pos = fileName.lastIndexOf(".");
		
		//pngをアップロードして、jpgに設定するとおかしいことに何も壊しませんが偽物のpngになりますのでそれを避けてみます。
		//「.」も含めた拡張子を取得します
		String ext = fileName.substring(pos);
		
		fileName = fileName.substring(0 ,pos);
		
		//fileNameが長くなったら困るので長さを20文字に制限します。これにランダムの～24文字が追加されるのでまだ100長さから遠い
		if(fileName.length() > 20) {
			fileName = fileName.substring(0, 20);
		}
		
		return fileName + "?" + ext;
	}

}
