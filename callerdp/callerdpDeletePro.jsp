<%@page import="business.LogHistory"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;

String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

try{
    //���� ó���κ�
//     AddServiceDAO dao 	= new AddServiceDAO();
    int count = 0 ;
 	// ############### LogHistory ó��  ###############
	//returnVal = dao.forkingDelete(deleteStr);
// 	count += dao.forkingDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################	
	
		// ############### LogHistory ó��  ###############
// 			LogHistory	logHistory 	= new LogHistory();
// 			String strIp = request.getRemoteAddr() ;
		// ##############################################
					
		//�����κ��� DataStatement ��ü�� �Ҵ�
		DataStatement stmt = null;
	
        String sql="";
        ResultSet rs=null;
        String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
        try {       
        	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
            if (stmt != null){
            		// Ʈ����� ����
    				stmt.stxTransaction();
            		for(String strE164 : e164s){
            			strE164 = strE164.trim();
            			
           				sql = " DELETE FROM Table_FeatureService Where ServiceNo = 5561 AND E164 = '" + strE164 + "' ; ";
           				System.out.println("sql :"+ sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	/***** SSW ó��(090615) ********/
//     	            	 int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2,e164 + sipEndpointId," ",  "(SSW).active" );

    					// ############### LogHistory ó��  ###############
// 	    					logHistory.LogHistorySave(userID+"|83|���ѹ���Ƽ�� ("+strE164+" ��)|1|"+strIp);
            		}
					stmt.endTransaction(true);
					count = 1 ;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback ó��
        	e.printStackTrace();
        	count = 0 ;
        } finally {
            try {
                if (rs != null) rs.close();                
            } catch (Exception e) {}
            if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
        }
        
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(/* count >= e164s.length */ count > 0){
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
} finally {}	
%>