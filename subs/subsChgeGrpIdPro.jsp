<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );

String grpid      	= StringUtil.null2Str(request.getParameter("groupid"),"").trim();
 
String result = null;

if(grpid.length()==0){
	result = "MSG:"+"Company ID 값을 확인해주세요.";
}

if(result!=null){
	out.clear(); out.print(result);
	return ;
}

ses.setAttribute("login.name", grpid) ;

//result = "NO:Company ID 가 ";
out.clear();
out.print(result==null?"OK":result);
%>