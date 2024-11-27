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

String 	hiEndPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// ����� �ܸ��� ID
String 	hiEi64			= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// E164
String 	delType			= new String(request.getParameter("hiDeleteType").getBytes("8859_1"), "euc-kr");	// ����Ÿ ���� ����

String 	userID			= (String)ses.getAttribute("login.user");//new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// �α��� ID

String[] e164s = StringUtil.getParser(hiEi64, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	//stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //���� ó���κ�
    IpcsUserDAO dao = new IpcsUserDAO();
    int count = 0 ;
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		//count += dao.callBlockDelete(strE164, startprefix, request.getRemoteAddr(), userID) ?1:0;
    		if(delType.equals("1")){
				// ��ȣ �� ����� ���� ��ü ����
				count += dao.ipcsDelete(hiEndPointID, hiEi64, sesSysGroupID) ?1:0;
			}else{
				// ����� ������  ����
				count += dao.userDelete(hiEndPointID, hiEi64, sesSysGroupID) ?1:0;
			}
    		
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){
		// ############### LogHistory ó��  ###############
		/* LogHistory	logHistory 	= new LogHistory();
		int int_result = logHistory.LogHistorySave(userID+"|82|���γ�����ȣ/�ܸ����� ("+hiEi64.replace("", ",")+" ��)|2|"+strIp);
		 */
		if(1!=1)
		try{
	    	// �����κ��� DataStatement ��ü�� �Ҵ�
	    	stmt 	= ConnectionManager.allocStatement("EMS");
	    	stmt.stxTransaction();
	    	//LogHistory	logHistory 	= new LogHistory();
	    	String strTmp = userID+"|82|���γ�����ȣ/�ܸ�����|2|"+request.getRemoteAddr() ;
	    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
			String		userId 		= blockStr[0];
			int			categori	= Integer.parseInt(blockStr[1]);
			String		subject 	= blockStr[2];
			int			action		= Integer.parseInt(blockStr[3]);
			String		clientIp	= blockStr[4];
			String sql;
			for(String num : e164s){
		    	sql = " INSERT INTO table_operationhistory(checktime, managerid, sysgroupid, categori, subject, actiondml, ipaddress) ";
		        sql = sql + " VALUES(now(), '"+userId+"', 'callbox', "+categori+", '"+subject+" ("+num+" ��)"+"', "+action+", '"+clientIp+"') ";
		        stmt.executeUpdate(sql);
			}
			System.out.println("Log Save Success!!(web)");
	     	stmt.endTransaction(true);			// commit ó��
    	}catch(Exception e){
    		stmt.endTransaction(false);		// rollback ó��
            e.printStackTrace();
    	}finally {
            //�Ҵ���� DataStatement ��ü�� �ݳ�
            if (stmt != null ){
            	ConnectionManager.freeStatement(stmt);
            }
        }
	 	// ##############################################
%>
    <script>
        alert("�����Ǿ����ϴ�.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
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
    	alert("�����Ǿ����ϴ�.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //�Ҵ���� DataStatement ��ü�� �ݳ�
    //if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>