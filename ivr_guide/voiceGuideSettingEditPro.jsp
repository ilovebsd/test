<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO"%>
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

	 	String strAdIndex = request.getParameter("adIndex");
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
			sql += "FROM nasa_answer_mode WHERE am_index = "+strAmIndex+" ";
// 			sql += "AND checkgroupid = '"+ authGroupid +"' ";
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
		
		if(stmt!=null) stmt.stxTransaction();
		
		//iRtn = modeSettingDAO.updateModeSetting(modeSettingDTO);
		sql = "UPDATE nasa_answer_dateday SET	\n";
		sql += "tr_idx = %s,				    \n";
		sql += "am_index = %s,					\n";
		sql += "am_mode_name = '%s',			\n";
		sql += "ad_date_type = '%s',			\n";
		sql += "ad_sdate_day = '%s', 			\n";
		sql += "ad_edate_day = '%s', 			\n";
		sql += "ad_week_mon = '%s',				\n";
		sql += "ad_week_tue = '%s', 			\n";
		sql += "ad_week_wed = '%s', 			\n";
		sql += "ad_week_thu = '%s', 			\n";
		sql += "ad_week_fri = '%s', 			\n";
		sql += "ad_week_sat = '%s', 			\n";
		sql += "ad_week_sun = '%s', 			\n";
		sql += "ad_memo = '%s'					\n";
// 		sql += ", checkgroupid = '%s'			\n";
		sql += "WHERE ad_index = %s			    ";
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
				, strAdIndex
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
		
		jsArray.append("[\""+strTrIdx+"\",\""+strAmIndex+"\"");
		jsArray.append(",\""+strAmModeName+"\",\""+strAdDateType+"\",\""+strAdSDateDay+"\"");
		jsArray.append(",\""+strAdWeekMon+"\",\""+strAdWeekTue+"\",\""+strAdWeekWed+"\"");
		jsArray.append(",\""+strAdWeekThu+"\",\""+strAdWeekFri+"\",\""+strAdWeekSat+"\"");
		jsArray.append(",\""+strAdWeekSun+"\",\""+strAdMemo+"\"");
		jsArray.append("]}");
		if(jsArray.length()>0)	jsArray.append("]");
		
		System.out.println("저장성공------^^");
		out.clear();
		//out.print("OK:"); out.print(jsArray.toString());
%>
	    <script>
	        //parent.goInsertOk('<%=jsArray.toString()%>');
	        parent.goEditDone(<%=jsArray.toString()%>);
	        parent.hiddenAdCodeDiv();
	        alert('수정 되었습니다.');
	    </script>
<%
		if(stmt!=null) stmt.endTransaction(true);
	}else{
		System.out.println("저장실패------ㅜㅜ");
		out.clear();
		//out.print("NO");
%>
	    <script>
	        //parent.goInsertFail();
	        parent.hiddenAdCodeDiv();
	        alert('수정에 실패하였습니다.');
	    </script>
<%
		if(stmt!=null) stmt.endTransaction(false);
	}	
	
	
}catch(Exception ex){
	System.out.println(ex);
	if(stmt!=null) stmt.endTransaction(false);
%>
    <script>
        //parent.goInsertFail();
        parent.hiddenAdCodeDiv();
        alert('수정에 실패하였습니다.');
    </script>
<%
}finally{
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
} 

%>
