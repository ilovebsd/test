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

// 서버로부터 DataStatement 객체를 할당
try{
    //삭제 처리부분
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
        			String 			domainid 	= commonData.getDomain(stmt);			// 도메인ID 조회

        			String[]		tempDomain;
        			if(!"".equals(domainid)){
        				tempDomain 		= domainid.split("[.]");
        				domainid		= tempDomain[0];
        				sipEndpointId 	= "@" + domainid + ".callbox.kt.com:5060";
        			} 
        			
            		// 트랜잭션 시작
    				stmt.stxTransaction();
            		for(String strE164 : e164s){
            			strE164 = strE164.trim();
            			
    	            	sql = " DELETE FROM Table_FeatureService WHERE E164 = '" + strE164 + "' AND ServiceNo = 5511 ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	sql = " Update table_sipendpoint Set ZONECODE = '' Where endpointid = '" + strE164 + sipEndpointId + "' ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	/***** SSW 처리(090615) ********/
    	                int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2, strE164 + sipEndpointId," ",  "(SSW).active" );
    	                
    					// ############### LogHistory 처리  ###############
//     					LogHistory	logHistory 	= new LogHistory();
//     					logHistory.LogHistorySave(userID+"|83|원넘버멀티폰 ("+strE164+" 번)|1|"+strIp);
						// ##############################################
            		}
					stmt.endTransaction(true);
					count = 1 ;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback 처리
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
        alert("삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
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
    	alert("삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {}	
%>