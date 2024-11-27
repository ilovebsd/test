<%@page import="acromate.common.util.StringUtil"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>

<%

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
	try{
		String 		req_Keynumberid 	= request.getParameter("hiKeynumberid");
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		int 		cnt2			= 0;
		int 		cnt3			= 0;
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		// �����κ��� DataStatement ��ü�� �Ҵ�
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);		
		
		//System.out.println("SQL �����ȳ� ��ȣ �ߺ� �˻����� : "+req_Keynumberid);
		
		try{
			if (stmt != null) {
				// EndPointId �ߺ� üũ
				sql	="Select count(*) From table_prefixtable Where startprefix = '"+req_Keynumberid+"'";
// 				sql	+=" AND checkgroupid='"+authGroupid+"'";
				System.out.println("\nSQL: "+sql);
				rs = stmt.executeQuery(sql);
				
				//System.out.println("��� SQL : "+sql);
				
				if (rs.next()){ 
					cnt = Integer.parseInt(rs.getString(1));
				}
				rs.close();
				
				if (cnt > 0){
					out.clear();
					out.print("NO");
				}else{
					// E164 �ߺ� üũ
					sql	="Select count(*) From table_e164 Where e164 = '"+req_Keynumberid+"'";
// 					sql	+=" AND checkgroupid='"+authGroupid+"'";
					System.out.println("\nSQL: "+sql);
					rs = stmt.executeQuery(sql);
					
					//System.out.println("��� SQL2 : "+sql);
					
					if (rs.next()){ 
						cnt2 = Integer.parseInt(rs.getString(1));
					}
					rs.close();
					if (cnt2 > 0){
						out.clear();
						out.print("NO2");
					}else{
						// �μ���ǥ ��ȣ�� ��ϵǾ� �ִ��� üũ
						sql	="Select Count(*) From table_keynumberid Where keynumberid = '"+req_Keynumberid+"'";
// 						sql	+=" AND checkgroupid='"+authGroupid+"'";
						System.out.println("\nSQL: "+sql);
						rs = stmt.executeQuery(sql);
						
						//System.out.println("��� SQL3 : "+sql);
						
						if (rs.next()){ 
							cnt3 = Integer.parseInt(rs.getString(1));
						}
						rs.close();
						if (cnt3 > 0){
							out.clear();
							out.print("NO3");						
						}else{
							out.clear();
							out.print("OK");
						}
					}
				}
			}
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
