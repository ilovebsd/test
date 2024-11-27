<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.*" %>

<% 
int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

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
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// 서버로부터 DataStatement 객체를 할당
	DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);		

    try{
        if (stmt != null) {
            if("2".equals(callType)){
            	// table_e164 체크
                sql	 =" Select count(*) From table_e164 Where e164 = '"+ e164Number +"' ";
                rs = stmt.executeQuery(sql);
				
				System.out.println("사용 SQL1 : "+sql);				
				if (rs.next())	cnt = rs.getInt(1);
				rs.close();

                if (cnt == 0){
                    Str = "NO";
                }else{
                    sql	 ="Select count(*) From nasa_vms_user Where vms_id = '"+ e164Number +"' ";
                    rs = stmt.executeQuery(sql);
    				
    				System.out.println("사용 SQL2 : "+sql);				
    				if (rs.next())	cnt2 = rs.getInt(1);
    				rs.close();

                    if (cnt2 == 0){
                        Str = "NO2";
                    }else{
                    	if("1".equals(forwardingType)){
	    					// 일자별 시간 조건
                    		sql	="\n Select count(*) From table_keynumberforward_days ";
	    					sql += "\n Where keynumber = '"+e164dept+"' and forwardday = '"+forwardingValue+"' ";
	    					sql += "\n   and ((((starttime <= '"+startTime+"' and endtime > '"+startTime+"') or (starttime < '"+endTime+"' and endtime > '"+endTime+"'))) ";
	    					sql += "\n    or ((starttime >= '"+startTime+"' and endtime <= '"+endTime+"'))) ";
	    					rs = stmt.executeQuery(sql);
    	    				
    	    				System.out.println("사용 SQL3-1 : "+sql);				
    	    				if (rs.next())	cnt3 = rs.getInt(1);
    	    				rs.close();
    	
    	                    if (cnt3 > 0){
    	                        Str = "NO3";
    	                    }else{
                    			Str = "OK";
    	                    }
                    	}else if("2".equals(forwardingType)){
	    					// 요일별 시간 조건
                    		sql	="\n Select count(*) From table_keynumberforward_week ";
	    					sql += "\n Where keynumber = '"+e164dept+"' and dayoftheweek = '"+forwardingValue+"' ";
	    					sql += "\n   and ((((starttime <= '"+startTime+"' and endtime > '"+startTime+"') or (starttime < '"+endTime+"' and endtime > '"+endTime+"'))) ";
	    					sql += "\n    or ((starttime >= '"+startTime+"' and endtime <= '"+endTime+"'))) ";
	    					rs = stmt.executeQuery(sql);
    	    				
    	    				System.out.println("사용 SQL3-2 : "+sql);				
    	    				if (rs.next())	cnt3 = rs.getInt(1);
    	    				rs.close();
    	
    	                    if (cnt3 > 0){
    	                        Str = "NO4";
    	                    }else{
                    			Str = "OK";
    	                    }
                    	}
                    }
                }
            }else{
            	if("1".equals(forwardingType)){
					// 일자별 시간 조건
            		sql	="\n Select count(*) From table_keynumberforward_days ";
					sql += "\n Where keynumber = '"+e164dept+"' and forwardday = '"+forwardingValue+"' ";
					sql += "\n   and ((((starttime <= '"+startTime+"' and endtime > '"+startTime+"') or (starttime < '"+endTime+"' and endtime > '"+endTime+"'))) ";
					sql += "\n    or ((starttime >= '"+startTime+"' and endtime <= '"+endTime+"'))) ";
					rs = stmt.executeQuery(sql);
    				
    				System.out.println("사용 SQL3-1 : "+sql);				
    				if (rs.next())	cnt3 = rs.getInt(1);
    				rs.close();

                    if (cnt3 > 0){
                        Str = "NO3";
                    }else{
            			Str = "OK";
                    }
            	}else if("2".equals(forwardingType)){
					// 요일별 시간 조건
            		sql	="\n Select count(*) From table_keynumberforward_week ";
					sql += "\n Where keynumber = '"+e164dept+"' and dayoftheweek = '"+forwardingValue+"' ";
					sql += "\n   and ((((starttime <= '"+startTime+"' and endtime > '"+startTime+"') or (starttime < '"+endTime+"' and endtime > '"+endTime+"'))) ";
					sql += "\n    or ((starttime >= '"+startTime+"' and endtime <= '"+endTime+"'))) ";
					rs = stmt.executeQuery(sql);
    				
    				System.out.println("사용 SQL3-2 : "+sql);				
    				if (rs.next())	cnt3 = rs.getInt(1);
    				rs.close();

                    if (cnt3 > 0){
                        Str = "NO4";
                    }else{
            			Str = "OK";
                    }
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
