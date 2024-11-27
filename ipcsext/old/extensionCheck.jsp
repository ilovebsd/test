<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>

<%
	try{
		String 		hiExtension 	= request.getParameter("hiExtension");
		String 		hiE164 			= request.getParameter("hiEi64");
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		int 		cnt2			= 0;
		int 		cnt3			= 0;
		int 		cnt4			= 0;
		int 		cnt5			= 0;
		
		// 서버로부터 DataStatement 객체를 할당
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");		
		
		System.out.println("SQL 검색조건 : "+hiExtension);
		
		try{
			if (stmt != null) {
				// table_e164 중복 체크
				sql	="Select count(*) From table_e164 Where extensionnumber = '" + hiExtension + "'";
				rs = stmt.executeQuery(sql);
				
				System.out.println("사용 SQL : "+sql);
				
				if (rs.next()){ 
					cnt = Integer.parseInt(rs.getString(1));
				}
				rs.close();
				
				if (cnt > 0){
				%>				
					NO1
				<%
				}else{
					// table_e164route 중복 체크
					sql	="Select count(*) From table_e164route Where routingnumber = '99"+hiExtension+"'";
					rs = stmt.executeQuery(sql);
					
					System.out.println("사용 SQL2 : "+sql);
					
					if (rs.next()){ 
						cnt2 = Integer.parseInt(rs.getString(1));
					}
					rs.close();
					if (cnt2 > 0){
					%>				
						NO2
					<%
					}else{
						// TABLE_SUBSCRIBER 내선번호  중복 체크
						sql	="Select count(*) From TABLE_SUBSCRIBER Where extension = '"+hiExtension+"'";
						rs = stmt.executeQuery(sql);
						
						System.out.println("사용 SQL3 : "+sql);
						
						if (rs.next()){ 
							cnt3 = Integer.parseInt(rs.getString(1));
						}
						rs.close();
						if (cnt3 > 0){
						%>				
							NO3
						<%
						}else{
							// table_localprefix 중복 체크
							sql	="Select count(*) From table_localprefix Where prefixtype = 2 and startprefix = '99"+hiExtension+"'";
							rs = stmt.executeQuery(sql);
							
							System.out.println("사용 SQL4 : "+sql);
							
							if (rs.next()){ 
								cnt4 = Integer.parseInt(rs.getString(1));
							}
							rs.close();
							if (cnt4 > 0){
							%>				
								NO4
							<%
							}else{
								// 부서 SMS 번호체 등록된 번호인지 체크
								sql	 =" SELECT Count(*) FROM table_keynumber_sms ";
								sql	 = sql + " WHERE keynumberid = (SELECT keynumber FROM table_dept WHERE deptid = (SELECT department FROM table_subscriber WHERE phonenum = '"+ hiE164 +"')) ";
								sql	 = sql + "   AND e164 = '"+ hiE164 +"' ";
								rs = stmt.executeQuery(sql);
								
								System.out.println("사용 SQL5 : "+sql);
								
								if (rs.next()){ 
									cnt5 = Integer.parseInt(rs.getString(1));
								}
								rs.close();
								if (cnt5 > 0){
								%>
									NO5
								<%
								}else{
								%>	
									OK
								<%
								}
							}	// 체크 End
						}	// 체크 End								
					}	// 체크 End
				}	// 체크 End
			}	// 체크 End
		}catch(Exception se){
			System.out.println("error-->" +se );
		}finally{
			try{
				if(rs != null)	rs.close();
				
				//할당받은 DataStatement 객체는 반납
				if (stmt != null ) ConnectionManager.freeStatement(stmt);
			}catch(Exception e){
				System.out.println("DB Connection Exception : "+e);
			}			
		}	
	}catch(Exception ex){
		System.out.println(ex);
	}finally{
	} 
%>
