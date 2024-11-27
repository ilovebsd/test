<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="com.acromate.util.Str"%>

<%
int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

	try{
		String 		strE164 		= request.getParameter("hie164");
		String 		uploadfilename 	= request.getParameter("uploadfilename");
		String		soundName		= "";
		ResultSet	rs 				= null;
		String		sql				= "";		
		int 		cnt				= 0;
		
		soundName = Str.CheckNullString(uploadfilename.substring(uploadfilename.lastIndexOf("\\")+1)); //원파일명
		//System.out.println("############## 파일명 : "+soundName);
		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		// 서버로부터 DataStatement 객체를 할당
		DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);		
		
		try{
			if (stmt != null) {
				String strTmp = "%,"+soundName;
				sql = "\n SELECT count(*) FROM table_featureservice " ;
				sql = sql +  "\n  WHERE userparam like '" + strTmp + "' ";
				sql = sql +  "\n     OR userparam = '" + soundName + "' ";
				
				rs = stmt.executeQuery(sql);
				
				//System.out.println("사용 SQL2 : "+sql);
				
				if (rs.next()){ 
					cnt = Integer.parseInt(rs.getString(1));
				}
				rs.close();
				
				if (cnt > 0){
					out.clear();
					out.print("NO");
				}else{
					out.clear();
					out.print("OK");
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
	} 
%>
