<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.*" %>

<%
    String Str = "OK";
	try{
		String 		e164Number 	= StringUtil.null2Str(request.getParameter("e164"),"");
		String 		startTime 			= StringUtil.null2Str(request.getParameter("startTime"),"");
		String 		endTime 			= StringUtil.null2Str(request.getParameter("endTime"),"");
		
		String 		sql       	= "";		
		ResultSet   rs 			= null;
		int    		cnt       	= 0;
		int    		cnt2       	= 0;
		int    		cnt3       	= 0;
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		// �����κ��� DataStatement ��ü�� �Ҵ�
		DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);		

        try{
            if (stmt != null) {
  				// �ð� ����
              	sql	="\n Select count(*) From table_forward ";
  				sql += "\n Where e164 = '"+e164Number+"' and forwardtype = 0 ";
  				rs = stmt.executeQuery(sql);
   				
   				System.out.println("��� SQL : "+sql);				
   				if (rs.next())	cnt3 = rs.getInt(1);
   				rs.close();

                if (cnt3 >= 3){
                   	Str = "NO";
                }else{
	              	sql	="\n Select count(*) From table_forward ";
	  				sql += "\n Where e164 = '"+e164Number+"' and forwardtype = 0 ";
	  				sql += "\n   and ((((fromtime <= '"+startTime+"' and totime > '"+startTime+"') or (fromtime < '"+endTime+"' and totime > '"+endTime+"'))) ";
	  				sql += "\n    or ((fromtime >= '"+startTime+"' and totime <= '"+endTime+"'))) ";
	  				rs = stmt.executeQuery(sql);
	   				
	   				System.out.println("��� SQL : "+sql);				
	   				if (rs.next())	cnt3 = rs.getInt(1);
	   				rs.close();
	
	                if (cnt3 > 0){
	                   	Str = "NO2";
	                }else{
	              		Str = "OK";
	                }
	                System.out.println("Result : "+Str);		
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
        out.clear();
        out.print(Str);
	} 
%>