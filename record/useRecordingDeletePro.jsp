<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet, business.LogHistory, business.CommonData"%>

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

// �����κ��� DataStatement ��ü�� �Ҵ�
try{
    //���� ó���κ�
    int count = 0 ;
	DataStatement stmt = null;
	String sql="", sipEndpointId="";
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
        try {       
        	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
            if (stmt != null){
//             		AddServiceDAO dao 	= new AddServiceDAO();
            		
					String strIp = request.getRemoteAddr() ;
					
            		CommonData		commonData	= new CommonData();
        			String 			domainid 	= commonData.getDomain(stmt);			// ������ID ��ȸ

        			String[]		tempDomain;
        			if(!"".equals(domainid)){
        				tempDomain 		= domainid.split("[.]");
        				domainid		= tempDomain[0];
        				sipEndpointId 	= "@" + domainid + ".callbox.kt.com:5060";
        			} 
        			
            		// Ʈ����� ����
    				stmt.stxTransaction();
            		for(String strE164 : e164s){
            			strE164 = strE164.trim();
            			
    	            	sql = " DELETE FROM Table_FeatureService WHERE E164 = '" + strE164 + "' AND ServiceNo = 5511 ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	sql = " Update table_sipendpoint Set ZONECODE = '' Where endpointid = '" + strE164 + sipEndpointId + "' ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	/***** SSW ó��(090615) ********/
    	                int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2, strE164 + sipEndpointId," ",  "(SSW).active" );
    	                
    					// ############### LogHistory ó��  ###############
//     					LogHistory	logHistory 	= new LogHistory();
//     					logHistory.LogHistorySave(userID+"|83|���ѹ���Ƽ�� ("+strE164+" ��)|1|"+strIp);
						// ##############################################
            		}
					stmt.endTransaction(true);
					count = 1 ;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback ó��
        	e.printStackTrace();
        	count = 0 ;
        } finally {
            if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
        }
	
	
	// ##############################################
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