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
//String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// �α��� ID

String deleteStr      = StringUtil.null2Str(request.getParameter("deleteStr"),"");
String[] arrDelIndex = StringUtil.getParser(deleteStr, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //���� ó���κ�
    int iRtn = 0, iRtnCnt = 0 ;
    if(stmt!=null) stmt.stxTransaction();
    
    String amModeName = "";
    String strMsg = "";
    
    for(String strDelIndex : arrDelIndex){
    	iRtn = -1;

    	//
    	sql = "select count(*) from nasa_answer_dateday where am_index = %s ";
//     	sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
    	sql = String.format(sql
        		, strDelIndex
        		);
        System.out.println("sql : "+ sql);
    	rs = stmt.executeQuery(sql);
    	if(rs.next()) {
 			if(rs.getInt(1)==0){
 				sql = "DELETE FROM nasa_answer_mode \n";
 		        sql += "WHERE am_index = %s ";
//  		       sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
 		        sql = String.format(sql
 		        		, strDelIndex
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
        	sql = "DELETE FROM nasa_answer_time     \n";
            sql += "WHERE am_index = %s ";
//             sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
            sql = String.format(sql
            		, strDelIndex
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
				strMsg += "\"" + amModeName + "\".\\n";
				break;
			case -1:
				strMsg += "\"" + amModeName + "\".\\n";
				break;
		}
    }//for
// 	if(strMsg.length() > 0)
// 		request.setAttribute("msg", strMsg);

 	// ############### LogHistory ó��  ###############
	//returnVal = dao.virtualNumberDelete(deleteStr);
	//count += dao.virtualNumberDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################
    for(String strDelIndex : arrDelIndex)
    	if( (strDelIndex = strDelIndex.trim()).length()>1 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strDelIndex+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    
    if(/* count >= adIndexs.length */ iRtn > 0 ){
    	
    	if(strMsg.length()>0){
        	if(stmt!=null) stmt.endTransaction(false);    	
%>
    <script>
        alert("������� ���佺�����Դϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%    		
    	}else{
    		if(stmt!=null) stmt.endTransaction(true);    	
%>
    <script>
        alert("�����Ǿ����ϴ�.");
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
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
	if(stmt!=null) stmt.endTransaction(false);
	
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strKey : arrDelIndex)
	       	if( (strKey = strKey.trim()).length()>1 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strKey+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");

 %>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
	try{ if(rs!=null) rs.close(); }catch(Exception e){}	
    //�Ҵ���� DataStatement ��ü�� �ݳ�
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>