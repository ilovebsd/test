<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.addition.AlarmServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = 0; 
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

String userID      = Str.CheckNullString(scDTO.getSubsID()).trim();
 */

//String grpid        = StringUtil.null2Str(request.getParameter("grpid"),"");////////////////
String e164        = StringUtil.null2Str(request.getParameter("e164"),"");
String alarmtype   = StringUtil.null2Str(request.getParameter("alarmtype"),"");
String alarmtime_1 = StringUtil.null2Str(request.getParameter("alarmtime_1"),"");
String alarmtime_2 = StringUtil.null2Str(request.getParameter("alarmtime_2"),"");
String alarmtime_3 = StringUtil.null2Str(request.getParameter("alarmtime_3"),"");
String alarmdate_1 = StringUtil.null2Str(request.getParameter("alarmdate_1"),"");
String alarmdate_2 = StringUtil.null2Str(request.getParameter("alarmdate_2"),"");
String alarmdate_3 = StringUtil.null2Str(request.getParameter("alarmdate_3"),"");
String alarmtime   = "";
String alarmdate   = "";

if("1".equals(alarmtime_1)){
    alarmtime = StringUtil.leftPadWithZero(alarmtime_2, 2) + alarmtime_3;
}else if("2".equals(alarmtime_1)){
    //alarmtime = (Integer.parseInt(alarmtime_2)+12) + alarmtime_3;
	if(("12".equals(alarmtime_2))&&("00".equals(alarmtime_3))){
		alarmtime = "2400";
	}else if(("12".equals(alarmtime_2))&&(!"00".equals(alarmtime_3))){
		alarmtime = "00" + alarmtime_3;
	}else{
		alarmtime = (Integer.parseInt(alarmtime_2)+12) + alarmtime_3;
	}
}
if("1".equals(alarmtype)){
    alarmdate = alarmdate_1 + alarmdate_2 + alarmdate_3;
}else{
    alarmdate = "";
}

String[] e164s = e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //처리부분
    AlarmServiceDAO alarmServiceDAO = new AlarmServiceDAO();
    int count = 0 ;
    String alarm = "";
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		
    		System.out.println("insert >> e164="+strE164+", alarmtype="+alarmtype+", alarmtime="+alarmtime+", alarmdate="+alarmdate);
    		
    		alarmServiceDAO.deleteAll(stmt, strE164) ;
    		count += alarmServiceDAO.insert(stmt, strE164, alarmtype, alarmtime, alarmdate);
    		
    		if(alarmdate.length()>7){
    			alarm = alarmdate.substring(0, 4)+"-"+alarmdate.substring(4, 6)+"-"+alarmdate.substring(6, 8) ;
				alarm += " "+alarmtime.substring(0, 2)+":"+alarmtime.substring(2, 4);
    		}
			jsArray.append("[\""+strE164+"\",\""+alarm+"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){
%>
    <script>
        alert("등록되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
      	//parent.location.href="<%=StaticString.ContextRoot%>/alarm/alarmTimeList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("등록 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	String alarm = "";
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		if(alarmdate.length()>7){
	    			alarm = alarmdate.substring(0, 4)+"-"+alarmdate.substring(4, 6)+"-"+alarmdate.substring(6, 8) ;
					alarm += " "+alarmtime.substring(0, 2)+":"+alarmtime.substring(2, 4);
	    		}
	       		jsArray.append("[\""+strE164+"\",\""+alarm+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
 %>
    <script>
    	alert("등록되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>