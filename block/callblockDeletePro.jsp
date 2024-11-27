<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.List"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="java.sql.*, business.LogHistory, acromate.*"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user");
String checkgroupid = (String)ses.getAttribute("login.name");

String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String startprefix = StringUtil.null2Str(request.getParameter("prefix"),"");

String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;

try{
	//stmt 			= ConnectionManager.allocStatement("SSW");
    //���� ó���κ�
    AddServiceDAO dao 	= new AddServiceDAO();
    
    int count = 0 ;
    
    boolean 		returnVal 	= false;
    ResultSet 	rs 				= null;
   	try {
		String		sql 			= "";
    	int       	nResult     	= 0;
    	int 		cnt 			= 0;
    	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
    	// �����κ��� DataStatement ��ü�� �Ҵ�
    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    	
    	if("#, *".equals(startprefix)){//if special code 
			startprefix = "#";
        }
        	
    	stmt.stxTransaction();
    	
    	for(String strE164 : e164s)
        	if( (strE164 = strE164.trim()).length()>0 ){
        		if(jsArray.length()==0)	jsArray.append("[{params:");
           		else					jsArray.append(",{params:");
//         		count += dao.callBlockDelete(strE164, startprefix, request.getRemoteAddr(), userID) ?1:0;
        		
				//sql = " Delete From table_e164block Where e164 = '" + e164 +"' and inoutflag = 0 and startprefix = '" + blockE164 +"' ";
				sql = " Delete From table_e164block Where e164 = '" + strE164 +"' AND inoutflag = 0 AND checkgroupid='"+checkgroupid+"' ";
				if(startprefix.length()>0) sql += " AND startprefix = '" + startprefix +"' ";
				System.out.println("SQL :\n"+sql);
				stmt.executeUpdate(sql);
				
				if(startprefix.length()==0){
					String 	callerService 	= "", strTemp="";
	            	sql  = " SELECT callerservice FROM table_e164 WHERE e164 = '" + strE164 +"' AND checkgroupid='"+checkgroupid+"' ";
	            	System.out.println("SQL :\n"+sql);
	                rs = stmt.executeQuery(sql);
					if (rs.next()){ 
						strTemp = rs.getString(1);
					}
					rs.close();
	                if (rs != null) rs.close();
	                
	                if (!"".equals(strTemp) && strTemp!=null){
                    	callerService = strTemp.substring(0, 1) + "0" + strTemp.substring(2, 64);
                    	
                        sql = "\n Update table_E164 set callerservice  = '" + callerService + "' ";
                        sql = sql + "\n  WHERE e164 = '" + strE164 +"' AND checkgroupid='"+checkgroupid+"' ";
                        System.out.println("SQL :\n"+sql);
                        nResult = stmt.executeUpdate(sql);
		    			if (nResult < 0){	throw new Exception(l.x("[CallBlock ���] '","[CallBlock Properties Error] '")+l.x("'CallBlock ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

// 		    			sql = " Delete From table_e164block Where e164 = '" + strE164 +"'  And inoutflag = 0 ";
// 		    			stmt.executeUpdate(sql);
			        	
                    }
				}
            	
            	jsArray.append("[\""+strE164+"\",\""+startprefix+"\"]}");
        		count += 1;
           	}

        stmt.endTransaction(true);			// commit ó��
        returnVal = true;
    } catch (Exception e) {
    	stmt.endTransaction(false);		// rollback ó��
        e.printStackTrace();
        returnVal = false;
    } finally {
    	if (rs != null) rs.close();
        //�Ҵ���� DataStatement ��ü�� �ݳ�
        if (stmt != null ) ConnectionManager.freeStatement(stmt);
        
        if(returnVal){
	    	// ############### LogHistory ó��  ###############
	    	if(1!=1)
		    try{
		    	// �����κ��� DataStatement ��ü�� �Ҵ�
		    	stmt 	= ConnectionManager.allocStatement("EMS");
		    	stmt.stxTransaction();
		    	//LogHistory	logHistory 	= new LogHistory();
		    	String strTmp = userID+"|83|�߽����� "+(startprefix.length()==0?"��ȣ����":"")+"|2|"+request.getRemoteAddr() ;
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
    	}//
    }
    
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){

    	if(startprefix.length()>0) {
    		out.clear();
    		out.print(jsArray.toString()) ;
    	}else{
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
    	if(startprefix.length()>0) {
    		out.clear();
    		out.print("NO") ;
    	}else{
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    	}
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
}	
%>