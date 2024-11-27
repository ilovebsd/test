<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>

<%
	try{
		HttpSession ses = request.getSession(false);
		String checkgroupid = ses != null?(String)ses.getAttribute("login.name") : null;
		 
		String 		hiExtension 	= Str.CheckNullString(request.getParameter("hiExtension")).trim();
		String 		hiE164 			= Str.CheckNullString(request.getParameter("hiEi64")).trim();
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		int 		cnt2			= 0;
		int 		cnt3			= 0;
		int 		cnt4			= 0;
		int 		cnt5			= 0;
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		// �����κ��� DataStatement ��ü�� �Ҵ�
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);		
		
		System.out.println("SQL �˻����� : "+hiExtension);
		
		try{
			if (stmt != null) {
				// table_e164 �ߺ� üũ
				sql	="Select count(*) From table_e164 Where extensionnumber = '" + hiExtension + "' AND checkgroupid = '"+checkgroupid+"'";
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
					String groupExtCode = "";
			    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+checkgroupid+"' ";
			    	rs = stmt.executeQuery(sql);
			        if (rs.next()) groupExtCode = rs.getString(1); 
			        rs.close();
			        
					// table_e164route �ߺ� üũ
					sql	="Select count(*) From table_e164route Where routingnumber = '"+groupExtCode + hiExtension+"'";
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
						// TABLE_SUBSCRIBER ������ȣ  �ߺ� üũ
						sql	="Select count(*) From TABLE_SUBSCRIBER Where extension = '"+hiExtension+"' AND checkgroupid = '"+checkgroupid+"'";
						rs = stmt.executeQuery(sql);
						
						System.out.println("��� SQL3 : "+sql);
						
						if (rs.next()){ 
							cnt3 = Integer.parseInt(rs.getString(1));
						}
						rs.close();
						if (cnt3 > 0){
						%>				
							NO3
						<%
						}else{
							// table_localprefix �ߺ� üũ
							sql	="Select count(*) From table_localprefix Where prefixtype = 2 and startprefix = '"+groupExtCode + hiExtension+"'";
							rs = stmt.executeQuery(sql);
							
							System.out.println("��� SQL4 : "+sql);
							
							if (rs.next()){ 
								cnt4 = Integer.parseInt(rs.getString(1));
							}
							rs.close();
							if (cnt4 > 0){
							%>				
								NO4
							<%
							}else{
								// �μ� SMS ��ȣü ��ϵ� ��ȣ���� üũ
								sql	 =" SELECT Count(*) FROM table_keynumber_sms ";
								sql	 = sql + " WHERE keynumberid = (SELECT keynumber FROM table_dept WHERE deptid = (SELECT department FROM table_subscriber WHERE phonenum = '"+ hiE164 +"')) ";
								sql	 = sql + "   AND e164 = '"+ hiE164 +"' ";
								rs = stmt.executeQuery(sql);
								
								System.out.println("��� SQL5 : "+sql);
								
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
							}	// üũ End
						}	// üũ End								
					}	// üũ End
				}	// üũ End
			}	// üũ End
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
