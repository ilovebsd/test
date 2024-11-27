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
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;

String paramE164      = StringUtil.null2Str(request.getParameter("e164"),"");
String deleteStr = StringUtil.null2Str(request.getParameter("deleteStr"),"");	// ������ ��ȭ ���


String[] e164s = StringUtil.getParser(paramE164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;
ResultSet rs = null;

int count = 0;
String e164="", sql="";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //���� ó���κ�
    AddServiceDAO dao = new AddServiceDAO();
    //count = dao.callChangeNumberDelete(e164, request.getRemoteAddr(), userID)?1:0;
    if(e164s != null){
    	if(stmt!=null) stmt.stxTransaction();
    	
    	for(int k=0; k < e164s.length; k++){
			e164   = e164s[k];
			String 	forwardnum 	= "";
            int		forwardType	= 0;
            
        	//sql  = " SELECT forwardnum FROM table_KeyNumberID WHERE KEYNUMBERID = '" + e164 +"' ";
        	sql  = " SELECT forwardType FROM table_KeyNumberID WHERE KEYNUMBERID = '" + e164 +"' ";
        	System.out.println("sql :"+sql);
            rs = stmt.executeQuery(sql);
			if (rs.next()){ 
				//forwardnum 	= rs.getString(1);
				forwardType	= rs.getInt(1);
			}
            if (rs != null) 
            	rs.close();
        	
            //if (!"".equals(forwardnum) && forwardnum !=  null){
            if (forwardType==1 || forwardType == 2){
            	sql = " Update table_KeyNumberID Set forwardtype = 0, forwardnum = '', vmsforward = 0 "; 
    			sql = sql + " WHERE KEYNUMBERID = '" + e164 +"' ";
    			System.out.println("sql :"+sql);
    			count += stmt.executeUpdate(sql);
    			//if (nResult < 0){	throw new Exception(l.x("[��ǥ��ȣ ������ȯ ��ȣ ����] '","[Auth Properties Error] '")+l.x("'��ǥ��ȣ ������ȯ ��ȣ ������ �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
            
//	            int cnt = 0;
	            
//            	sql  = " SELECT count(*) FROM table_E164 WHERE e164 = '" + forwardnum +"' ";
        		
//                rs = statement.executeQuery(sql);
//				if (rs.next()){ 
//					cnt = Integer.parseInt(rs.getString(1));
//				}
//				rs.close();
                
//                if (rs != null) rs.close();
            	
//                if (cnt > 0){
//	    			String temp_AnswerService = "";
//                	sql = "SELECT answerservice FROM table_E164 WHERE e164 = '" + forwardnum + "'";
//                    rs = statement.executeQuery(sql);
//                    if (rs.next()) temp_AnswerService = rs.getString(1);
//                    rs.close();
//                    String answerService = temp_AnswerService.substring(0, 3) + "0" + temp_AnswerService.substring(4, 64);

//                	sql = " update table_e164 set Answerservice  = '" + answerService + "' ";
//                	sql += "\n  Where e164  = '" + forwardnum + "' ";
//                	statement.executeUpdate(sql);
//                }
                
                // ���Ǻ� ȣ��ȯ ���� �߰�
            	sql = " delete from table_keynumberforward_days Where keynumber  = '" + e164 + "' ";
            	System.out.println("sql :"+sql);
            	stmt.executeUpdate(sql);
            	
            	sql = " delete from table_keynumberforward_week Where keynumber  = '" + e164 + "' ";
            	System.out.println("sql :"+sql);
            	stmt.executeUpdate(sql);
            	
				// ############### LogHistory ó��  ###############
// 				int int_result = logHistory.LogHistorySave(userID+"|83|��ǥ��ȣ ������ȭ ("+e164+" ��)|2|"+strIp);
				// ##############################################
				
    			System.out.println("���� ����");
            }
		}//for
            
    	if(stmt!=null) stmt.endTransaction(true);
	}
    
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		//count += dao.deleteAll(stmt, strE164);
    		
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
} catch (Exception e) {
    if(stmt!=null) stmt.endTransaction(false);    
    
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
	}
} finally {
    //�Ҵ���� DataStatement ��ü�� �ݳ�
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
    
    if(/* count >= e164s.length */ count > 0 ){
    	//out.clear(); out.print("OK");    	
%>
   <script>
        alert("�����Ǿ����ϴ�.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
    	//out.clear(); out.print("NO");
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
}	
%>