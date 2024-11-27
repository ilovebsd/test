<%@page import="com.acromate.dto.element.E164RouteDTO"%>
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
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");
 */
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;

boolean bModify = !"1".equals( (String)request.getParameter("procmode") );
 
String 	insertStr	= new String(Str.CheckNullString(request.getParameter("insertStr")).getBytes("8859_1"), "euc-kr");	//
String  extensionNum = "";
String  hiOldExtension = "";

DataStatement 	stmt 	= null;
try{
		ResultSet	rs 				= null;
		String		sql				= "";		
		boolean 	returnVal 		= false;
		int 		totalCnt		= 0;
		
		String[] params = StringUtil.getParser(insertStr, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
		StringBuffer jsArray = new StringBuffer();
		
		try{
// 			AddServiceDAO dao 	= new AddServiceDAO();
			//returnVal = dao.callBlockEdit(e164, callBlockType, prefixType, blockType, blockE164, note, authGroupid);

			try {
		    	int       	nResult     	= 0;
		    	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		    	// 서버로부터 DataStatement 객체를 할당
		    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
		    	
		    	String groupExtCode = "";
		    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+authGroupid+"' ";
		    	System.out.println("SQL : "+sql);
		    	rs = stmt.executeQuery(sql);
		        if (rs.next()) groupExtCode = rs.getString(1); 
		        if(rs!=null) rs.close();
		        
		        int idxE164 = -1, idxValue = -1;
		        String e164="";
		        
		        if(stmt!=null) stmt.stxTransaction();
		    	
		    	for(String strParam : params){
		    		strParam = strParam.trim();
		    		if( (idxE164=strParam.indexOf(':'))==-1 
		    				|| (idxValue=strParam.indexOf(','))==-1) 
		    			continue;
		    		
		    		e164 = strParam.substring(0, idxE164);
		    		hiOldExtension = strParam.substring(idxE164+1, idxValue).trim();
		    		extensionNum = strParam.substring(idxValue+1).trim();
		    		
		    		if(hiOldExtension.equals(extensionNum))	continue;
		    		
		    		if(1==1){
		    			System.out.println("e164-->" +e164 );
		    			System.out.println("hiOldExtension-->" +hiOldExtension );
		    			System.out.println("extensionNum-->" +extensionNum +"\n" );
		    			//continue ;
		    		}
		    		
		            sql = "\n UPDATE table_subscriber ";
		            sql += "\n SET extension = '" + extensionNum +"' ";
		            sql += "\n WHERE phonenum = '" + e164 +"' "; 
		            System.out.println("SQL : "+sql);
		            nResult = stmt.executeUpdate(sql);
		    		//if (nResult < 0){	throw new Exception(l.x("[CallBlock 등록] '","[CallBlock Properties Error] '")+l.x("'CallBlock 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		    		
		    		sql = "\n UPDATE TABLE_E164 ";
		            sql += "\n SET extensionnumber = '" + extensionNum +"' ";
		            sql += "\n WHERE e164 = '" + e164 +"' "; 
		            System.out.println("SQL : "+sql);
		            nResult = stmt.executeUpdate(sql);
		    		//if (nResult < 0){	throw new Exception(l.x("[CallBlock 등록] '","[CallBlock Properties Error] '")+l.x("'CallBlock 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		    		
		    		if(1!=1){
				    	sql = "SELECT E164, EndpointID, EndpointType, RoutingNumber, RoutingNumberType, Protocol, Priority ";
				    	sql += "\n FROM table_e164route " ;
				    	sql += "\n WHERE routingnumber = '"+groupExtCode + hiOldExtension+"' " ;
				    	System.out.println("SQL : "+sql);
				    	rs = stmt.executeQuery(sql);
				    	E164RouteDTO dto = null;
				        if (rs.next()) {
				        	dto = new E164RouteDTO();
				        	dto.setE164( Str.CheckNullString(rs.getString("E164") ) );
				        	dto.setEndpointID( Str.CheckNullString(rs.getString("EndpointID") ) );
				        	dto.setEndpointType( Str.CheckNullInt(rs.getString("EndpointType") ) );
				        	dto.setRoutingNumber( Str.CheckNullString(rs.getString("RoutingNumber") ) );
				        	dto.setRoutingNumberType( Str.CheckNullInt(rs.getString("RoutingNumberType") ) );
				        	dto.setProtocol( Str.CheckNullInt(rs.getString("Protocol") ) );
				        	dto.setPriority( Str.CheckNullInt(rs.getString("Priority") ) );
				        }
				        if(rs!=null) rs.close();
			    		
				        if(dto!=null){
				        	sql = "\n DELETE FROM table_e164route ";
					    	sql += "\n WHERE routingnumber = '"+groupExtCode + hiOldExtension+"' " ;
		 		            System.out.println("SQL : "+sql);
		 		            nResult = stmt.executeUpdate(sql);
		 		            
				        	String strExtension = /* "99"+ */groupExtCode + extensionNum;
				        	dto.setRoutingNumber(strExtension);
				        	sql = "\n INSERT INTO table_e164route ";
				        	sql += "\n (E164, EndpointID, EndpointType, RoutingNumber, RoutingNumberType, Protocol, Priority) " ;
				        	sql += "\n VALUES ( " ;
				        	sql += "\n '" + dto.getE164() + "' " ;
				        	sql += "\n , '" + dto.getEndpointID() + "' " ;
				        	sql += "\n , " + dto.getEndpointType() + " " ;
				        	sql += "\n , '" + dto.getRoutingNumber() + "' " ;
				        	sql += "\n , " + dto.getRoutingNumberType() + " " ;
				        	sql += "\n , " + dto.getProtocol() + " " ;
				        	sql += "\n , " + dto.getPriority() + " " ;
		 		           	sql += "\n ) " ;
		 		            System.out.println("SQL : "+sql);
		 		            nResult = stmt.executeUpdate(sql);
				        }
		    		}
		    		/***** table_e164route 에서 routingnumber 수정 ********/
		            String strExtension = /* "99"+ */groupExtCode + extensionNum;
		            sql = "\n UPDATE table_e164route ";
		            sql += "\n SET routingnumber = '" + strExtension + "' " ;
		            //sql += "\n WHERE routingnumber = '"+groupExtCode + hiOldExtension+"' " ;
		            sql += "\n WHERE e164 = '"+e164+"' AND RoutingNumberType = 5 " ;
		            System.out.println("SQL : "+sql);
		            nResult = stmt.executeUpdate(sql);
		            //if (nResult < 0){	throw new Exception(l.x("[CallBlock 등록] '","[CallBlock Properties Error] '")+l.x("'CallBlock 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		
		    	}//for
		    	
		    	stmt.endTransaction(true);			// commit 처리
		        returnVal = true;
		        
	        } catch (Exception e) {
	        	stmt.endTransaction(false);		// rollback 처리
	            e.printStackTrace();
	            returnVal = false;
	        } finally {
	            //할당받은 DataStatement 객체는 반납
	            if (stmt != null ) ConnectionManager.freeStatement(stmt);
	        }
        
			if (returnVal){
				// ############### LogHistory 처리  ###############
				if(1!=1)
    		    try{
    		    	// 서버로부터 DataStatement 객체를 할당
    		    	stmt 	= ConnectionManager.allocStatement("EMS");
    		    	stmt.stxTransaction();
    		    	//LogHistory	logHistory 	= new LogHistory();
    		    	String strTmp = userID+"|83|발신제한 |3|"+request.getRemoteAddr() ;
    		    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
    				String		userId 		= blockStr[0];
    				int			categori	= Integer.parseInt(blockStr[1]);
    				String		subject 	= blockStr[2];
    				int			action		= Integer.parseInt(blockStr[3]);
    				String		clientIp	= blockStr[4];
    				//String sql;
    				for(String num : params){
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

				out.clear();
				if(1!=1&& !bModify){
					for(String strParam : params)
				       	if( (strParam = strParam.trim()).length()>0 ){
				       		if(jsArray.length()==0)	jsArray.append("[{params:");
				       		else					jsArray.append(",{params:");
				       		
				       		jsArray.append("[\""+strParam+"\",\""+""+"\"]}");
				       	}
			        if(jsArray.length()>0)	jsArray.append("]");
			        out.print(jsArray.toString());
				}else
					out.print("OK");
			}else{
				out.clear();
				out.print("NO");					
			}

		}catch(Exception se){
			System.out.println("error-->" +se );
			if(nModeDebug==1){
		    	/* for(String strParam : params)
			       	if( (strParam = strParam.trim()).length()>0 ){
			       		if(jsArray.length()==0)	jsArray.append("[{params:");
			       		else					jsArray.append(",{params:");
			       		
			       		jsArray.append("[\""+strParam+"\",\""+""+"\"]}");
			       	}
		        if(jsArray.length()>0)	jsArray.append("]");
		         */
		        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
		     	
		        out.clear();
		        if(1!=1&& !bModify) out.print(jsArray.toString());
		        else out.print("OK");
		        return;
			}
			out.clear();
			out.print("NO");
		}finally{}	
	}catch(Exception ex){
		System.out.println(ex);
	}finally{
	} 
%>
