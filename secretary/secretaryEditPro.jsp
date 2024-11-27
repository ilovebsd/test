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
<%@ page import="java.sql.ResultSet"%>
<%@ page import="business.LogHistory"%>
<%@ page import="acromate.l"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
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
String hiNumber        = StringUtil.null2Str(request.getParameter("hiNumber"),"");

String logElement = e164 ;
System.out.println("e164:"+e164);
String[] e164s = e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

boolean 		returnVal 	= false;
DataStatement 	statement 	= null;
ResultSet 	rs 		= null;

try{
    String      sql 		= "" ;
    int       	nResult         = 0;
    String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
statement = ConnectionManager.allocStatement("SSW", sesSysGroupID);
statement.stxTransaction();

    int count = 0 ;
    String alarm = "";
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
		            int cnt = 0;
		            
	            	sql  = " SELECT count(*) FROM table_featureservice WHERE e164 = '" + strE164 +"' and serviceno = 5121 ";
	        		
	                rs = statement.executeQuery(sql);
					if (rs.next()){ 
						cnt = rs.getInt(1) ;
					}
					rs.close();
	                
	                if (rs != null) {
	                	rs.close();
                        rs = null ;
                    }
                	
                    if (cnt > 0){
                    	sql = " update table_featureservice set userparam = '" + hiNumber + "' "; 
            			sql = sql + "  WHERE e164 = '" + strE164 +"' and serviceno = 5121 ";
	        			System.out.println(sql);
                        nResult = statement.executeUpdate(sql);
                        if (nResult < 1){	throw new Exception(l.x("[AlertInfo 등록 오류] '","[AlertInfo] '")+strE164+l.x("'는 AlertInfo등록이 실패하였습니다.","' Insert Fail"));	}            
                    }
                    count++ ;
                    
			jsArray.append("[\""+strE164+"\",\""+alarm+"\"]}");
       	}
       	if (statement != null ) statement.endTransaction(true);			// commit 처리
		// ############### LogHistory 처리  ###############
	    //String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID
		//LogHistory	logHistory 	= new LogHistory();
        //int int_result = logHistory.LogHistorySave(userID+"|83|음성사서함 ("+logElement.substring(0,90)+"... 번)|1|"+ request.getRemoteAddr());
		// ##############################################
	    returnVal = true;
    if(jsArray.length()>0)	jsArray.append("]");
    if(count >= e164s.length){
%>
    <script>
        alert("등록되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
      	//parent.location.href="./alarmTimeList.jsp";
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
	if (statement != null ) statement.endTransaction(false);		// rollback 처리
	e.printStackTrace();
    returnVal = false;
 %>
    <script>
        alert("등록 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
} finally {
    //할당받은 DataStatement 객체는 반납
    if (rs != null) rs.close();
    if (statement != null ) ConnectionManager.freeStatement(statement);
}	
%>