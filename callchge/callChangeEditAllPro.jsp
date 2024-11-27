<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="business.LogHistory"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses 	= request.getSession();
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String checkgroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String 	userID		= (String)ses.getAttribute("login.user") ; 

String 	e164 			= new String(Str.CheckNullString(request.getParameter("hiE164")).getBytes("8859_1"), "euc-kr");			// 
String 	changeNum 		= new String(Str.CheckNullString(request.getParameter("hiNumber")).getBytes("8859_1"), "euc-kr");		// 
String 	changeType 		= new String(Str.CheckNullString(request.getParameter("hiChangeType")).getBytes("8859_1"), "euc-kr");	// 1 : 일반, 2 : VMS
String 	oldChangeNum 	= new String(Str.CheckNullString(request.getParameter("hiOldNumber")).getBytes("8859_1"), "euc-kr");

String[] e164s = StringUtil.getParser(e164, "");
StringBuffer jsArray = new StringBuffer();
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// 로그인 ID
boolean 	returnVal 		= false;
try{
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		totalCnt		= 0;
		
		DataStatement 	stmt 	= null;
		//AddServiceDAO dao 	= new AddServiceDAO();
		//returnVal = dao.callChangeNumberEdit(e164, changeNum, changeType, oldChangeNum);
		//returnVal = dao.callChangeNumberEdit2(e164, changeNum, changeType);
    	try {
	    	int       	nResult     = 0;
	        String    	fileName 	= "";
	        String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	    	// 서버로부터 Datastmt 객체를 할당
	    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	    	stmt.stxTransaction();
	    	
            int cnt = 0;
            
            for(String strE164 : e164s){
            	sql = " Update table_KeyNumberID Set forwardtype = 1, forwardnum = '" + changeNum + "' ";
        		if("2".equals(changeType)){
        			sql = sql + " , vmsforward = 1 ";
        		}else{
        			sql = sql + " , vmsforward = 0 ";
        		}
    			sql = sql + " WHERE KEYNUMBERID = '" + strE164 +"' ";
    			nResult = stmt.executeUpdate(sql);
    			//if (nResult < 0){	throw new Exception(l.x("[대표번호 착신전환 번호 등록] '","[Auth Properties Error] '")+l.x("'대표번호 착신전환 번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

    			
            	sql = " delete from table_keynumberforward_days Where keynumber  = '" + strE164 + "' ";
            	stmt.executeUpdate(sql);
            	sql = " delete from table_keynumberforward_week Where keynumber  = '" + strE164 + "' ";
            	stmt.executeUpdate(sql);
		    	
	            stmt.endTransaction(true);			// commit 처리
		        returnVal = true;
            }//for
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback 처리
            e.printStackTrace();
            returnVal = false;
        } finally {
            //할당받은 DataStatement 객체는 반납
            if (stmt != null ) ConnectionManager.freeStatement(stmt);
        }

		if (returnVal){
			// ############### LogHistory 처리  #############
			/* String		strIp		= request.getRemoteAddr();
			LogHistory	logHistory 	= new LogHistory();
			int int_result = logHistory.LogHistorySave(userID+"|83|대표번호 조건별 착신전화 ("+e164+" 번)|3|"+strIp);
			 */
			if(1!=1)
			try{
		    	// 서버로부터 DataStatement 객체를 할당
		    	stmt 	= ConnectionManager.allocStatement("EMS");
		    	stmt.stxTransaction();
		    	//LogHistory	logHistory 	= new LogHistory();
		    	String strTmp = userID+"|83|대표번호 조건별 착신전화 |3|"+request.getRemoteAddr() ;
		    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
				String		userId 		= blockStr[0];
				int			categori	= Integer.parseInt(blockStr[1]);
				String		subject 	= blockStr[2];
				int			action		= Integer.parseInt(blockStr[3]);
				String		clientIp	= blockStr[4];
				//String sql;
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
		 	
			//out.clear();out.print("OK");
		}
}catch(Exception ex){
	System.out.println("error-->");
	ex.printStackTrace() ;
}finally{
	
}

if(returnVal){
	
	for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		
    		jsArray.append("[\""+strE164+"\",\""+changeNum+"\",\""+changeType+"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
%>
	<script>
        alert('등록되었습니다.');
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%		
}else{
%>
    <script>
        alert('등록 중 오류가 발생하였습니다.');
        parent.hiddenAdCodeDiv();
    </script>
<%		
}
%>

