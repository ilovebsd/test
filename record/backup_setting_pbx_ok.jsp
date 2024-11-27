<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*,bizportal.nasacti.record.*,java.lang.*"%>

<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>

<%
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

String groupID    = Str.CheckNullString(scDTO.getLoginGroup()).trim();
 */
 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String groupID = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

if(groupID==null) return ;

String pageDir = "";//"/ems";

String ipAddr = "";								//아이피 주소
String backDrive = "";							//백업경로
String backuppath = "";
//String backupUse = "";							//백업사용 유무
String backupType = "";							//원본파일 보존 설정
String typeMonth = "";							//보존 개월 수
String typeUse = "";							//최대 사용률
String originaltrans = "";						//원본설정
String backuptrans = "";						//백업설정
String txt_Backup_Lastday = "";

String apm ="1";//1-오전,2-오후
int intBkShour = 0;
int intBkSmin = 0;


ipAddr = request.getParameter("ipaddr");
backDrive = request.getParameter("backdrive");

//backuppath = request.getParameter("backuppath");
backuppath = new String(request.getParameter("backuppath").getBytes("8859_1"), "euc-kr");

//backupUse = request.getParameter("backupuse");
backupType = request.getParameter("backuptype");
typeMonth = request.getParameter("typemonth");
typeUse = request.getParameter("typeuse");
//originaltrans = request.getParameter("originaltrans");
backuptrans = request.getParameter("backuptrans");
txt_Backup_Lastday = request.getParameter("txt_Backup_Lastday");

/*
apm = request.getParameter("apm");
intBkShour = Integer.parseInt(request.getParameter("intBkShour"));
intBkSmin = Integer.parseInt(request.getParameter("intBkSmin"));

if( apm.equals("1") ){
	if( intBkShour == 12 ){
		intBkShour = 0;
	}else{
		intBkShour = intBkShour;
	}
}else if( apm.equals("2") ){
	if( intBkShour == 12 ){
		intBkShour = intBkShour;
	}else{
		intBkShour = intBkShour + 12;
	}
}
*/
String ftphost = "";
String ftpwebhost = "";
int ftpport = 21;
String ftpuser = "ktcallbox";
String ftppassword = "ipcs1.";
String ftpremotepath = "", ftpdir = "";


ftphost = request.getParameter("ftphost");
ftpwebhost = "";//request.getParameter("ftpwebhost");
if( request.getParameter("ftpport").equals("") ){
	ftpport = 21;
}else{
	ftpport = Integer.parseInt(request.getParameter("ftpport"));
}

ftpuser = request.getParameter("ftpuser");
ftppassword = request.getParameter("ftppassword");
ftpremotepath = request.getParameter("ftpremotepath");
ftpdir = request.getParameter("ftpdir");

backupConfigBean  backupConfigBean = new backupConfigBean();

//backupConfigBean.setAuto(backupUse);
backupConfigBean.setServerIp(ipAddr);
backupConfigBean.setDvdDrive(backDrive);
backupConfigBean.setBackupPath(backuppath);
backupConfigBean.setPreservationType(backupType);
backupConfigBean.setPreservationMonth(typeMonth);
backupConfigBean.setPreservationCapacity(typeUse);
//backupConfigBean.setOriginaltrans(originaltrans);
backupConfigBean.setBackuptrans(backuptrans);
backupConfigBean.setTxt_Backup_Lastday(txt_Backup_Lastday);
//backupConfigBean.setIntBkShour(intBkShour);
//backupConfigBean.setIntBkSmin(intBkSmin);

//backupConfigClass backupConfig = new backupConfigClass();
//backupConfig.backupConfigUpdate(backupConfigBean);


FtpConfigBean FtpBean = new FtpConfigBean();

FtpBean.setFtpHost(ftphost);
FtpBean.setFtpWebHost(ftpwebhost);
FtpBean.setFtpUser(ftpuser);
FtpBean.setFtpPassword(ftppassword);
FtpBean.setFtpPort(ftpport);
FtpBean.setFtpRemotepath(ftpremotepath);

// FtpBean.setBackupType(Str.CheckNullInt(backuptrans));
// FtpBean.setNicType(1);
// FtpBean.setSetDate(txt_Backup_Lastday);
// FtpBean.setSaveRate(100) ;
// FtpBean.setGroupId(groupID);
int bakupType = Str.CheckNullInt(backupType);
int nicType = 1;
String setDate = txt_Backup_Lastday;
int saveRate = 100;

//FtpConfigClass ftpClass = new FtpConfigClass();
//ftpClass.FtpUpdate(FtpBean);
DataStatement stmt = null;
ResultSet rs = null;
int count = 0;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	String query = "SELECT ftpIp FROM Table_RecordBackupFTP \n";
	query += "WHERE groupid= '"+groupID+"' \n";
	//query += "AND ftpIp= '"+FtpBean.getFtpHost()+"' \n";
	
	System.out.println("SQL :\n "+query.toString());
	rs = stmt.executeQuery(query.toString()) ;
	
	String oldFtpIp = "";
	if(rs!=null && rs.next())
		oldFtpIp = rs.getString("ftpIp") ;

	if(stmt!=null) stmt.stxTransaction();
	
	query = "";
	if(oldFtpIp.length()>0 
			&& oldFtpIp.equals(FtpBean.getFtpHost()) ){
		
		query = "UPDATE Table_RecordBackupFTP SET \n";
		query += " ForwardIp = %s , \n";
		query += " ftpUserId = %s , \n";
		query += " ftpPasswd = %s , \n";
		query += " ftpDir = %s , \n";
		query += " SaveRate = %s , \n";
// 		query += " SetDate = %s , \n";
		query += " backupType = %s , \n";
		query += " nicType = %s \n";
		query += " , checkgroupid = %s \n";
		query += "WHERE Groupid = %s \n";
		query += "AND ftpIp = %s ";
		
		query = String.format(query
				, "'"+FtpBean.getFtpWebHost()+"'"
				, "'"+FtpBean.getFtpUser()+"'"
				, "'"+FtpBean.getFtpPassword()+"'"
				, "'"+ftpdir+"'"
				, ""+saveRate
// 				, stmt.getToDate("'"+setDate+"'", "YYYYMMDD")
				, ""+bakupType
				, ""+nicType
				, "'"+groupID+"'"
				
				, "'"+groupID+"'"
				, "'"+FtpBean.getFtpHost()+"'"
				) ;
	}else{
		if(oldFtpIp.length()>0){
			query = "DELETE FROM Table_RecordBackupFTP \n";
			query += "WHERE Groupid = '"+groupID+"' \n";
			query += "AND ftpIp = '"+oldFtpIp+"' ";
			
			System.out.println("SQL :\n "+query.toString());
			stmt.executeUpdate(query.toString()) ;
		}
		
		query = "INSERT INTO Table_RecordBackupFTP (";
		query += " Groupid, ";
		query += " ftpIp, ";
		query += " ForwardIp, ";
		query += " ftpUserId, ";
		query += " ftpPasswd, ";
		query += " ftpdir, ";
		query += " SaveRate, ";
// 		query += " SetDate, ";
		query += " backupType, ";
		query += " nicType ";
		query += " , checkgroupid ";
		query += "\n) VALUES (\n";
		query += " %s, %s, %s, %s, %s, %s, %s, %s, %s, %s ";
		query += " ) ";
		query = String.format(query
				, "'"+groupID+"'"
				, "'"+FtpBean.getFtpHost()+"'"
				, "'"+FtpBean.getFtpWebHost()+"'"
				, "'"+FtpBean.getFtpUser()+"'"
				, "'"+FtpBean.getFtpPassword()+"'"
				, "'"+ftpdir+"'"
				, ""+saveRate
// 				, stmt.getToDate("'"+setDate+"'", "YYYYMMDD")
				, ""+bakupType
				, ""+nicType
				, "'"+groupID+"'"
				) ;
	}
	
	System.out.println("SQL :\n "+query.toString());
	if(query.length()>0)
		count += stmt.executeUpdate(query.toString()) ;
	
	if(stmt!=null) stmt.endTransaction(true);
}catch(Exception ex){
	if(stmt!=null) stmt.endTransaction(false);
	System.out.println("Exception" + ex);		
}finally{
	if(stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
<html>
<head>
<Script language="javascript">
<!--
//top.TopView.CtiSend_Send("83");
//top.TopView.CtiSend_Driver("83");
//alert("수정되었습니다.");
//document.location.href= "backup_setting.jsp";
//-->
</script>

</head>
<body>
<form name="form1" method="post">
	<input type="hidden" name="socketDriver" value="Y">
</form>
</body>
</html>
<script language="javascript">
<!--

<% if(count>0){ %>
	alert("저장되었습니다.");
<% }else{ %>
	alert("저장이 실패되었습니다.");
<% } %>
//parent.location.href="<%=StaticString.ContextRoot+pageDir%>/record/backup_setting_pbx.jsp";
parent.location.href=parent.location.href;
	
//var frm = document.form1;
//frm.action ="backup_setting_pbx.jsp";
//frm.submit();

//-->
</script>
