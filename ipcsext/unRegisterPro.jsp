<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.ConnectionManager"%>

<%
	String 	Str = "";
	try{
		String 		endPointId 	= request.getParameter("endPointId");
		System.out.println("UnRegister : "+endPointId);
		
		//int cnt = ConnectionManager.unregisterEndpoint(endPointId,(short)2);
		int cnt = ConnectionManager.unregisterEndpoint(endPointId,(short)2, (short)1, "" ,  "(SSW).active" ) ;
		
		if (cnt == 0) {
			Str = "OK";
		}else{
			Str = "NO";
		}
		
		System.out.println("UnRegister Result : "+cnt);
		
	}catch(Exception se){
		System.out.println("error-->" +se );
		Str = "NO";
	}finally{
        out.clear();
        out.print(Str);
	} 
%>
