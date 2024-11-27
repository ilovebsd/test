<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.List"%>
<%@ page import="dao.ipcs.IpcsUserDAO, business.LogHistory"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );

String 	hiEndPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// 연결된 단말기 ID
String 	hiEi64			= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// E164
String 	delType			= new String(request.getParameter("hiDeleteType").getBytes("8859_1"), "euc-kr");	// 데이타 삭제 유형

String 	userID			= (String)ses.getAttribute("login.user");//new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

String[] e164s = StringUtil.getParser(hiEi64, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	//stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    IpcsUserDAO dao = new IpcsUserDAO();
    int count = 0 ;
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		//count += dao.callBlockDelete(strE164, startprefix, request.getRemoteAddr(), userID) ?1:0;
    		if(delType.equals("1")){
				// 번호 및 사용자 정보 전체 삭제
				count += dao.ipcsDelete(hiEndPointID, hiEi64, sesSysGroupID) ?1:0;
			}else{
				// 사용자 정보만  삭제
				count += dao.userDelete(hiEndPointID, hiEi64, sesSysGroupID) ?1:0;
			}
    		
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){
		// ############### LogHistory 처리  ###############
		/* LogHistory	logHistory 	= new LogHistory();
		int int_result = logHistory.LogHistorySave(userID+"|82|개인내선번호/단말관리 ("+hiEi64.replace("", ",")+" 번)|2|"+strIp);
		 */
		if(1!=1)
		try{
	    	// 서버로부터 DataStatement 객체를 할당
	    	stmt 	= ConnectionManager.allocStatement("EMS");
	    	stmt.stxTransaction();
	    	//LogHistory	logHistory 	= new LogHistory();
	    	String strTmp = userID+"|82|개인내선번호/단말관리|2|"+request.getRemoteAddr() ;
	    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
			String		userId 		= blockStr[0];
			int			categori	= Integer.parseInt(blockStr[1]);
			String		subject 	= blockStr[2];
			int			action		= Integer.parseInt(blockStr[3]);
			String		clientIp	= blockStr[4];
			String sql;
			for(String num : e164s){
		    	sql = " INSERT INTO table_operationhistory(checktime, managerid, sysgroupid, categori, subject, actiondml, ipaddress) ";
		        sql = sql + " VALUES(now(), '"+userId+"', 'callbox', "+categori+", '"+subject+" ("+num+" 번)"+"', "+action+", '"+clientIp+"') ";
		        stmt.executeUpdate(sql);
			}
			System.out.println("Log Save Success!!(web)");
	     	stmt.endTransaction(true);			// commit 처리
    	}catch(Exception e){
    		stmt.endTransaction(false);		// rollback 처리
            e.printStackTrace();
    	}finally {
            //할당받은 DataStatement 객체는 반납
            if (stmt != null ){
            	ConnectionManager.freeStatement(stmt);
            }
        }
	 	// ##############################################
%>
    <script>
        alert("해제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("해제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
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

 %>
    <script>
    	alert("해제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    //if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>