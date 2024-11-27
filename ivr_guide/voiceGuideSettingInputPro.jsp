
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="waf.*"%>
<%@ page import="dto.ipcs.IpcsIvrDTO" %>
<%@ page import="dao.ipcs.IpcsIvrDAO" %>
<%@ page import="dto.system.PrefixTableDTO"%>
<%@ page import="dao.system.PrefixTableDAO"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="system.SystemConfigSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="business.LogHistory"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO"%>

<meta http-equiv='Content-type' content='text/html; charset=euc-kr'>

<%
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}
 */

 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
response.setCharacterEncoding("euc-kr"); 

boolean returnVal 	= false;

// String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// 도메인
// String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
// String 	scCompany	= request.getParameter("hiScCompany");												// 음성안내 그룹명
// //String 	scCompany 	= new String(Str.CheckNullString(request.getParameter("hiScCompany")).getBytes("8859_1"), "euc-kr").trim();		//음성안내 그룹명
// int		e164Leng	= ei64.length();
// //String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID
DataStatement 	stmt = null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);

IpcsIvrDTO 		ipcsDTO = new IpcsIvrDTO();
PrefixTableDTO 	dto 	= new PrefixTableDTO();

String selectWan	= "";
String wanName		= "";
String tempStr		= "";
String wanIp		= "";
int    nTemp 		= 0;
String lanIp		= "";

try{
	 int iRtn = -1;

		String strTrIdx = Str.CheckNullString(request.getParameter("trIdx"));
		String strAmIndex = Str.CheckNullString(request.getParameter("amIndex"));
		String strAdDateType = Str.CheckNullString(request.getParameter("adDateType"));
		String strAmModeName = "";
		String strAdMemo = "";
		String strAdWeekMon = request.getParameter("adWeekMon") == null ? "N" : "Y";
		String strAdWeekTue = request.getParameter("adWeekTue") == null ? "N" : "Y";
		String strAdWeekWed = request.getParameter("adWeekWed") == null ? "N" : "Y";
		String strAdWeekThu = request.getParameter("adWeekThu") == null ? "N" : "Y";
		String strAdWeekFri = request.getParameter("adWeekFri") == null ? "N" : "Y";
		String strAdWeekSat = request.getParameter("adWeekSat") == null ? "N" : "Y";
		String strAdWeekSun = request.getParameter("adWeekSun") == null ? "N" : "Y";
		String strStartMonth = Str.CheckNullString(request.getParameter("startMonth"));
		String strStartDay = Str.CheckNullString(request.getParameter("startDay"));
		String strEndMonth = Str.CheckNullString(request.getParameter("endMonth"));
		String strEndDay = Str.CheckNullString(request.getParameter("endDay"));
		String strAdSDateDay = "";
		String strAdEDateDay = "";

		if(strAdDateType.equals("W")) {
			strAdSDateDay = "";
			strAdEDateDay = "";
		} else {
        	strAdSDateDay = strStartMonth + "/" + strStartDay;
			strAdEDateDay = strEndMonth + "/" + strEndDay;
		}
		 
		try{
			/* ResponseTimeDAO responseTimeDAO = ResponseTimeDAO.getInstance();
			ResponseTimeDTO responseTimeDTO = responseTimeDAO.getResponseTime(strAmIndex);
			strAmModeName = responseTimeDTO.getAmModeName();
			 */
			sql = "SELECT am_index, am_mode_name, am_memo        \n";
			sql += "FROM nasa_answer_mode WHERE am_index = '"+strAmIndex+"' ";
// 			sql += "AND checkgroupid = '"+authGroupid+"' ";
			
			System.out.println("sql : "+sql);
			rs = stmt.executeQuery(sql);
			if(rs.next()) {
//	 			responseTimeDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
//	 			responseTimeDTO.setAmModeName(rs.getString("am_mode_name"));
//	 			responseTimeDTO.setAmMemo(rs.getString("am_memo"));
				strAmModeName = Str.CheckNullString(rs.getString("am_mode_name"));
				strAdMemo	  = Str.CheckNullString(rs.getString("am_memo"));
			}
		}catch(Exception ex){
		}finally{
			if(rs!=null){
				rs.close();	rs = null;
			}
		}
		
//  		ModeSettingDTO modeSettingDTO = new ModeSettingDTO();

		//iRtn = modeSettingDAO.insertModeSetting(modeSettingDTO);
		sql = "INSERT INTO nasa_answer_dateday(ad_index,tr_idx,am_index,		    \n";
		sql += "am_mode_name,ad_date_type,ad_sdate_day,ad_edate_day,ad_week_mon,	\n";
		sql += "ad_week_tue,ad_week_wed,ad_week_thu,ad_week_fri,ad_week_sat,		\n";
		sql += "ad_week_sun,ad_memo												    \n";
// 		sql += ", checkgroupid ";
		sql += "\n";
		//sql += ") values (nextval('nasa_answer_dateday_ad_index_seq'),?,?,?,?,?,?,?,?,?,?,?,?,?,?)    ";
// 		sql += ") values (nextval('nasa_answer_dateday_ad_index_seq')";
// 		sql += ") values ( (SELECT (max(ad_index)+1) as nextidx FROM nasa_answer_dateday) ";
		sql += ") values ( (SELECT (CASE WHEN max(ad_index)>0 THEN (max(ad_index)+1) ELSE 1 END) as nextidx FROM nasa_answer_dateday) ";
		sql += ",%s,%s,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s' ";
// 		sql += " ,'%s' ";
		sql += " ) ";
		sql = String.format(sql
				, strTrIdx
				, strAmIndex
				, strAmModeName
				, strAdDateType
				, strAdSDateDay
				, strAdEDateDay
				, strAdWeekMon
				, strAdWeekTue
				, strAdWeekWed
				, strAdWeekThu
				, strAdWeekFri
				, strAdWeekSat
				, strAdWeekSun
				, strAdMemo
// 				, authGroupid
				);
		
		System.out.println("sql : "+sql);
		iRtn = stmt.executeUpdate(sql);
		
		if(iRtn > 0) iRtn = 1;
		
		sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
		System.out.println("sql : "+sql);
		stmt.executeUpdate(sql);
		
		switch(iRtn) {
		    case 1:
		    	returnVal = true;
				break;
			case 2:
				//request.setAttribute("msg", "ok");
				returnVal = false;
				break;
			case -1:
				//request.setAttribute("msg", "faile");
				returnVal = false;
				break;
		}
// 		return "./voiceGuideSettingListForm.do2";
	if(returnVal){
		// ############### LogHistory 처리  ###############
		String		strIp		= request.getRemoteAddr();
// 		LogHistory	logHistory 	= new LogHistory();
// 		int int_result = logHistory.LogHistorySave(userID+"|82|음성안내 설정 ("+ei64+" 번)|1|"+strIp);
		// ##############################################

		StringBuffer jsArray = new StringBuffer();
		if(jsArray.length()==0)	jsArray.append("[{params:");
   		else					jsArray.append(",{params:");
		
// 		jsArray.append("[\""+scCompany+"\",\""+ei64+"\",\""+endPointID+"\"]}");
		jsArray.append("[\""+""+"\"]}");
		if(jsArray.length()>0)	jsArray.append("]");

		out.clear();
		//out.print("OK:"); out.print(jsArray.toString());
		if(stmt!=null) stmt.endTransaction(true);
%>
	    <script>
	    	alert('등록되었습니다.');
	        parent.goInsertDone(<%=jsArray.toString()%>);
	        parent.hiddenAdCodeDiv();
	    </script>
<%
		System.out.println("success------^^");
	}else{
		out.clear();
		//out.print("NO");
		if(stmt!=null) stmt.endTransaction(false);
%>
	    <script>
	        //parent.goInsertFail();
	        alert('등록에 실패하였습니다.');
	        parent.hiddenAdCodeDiv();
	    </script>
<%
		System.out.println("failed------!!");
	}	
}catch(Exception ex){
	System.out.println(ex);
	if(stmt!=null) stmt.endTransaction(false);
%>
    <script>
        //parent.goInsertFail();
        alert('등록에 실패하였습니다.');
        parent.hiddenAdCodeDiv();
    </script>
<%
}finally{
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
} 

%>
