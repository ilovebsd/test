<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
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

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;
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
			if (stmt != null) {
				String[] 	params 		= StringUtil.getParser(insertStr, "");
				String e164 = "", hiOldExtension="", extensionNum="", whereInE164s = "";

				String groupExtCode = "";
		    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+authGroupid+"' ";
		    	System.out.println("SQL : "+sql);
		    	rs = stmt.executeQuery(sql);
		        if (rs.next()) groupExtCode = rs.getString(1); 
		        rs.close();
		        
		        /**
				for(non_edit_list)
				for(edit_list)
				
				db = select_where e164 not in (all_list.e164s)
				
				if( db.ext == edit.ext ) failed
	    		**/
	    		
		        HashMap<String, String> lstNonEdit = new HashMap<String, String>();
		        HashMap<String, String[]> lstEdit = new HashMap<String, String[]>();
		        
		        int idxE164 = -1, idxValue = -1;
		    	for(String strParam : params){
		    		strParam = strParam.trim();
		    		if( (idxE164=strParam.indexOf(':'))==-1 
		    				|| (idxValue=strParam.indexOf(','))==-1) 
		    			continue;
		    		
		    		e164 = strParam.substring(0, idxE164);
		    		hiOldExtension = strParam.substring(idxE164+1, idxValue).trim().toString();
		    		extensionNum = strParam.substring(idxValue+1).trim().toString();
		    		
		    		if(hiOldExtension.equals(extensionNum))//	continue;
		    			lstNonEdit.put(e164, hiOldExtension);
		    		else
		    			lstEdit.put(e164, new String[]{hiOldExtension, extensionNum});
		    		
		    		whereInE164s += ",'"+e164+"'";
		    		
		    		if(1!=1){
		    			System.out.println("chk.e164-->" +e164 );
		    			System.out.println("chk.hiOldExtension-->" +hiOldExtension );
		    			System.out.println("chk.extensionNum-->" +extensionNum +"\n" );
		    		}
		    	}//for
		    	
		    	String tmpE164;
		    	String[] extnums;
		    	Iterator tmpiters, iters = lstEdit.keySet().iterator() ;
    			while(iters.hasNext()){
    				e164 = (String) iters.next() ;
    				extnums = lstEdit.get(e164);
    				
    				/**	dupchk_1 **/
    				tmpiters = lstNonEdit.keySet().iterator();
    				while(tmpiters.hasNext()){
    					tmpE164 = (String) tmpiters.next();
    					hiOldExtension = lstNonEdit.get(tmpE164);	
    					if(hiOldExtension.equals(extnums[1])){
    						out.clear();
    						out.print("NO:"+e164);
    						return ;
    					}
    				}//while
		    		
		    		//Table_E164
		    		sql	="\n SELECT count(*) FROM Table_E164 ";
					sql += "\n WHERE e164 NOT IN (" + whereInE164s.substring(1) +") ";
					sql += "\n AND extensionnumber = '" + extnums[1] +"' ";
					if(authGroupid!=null)
						sql += "\n  AND checkgroupid = '" + authGroupid+"' ";
					System.out.println("SQL : "+sql);
					rs = stmt.executeQuery(sql);
					cnt = 0;
					if (rs.next()){ 
						cnt = Integer.parseInt(rs.getString(1));
						totalCnt = totalCnt + cnt;
					}
					rs.close();
					if(cnt>0){
						out.clear();
						out.print("NO:"+e164);
						return ;
					}
					
					//table_e164route
					String strExtension = /* "99"+ */groupExtCode + extensionNum;
					sql	="\n SELECT count(*) FROM table_e164route ";
					sql += "\n WHERE e164 NOT IN (" + whereInE164s.substring(1) +") ";
					sql += "\n AND routingnumber = '"+groupExtCode + hiOldExtension+"' " ;
					if(authGroupid!=null)
						sql += "\n  AND checkgroupid = '" + authGroupid+"' ";
					System.out.println("SQL : "+sql);
					rs = stmt.executeQuery(sql);
					cnt = 0;
					if (rs.next()){ 
						cnt = Integer.parseInt(rs.getString(1));
						totalCnt = totalCnt + cnt;
					}
					rs.close();
					if(cnt>0){
						out.clear();
						out.print("NO:"+e164);
						return ;
					}
    			}//while
		    	
		    	out.clear();
				out.print("OK");
			}else{
				out.clear();
				out.print("NO");
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
