<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>

<%
	try{
		String 		req_EndPointId 	= request.getParameter("fullEndPointId");
		String 		req_Ei64 		= request.getParameter("hiEi64");		
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		int 		cnt2			= 0;
		int 		cnt3			= 0;
		int 		cnt4			= 0;
		int 		cnt5			= 0;
		int 		cnt6			= 0;
		int 		cnt7			= 0;
		
		// 서버로부터 DataStatement 객체를 할당
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");		
		
		System.out.println("SQL 검색조건 : "+req_EndPointId);
		
		try{
			if (stmt != null) {
				// EndPointId 중복 체크
				sql	="Select count(*) From table_sipendpoint Where endpointid = '"+req_EndPointId+"'";
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
					// E164 중복 체크
					sql	="Select count(*) From table_e164 Where e164 = '"+req_Ei64+"'";
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
						// 등록된 부서가 있는지 체크
						//sql	="Select count(*) From table_dept";
						sql	="Select count(*) From table_dept Where Deptid <> 1 ";
						rs = stmt.executeQuery(sql);
						
						System.out.println("사용 SQL3 : "+sql);
						
						if (rs.next()){ 
							cnt3 = Integer.parseInt(rs.getString(1));
						}
						rs.close();
						if (cnt3 <= 0){
						%>				
							NO3
						<%
						}else{
							// 등록된 직급이 있는지 체크
							sql	="Select count(*) From table_position";
							rs = stmt.executeQuery(sql);
							
							System.out.println("사용 SQL4 : "+sql);
							
							if (rs.next()){ 
								cnt4 = Integer.parseInt(rs.getString(1));
							}
							rs.close();
							if (cnt4 <= 0){
							%>				
								NO4
							<%
							}else{
								// 도메인이 등록되어 있는지 체크
								sql	="Select Count(*) From Table_Domain";
								rs = stmt.executeQuery(sql);
								
								System.out.println("사용 SQL5 : "+sql);
								
								if (rs.next()){ 
									cnt5 = Integer.parseInt(rs.getString(1));
								}
								rs.close();
								if (cnt5 <= 0){
								%>				
									NO5
								<%
								}else{
									// 음성안내 번호로 등록되어 있는지 체크
									sql	="Select Count(*) From table_prefixtable Where startprefix = '"+req_Ei64+"'";
									rs = stmt.executeQuery(sql);
									
									System.out.println("사용 SQL6 : "+sql);
									
									if (rs.next()){ 
										cnt6 = Integer.parseInt(rs.getString(1));
									}
									rs.close();
									if (cnt6 > 0){
									%>
										NO6
									<%
									}else{
										// 부서대표 번호로 등록되어 있는지 체크
										sql	="Select Count(*) From table_keynumberid Where keynumberid = '"+req_Ei64+"'";
										rs = stmt.executeQuery(sql);
										
										System.out.println("사용 SQL7 : "+sql);
										
										if (rs.next()){ 
											cnt7 = Integer.parseInt(rs.getString(1));
										}
										rs.close();
										if (cnt7 > 0){
										%>
											NO7
										<%
										}else{
										%>
											OK
										<%
										}
									}	// 부서대표 번호 체크 End
								}	// 음성안내 번호 체크 End
							}	// 도메인 등록 체크 End
						}	// 등록된 직급 체크 End								
					}	// 등록된 부서 체크 End
				}	// E164 중복 체크 End
			}	// EndPointId 중복 체크 End
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
