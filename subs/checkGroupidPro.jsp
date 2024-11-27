<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

String grpid      	= StringUtil.null2Str(request.getParameter("groupid"),"").trim();
 
String loginid      = StringUtil.null2Str(request.getParameter("loginid"),"").trim();
String password     = StringUtil.null2Str(request.getParameter("password"),"").trim();

String areanum     = StringUtil.null2Str(request.getParameter("areanum"),"").trim();
String localnum     = StringUtil.null2Str(request.getParameter("localnum"),"").trim();
String extnum      	= StringUtil.null2Str(request.getParameter("extnum"),"").trim();
String authpasswd   = StringUtil.null2Str(request.getParameter("authpasswd"),"").trim();
String createcount  = StringUtil.null2Str(request.getParameter("createcount"),"").trim();

String outproxyip   = StringUtil.null2Str(request.getParameter("outproxyip"),"").trim();
String startprefix  = StringUtil.null2Str(request.getParameter("startprefix"),"").trim();
String endprefix    = StringUtil.null2Str(request.getParameter("endprefix"),"").trim();
String mindigit     = StringUtil.null2Str(request.getParameter("mindigit"),"").trim();
String maxdigit     = StringUtil.null2Str(request.getParameter("maxdigit"),"").trim();

String result = null;

if(grpid.length()==0){
	result = "MSG:"+"Company ID 값을 확인해주세요.";
}else if(loginid.length()==0 
		|| password.length()==0){
	result = "MSG:"+"Manager Login 값을 확인해주세요.";
}else if(localnum.length()==0 
		|| extnum.length()==0
		|| authpasswd.length()==0
		|| createcount.length()==0
		){
	result = "MSG:"+"Phone-Number 값을 확인해주세요.";
}else if(outproxyip.length()==0 
		|| startprefix.length()==0
		|| endprefix.length()==0
		|| mindigit.length()==0
		|| maxdigit.length()==0
		){
	result = "MSG:"+"Routing 값을 확인해주세요.";
}

if(result!=null){
	out.clear(); out.print(result);
	return ;
}

ArrayList 		envList = null;
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    CommonDAO dao = new CommonDAO();
    if(result==null){
	    envList = dao.select(stmt, "SELECT checkgroupid FROM Table_subscriberGroup WHERE checkgroupid='"+grpid+"' LIMIT 1", new String[]{"checkgroupid"} ) ;
	    if( envList.size() > 0 ){
	    	result = "NO:Company ID 가 ";
	    }
    }
    if(result==null){//manager
	    envList = dao.select(stmt, "SELECT checkgroupid FROM Table_subscriber WHERE id='"+loginid+"' LIMIT 1", new String[]{"checkgroupid"} ) ;
	    if( envList.size() > 0 ){
	    	result = "NO:Manager ID 가 ";
	    }
    }
    if(result==null){//e164
    	String endnum = (Str.CheckNullLong(areanum+localnum+extnum) + Str.CheckNullInt(createcount)) + "";
	    envList = dao.select(stmt, "SELECT checkgroupid FROM Table_e164 WHERE CAST(e164 AS bigint) >= "+areanum+localnum+extnum+" AND CAST(e164 AS bigint) < "+endnum+" LIMIT 1", new String[]{"checkgroupid"} ) ;
	    if( envList.size() > 0 ){
	    	result = "NO:Phone-Number 중 ";
	    }
    }
    if(result==null){//prefixtableid, prefixtable
	    envList = dao.select(stmt, "SELECT checkgroupid FROM Table_prefixtable WHERE startprefix='"+startprefix+"' AND prefixtableid='"+grpid+"' LIMIT 1", new String[]{"checkgroupid"} ) ;
	    if( envList.size() > 0 ){
	    	result = "NO:Start Prefix 가 ";
	    }
    }
    
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	result = 1==2?"NO:"+grpid:"OK" ;
    	///result = "MSG:"+"";
	}else result = "MSG:DB 오류가 발생했습니다.";
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
    out.clear();
	out.print(result==null?"OK":result);
}	
%>