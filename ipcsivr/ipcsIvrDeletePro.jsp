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

String 	hiEi64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");		//
//String	hiAuthId	= new String(request.getParameter("hiAuthId").getBytes("8859_1"), "euc-kr");	//
//String	pageType	= new String(Str.CheckNullString(request.getParameter("pageType")).getBytes("8859_1"), "euc-kr");		//

String[] e164s = StringUtil.getParser(hiEi64, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
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
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	stmt.stxTransaction();
	for(String strE164 : e164s){
		strE164 = strE164.trim();
		
		/***** NASA_TRUNK_SET  ********/
    	sql = "DELETE FROM NASA_TRUNK_SET WHERE ivr_tel = '"+strE164+"'";
    	sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
        System.out.println("1:"+sql);
        stmt.executeUpdate(sql);
        
        /***** table_prefixtable  (09.05.14)********/
        sql = "DELETE FROM table_prefixtable WHERE startprefix = '"+strE164+"'";
        sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
        System.out.println("2:"+sql);
        stmt.executeUpdate(sql);
        
        /***** Table_arsnumbergroupsearch (hc-add : 200211 : req.chun) ********/
	   	sql = "DELETE FROM table_arsnumbergroupsearch WHERE e164 = '" + strE164 + "'";
	    sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
	    System.out.println("3:"+sql);
	    stmt.executeUpdate(sql);
	     
	    /***** Table_localprefix (hc-add : 200211 : req.chun) ********/
	    sql = "DELETE FROM table_localprefix WHERE startprefix = '" + strE164 + "'";
	    sql = sql + " AND checkgroupid = '"+authGroupid+"' " ;
	    System.out.println("4:"+sql);
	    stmt.executeUpdate(sql);

        /***** Table_Sipendpoint ********/
//        sql = "DELETE FROM table_sipendpoint WHERE endpointid = '" + hiAuthId + "'";
//        System.out.println("2:"+sql);
//        stmt.executeUpdate(sql);
        
        /***** Table_E164 ********/
//        sql = "DELETE FROM table_e164 WHERE e164 = '"+strE164+"'";
//        System.out.println("3:"+sql);
//        stmt.executeUpdate(sql);
                    
        /***** Table_E164route ********/
//        sql = "DELETE FROM table_e164route WHERE e164 = '"+strE164+"'";
//        System.out.println("4:"+sql);
//        stmt.executeUpdate(sql);

        /***** Table_Auth ********/
//        sql = "DELETE FROM table_auth WHERE endpointid = '" + hiAuthId + "'";
//        System.out.println("5:"+sql);
//        stmt.executeUpdate(sql);
        /**************************************************/
        
        /***** nasa_vms_user Update********/
        sql   = "update nasa_systemupdate set su_check = 'Y'";
        System.out.println("6:"+sql);
        nResult = stmt.executeUpdate(sql);
        if (nResult < 1){	throw new Exception(l.x("[IVR Systemv] '","[Auth Properties Error] '")+strE164+l.x("'IVR System IVR System","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
           
        // ############### LogHistory ###############
        //int int_result = logHistory.LogHistorySave(userID+"|82| ("+hiEi64+" |2|"+strIp);
	}
	if(stmt!=null) stmt.endTransaction(true);			// commit
	
	if (e164s.length > 0) {
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\"]}");
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
	       		
	       		jsArray.append("[\""+strE164+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
	}
}finally{
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
	out.clear();
    if(e164s.length>0){
    	//out.print(jsArray.toString());
%>
    <script>
        parent.goDeleteOk(<%=jsArray.toString()%>);
    </script>
<%
    }
    else out.print("NO");
}
%>
