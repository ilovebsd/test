<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.*" %>

<%
    String Str = "OK";
	try{
		String 		e164Number 	= StringUtil.null2Str(request.getParameter("e164"),"");
		String 		callType 	= StringUtil.null2Str(request.getParameter("callChangeType"),"");
		
		String 		e164dept 			= StringUtil.null2Str(request.getParameter("e164dept"),"");
		String 		forwardingType 		= StringUtil.null2Str(request.getParameter("forwardingType"),"");
		String 		forwardingValue 	= StringUtil.null2Str(request.getParameter("forwardingValue"),"");
		String 		startTime 			= StringUtil.null2Str(request.getParameter("startTime"),"");
		String 		endTime 			= StringUtil.null2Str(request.getParameter("endTime"),"");
		
		String 		sql       	= "";		
		ResultSet   rs 			= null;
		int    		cnt       	= 0;
		int    		cnt2       	= 0;
		int    		cnt3       	= 0;
		
		// 서버로부터 DataStatement 객체를 할당
		DataStatement stmt = ConnectionManager.allocStatement("SSW");		

        try{
            if (stmt != null) {
  				// 시간 조건
              	sql	="\n Select count(*) From table_forward ";
  				sql += "\n Where e164 = '"+e164Number+"' and forwardtype = 0 ";
  				rs = stmt.executeQuery(sql);
   				
   				System.out.println("사용 SQL : "+sql);				
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
	   				
	   				System.out.println("사용 SQL : "+sql);				
	   				if (rs.next())	cnt3 = rs.getInt(1);
	   				rs.close();
	
	                if (cnt3 > 0){
	                   	Str = "NO2";
	                }else{
	              		Str = "OK";
	                }
                }
            }
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
        out.clear();
        out.print(Str);
	} 
%>