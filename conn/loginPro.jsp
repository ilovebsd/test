<%@page import="bizportal.nasacti.ipivr.common.IpivrConfig"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="webuser.ServerLogin"%>

<% 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

/* BASE64Encoder enc = new sun.misc.BASE64Encoder();
String id = request.getParameter("loginid");
   String encId = (id!=null&&id.length()>0)? enc.encode(id.getBytes()) : "";
   
	String pw = request.getParameter("psword");
	String encPw = (pw!=null&&pw.length()>0)? enc.encode(pw.getBytes()) : "";
	 */
String id   = StringUtil.null2Str(request.getParameter("linid"),"");
String pw   = StringUtil.null2Str(request.getParameter("linps"),"");

sun.misc.BASE64Decoder dec = new sun.misc.BASE64Decoder();
if( id!=null && id.length()>0 ) {
	// Decode it, using any base 64 decoder
    String useridDecoded = new String(dec.decodeBuffer(id));
    id = useridDecoded ;
}
	
if( pw!=null && pw.length()>0 ){
	String userpassDecoded = new String(dec.decodeBuffer(pw));
	pw = userpassDecoded ;
}

String[][] 		values = null;
ArrayList 		envList = null;
DataStatement 	stmt = null;
int count = 0;

try{
    String userid = null, authGroupid = null, loginLevel = null;
	//처리부분
	try{
		if (ServerLogin.isLogin() == false 
				//&& ServerLogin.serverLogin==null 
						 ) {
	    	ServletContext context = getServletContext();
	    	ServerLogin.getServerLogin().login(context) ; 
	    }
		stmt 			= ConnectionManager.allocStatement("SSW");
	}catch(Exception ex){
		ex.printStackTrace();
		stmt = null;
	}
	
	if(stmt!=null && id.length()>0 && pw.length()>0){
			CommonDAO		commonDao		= new CommonDAO();
			String 			commonSql		= "SELECT id, pwd, checkgroupid, loginlevel FROM table_subscriber WHERE id='"+id.trim()+"' AND pwd='"+pw.trim()+"'";
			String 			strColNames[]	= {"id","pwd","checkgroupid", "loginlevel"};
			
			envList			= commonDao.select(stmt,commonSql,strColNames);
	}
	if (stmt != null) ConnectionManager.freeStatement(stmt);
	
	count 			= envList==null? 0 : envList.size();
	
	values = new String[count][4];
	
	if(/* envList!=null && */ count>0){
		HashMap temp= null;
		int flagAlarm = 0;
		for(int idx=0;idx<count;idx++){
			if(envList!=null)
				temp	=	(HashMap)envList.get(idx);
			
			if(temp!=null){
				userid = (String)temp.get("id");
				loginLevel = (String)temp.get("loginlevel");
			 	authGroupid = (String)temp.get("checkgroupid") ;
			}
		}//for
	}else if(nModeDebug==1){	
		if("aaa:ccc".equals(id+":"+pw))
			count = 1; 
		userid = "DEBUG_USER";
		authGroupid = "DEBUG_GRP"; 
		loginLevel = "2";
	}
				
    if(count > 0){
    	
    	HttpSession ses = request.getSession(false);
    	ses.setAttribute("login.user", userid) ;
    	ses.setAttribute("login.name", authGroupid) ;
    	ses.setAttribute("login.level", loginLevel) ;
    	
    	request.getSession(false).setAttribute("login.sysgroupname", ConnectionManager.getInstance().getSysGroupName() );
    	request.getSession(false).setAttribute("login.sysgroupid", ConnectionManager.getInstance().getSysGroupID() );
		//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		
		IpivrConfig ipivrConfig = IpivrConfig.getInstance();
		String voiceFileBasePath = ipivrConfig.voiceFileBasePath +"/"+ConnectionManager.getInstance().getSysGroupName();// /data/MS/v1xx/.. == host/MS/v1xx/..
		
		String strAnCodePath = voiceFileBasePath+"/SoundV/Ancode"; //config.getInitParameter("AnCodePath");        // Ancode
		String strFileMentPath = voiceFileBasePath+"/SoundV/FileMent"; //config.getInitParameter("FileMentPath");  // Filement
		String strIpcsFilePath = voiceFileBasePath+"/ipcs_files"; //ipivrConfig.strRealPath +"/../ipcs_files";		//hc-add : req.chun
			
		request.getSession(false).setAttribute("login.voiceFileBasePath", voiceFileBasePath );
		request.getSession(false).setAttribute("login.strAnCodePath", strAnCodePath );
		request.getSession(false).setAttribute("login.strFileMentPath", strFileMentPath );
		request.getSession(false).setAttribute("login.strIpcsFilePath", strIpcsFilePath );
		
		//StaticString.wavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
		//StaticString.userWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
		String strWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
		String strUserWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
		request.getSession(false).setAttribute("login.strWavPath", strWavPath );
		request.getSession(false).setAttribute("login.strUserWavPath", strUserWavPath );
		
%>
   <script>
       	alert("로그인되었습니다.");
       	parent.hiddenAdCodeDiv();
	   	<%if("2".equals(loginLevel)) {%>
      		parent.location.href="../subs/subsList.jsp";
       	<%}else{%>
	   		parent.location.href="../ipcsext/ipcsExtList.jsp";
	   	<%}%>
   </script>
<%
    }else{
%>
    <script>
        alert("로그인 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>