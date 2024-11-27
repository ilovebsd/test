<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.DataOutputStream"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*,bizportal.nasacti.record.*,java.lang.*"%>

<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>

<%
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String groupID    = Str.CheckNullString(scDTO.getLoginGroup()).trim();
 */
 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String groupID = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

if(11==1&& groupID==null) return ;

String pageDir = "";//"/ems";

//request.setCharacterEncoding("UTF-8");

int count = 0;

String emotion 	= "";								//감정
String volume 	= "";							//볼륨
String format 	= "";							//포멧
String speaker 	= "";							//스피커
String text 	= "";							//Text

emotion = request.getParameter("emotion");
volume = request.getParameter("volume");
format = request.getParameter("format");
speaker = request.getParameter("speaker");
text = request.getParameter("text");
//text = new String(request.getParameter("text").getBytes("8859_1"), "euc-kr");

		String clientId = "bbcykkn1bo";//애플리케이션 클라이언트 아이디값";
        String clientSecret = "oJNuTgcI4hpITUXijZaAIBro08ydkH1WM6arEohN";//애플리케이션 클라이언트 시크릿값";
        try {
            //String text = URLEncoder.encode("만나서 반갑습니다.", "UTF-8"); // 13자
            String apiURL = "https://naveropenapi.apigw.ntruss.com/voice-premium/v1/tts";
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("X-NCP-APIGW-API-KEY-ID", clientId);
            con.setRequestProperty("X-NCP-APIGW-API-KEY", clientSecret);
            // post request
            //String postParams = "speaker=nara&volume=0&emotion=0&format=mp3&text=" + text;
            String postParams = "speaker=nara&volume="+volume+"&emotion="+emotion+"&format="+format+"&text=" + text;
            con.setDoOutput(true);
            OutputStream cos = con.getOutputStream();
            DataOutputStream wr = new DataOutputStream(cos);
            wr.writeBytes(postParams);
            wr.flush();
            wr.close();
            cos.close();
            
            int responseCode = con.getResponseCode();
            BufferedReader br;
            if(responseCode==200) { // 정상 호출
                InputStream is = con.getInputStream();
                /*
                int read = 0;
                byte[] bytes = new byte[1024];
                // 랜덤한 이름으로 mp3 파일 생성
                String tempname = Long.valueOf(new Date().getTime()).toString();
                File f = new File(tempname + "." + format);
                f.createNewFile();
               	OutputStream outputStream = new FileOutputStream(f);
                while ((read =is.read(bytes)) != -1) {
                    outputStream.write(bytes, 0, read);
                } 
                if(is!=null) is.close();
                if(outputStream!=null) outputStream.close();
                */
                count = 1;
                
             	// 서버에 실제 저장된 파일명
//                 String filename = tempname + "." + format ;
            		
             	// 실제 내보낼 파일명
             	String text_title = new String(request.getParameter("text").getBytes("8859_1"), "utf-8").trim();
                String orgfilename = text_title.substring(0, text_title.length()>5?5:text_title.length()) 
                						+ "."+ format ;
            		
//                 InputStream in = null;
                OutputStream os = null;
//                 File file = null;
                boolean skip = false;
                String client = "";

             	// 파일을 읽어 스트림에 담기
                try{
//                  file = f;//file = new File(savePath, filename);
//                  in = is ;//new FileInputStream(file);
                }catch(Exception fe){
                    skip = true;
                }
        		
                client = request.getHeader("User-Agent");
                
                // 파일 다운로드 헤더 지정
                response.reset() ;
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Description", "JSP Generated Data");
         
                if(!skip){
                    if(client.indexOf("MSIE") != -1 
                    		|| client.indexOf("Windows NT") != -1
                    	){// IE
                        response.setHeader ("Content-Disposition", "attachment; filename="+new String(orgfilename.getBytes("KSC5601"),"ISO8859_1"));
                    }else{
                        // 한글 파일명 처리
                        orgfilename = new String(orgfilename.getBytes("utf-8"),"iso-8859-1");
         
                        response.setHeader("Content-Disposition", "attachment; filename=\"" + orgfilename + "\"");
                        response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
                    } 
                    //response.setHeader ("Content-Length", file.length() );
               
                    os = response.getOutputStream();
                    byte b[] = new byte[1024/* (int)file.length() */];
                    int leng = 0;
                     
                    while( (leng = is/* in */.read(b)) != -1/* > 0 */ ){
                        os.write(b,0,leng);
                    }
                    
                    /* 
                    >> response.getOutputStream();
                    Exception : java.lang.IllegalStateException: getOutputStream() has already been called for this response
                    */
                    out.clear();
                    out=pageContext.pushBody();
                }else{
                    response.setContentType("text/html;charset=UTF-8");
                    out.println("<script language='javascript'>alert('파일을 찾을 수 없습니다');history.back();</script>");
                }
                is/* in */.close();
                os.close();

            } else {  // 에러 발생
                br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
                String inputLine;
                StringBuffer sbResponse = new StringBuffer();
                while ((inputLine = br.readLine()) != null) {
                	sbResponse.append(inputLine);
                }
                br.close();
                System.out.println(sbResponse.toString());
                count = -1;
            }
        } catch (Exception e) {
            //System.out.println(e);
            count = -1;
        }

%>
<html>
<head>
</head>
<body>
</body>
</html>
<script language="javascript">
<!--
<% if(count>0){ %>
	alert("저장되었습니다.");
<% }else{ %>
	alert("저장이 실패되었습니다.");
<% } %>
//parent.location.href="<%=StaticString.ContextRoot+pageDir%>/tts/down_tts.jsp";
parent.location.href=parent.location.href;

//-->
</script>
