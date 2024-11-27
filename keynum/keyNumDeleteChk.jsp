<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.*" %>

<% 
int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

String Str = "OK";
try{
	String 		e164 	= StringUtil.null2Str(request.getParameter("keynumberid"),"");
	String[] e164s = StringUtil.getParser(e164, "");
	
	String 		sql       	= "";		
	ResultSet   rs 			= null;
	int    		cnt       	= 0;
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// �����κ��� DataStatement ��ü�� �Ҵ�
	DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);		

    try{
        if (stmt != null) {
        	for(String strE164 : e164s){
	           	// table_keynumber üũ
	            sql	 =" Select count(*) From table_keynumber Where e164 = '"+ strE164 +"' ";
	            rs = stmt.executeQuery(sql);
				
				System.out.println("��� SQL1 : "+sql);				
				if (rs.next())	cnt = rs.getInt(1);
				rs.close();
	
	            if (cnt > 0){
	                Str = "NO";
	                break;
	            }else{
	         		Str = "OK";
	            }
        	}//for
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
