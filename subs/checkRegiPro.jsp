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

String loginid      = StringUtil.null2Str(request.getParameter("loginid"),"").trim();
String password     = StringUtil.null2Str(request.getParameter("password"),"").trim();

String result = null;

if(loginid.length()==0){
	result = "MSG:"+"Login ID 값을 입력해주세요.";
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
    if(result==null){//manager
	    envList = dao.select(stmt, "SELECT checkgroupid FROM Table_subscriber WHERE id='"+loginid+"' LIMIT 1", new String[]{"checkgroupid"} ) ;
	    if( envList.size() > 0 ){
	    	result = "NO:Login ID 가 ";
	    }
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	result = 1==2?"NO:"+loginid:"OK" ;
    	///result = "MSG:"+"";
	}else result = "MSG:DB 오류가 발생했습니다.";
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
    out.clear();
	out.print(result==null?"OK":result);
}	
%>