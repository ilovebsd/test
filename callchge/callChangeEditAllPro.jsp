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
String 	changeType 		= new String(Str.CheckNullString(request.getParameter("hiChangeType")).getBytes("8859_1"), "euc-kr");	// 1 : �Ϲ�, 2 : VMS
String 	oldChangeNum 	= new String(Str.CheckNullString(request.getParameter("hiOldNumber")).getBytes("8859_1"), "euc-kr");

String[] e164s = StringUtil.getParser(e164, "");
StringBuffer jsArray = new StringBuffer();
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// �α��� ID
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
	    	// �����κ��� Datastmt ��ü�� �Ҵ�
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
    			//if (nResult < 0){	throw new Exception(l.x("[��ǥ��ȣ ������ȯ ��ȣ ���] '","[Auth Properties Error] '")+l.x("'��ǥ��ȣ ������ȯ ��ȣ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

    			
            	sql = " delete from table_keynumberforward_days Where keynumber  = '" + strE164 + "' ";
            	stmt.executeUpdate(sql);
            	sql = " delete from table_keynumberforward_week Where keynumber  = '" + strE164 + "' ";
            	stmt.executeUpdate(sql);
		    	
	            stmt.endTransaction(true);			// commit ó��
		        returnVal = true;
            }//for
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
			/* String		strIp		= request.getRemoteAddr();
			LogHistory	logHistory 	= new LogHistory();
			int int_result = logHistory.LogHistorySave(userID+"|83|��ǥ��ȣ ���Ǻ� ������ȭ ("+e164+" ��)|3|"+strIp);
			 */
			if(1!=1)
			try{
		    	// �����κ��� DataStatement ��ü�� �Ҵ�
		    	stmt 	= ConnectionManager.allocStatement("EMS");
		    	stmt.stxTransaction();
		    	//LogHistory	logHistory 	= new LogHistory();
		    	String strTmp = userID+"|83|��ǥ��ȣ ���Ǻ� ������ȭ |3|"+request.getRemoteAddr() ;
		    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
				String		userId 		= blockStr[0];
				int			categori	= Integer.parseInt(blockStr[1]);
				String		subject 	= blockStr[2];
				int			action		= Integer.parseInt(blockStr[3]);
				String		clientIp	= blockStr[4];
				//String sql;
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
        alert('��ϵǾ����ϴ�.');
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%		
}else{
%>
    <script>
        alert('��� �� ������ �߻��Ͽ����ϴ�.');
        parent.hiddenAdCodeDiv();
    </script>
<%		
}
%>

