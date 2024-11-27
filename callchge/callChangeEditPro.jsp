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

String 	e164 		= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr").trim();
String 	changeNum 	= new String(Str.CheckNullString(request.getParameter("changeNum")).getBytes("8859_1"), "euc-kr").trim();
String 	changeType 	= new String(Str.CheckNullString(request.getParameter("changeType")).getBytes("8859_1"), "euc-kr").trim();

String 	conditionType 	= new String(Str.CheckNullString(request.getParameter("conditionType")).getBytes("8859_1"), "euc-kr");	// 1 : 무조건 착신전환, 2 : 조건별 착신전화
String 	forwardingType 	= new String(Str.CheckNullString(request.getParameter("forwardingType")).getBytes("8859_1"), "euc-kr");	// 1 : 일자별 시간 조건, 2 : 요일별 시간 조건
String 	fDay 			= new String(Str.CheckNullString(request.getParameter("fDay")).getBytes("8859_1"), "euc-kr");				// 착신전화 일자
String 	fWeek 			= new String(Str.CheckNullString(request.getParameter("fWeek")).getBytes("8859_1"), "euc-kr");				// 착신전화 요일 (일월화수목금토)
String 	startTime 		= new String(Str.CheckNullString(request.getParameter("startTime")).getBytes("8859_1"), "euc-kr");			// 시작시간
String 	endTime 		= new String(Str.CheckNullString(request.getParameter("endTime")).getBytes("8859_1"), "euc-kr");			// 종료시간

String[] e164s = StringUtil.getParser(e164, "");
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// 로그인 ID
try{
		ResultSet	rs 				= null;
		String		sql				= "";		
		boolean 	returnVal 		= false;
		int 		totalCnt		= 0;
		
		DataStatement 	statement 	= null;
		try{
			AddServiceDAO dao 	= new AddServiceDAO();
			//returnVal = dao.callChangeNumberEdit_New(e164, changeNum, changeType, conditionType, forwardingType, fDay, fWeek, startTime, endTime);
	    	try {
		    	int       	nResult     = 0;
		        String    	fileName 	= "";
		        String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		    	// 서버로부터 DataStatement 객체를 할당
		    	statement 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
		    	statement.stxTransaction();
		    	
	            int cnt = 0;
	            
	            for(String strE164 : e164s){
	            	strE164 = strE164.trim();
	            	
		        	sql  = " SELECT count(*) FROM table_KeyNumberID WHERE KEYNUMBERID = '" + strE164 +"' ";
		    		
		            rs = statement.executeQuery(sql);
					if (rs.next()){ 
						cnt = Integer.parseInt(rs.getString(1));
					}
					rs.close();
		            
		            if (rs != null) 
		            	rs.close();
		        	
		            if (cnt > 0){
		            	if("1".equals(conditionType)){
		            		// 무조건 착신전화 (호전환)
		            		sql = " Update table_KeyNumberID Set forwardtype = 1, forwardnum = '" + changeNum + "' ";
		            		if("2".equals(changeType)){
				    			sql = sql + " , vmsforward = 1 ";
		            		}else{
		            			sql = sql + " , vmsforward = 0 ";
		            		}
			    			sql = sql + " WHERE KEYNUMBERID = '" + strE164 +"' ";
			    			nResult = statement.executeUpdate(sql);
			    			//if (nResult < 0){	throw new Exception(l.x("[대표번호 착신전환 번호 등록] '","[Auth Properties Error] '")+l.x("'대표번호 착신전환 번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
			    			
		                	sql = " delete from table_keynumberforward_days Where keynumber  = '" + strE164 + "' ";
		                	statement.executeUpdate(sql);
		                	sql = " delete from table_keynumberforward_week Where keynumber  = '" + strE164 + "' ";
		                	statement.executeUpdate(sql);
		                	
		            	}else{
		            		// 조건별 착신전화 (호전환)
		            		sql = " Update table_KeyNumberID Set forwardtype = 2 ";
		            		if("2".equals(changeType)){
				    			sql = sql + " , forwardnum = '', vmsforward = 1 ";
		            		}else{
		            			sql = sql + " , forwardnum = '', vmsforward = 0 ";
		            		}
			    			sql = sql + " WHERE KEYNUMBERID = '" + e164 +"' ";
			    			nResult = statement.executeUpdate(sql);
			    			//if (nResult < 0){	throw new Exception(l.x("[대표번호 착신전환 번호 등록] '","[Auth Properties Error] '")+l.x("'대표번호 착신전환 번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
			    			
			    			if("1".equals(forwardingType)){
			    				// 일자별 시간 조건
		                    	sql = " insert into table_keynumberforward_days(keynumber, forwardday, starttime, endtime, forwardnumber, vmsforward) ";
		                    	sql += "\n  values('" + strE164 + "', '" + fDay + "', '" + startTime + "', '" + endTime + "', '" + changeNum + "' ";
		                    	if("2".equals(changeType)){
		                    		sql += " , 1)";
		                    	}else{
		                    		sql += " , 0)";
		                    	}
		                    	statement.executeUpdate(sql);
			    			}else{	
			    				// 요일별 시간 조건
		                    	sql = " insert into table_keynumberforward_week(keynumber, dayoftheweek, starttime, endtime, forwardnumber,vmsforward) ";
		                    	sql += "\n  values('" + strE164 + "', '" + fWeek + "', '" + startTime + "', '" + endTime + "', '" + changeNum + "' ";
		                    	if("2".equals(changeType)){
		                    		sql += " , 1)";
		                    	}else{
		                    		sql += " , 0)";
		                    	}
		                    	statement.executeUpdate(sql);
			    			}
		            	}
		            }
			    	
		            statement.endTransaction(true);			// commit 처리
			        returnVal = true;
	            }//for
	        } catch (Exception e) {
	        	statement.endTransaction(false);		// rollback 처리
	            e.printStackTrace();
	            returnVal = false;
	        } finally {
	            //할당받은 DataStatement 객체는 반납
	            if (statement != null ) ConnectionManager.freeStatement(statement);
	        }

			if (returnVal){
				// ############### LogHistory 처리  #############
				/* String		strIp		= request.getRemoteAddr();
				LogHistory	logHistory 	= new LogHistory();
				int int_result = logHistory.LogHistorySave(userID+"|83|대표번호 조건별 착신전화 ("+e164+" 번)|3|"+strIp);
				 */
				if(1!=1)
				try{
			    	// 서버로부터 DataStatement 객체를 할당
			    	statement 	= ConnectionManager.allocStatement("EMS");
			    	statement.stxTransaction();
			    	//LogHistory	logHistory 	= new LogHistory();
			    	String strTmp = userID+"|83|대표번호 조건별 착신전화 |3|"+request.getRemoteAddr() ;
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
				        statement.executeUpdate(sql);
					}
					System.out.println("Log Save Success!!(web)");
					statement.endTransaction(true);			// commit 처리
		    	}catch(Exception e){
		    		statement.endTransaction(false);		// rollback 처리
		            e.printStackTrace();
		    	}finally {
		            //할당받은 DataStatement 객체는 반납
		            if (statement != null ){
		            	ConnectionManager.freeStatement(statement);
		            }
		        }
			 	// ##############################################
				
				out.clear();
				out.print("OK");
			}else{
				out.clear();
				out.print("NO");					
			}

		}catch(Exception se){
			System.out.println("error-->" +se );
			out.clear();
			out.print("NO");
		}finally{

		}	
	}catch(Exception ex){
		System.out.println(ex);
		out.clear();
		out.print("NO");
	}finally{
	} 
%>
