<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet, business.LogHistory, business.CommonData"%>

<% 
HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String e164	= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");
String[] e164s  = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
	
        int count = 0;
        String sql="", sipEndpointId="";
        String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
        try {       
        	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
            if (stmt != null){
//             		AddServiceDAO dao 	= new AddServiceDAO();
            		// ############### LogHistory 처리  ###############
// 					LogHistory	logHistory 	= new LogHistory();
					// ##############################################
            		
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
            			
    	            	sql = " INSERT INTO Table_FeatureService ( E164, ServiceNo, PRIORITY , userparam, InOutFlag, ServiceType, ErrorControl, checkgroupid ) "; 
    	            	sql += "\n VALUES ('" + strE164 + "', 5511, 5511, '001',2,1, 0, '"+authGroupid+"' ) ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	sql = " Update table_sipendpoint Set ZONECODE = 'Z0001' Where endpointid = '" + strE164 + sipEndpointId + "' ";
    	            	System.out.println("sql :"+sql);
    	            	stmt.executeUpdate(sql);
    	            	
    	            	/***** SSW 처리(090615) ********/
    	                int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2, strE164 + sipEndpointId," ",  "(SSW).active" );
    	                
    					// ############### LogHistory 처리  ###############
//     					logHistory.LogHistorySave(userID+"|83|원넘버멀티폰 ("+strE164+" 번)|1|"+strIp);
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
        
        if(count > 0){
        	if (e164s.length > 0) {
        		for(String strE164 : e164s)
        	       	if( (strE164 = strE164.trim()).length()>0 ){
        	       		if(jsArray.length()==0)	jsArray.append("[{params:");
        	       		else					jsArray.append(",{params:");
        	       		
        	       		jsArray.append("[\""+strE164+"\",\"\"]}");
        	       	}
                if(jsArray.length()>0)	jsArray.append("]");
        	}	
%>
    <script>
        alert("저장되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
        }else{
%>
    <script>
        alert("저장이 실패하였습니다.");
    </script>
<%
        }
%>

