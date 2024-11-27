<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="dao.addition.ArrivalSwitchDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>

<%@ page import="acromate.*"%>
<%@ page import="business.LogHistory"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String checkgroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;

 String 	procMode		= new String(Str.CheckNullString(request.getParameter("procMode")).getBytes("8859_1"), "euc-kr");// ó�� ��� [insert, update]
 
 	String 	e164		= new String(Str.CheckNullString(request.getParameter("hiE164")).getBytes("8859_1"), "euc-kr");			// e164
	String 	arrivalType	= new String(Str.CheckNullString(request.getParameter("hiArrivalType")).getBytes("8859_1"), "euc-kr");	// �������� ����
	String 	number1		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber1")).getBytes("8859_1"), "euc-kr");	// ������ȯ ������ȣ
	
	String 	chkForward0	= new String(Str.CheckNullString(request.getParameter("hiChkForward_0")).getBytes("8859_1"), "euc-kr");	// ���Ǻ� ������ȯ ����
	String 	number2		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber2")).getBytes("8859_1"), "euc-kr");	// ������ȯ ������ȣ
	String 	fromTime	= new String(Str.CheckNullString(request.getParameter("hiToTime")).getBytes("8859_1"), "euc-kr");		// ���۽ð�
	String 	toTime		= new String(Str.CheckNullString(request.getParameter("hiFromTime")).getBytes("8859_1"), "euc-kr");		// ����ð�
	
	String 	chkForward1	= new String(Str.CheckNullString(request.getParameter("hiChkForward_1")).getBytes("8859_1"), "euc-kr");	// ���Ǻ� ������ȯ ����
	String 	number3		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber3")).getBytes("8859_1"), "euc-kr");	// ������ȯ ������ȣ
	String 	waitTime	= new String(Str.CheckNullString(request.getParameter("hiwaitTime")).getBytes("8859_1"), "euc-kr");		// ���ð�
	
	String 	chkForward2	= new String(Str.CheckNullString(request.getParameter("hiChkForward_2")).getBytes("8859_1"), "euc-kr");	// ���Ǻ� ������ȯ ����
	String 	number4		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber4")).getBytes("8859_1"), "euc-kr");	// ������ȯ ������ȣ
				
	String 	chkForward3	= new String(Str.CheckNullString(request.getParameter("hiChkForward_3")).getBytes("8859_1"), "euc-kr");	// ���Ǻ� ������ȯ ����
	String 	number5		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber5")).getBytes("8859_1"), "euc-kr");	// ������ȯ ������ȣ

String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();
String	sql = "", strIp;
int count = 0, nResult = 0;
DataStatement stmt = null;
ResultSet 	rs 	= null;
try{

	strIp = request.getRemoteAddr() ;
// 	LogHistory	logHistory 	= new LogHistory();
	ArrivalSwitchDAO dao 	= new ArrivalSwitchDAO();
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// �����κ��� DataStatement ��ü�� �Ҵ�
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	stmt.stxTransaction();
	for(String strE164 : e164s){
		/* sql  = " SELECT count(*) FROM table_featureservice WHERE e164 = '" + strE164 +"' AND checkgroupid='"+authGroupid+"' AND serviceno = 5431 ";
        rs = stmt.executeQuery(sql);
		if (rs.next()) count = Integer.parseInt(rs.getString(1));
		rs.close();
        if (rs != null) rs.close();
         */
        strE164 = strE164.trim();
        if (true){//���
        	 String temp_AnswerService = "";
             String answerService = "";
             
             sql = "SELECT answerservice FROM table_E164 WHERE e164 = '" + strE164 + "'";
             rs = stmt.executeQuery(sql);
             if (rs.next()) temp_AnswerService = rs.getString(1);
             rs.close();

             if(arrivalType.equals("0")){
             	answerService = temp_AnswerService.substring(0, 3) + "0" + temp_AnswerService.substring(4, 64);
             }else if(arrivalType.equals("1")){
             	answerService = temp_AnswerService.substring(0, 3) + "1" + temp_AnswerService.substring(4, 64);
             }else if(arrivalType.equals("2")){
             	answerService = temp_AnswerService.substring(0, 3) + "2" + temp_AnswerService.substring(4, 64);
             }else if(arrivalType.equals("3")){
             	answerService = temp_AnswerService.substring(0, 3) + "3" + temp_AnswerService.substring(4, 64);
             }
             
             if(arrivalType.equals("1")){
             	sql   = "Update table_E164 set answerservice = '" + answerService + "', directforwardnumber = '" + number1 + "' WHERE e164 = '" + strE164 + "' AND checkgroupid='"+checkgroupid+"'";
             }else{
             	sql   = "Update table_E164 set answerservice = '" + answerService + "', directforwardnumber = null WHERE e164 = '" + strE164 + "' AND checkgroupid='"+checkgroupid+"'";
             }
             System.out.println("1:"+sql);
             nResult = stmt.executeUpdate(sql);
             if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                

             // �μ���ǥ��ȣ �����缭�� ������ȯ ----------------------
             if(!"3".equals(arrivalType)){
             	sql   = "Update table_keynumberid set forwardtype = 0 , forwardnum = '' WHERE forwardnum = '" + strE164 + "' AND checkgroupid='"+checkgroupid+"'";
             }
             System.out.println("2:"+sql);
             nResult = stmt.executeUpdate(sql);
             if (nResult < 0){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
             // ------------------------------------------------
             
             if(!arrivalType.equals("2")){
 	            // �μ���ǥ��ȣ �����缭�� ������ȯ ----------------------
 	        	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' AND checkgroupid='"+checkgroupid+"'";                
 	        	System.out.println("3:"+sql);
 	            nResult = stmt.executeUpdate(sql);
 	            if (nResult < 0){	throw new Exception(l.x("[������ȯ ����] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
             }
             
             if(arrivalType.equals("2")){
 				//returnVal2 = dao.forwardUpdateNew(e164, chkForward0, number2, toTime, fromTime, chkForward1, number3, waitTime, chkForward2, number4, chkForward3, number5);
            	 if(chkForward0.equals("1")){
                     if(!"".equals(number2) 
                    		 && "update".equals(procMode) ){
     	            	// Ư���ð��뺰 ������ȯ 
     	            	int maxValue = dao.getMaxValue(stmt, strE164);
     	            	maxValue = maxValue+1;
     	            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', "+maxValue+", '"+ number2 +"', 0, 0, '"+ fromTime +"', '"+ toTime +"', '"+checkgroupid+"')";
     	            	
     	            	System.out.println("0:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
                     }
                 }else{
                 	// Ư���ð��뺰 ������ȯ ����
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 0 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 0 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("0:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ����] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 }
                 if(chkForward1.equals("1")){
                     // �������϶� ������ȯ
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number3 +"', forwardwaittime = '"+ waitTime +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 1 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number3 +"', 1, "+waitTime+", '0000', '2400', '"+checkgroupid+"')";
     	                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
                     }
                 }else{
                 	// �������϶� ������ȯ ����
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ����] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 } 
                 if(chkForward2.equals("1")){
                     // ��ȭ���϶� ������ȯ
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number4 +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 2 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number4 +"', 2, 0, '0000', '2400', '"+checkgroupid+"')";            	
     	
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
                     }
                 }else{
                 	// ��ȭ���϶� ������ȯ ����
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ����] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 } 
                 if(chkForward3.equals("1")){
                     // �ܸ�����϶� ������ȯ
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number5 +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 3 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number5 +"', 3, 0, '0000', '2400', '"+checkgroupid+"')";            	
     	
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ���] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
                     }                
                 }else{
                 	// �ܸ�����϶� ������ȯ ����
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 AND checkgroupid='"+checkgroupid+"'";	                
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[������ȯ ����] '","[Auth Properties Error] '")+strE164+l.x("'�� ������ȯ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     } 
                 }
 			 }//arrivalType.equals("2")
        }
	}
	if(stmt!=null) stmt.endTransaction(true);			// commit ó��
	
	if (e164s.length > 0) {
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+arrivalType+"\"]}");
	       		// ############### LogHistory ó��  ###############
	       		//logHistory.LogHistorySave(userID+"|83|������ȯ ("+strE164+" ��)|1|"+strIp);//���
// 	        	logHistory.LogHistorySave(userID+"|83|������ȯ ("+strE164+" ��)|3|"+strIp);//����
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        
        out.clear();
		if("insert".equals(procMode)){
%>
        <script>
            alert("�����Ǿ����ϴ�.");
            parent.goInsertDone(<%=jsArray.toString()%>);
            parent.hiddenAdCodeDiv();
        </script>
<%		
		}//else out.print(jsArray.toString());
		else {//update
%>
	        <script>
	            parent.goPopupInsertDone(<%=jsArray.toString()%>);
	        </script>
<%			
		}
	}	

}catch(Exception se){
	System.out.println("error-->" +se );
	if(stmt!=null) stmt.endTransaction(false);		// rollback ó��
	if(nModeDebug==1){
    	count = 1;
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
	}else{
		out.clear();
	    if(e164s.length>0){
%>
	        <script>
	            alert("���� �� ������ �߻��Ͽ����ϴ�.");
	            //parent.hiddenAdCodeDiv();
	        </script>
<%		
	    }
	    else out.print("NO");
	}
}finally{
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
}
%>
