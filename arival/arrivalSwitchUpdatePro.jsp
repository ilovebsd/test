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

 String 	procMode		= new String(Str.CheckNullString(request.getParameter("procMode")).getBytes("8859_1"), "euc-kr");// 처리 모드 [insert, update]
 
 	String 	e164		= new String(Str.CheckNullString(request.getParameter("hiE164")).getBytes("8859_1"), "euc-kr");			// e164
	String 	arrivalType	= new String(Str.CheckNullString(request.getParameter("hiArrivalType")).getBytes("8859_1"), "euc-kr");	// 착신제한 유형
	String 	number1		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber1")).getBytes("8859_1"), "euc-kr");	// 착신전환 지정번호
	
	String 	chkForward0	= new String(Str.CheckNullString(request.getParameter("hiChkForward_0")).getBytes("8859_1"), "euc-kr");	// 조건부 착신전환 유형
	String 	number2		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber2")).getBytes("8859_1"), "euc-kr");	// 착신전환 지정번호
	String 	fromTime	= new String(Str.CheckNullString(request.getParameter("hiToTime")).getBytes("8859_1"), "euc-kr");		// 시작시간
	String 	toTime		= new String(Str.CheckNullString(request.getParameter("hiFromTime")).getBytes("8859_1"), "euc-kr");		// 종료시간
	
	String 	chkForward1	= new String(Str.CheckNullString(request.getParameter("hiChkForward_1")).getBytes("8859_1"), "euc-kr");	// 조건부 착신전환 유형
	String 	number3		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber3")).getBytes("8859_1"), "euc-kr");	// 착신전환 지정번호
	String 	waitTime	= new String(Str.CheckNullString(request.getParameter("hiwaitTime")).getBytes("8859_1"), "euc-kr");		// 대기시간
	
	String 	chkForward2	= new String(Str.CheckNullString(request.getParameter("hiChkForward_2")).getBytes("8859_1"), "euc-kr");	// 조건부 착신전환 유형
	String 	number4		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber4")).getBytes("8859_1"), "euc-kr");	// 착신전환 지정번호
				
	String 	chkForward3	= new String(Str.CheckNullString(request.getParameter("hiChkForward_3")).getBytes("8859_1"), "euc-kr");	// 조건부 착신전환 유형
	String 	number5		= new String(Str.CheckNullString(request.getParameter("hiTxtNumber5")).getBytes("8859_1"), "euc-kr");	// 착신전환 지정번호

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
	// 서버로부터 DataStatement 객체를 할당
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
        if (true){//등록
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
             if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                

             // 부서대표번호 음성사서함 착신전환 ----------------------
             if(!"3".equals(arrivalType)){
             	sql   = "Update table_keynumberid set forwardtype = 0 , forwardnum = '' WHERE forwardnum = '" + strE164 + "' AND checkgroupid='"+checkgroupid+"'";
             }
             System.out.println("2:"+sql);
             nResult = stmt.executeUpdate(sql);
             if (nResult < 0){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
             // ------------------------------------------------
             
             if(!arrivalType.equals("2")){
 	            // 부서대표번호 음성사서함 착신전환 ----------------------
 	        	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' AND checkgroupid='"+checkgroupid+"'";                
 	        	System.out.println("3:"+sql);
 	            nResult = stmt.executeUpdate(sql);
 	            if (nResult < 0){	throw new Exception(l.x("[착신전환 삭제] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 삭제가 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
             }
             
             if(arrivalType.equals("2")){
 				//returnVal2 = dao.forwardUpdateNew(e164, chkForward0, number2, toTime, fromTime, chkForward1, number3, waitTime, chkForward2, number4, chkForward3, number5);
            	 if(chkForward0.equals("1")){
                     if(!"".equals(number2) 
                    		 && "update".equals(procMode) ){
     	            	// 특정시간대별 착신전환 
     	            	int maxValue = dao.getMaxValue(stmt, strE164);
     	            	maxValue = maxValue+1;
     	            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', "+maxValue+", '"+ number2 +"', 0, 0, '"+ fromTime +"', '"+ toTime +"', '"+checkgroupid+"')";
     	            	
     	            	System.out.println("0:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
                     }
                 }else{
                 	// 특정시간대별 착신전환 삭제
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 0 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 0 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("0:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 삭제] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 삭제가 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 }
                 if(chkForward1.equals("1")){
                     // 무응답일때 착신전환
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number3 +"', forwardwaittime = '"+ waitTime +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 1 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number3 +"', 1, "+waitTime+", '0000', '2400', '"+checkgroupid+"')";
     	                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
                     }
                 }else{
                 	// 무응답일때 착신전환 삭제
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 1 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("1:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 삭제] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 삭제가 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 } 
                 if(chkForward2.equals("1")){
                     // 통화중일때 착신전환
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number4 +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 2 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number4 +"', 2, 0, '0000', '2400', '"+checkgroupid+"')";            	
     	
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
                     }
                 }else{
                 	// 통화중일때 착신전환 삭제
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 2 AND checkgroupid='"+checkgroupid+"'";                
     	            	System.out.println("2:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 삭제] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 삭제가 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     }
                 } 
                 if(chkForward3.equals("1")){
                     // 단말장애일때 착신전환
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){            
     	            	sql = "Update Table_Forward set forwardnumber = '"+ number5 +"' ";
     	            	sql = sql + " Where e164 = '" + strE164 +"' And forwardtype = 3 AND checkgroupid='"+checkgroupid+"'";
     	                
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
                     }else{            	
     	            	sql = "Insert Into Table_Forward(e164, ordernumber, forwardnumber, forwardtype, forwardwaittime, fromtime, totime, checkgroupid) ";
     	            	sql = sql + "Values('"+ strE164 +"', 1, '"+ number5 +"', 3, 0, '0000', '2400', '"+checkgroupid+"')";            	
     	
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 등록] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
                     }                
                 }else{
                 	// 단말장애일때 착신전환 삭제
                 	sql = "SELECT COUNT(*) FROM Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 ";
                     rs = stmt.executeQuery(sql);
                     if(rs.next()==true)	count = rs.getInt(1);
                     rs.close();
                     if (count > 0){                        	
     	            	sql = "Delete From Table_Forward Where e164 = '" + strE164 +"' And forwardtype = 3 AND checkgroupid='"+checkgroupid+"'";	                
     	            	System.out.println("3:"+sql);
     	                nResult = stmt.executeUpdate(sql);
     	                if (nResult < 1){	throw new Exception(l.x("[착신전환 삭제] '","[Auth Properties Error] '")+strE164+l.x("'는 착신전환 삭제가 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	            	
                     } 
                 }
 			 }//arrivalType.equals("2")
        }
	}
	if(stmt!=null) stmt.endTransaction(true);			// commit 처리
	
	if (e164s.length > 0) {
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+arrivalType+"\"]}");
	       		// ############### LogHistory 처리  ###############
	       		//logHistory.LogHistorySave(userID+"|83|착신전환 ("+strE164+" 번)|1|"+strIp);//등록
// 	        	logHistory.LogHistorySave(userID+"|83|착신전환 ("+strE164+" 번)|3|"+strIp);//수정
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        
        out.clear();
		if("insert".equals(procMode)){
%>
        <script>
            alert("수정되었습니다.");
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
	if(stmt!=null) stmt.endTransaction(false);		// rollback 처리
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
	            alert("수정 중 오류가 발생하였습니다.");
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
