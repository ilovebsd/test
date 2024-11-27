<%@page import="com.acromate.data.DataIO"%>
<%@page import="com.acromate.session.EmsServerAgent"%>
<%@page import="com.acromate.session.UserSessionClient"%>
<%@page import="sun.security.jca.GetInstance"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.addition.AlarmServiceDAO"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="webuser.ServerLogin"%>

<% 

int nModeDebug = 0;

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

String sysgroupname = StringUtil.null2Str(request.getParameter("sysgroupname"),"");
String sysgroupId="";

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
	if (ServerLogin.isLogin() == false) {
    	ServletContext context = getServletContext();
    	ServerLogin.getServerLogin().login(context) ; 
    }
	
	if(sysgroupname.length()>0){
		//sysgroupname
		UserSessionClient userSessionClient = ConnectionManager.getInstance().getSessionClient();
		EmsServerAgent svrAgent = userSessionClient.getEmsServerAgent();
		DataIO dto = svrAgent.getGroups().getHead();//GroupSystem
		StringBuilder sb = new StringBuilder();
		String sysgroupName="";
		while(dto!=null){
			dto.getParam("groupName", sb.delete(0, sb.length()) ); 	sysgroupName = sb.toString().replace("'", "");
			if(sysgroupName.equals(sysgroupname)){
				dto.getParam("groupId", sb.delete(0, sb.length()) ); 	sysgroupId = sb.toString().replace("'", "");
				break;
			}
			dto = dto.m_pNext;
		}
		sb=null;
			
		if(sysgroupId.length()==0){
%> 	<script>
        alert("로그인 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
	</script>
<%
				return;
		}
		if(11==1){
			ConnectionManager.getInstance().setSysGroupID(sysgroupname, sysgroupId);
			String sysGroupId = ConnectionManager.getInstance().getSysGroupID();
			String sysGroupName = ConnectionManager.getInstance().getSysGroupName();
		}
		
	}
	
    String authGroupid = null;
	//처리부분
	try{
			stmt 			= ConnectionManager.allocStatement("SSW", sysgroupId);
	}catch(Exception ex){
		stmt = null;
	}
	
	if(stmt!=null && id.length()>0 && pw.length()>0){
			CommonDAO		commonDao		= new CommonDAO();
			String 			commonSql		= "SELECT id, pwd, checkgroupid FROM table_subscriber WHERE id='"+id.trim()+"' AND pwd='"+pw.trim()+"'";
			String 			strColNames[]	= {"id","pwd","checkgroupid"};
			
			envList			= commonDao.select(stmt,commonSql,strColNames);
			//if (stmt != null) ConnectionManager.freeStatement(stmt);
	}
	count 			= envList==null? 0 : envList.size();
	
	values = new String[count][3];
	
	if(/* envList!=null && */ count>0){
		HashMap temp= null;
		int flagAlarm = 0;
		for(int idx=0;idx<count;idx++){
			if(envList!=null)
				temp	=	(HashMap)envList.get(idx);
			
			if(temp!=null){
				values[idx][0] = (String)temp.get("id");
				values[idx][1] = (String)temp.get("pwd");
				values[idx][2] = (String)temp.get("checkgroupid");
				
			 	authGroupid = values[idx][2] ;
			}
		}//for
	}
    
	if(nModeDebug==1){	
		if("aaa:ccc".equals(id+":"+pw))
			count = 1; authGroupid = "TEST ID"; 
	}
				
    if(count > 0){
    	
    	HttpSession ses = request.getSession(false);
    	ses.setAttribute("login.name", authGroupid) ;
    	
    	request.getSession(false).setAttribute("login.sysgroupid", sysgroupId );
		//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		
%>
    <script>
    	<%-- alert("<%=sysgroupname%>"); --%>
        alert("로그인되었습니다.");
        parent.hiddenAdCodeDiv();
        //parent.location.href="<%=StaticString.ContextRoot%>/alarm/alarmTimeList.jsp";
        parent.location.href = parent.location.href/* "alarmTimeList.jsp"; */
    </script>
<%
    }else{
    	/* Cookie imsicookie = null;
		for(Cookie ck : request.getCookies()){
    		if( "id_cookie_alarm".equals(ck.getName()) ){
    			imsicookie = ck; break;
    		}
		}
		if(imsicookie==null)
			imsicookie = new Cookie("id_cookie_alarm", null);
		imsicookie.setValue(null) ;
		imsicookie.setPath("/"); 
		imsicookie.setMaxAge(-1); //브라우저를 닫으면 쿠키가 자동소멸
		response.addCookie(imsicookie);  */
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