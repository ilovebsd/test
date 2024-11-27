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
 
String 	callBlockType 	= new String(Str.CheckNullString(request.getParameter("callBlockType")).getBytes("8859_1"), "euc-kr").trim();
//callBlockType 	= new String(Str.CheckNullString(request.getParameter("radioType1")).getBytes("8859_1"), "euc-kr");		//
String 	e164 			= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");		// 
String 	prefixType 		= new String(Str.CheckNullString(request.getParameter("prefixType")).getBytes("8859_1"), "euc-kr");
String 	blockType 		= new String(Str.CheckNullString(request.getParameter("blockType")).getBytes("8859_1"), "euc-kr");
String 	blockE164 		= new String(Str.CheckNullString(request.getParameter("blockE164")).getBytes("8859_1"), "euc-kr");
//String 	note 			= new String(Str.CheckNullString(request.getParameter("note")).getBytes("8859_1"), "euc-kr");
String 	note			= Str.CheckNullString(request.getParameter("note"));

// String 	note 			= StringUtil.null2Str(request.getParameter("note"),"");
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

DataStatement 	stmt 	= null;
try{
		ResultSet	rs 				= null;
		String		sql				= "";		
		boolean 	returnVal 		= false;
		int 		totalCnt		= 0;
		
		String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
		StringBuffer jsArray = new StringBuffer();
		
		try{
			AddServiceDAO dao 	= new AddServiceDAO();
			//returnVal = dao.callBlockEdit(e164, callBlockType, prefixType, blockType, blockE164, note, authGroupid);

			try {
		    	int       	nResult     	= 0;
		    	String 		startprefix		= blockE164;
		    	String		endprefix		= "", strTemp 		= "", callerService 	= "";
		    	
		    	if("3".equals(callBlockType)||"1".equals(callBlockType)){
		    		if(!"".equals(blockE164)){
				        endprefix = "________________________________";
				        if("#, *".equals(startprefix)){//if special code 
							startprefix = "#";
							endprefix = "*" + endprefix.substring(1);
				        }else if(blockE164.length() < 32) {
				            int nLength = blockE164.length();
				            endprefix = blockE164 + endprefix.substring(nLength);
				        }
				        else if (blockE164.length() == 32 )
				            endprefix = blockE164 ;
		    		}
		    	}
		    	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		    	// 서버로부터 DataStatement 객체를 할당
		    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
		    	stmt.stxTransaction();
		    	
		    	for(String strE164 : e164s){
		    		strE164 = strE164.trim();
		    		
		    		sql  = " SELECT callerservice FROM table_e164 WHERE e164 = '" + strE164 +"' ";
		    		System.out.println("SQL :\n"+sql);
		            rs = stmt.executeQuery(sql);
					if (rs.next()){ 
						strTemp = rs.getString(1);
					}
					rs.close();
		            if (rs != null) rs.close();
		        	
		            if (!"".equals(strTemp) && strTemp!=null){
		            	callerService = strTemp.substring(0, 1) + callBlockType + strTemp.substring(2, 64);
		            	
		                sql = "\n Update table_E164 set callerservice  = '" + callerService + "' ";
		                sql = sql + "\n  WHERE e164 = '" + strE164 +"' ";
		                System.out.println("SQL :\n"+sql);
		                nResult = stmt.executeUpdate(sql);
		    			//if (nResult < 0){	throw new Exception(l.x("[CallBlock 등록] '","[CallBlock Properties Error] '")+l.x("'CallBlock 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		
		    			//if("3".equals(callBlockType)){
		    			if("3".equals(callBlockType)||"1".equals(callBlockType)){
		    				if(!"".equals(blockE164)){
	    						sql = " Insert into Table_E164block(e164, inoutflag, startprefix, endprefix, prefixtype, blockidtype, description, checkgroupid) ";
					            sql = sql + " Values('" + strE164 + "', 0, '" + startprefix + "', '" + endprefix + "', " + prefixType + ", " + blockType + ", '" + note + "', '"+authGroupid+"') ";
					            System.out.println("SQL :\n"+sql);
					            stmt.executeUpdate(sql);
		    				}
		    			}else{
		                	sql = " Delete From table_e164block Where e164 = '" + e164 +"' ";
		                	System.out.println("SQL :\n"+sql);
		                	stmt.executeUpdate(sql);
		    			}
		            }
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

				out.clear();
				if(!bModify){
					for(String strE164 : e164s)
				       	if( (strE164 = strE164.trim()).length()>0 ){
				       		if(jsArray.length()==0)	jsArray.append("[{params:");
				       		else					jsArray.append(",{params:");
				       		
				       		jsArray.append("[\""+strE164+"\",\""+callBlockType+"\"]}");
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
		    	for(String strE164 : e164s)
			       	if( (strE164 = strE164.trim()).length()>0 ){
			       		if(jsArray.length()==0)	jsArray.append("[{params:");
			       		else					jsArray.append(",{params:");
			       		
			       		jsArray.append("[\""+strE164+"\",\""+callBlockType+"\"]}");
			       	}
		        if(jsArray.length()>0)	jsArray.append("]");
		        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
		     	
		        out.clear();
		        if(!bModify) out.print(jsArray.toString());
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
