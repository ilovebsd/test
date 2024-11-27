<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.*" %>

<%
    String Str = "OK";
	try{
		String hiE164	 = StringUtil.null2Str(request.getParameter("hiE164"),"").trim();
		String sql       = "";		
		ResultSet     rs = null;
		int    cnt       = 0;
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		// 서버로부터 DataStatement 객체를 할당
		DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);		

        try{
            if (stmt != null) {
                // 부서 SMS 번호체 등록된 번호인지 체크
				sql	 =" SELECT Count(*) FROM table_keynumber_sms ";
				sql	 = sql + " WHERE keynumberid = (SELECT keynumber FROM table_dept WHERE deptid = (SELECT department FROM table_subscriber WHERE phonenum = '"+ hiE164 +"')) ";
				sql	 = sql + "   AND e164 = '"+ hiE164 +"' ";
                rs = stmt.executeQuery(sql);
				
				System.out.println("사용 SQL : "+sql);				
				if (rs.next())	cnt = rs.getInt(1);
				rs.close();

                if (cnt == 0){
                    Str = "OK";
                }else{
                    Str = "NO";
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