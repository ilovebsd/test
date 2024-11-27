<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;

String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String deleteStr = StringUtil.null2Str(request.getParameter("deleteStr"),"");	// 삭제할 통화 목록


String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
// DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
// 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    AddServiceDAO dao = new AddServiceDAO();
    int count = dao.callChangeNumberDelete(e164, request.getRemoteAddr(), userID, sesSysGroupID)?1:0;
    
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		//count += dao.deleteAll(stmt, strE164);
    		
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(/* count >= e164s.length */ count > 0 ){
    	out.clear();
		out.print("OK");    	
%>
   <%--  <script>
        alert("해제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script> --%>
<%
    }else{
    	out.clear();
		out.print("NO");
%>
    <!-- <script>
        alert("해제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script> -->
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
   	 	out.clear();
		out.print("OK");
 %>
   <%--  <script>
    	alert("해제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script> --%>
<%
	}else{
		out.clear();
		out.print("NO");
	}
} finally {
    //할당받은 DataStatement 객체는 반납
//     if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>