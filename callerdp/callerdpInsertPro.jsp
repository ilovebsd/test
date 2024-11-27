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
        String sql="";//, sipEndpointId="";
        ResultSet rs=null;
        String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
        try {       
        	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
            if (stmt != null){
//             		AddServiceDAO dao 	= new AddServiceDAO();
            		// ############### LogHistory 처리  ###############
// 					LogHistory	logHistory 	= new LogHistory();
					// ##############################################
            		/* 
					String strIp = request.getRemoteAddr() ;
					
            		CommonData		commonData	= new CommonData();
        			String 			domainid 	= commonData.getDomain(stmt);			// 도메인ID 조회

        			String[]		tempDomain;
        			if(!"".equals(domainid)){
        				tempDomain 		= domainid.split("[.]");
        				domainid		= tempDomain[0];
        				sipEndpointId 	= "@" + domainid + ".callbox.kt.com:5060";
        			}
        			 */
        			String temp_AnswerService = "", answerService = "";
		            
            		// 트랜잭션 시작
    				stmt.stxTransaction();
            		for(String strE164 : e164s){
            			strE164 = strE164.trim();
            			
            			if(1==1){
            				sql = " DELETE FROM Table_FeatureService Where ServiceNo = 5561 AND E164 = '" + strE164 + "' ; ";
            				System.out.println("sql :"+ sql);
	    	            	stmt.executeUpdate(sql);
	    	            	
	    	            	sql = " INSERT INTO Table_FeatureService ";
	    	            	sql += " (E164,ServiceNo,PRIORITY,UserParam, InOutFlag,ServiceType,ErrorControl,Protocol,CheckGroupID) ";
	    	            	sql += " VALUES ('" + strE164 + "',5561,1,'',1,1,0,2,'IPCS') ; ";
	    	            	System.out.println("sql :"+ sql);
	    	            	stmt.executeUpdate(sql);
            			}else{
	            			sql = "SELECT answerservice FROM table_E164 WHERE e164 = '" + strE164 + "'";
	    		            rs = stmt.executeQuery(sql);
	    		            if (rs.next()) temp_AnswerService = rs.getString(1);
	    		            rs.close();                    	
	    		            answerService = temp_AnswerService.substring(0, 7) + "1" + temp_AnswerService.substring(8, 64);
	    	
	    	            	sql = " Update table_E164 Set answerservice = '" + answerService + "' Where e164 = '" + strE164 + "' ";
	    	            	stmt.executeUpdate(sql);
	    	            	
	    	            	sql = " Update table_sipendpoint Set multiendpoint = 1 Where endpointid = '" + strE164 + "' ";
	    	            	stmt.executeUpdate(sql);
	    	            	
	    	            	/***** SSW 처리(090615) ********/
// 	    	                int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2, strE164," ",  "(SSW).active" );
	    	                
	    					// ############### LogHistory 처리  ###############
	//     					logHistory.LogHistorySave(userID+"|83|원넘버멀티폰 ("+strE164+" 번)|1|"+strIp);
            			}
            		}
					stmt.endTransaction(true);
					count = 1 ;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback 처리
        	e.printStackTrace();
        	count = 0 ;
        } finally {
            try {
                if (rs != null) rs.close();                
            } catch (Exception e) {}
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

