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
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;
//String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

String deleteStr      = StringUtil.null2Str(request.getParameter("deleteStr"),"");
String[] adIndexs = StringUtil.getParser(deleteStr, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    int iRtn = 0, iRtnCnt = 0 ;
    if(stmt!=null) stmt.stxTransaction();
    
    for(String strAdIndex : adIndexs){
    	sql = "DELETE FROM nasa_answer_dateday     \n";
        sql += "WHERE ad_index = "+strAdIndex+"     ";
//         sql += "AND checkgroupid = '"+ authGroupid +"' ";
        System.out.println("sql : "+ sql);
    	iRtnCnt = stmt.executeUpdate(sql);
		
    	if(iRtnCnt > 0) iRtn = 1;
    }

    if(iRtn > 0){
		sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
		System.out.println("sql : "+ sql);
		stmt.executeUpdate(sql);
    }
	
 	// ############### LogHistory 처리  ###############
	//returnVal = dao.virtualNumberDelete(deleteStr);
	//count += dao.virtualNumberDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################
    for(String strAdIndex : adIndexs)
    	if( (strAdIndex = strAdIndex.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strAdIndex+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(/* count >= adIndexs.length */ iRtn > 0){
    	if(stmt!=null) stmt.endTransaction(true);    	
%>
    <script>
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        alert("삭제되었습니다.");
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
    	if(stmt!=null) stmt.endTransaction(false);
%>
    <script>
        parent.hiddenAdCodeDiv();
        alert("삭제 중 오류가 발생하였습니다.");
    </script>
<%
    }
} catch (Exception e) {
	if(stmt!=null) stmt.endTransaction(false);
	
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strE164 : adIndexs)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");

 %>
    <script>
        parent.hiddenAdCodeDiv();
        alert("삭제 중 오류가 발생하였습니다.");
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>