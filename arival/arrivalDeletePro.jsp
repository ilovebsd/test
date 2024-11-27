<%@page import="java.sql.Statement"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet, java.util.Vector"%>
<%@ page import="dao.addition.ArrivalSwitchDAO"%>
<%@ page import="business.LogHistory, com.acromate.driver.db.DataStatement, acromate.*"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 


HttpSession 		ses 		= request.getSession();
String userID = (String)ses.getAttribute("login.user") ;
String checkgroupid = (String)ses.getAttribute("login.name") ;

String 	e164 			= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");			//
String 	forwardNumber 	= new String(Str.CheckNullString(request.getParameter("forwardNumber")).getBytes("8859_1"), "euc-kr");	//
String 	startTime 		= new String(Str.CheckNullString(request.getParameter("startTime")).getBytes("8859_1"), "euc-kr");		// ���۽ð�
String 	endTime 		= new String(Str.CheckNullString(request.getParameter("endTime")).getBytes("8859_1"), "euc-kr");		// ����ð�

//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// �α��� ID

//System.out.println("e164 : "+e164);
//System.out.println("forwardNumber : "+forwardNumber);
//System.out.println("startTime : "+startTime);
//System.out.println("endTime : "+endTime);

boolean 	returnVal 		= false;
DataStatement stmt=null;
Vector 			vecTmpE164 	= new Vector();
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	ArrivalSwitchDAO dao 	= new ArrivalSwitchDAO();
	returnVal = dao.forwardDeleteNew(e164, forwardNumber, startTime, endTime, sesSysGroupID);
	try {
   		String		sql 		= "";
    	ResultSet 	rs 			= null;
    	int       	nResult     = 0;
        String    	fileName 	= "";
    	// �����κ��� DataStatement ��ü�� �Ҵ�
    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    	stmt.stxTransaction();
    		    			
       	sql = " Delete From table_forward ";
       	sql += "\n  Where e164 = '" + e164 + "' And forwardtype = 0 And forwardnumber = '" + forwardNumber + "' ";
       	sql += " And fromtime = '" + startTime + "' And totime = '" + endTime + "' ";
       	sql += " And checkgroupid = '" + checkgroupid + "'";
       	System.out.print("sql : \n"+ sql);
       	stmt.executeUpdate(sql);
		
		// table_forward ����Ÿ�� �ִ��� Ȯ��
         int cnt = 0;
       	sql  = " SELECT forwardnumber FROM table_forward WHERE e164 = '" + e164 + "' And forwardtype = 0 ";
    	System.out.print("sql : \n"+ sql);
           rs = stmt.executeQuery(sql);
           while(rs.next()){
           		vecTmpE164.add(Str.CheckNullString(rs.getString(1))) ;            	
           }
           rs.close();
           
           if (rs != null) rs.close();
       	
           cnt 	= vecTmpE164.size();
           String	strE164 	= ""; 

           //if(cnt > 0){
           //	sql = " Delete From table_forward Where e164 = '" + e164 + "' And forwardtype = 0 ";
           //	stmt.executeUpdate(sql);
           //}
           
           for(int i=0; i < cnt; i++){
           	strE164 = (String)vecTmpE164.get(i);
           	//int maxValue = getMaxValue(stmt, e164);
           	
       		sql = " Update table_forward Set ordernumber = "+(i+1)+" ";
   			sql = sql + " WHERE e164 = '" + e164 + "' And forwardnumber = '"+strE164+"' And forwardtype = 0 And checkgroupid = '" + checkgroupid + "'";
   			System.out.print("sql : \n"+ sql);
   			nResult = stmt.executeUpdate(sql);
   			if (nResult < 0){	throw new Exception(l.x("[������ȯ ��ȣ ���] '","[Auth Properties Error] '")+l.x("'������ȯ ��ȣ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
           }
    	
           stmt.endTransaction(true);			// commit ó��
        returnVal = true;
        
       } catch (Exception e) {
       	stmt.endTransaction(false);		// rollback ó��
           e.printStackTrace();
           returnVal = false;
       } finally {
           //�Ҵ���� DataStatement ��ü�� �ݳ�
           if (stmt != null ) ConnectionManager.freeStatement(stmt);
       }

	if (returnVal){
		// ############### LogHistory ó��  #############
		//String		strIp		= request.getRemoteAddr();
		//LogHistory	logHistory 	= new LogHistory();
		//int int_result = logHistory.LogHistorySave(userID+"|83|������ȯ("+e164+"���� "+forwardNumber+"��)|2|"+strIp);
		// ##############################################
		
		out.clear();
		out.print("OK");
	}else{
		out.clear();
		out.print("NO");					
	}

}catch(Exception se){
	System.out.println("error-->" +se );
	out.clear();
	out.print("NO");
}finally{

}	
%>
