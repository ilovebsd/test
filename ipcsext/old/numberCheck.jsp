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
		
		// �����κ��� DataStatement ��ü�� �Ҵ�
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");		
		
		System.out.println("SQL �˻����� : "+req_EndPointId);
		
		try{
			if (stmt != null) {
				// EndPointId �ߺ� üũ
				sql	="Select count(*) From table_sipendpoint Where endpointid = '"+req_EndPointId+"'";
				rs = stmt.executeQuery(sql);
				
				System.out.println("��� SQL : "+sql);
				
				if (rs.next()){ 
					cnt = Integer.parseInt(rs.getString(1));
				}
				rs.close();
				
				if (cnt > 0){
				%>				
					NO1
				<%
				}else{
					// E164 �ߺ� üũ
					sql	="Select count(*) From table_e164 Where e164 = '"+req_Ei64+"'";
					rs = stmt.executeQuery(sql);
					
					System.out.println("��� SQL2 : "+sql);
					
					if (rs.next()){ 
						cnt2 = Integer.parseInt(rs.getString(1));
					}
					rs.close();
					if (cnt2 > 0){
					%>				
						NO2
					<%
					}else{
						// ��ϵ� �μ��� �ִ��� üũ
						//sql	="Select count(*) From table_dept";
						sql	="Select count(*) From table_dept Where Deptid <> 1 ";
						rs = stmt.executeQuery(sql);
						
						System.out.println("��� SQL3 : "+sql);
						
						if (rs.next()){ 
							cnt3 = Integer.parseInt(rs.getString(1));
						}
						rs.close();
						if (cnt3 <= 0){
						%>				
							NO3
						<%
						}else{
							// ��ϵ� ������ �ִ��� üũ
							sql	="Select count(*) From table_position";
							rs = stmt.executeQuery(sql);
							
							System.out.println("��� SQL4 : "+sql);
							
							if (rs.next()){ 
								cnt4 = Integer.parseInt(rs.getString(1));
							}
							rs.close();
							if (cnt4 <= 0){
							%>				
								NO4
							<%
							}else{
								// �������� ��ϵǾ� �ִ��� üũ
								sql	="Select Count(*) From Table_Domain";
								rs = stmt.executeQuery(sql);
								
								System.out.println("��� SQL5 : "+sql);
								
								if (rs.next()){ 
									cnt5 = Integer.parseInt(rs.getString(1));
								}
								rs.close();
								if (cnt5 <= 0){
								%>				
									NO5
								<%
								}else{
									// �����ȳ� ��ȣ�� ��ϵǾ� �ִ��� üũ
									sql	="Select Count(*) From table_prefixtable Where startprefix = '"+req_Ei64+"'";
									rs = stmt.executeQuery(sql);
									
									System.out.println("��� SQL6 : "+sql);
									
									if (rs.next()){ 
										cnt6 = Integer.parseInt(rs.getString(1));
									}
									rs.close();
									if (cnt6 > 0){
									%>
										NO6
									<%
									}else{
										// �μ���ǥ ��ȣ�� ��ϵǾ� �ִ��� üũ
										sql	="Select Count(*) From table_keynumberid Where keynumberid = '"+req_Ei64+"'";
										rs = stmt.executeQuery(sql);
										
										System.out.println("��� SQL7 : "+sql);
										
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
									}	// �μ���ǥ ��ȣ üũ End
								}	// �����ȳ� ��ȣ üũ End
							}	// ������ ��� üũ End
						}	// ��ϵ� ���� üũ End								
					}	// ��ϵ� �μ� üũ End
				}	// E164 �ߺ� üũ End
			}	// EndPointId �ߺ� üũ End
		}catch(Exception se){
			System.out.println("error-->" +se );
		}finally{
			try{
				if(rs != null)	rs.close();
				
				//�Ҵ���� DataStatement ��ü�� �ݳ�
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
