<%@page import="java.sql.ResultSet"%>
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
String[] arrScCode_NwuIdx = StringUtil.getParser(deleteStr, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    int iRtn = 0, iRtnCnt = 0 ;
    if(stmt!=null) stmt.stxTransaction();
    
    String scCode = "", nwuIdx = "", scName = "";
    String strMsg = "";
    
    for(String strScCode_NwuIdx : arrScCode_NwuIdx){
    	String[] keys = strScCode_NwuIdx.split(",");    
    	scCode = keys[0];
    	nwuIdx = keys[1];
    	iRtn = -1;

    	/**
    	 * 
    	 */
    	sql = "select count(*) from nasa_answer_time where at_sc_code = %s ";
//     	sql += "AND checkgroupid = '"+ authGroupid +"' ";
    	sql = String.format(sql
        		, scCode
        		);
        System.out.println("sql : "+ sql);
    	rs = stmt.executeQuery(sql);
    	if(rs.next()) {
 			if(rs.getInt(1)==0){
 				sql = "DELETE FROM nasa_callprocessor ";
 		        sql += "WHERE sc_code = %s ";
//  		       	sql += "AND checkgroupid = '"+ authGroupid +"' ";
 		        sql = String.format(sql
 		        		, scCode
 		        		);
 		        System.out.println("sql : "+ sql);
 		    	iRtnCnt = stmt.executeUpdate(sql);
 		    	if(iRtnCnt > 0) iRtn = 1;
 			}else{
	    		iRtn = 2;
 			}
    	}
    	if(rs!=null) rs.close();
    	
    	if(iRtn == 1) {
        	sql = "DELETE FROM nasa_wave_use     \n";
            sql += "WHERE nwu_idx = %s ";
            sql = String.format(sql
            		, nwuIdx
            		);
            System.out.println("sql : "+ sql);
        	iRtnCnt = stmt.executeUpdate(sql);
        	
        	if(iRtnCnt > 0) {
    			iRtn = 1;
    			
        		sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
        		System.out.println("sql : "+ sql);
        		stmt.executeUpdate(sql);
            }
    	}
    	
    	switch(iRtn) {
	    	case 1://ok
				//request.setAttribute("msg", "???????????.");
				break;
			case 2:// exist data at this (FROM nasa_answer_time WHERE at_sc_code = ) 
				strMsg += "\"" + scName + "\".\\n";
				break;
			case -1:
				strMsg += "\"" + scName + "\".\\n";
				break;
		}
    }//for
// 	if(strMsg.length() > 0)
// 		request.setAttribute("msg", strMsg);

 	// ############### LogHistory 처리  ###############
	//returnVal = dao.virtualNumberDelete(deleteStr);
	//count += dao.virtualNumberDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################
    for(String strScCode_NwuIdx : arrScCode_NwuIdx)
    	if( (strScCode_NwuIdx = strScCode_NwuIdx.trim()).length()>1 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strScCode_NwuIdx+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    
    if(/* count >= adIndexs.length */ iRtn > 0 ){
    	if(strMsg.length()>0){
    		if(stmt!=null) stmt.endTransaction(false);    	
%>
    <script>
        alert("사용중인 응답모드 입니다.");
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%    		
    	}else{
    		if(stmt!=null) stmt.endTransaction(true);    	
%>
    <script>
        alert("삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    	}
    }else{
    	if(stmt!=null) stmt.endTransaction(false);
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
	if(stmt!=null) stmt.endTransaction(false);
	
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strKey : arrScCode_NwuIdx)
	       	if( (strKey = strKey.trim()).length()>1 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strKey+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");

 %>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>