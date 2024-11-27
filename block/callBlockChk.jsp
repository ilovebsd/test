<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");
*/
String 	insertStr	= new String(Str.CheckNullString(request.getParameter("insertStr")).getBytes("8859_1"), "euc-kr");	//
String 	blockE164	= new String(Str.CheckNullString(request.getParameter("blockE164")).getBytes("8859_1"), "euc-kr");	//

try{
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		int 		totalCnt		= 0;
		// 서버로부터 DataStatement 객체를 할당
		DataStatement 	stmt 		= null;		
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		try{
			stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
			
			if( "#, *".equals(blockE164.trim()))
				blockE164 = "#";
			
			if (stmt != null) {
				String[] 	blockStr 		= StringUtil.getParser(insertStr, "");
				String		e164 			= "";

				if(blockStr != null){
					for(int k=0; k < blockStr.length; k++){
						e164   = blockStr[k];
						sql	="Select count(*) From Table_E164block ";
						sql = sql + "\n  Where e164 = '" + e164 +"' and inoutflag = 0 and startprefix = '" + blockE164 +"' "; 
						rs = stmt.executeQuery(sql);
						
						System.out.println("사용 SQL "+k+" 번째 : "+sql);
						
						if (rs.next()){ 
							cnt = Integer.parseInt(rs.getString(1));
							totalCnt = totalCnt + cnt;
						}
						rs.close();
					}
					
					if (totalCnt > 0){
						out.clear();
						out.print("NO");
					}else{
						out.clear();
						out.print("OK");					
					}
				}
			}
		}catch(Exception se){
			System.out.println("error-->" +se );
			if(nModeDebug==1){
				out.clear();
				out.print("OK");
			}
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
