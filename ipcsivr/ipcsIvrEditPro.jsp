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

String 	e164 			= new String(Str.CheckNullString(request.getParameter("hiEi64")).getBytes("8859_1"), "euc-kr").trim();				// 
// String 	displayNumber 	= new String(Str.CheckNullString(request.getParameter("displaynumber")).getBytes("8859_1"), "euc-kr").trim();	// (Display)
// String 	fromNumber 		= new String(Str.CheckNullString(request.getParameter("fromnumber")).getBytes("8859_1"), "euc-kr").trim();		// (From)
//String 	hiScCompany 	= new String(Str.CheckNullString(request.getParameter("hiScCompany")).getBytes("8859_1"), "euc-kr").trim();		//
String 	hiScCompany 	= new String(Str.CheckNullString(request.getParameter("hiScCompany"))).trim();		//
String 	pageType 		= new String(Str.CheckNullString(request.getParameter("pageType")).getBytes("8859_1"), "euc-kr").trim();		//
//String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		//  ID

String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();
String	sql = "", strIp;
int count = 0, nResult = 0;
DataStatement stmt = null;
ResultSet 	rs 	= null;
try{
	strIp = request.getRemoteAddr() ;
// 	LogHistory	logHistory 	= new LogHistory();
	AddServiceDAO dao 	= new AddServiceDAO();
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// DataStatement
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	stmt.stxTransaction();
	for(String strE164 : e164s){
		strE164 = strE164.trim();
		
		/**** NASA_TRUNK_SET ********/
           sql = "Update NASA_TRUNK_SET Set sc_company = '" + hiScCompany + "' ";
           sql = sql + " WHERE ivr_tel = '"+e164+"'" ;
           sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
           
           System.out.println(" NASA_TRUNK_SET SQL : "+sql);
           stmt.executeUpdate(sql);            	
           
           /***** nasa_vms_user Update********/
           sql   = "update nasa_systemupdate set su_check = 'Y'";
           System.out.println("2:"+sql);
           nResult = stmt.executeUpdate(sql);
           if (nResult < 1){	throw new Exception(l.x("[IVR System ] '","[Auth Properties Error] '")+e164+l.x("'IVR System . IVR System .","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
           
           
           /***** table_prefixtablev(09.05.14)********/
           sql = "Update table_prefixtable Set description = '" + hiScCompany + "' ";
           sql = sql + " WHERE startprefix = '"+e164+"'" ;
           sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
           System.out.println("�����ȳ� ��ȣ table_prefixtable ���� SQL : "+sql);
           stmt.executeUpdate(sql);            
           /**************************************************/
           
           // ############### LogHistory ###############
           //int int_result = logHistory.LogHistorySave(userID+"|82|v("+hiEi64+" )|3|"+strIp);
	}
	if(stmt!=null) stmt.endTransaction(true);			// commit
	
	if (e164s.length > 0) {
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+hiScCompany+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
	}	
}catch(Exception se){
	System.out.println("error-->" +se );
	if(stmt!=null) stmt.endTransaction(false);		// rollback
	if(nModeDebug==1){
    	count = 1;
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+hiScCompany+"\"]}");
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
