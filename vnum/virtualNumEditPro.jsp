<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>

<%@ page import="acromate.*"%>
<%@ page import="business.LogHistory"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;

String 	e164 			= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr").trim();				// 
String 	displayNumber 	= new String(Str.CheckNullString(request.getParameter("displaynumber")).getBytes("8859_1"), "euc-kr").trim();	// 가상발신 번호(Display)
String 	fromNumber 		= new String(Str.CheckNullString(request.getParameter("fromnumber")).getBytes("8859_1"), "euc-kr").trim();		// 가상발신 번호(From)
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();
String	sql = "", strIp, userparam	= "3,";
int count = 0, nResult = 0;
DataStatement stmt = null;
ResultSet 	rs 	= null;
try{
	if("".equals(displayNumber)){
		userparam = userparam+" ,";
	}else{
		userparam = userparam+displayNumber+",";
	}
	if("".equals(fromNumber)){
		userparam = userparam+" ";
	}else{
		userparam = userparam+fromNumber;
	}

	strIp = request.getRemoteAddr() ;
// 	LogHistory	logHistory 	= new LogHistory();
	AddServiceDAO dao 	= new AddServiceDAO();
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// 서버로부터 DataStatement 객체를 할당
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	stmt.stxTransaction();
	for(String strE164 : e164s){
		strE164 = strE164.trim();
		
		sql  = " SELECT count(*) FROM table_featureservice WHERE e164 = '" + strE164 +"' AND checkgroupid='"+authGroupid+"' AND serviceno = 5431 ";
        rs = stmt.executeQuery(sql);
		if (rs.next()) count = Integer.parseInt(rs.getString(1));
		rs.close();
        if (rs != null) rs.close();
        
        if (count == 0){//등록
			int maxId2 	= dao.getMaxID(stmt, strE164);
        	sql = " INSERT INTO table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
			sql += "  VALUES('" + strE164 + "', 5431, "+ (maxId2 + 1) +", '" + userparam + "', 2, 1, 0, 2, '"+authGroupid+"')";
			nResult = stmt.executeUpdate(sql);
			if (nResult < 0){	throw new Exception(l.x("[가상발신번호 등록] '","[Auth Properties Error] '")+l.x("'가상발신번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
        
			// ############### LogHistory 처리  ###############
// 			logHistory.LogHistorySave(userID+"|83|가상발신번호 ("+strE164+" 번)|1|"+strIp);
        }else{//수정
        	sql = " UPDATE table_featureservice SET userparam = '" + userparam + "' "; 
			sql += "  WHERE e164 = '" + strE164 +"' AND checkgroupid='"+authGroupid+"' AND serviceno = 5431 ";
			nResult = stmt.executeUpdate(sql);
			if (nResult < 0){	throw new Exception(l.x("[가상발신번호 수정] '","[Auth Properties Error] '")+l.x("'가상발신번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
			
        	// ############### LogHistory 처리  ###############
//         	logHistory.LogHistorySave(userID+"|83|가상발신번호 ("+strE164+" 번)|3|"+strIp);	
        }
	}
	if(stmt!=null) stmt.endTransaction(true);			// commit 처리
	
	if (e164s.length > 0) {
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+userparam+"\",\""+displayNumber+"\",\""+fromNumber+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
	}	
}catch(Exception se){
	System.out.println("error-->" +se );
	if(stmt!=null) stmt.endTransaction(false);		// rollback 처리
	if(nModeDebug==1){
    	count = 1;
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+userparam+"\",\""+displayNumber+"\",\""+fromNumber+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
	}
}finally{
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
	out.clear();
    if(e164s.length>0) out.print(jsArray.toString());
    else out.print("NO");
}
%>
