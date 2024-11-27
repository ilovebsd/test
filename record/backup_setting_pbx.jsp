<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*,bizportal.nasacti.record.*,java.lang.*,java.io.*,java.text.*,java.util.regex.* "%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.ipcs.IpcsListDTO" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>

<%@ page import="business.CommonData"%>
<%@ page import="system.SystemConfigSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>

<%
/*     SessionManager manager = SessionManager.getInstance();
 if (manager.isLogin(request) == false) {
  response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
  return ;
 }
 HttpSession   hs   = request.getSession();
 String     id   = hs.getId();
 BaseEntity    entity  = manager.getBaseEntity(id);
 SubscriberInfoDTO  scDTO  = entity.getScDtoAttribute("scDTO");
 String userName = Str.CheckNullString(scDTO.getName()).trim();

String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // ��������(1:�����, 2:������)
String groupID = Str.CheckNullString(scDTO.getLoginGroup()).trim();
 */
 
String pageDir = "";//"/ems";
int nModeDebug = 0, nModePaging = 1;//config option
int nAllowUser = 0;//0: unauth, 1:auth, -1:DB err

HttpSession ses = request.getSession(false);
String groupID = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = ses != null?(String)ses.getAttribute("login.user") : null;
int userLevel = ses != null? Str.CheckNullInt((String)ses.getAttribute("login.level")) : -1;

if(groupID!=null && groupID.trim().length()>0){
	nAllowUser = 1;
	nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
}
else if(userID!=null&&userID.trim().length()>0){
   nAllowUser = 1; groupID = "";
} else{
	response.sendRedirect(StaticString.ContextRoot+pageDir) ;
	return ;
}

// String menu       = "6";  // �����̾� ����
// String submenu    = "4";  // ���� ���� ��� ����

String new_menu     = "E";  		// ����
String new_submenu  = "11";  		// ���� ���� ��� ����
//�����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 		= null;//ConnectionManager.allocStatement("SSW");

// // ������ ��ȸ
// CommonData		commonData	= new CommonData();
// String 			domainid 	= commonData.getDomain(stmt);						// ������ID ��ȸ
// String[]		tempDomain;
// if(!"".equals(domainid)){
// 	tempDomain 	= domainid.split("[.]");
// 	domainid	= tempDomain[0];			
// }
// // DDNS ���� ��ȸ
// SystemConfigSet 	systemConfig 	= new SystemConfigSet();
// String 				strVersion 		= systemConfig.getSystemVersion();					// ����
// //��ǰ��(�𵨸�) ���� ��ȸ
// String 				goodsName 		= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)

// //�Ҵ���� DataStatement ��ü�� �ݳ�
// if (stmt != null ) ConnectionManager.freeStatement(stmt);



String auto = "";						//������
String serverIp = "";					//�������ּ�
String dvdDrive = "";					//������
String backuppath = "";
String preservationType = "";			//���� ���� ���� ����
String preservationMonth = "";			//���� ���� ��
String preservationCapacity = "";		//�ִ����
String originaltrans = "";				//��������
int backuptrans = 1;				//�������
String txt_Backup_Lastday = "";

int intBkShour = 0;
int intBkSmin = 0;


//String socketDriver = request.getParameter("socketDriver");	//�������

Vector vList = null;

String ftpHost = "";
String ftpWebHost = "";
String ftpUser = "";
String ftpPassword = "";
int ftpPort = 21;
String ftpRemotepath = "", ftpdir="";
int ftpPasv = 0;

//FtpConfigClass ftpClass = new FtpConfigClass();
//vList = ftpClass.FtpSelect(groupID);
vList = new Vector();
ResultSet rs = null;
try{
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	//�����κ��� DataStatement ��ü�� �Ҵ�
	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	String query = "SELECT ";
	query += "ftpIP, forwardIP, ftpUserID, ftpPasswd \n";
	query += ", "+stmt.getToChar("setDate", "YYYYMMDD")+" as setDate \n";
	query += ", saveRate, backupType, nicType \n";
	query += ", ftpdir \n";
	query += "FROM Table_RecordBackupftp ";
	//if(groupID.length()>0)
	query += "WHERE GROUPID = '"+groupID+"' ";
	
	if(groupID.length()>0){
		System.out.println("SQL :\n "+query);
		rs = stmt.executeQuery(query) ;
		
		while(rs.next()){
			FtpConfigBean ftpBean = new FtpConfigBean();

			/*ftpBean.setFtpHost(rs.getString("ftp_host"));
			ftpBean.setFtpWebHost(rs.getString("ftp_web_host"));
			ftpBean.setFtpUser(rs.getString("ftp_user"));
			ftpBean.setFtpPassword(rs.getString("ftp_password"));
			ftpBean.setFtpPort(rs.getInt("ftp_port"));
			ftpBean.setFtpRemotepath(rs.getString("ftp_remote_path"));
			ftpBean.setFtpPasv(rs.getInt("ftp_pasv"));*/
			
			ftpBean.setFtpHost(ftpHost = rs.getString("ftpIP"));
			ftpBean.setFtpWebHost(ftpWebHost = rs.getString("forwardIP"));
			ftpBean.setFtpUser(ftpUser = rs.getString("ftpUserID"));
			ftpBean.setFtpPassword(ftpPassword = rs.getString("ftpPasswd"));
//	 		ftpBean.setSaveRate(rs.getInt("saveRate"));
//	 		ftpBean.setSetDate(rs.getString("setDate"));
//	 		ftpBean.setBackupType(rs.getInt("backupType"));
//	 		ftpBean.setNicType(rs.getInt("nicType"));
			backuptrans = rs.getInt("backupType");
			txt_Backup_Lastday = rs.getString("setDate");
			ftpdir = rs.getString("ftpdir");
			
			vList.add(ftpBean);

		}//while
	}//if
	
	
}catch (Exception ex){
	System.out.println("Exception >> " + ex);
}finally{
	if(rs != null) try{rs.close(); } catch(SQLException se) { se.printStackTrace();}
	if(stmt != null ) ConnectionManager.freeStatement(stmt);
}
		//return vList;
		
int counter = vList.size();

if( 1!=1&& counter > 0){

	for(int i = 0; i < vList.size(); i++){
		FtpConfigBean FtpBean = (FtpConfigBean)vList.elementAt(i);

		ftpHost = FtpBean.getFtpHost();
		ftpWebHost = FtpBean.getFtpWebHost();
		ftpUser = FtpBean.getFtpUser();
		ftpPassword = FtpBean.getFtpPassword();
		ftpPort = FtpBean.getFtpPort();
		ftpRemotepath = FtpBean.getFtpRemotepath();
		ftpPasv = FtpBean.getFtpPasv();
// 		backuptrans = FtpBean.getBackupType();
// 		txt_Backup_Lastday = FtpBean.getSetDate();
	}

}

String ftpStr ="";
//if(backuptrans.equals("3") || backuptrans.equals("4")){
if(backuptrans==1){
	ftpStr = "";
}else{
	//ftpStr = "readonly";
}

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<title>���� FTP ���� ����</title>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>

<!--���̾�-->
<script language="javascript">
<!--

function goLeftSelectBoxMenu(thisTarget) {
	//alert(thisTarget);
}
function func_logoutCommit(type) {
 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
}

//�˾�
function goPopup(msg){

	var parm = '&parm='+msg;
	var url = "pop_alert.jsp";

	getPage2(url,parm);
}
//�˾�


function getPage(url, parm){
	inf('hidden');
	engine.execute("POST", url, parm, "ResgetPage");
}

function getPage2(url, parm){
	inf('hidden');
	engine.execute("POST", url, parm, "ResgetPage2");
}

function ResgetPage(data){
	//alert(data);
	if(data){
		document.getElementById('popup_layer').innerHTML = data;
		showAdCodeDiv();
	}else{
		alert("����") ;
	}
}

function ResgetPage2(data){
	//alert(data);
	if(data){
		document.getElementById('popup_layer2').innerHTML = data;
		showAdCodeDiv2();
	}else{
		alert("����") ;
	}
}

function showAdCodeDiv() {
	try{
		setShadowDivVisible(false); //��� layer
	}catch(e){
	}
	setShadowDivVisible(true); //��� layer

	var d_id 	= 'popup_layer';
	var obj 	= document.getElementById(d_id);

	obj.style.zIndex=998;
	obj.style.display = "";
	//obj.style.top =100;
	//obj.style.left = 400;

	obj.style.left = document.body.scrollLeft + (document.body.clientWidth / 2) - obj.offsetWidth/2;
	obj.style.top = document.body.scrollTop + (document.body.clientHeight / 2) - obj.offsetHeight/2;

	//obj.style.zIndex=998;
	//obj.style.display = "";
	//obj.style.top =0;
	//obj.style.left = 0;

	SET_DHTML('popup_layer');
}

function showAdCodeDiv2() {
	try{
		setShadowDivVisible(false); //��� layer
	}catch(e){
	}
	setShadowDivVisible(true); //��� layer

	var d_id 	= 'popup_layer2';
	var obj 	= document.getElementById(d_id);

	obj.style.zIndex=998;
	obj.style.display = "";
	//obj.style.top =100;
	//obj.style.left = 400;
	obj.style.left = document.body.scrollLeft + (document.body.clientWidth / 2) - obj.offsetWidth/2;
	obj.style.top = document.body.scrollTop + (document.body.clientHeight / 2) - obj.offsetHeight/2;




	SET_DHTML('popup_layer2');
	document.getElementById('popup_layer').style.display="none";

}

function hiddenAdCodeDiv() {
	inf('visible'); //select box ���̱�
	setShadowDivVisible(false); //��� layer ����

	document.getElementById('popup_layer').style.display="none";
}

function hiddenAdCodeDiv2() {
	inf('visible'); //select box ���̱�
	setShadowDivVisible(false); //��� layer ����
	//document.getElementById('popup_layer').style.display="block";
	document.getElementById('popup_layer2').style.display="none";
}

//-->
</script>
<!--���̾�-->


<script language="javascript">
<!--

	function edit()
	{
		var frm = document.form1;
		
		if(frm.ftphost.value == ""){
			goPopup("alertFtphost");
			return;
		}
/*
		if(frm.ftpport.value == ""){
			goPopup("alertFtpport");
			return;
		}

		if(frm.ftpuser.value == ""){
			goPopup("alertFtpuser");
			return;
		}

		if(frm.ftppassword.value == ""){
			goPopup("alertFtppassword");
			return;
		}

		if(frm.ftpremotepath.value == ""){
			goPopup("alertFtpremotepath");
			return;
		}
*/

		/*
		if(!blankValueMsg("form1","ipaddr","������ �ּҸ� �Է��ϼ���."))
		{
			return false;
		}
		*/
		/*if(!blankValueMsg("form1","backdrive","��θ� �����ϼ���."))
		{
			return false;
		}*/
		/*
		if(!blankValueMsg("form1","backuppath","��θ� �����ϼ���."))
		{
			return false;
		}
		*/

		/*if(frm.backdrive.value == 'C:\\')
		{
			alert("C����̺�� �����ϽǼ� �����ϴ�.");
			return;
		}
		*/
		
		frm.target="procframe";
		frm.action="backup_setting_pbx_ok.jsp";
		frm.method="post";
		frm.submit();
        
		//frm.action = "backup_setting_pbx_ok.jsp";
		//frm.submit();
	}

	function setTypeChange(strValue)
	{

		var frm = document.form1;

		frm.backuptype[0].checked = false;
		frm.backuptype[1].checked = false;
		frm.typeuse.disabled = true;
		frm.typemonth.disabled = true;

		if(strValue == "0")
		{
			frm.backuptype[0].checked = true;
			frm.typemonth.disabled = false;
		}
		else if(strValue == "1")
		{
			frm.backuptype[1].checked = true;
			frm.typeuse.disabled = false;
		}
	}


function chagebackup(backupValue){

	if(backupValue == "0" || backupValue == "1" || backupValue == "2"){
		document.getElementsByName("ftphost")[0].readOnly = true;
		document.getElementsByName("ftpwebhost")[0].readOnly = true;
		document.getElementsByName("ftpport")[0].readOnly = true;
		document.getElementsByName("ftpuser")[0].readOnly = true;
		document.getElementsByName("ftppassword")[0].readOnly = true;
		document.getElementsByName("ftpremotepath")[0].readOnly = true;

	}else if(backupValue == "3" || backupValue == "4"){
		document.getElementsByName("ftphost")[0].readOnly = false;
		document.getElementsByName("ftpwebhost")[0].readOnly = false;
		document.getElementsByName("ftpport")[0].readOnly = false;
		document.getElementsByName("ftpuser")[0].readOnly = false;
		document.getElementsByName("ftppassword")[0].readOnly = false;
		document.getElementsByName("ftpremotepath")[0].readOnly = false;

	}

}

// -->
</script>

<style type="text/css">
<!--

body {
	background-color: #ffffff;
}

#menu {
      width: 180px; height: 44px;
      /* position: fixed; top: 5px; z-index: 900/* 999 */; */
      background-color: #D6D6D6;
 }
#menu p { margin-left:45px; }
  
 #fwidth, .fwidth
{
	/*���� ���� ���� */
	width:expression(
	document.body.clientWidth <= 760 || document.body.clientWidth >= 960
	? (document.body.clientWidth <= 760 ? '760px' : '960px' )
	: '100%'
	);
	width:100%; min-width:180px; max-width:960px; /*** Mozilla ***/
} 
-->
</style>

</head>
<%-- <body onLoad="MM_preloadImages('imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')"> --%>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" <%if(nAllowUser<1) out.println("onLoad=\"goLogin();\""); %>>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

<div>

<table width="900" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>

<table width="180" align="left" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td width="180" style="min-width:180px;" >
		<% int menu = 4, submenu = 0; %>
		<table id="menu" width="180" style="background: #FFFFFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	</td>
  </tr>
<table>
<!--���������� end-->


		<!--������������ star-->
		<form name="form1" method="post">
<input type="hidden" name="ipaddr" value="<%=serverIp%>">
<input type="hidden" name="backuppath" value="<%=backuppath%>">
<input type="hidden" name="ftpport" value="<%=ftpPort%>">
<input type="hidden" name="ftpremotepath" value="<%=ftpRemotepath%>">
<!-- <input type="hidden" name="backuptype" value="1"> -->

		<table width="700" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
	        <td valign="bottom">
	          <table width="700" border="0" cellspacing="0" cellpadding="0" align="center" bgcolor="#FFFFFF" style="border:0 solid rgb(160,160,160); ">
		          <tr align="center" height="7" ></tr>
	              <tr align="center" height="22" >
	                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
	                  <td colspan="2" align="left">
	                  	<%	/*
	                  		java: int nAllowUser, String authGroupid, int userLevel, String userID
	                  		javascript: func_logoutCommit(1)
	                  		*/
	                  		String authGroupid = groupID;
	                  	%>
	                  	<%@ include file="../topUserMenu_ems.jsp"%>
	                  <%-- <% if(nAllowUser==1) {
	                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"�α׾ƿ�\" onclick=\"func_logoutCommit(1)\">") ;
	                  %>
	                  		<font style="color: blue;vertical-align: bottom;"><%=groupID+(userLevel!=2?"":groupID.length()==0?userID:"("+userID+")")%></font>
	                	 	<input type="button" name="btnLogout" style="height: 18px; width: 80px;" value="�α׾ƿ�" onclick="func_logoutCommit(1)">
	                	 	<input type="button" style="height: 18px; width: 50px;" value="����" onclick="document.location.href = 'backup_setting_pbx.jsp'">
		           	  <% }
	                  	else{ 
		           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"�α���\" onclick=\"document.location.href = '.'\">") ;
		           	  %>
	                  		<input type="button" name="btnLogin" style="height: 18px" value="�α���" onclick="document.location.href = 'backup_setting_pbx.jsp'"> 
		           	  <% } %> --%>
	                  </td>
	                  <td colspan="3"></td>
	                  <td colspan="2" width="300" align="right"> 
	                  	<% if(1!=1&& nAllowUser==1) { %>
	                  	<input type="button" name="btnNewAlarm" style="height: 18px; width: 50px;" value="���" onclick="goNewInsert()">
	                  	<input type="button" name="btnPutAlarm" style="height: 18px; width: 80px;" value="���� ���" onclick="func_setActionBySelected(0)">
	                  	<input type="button" name="btnDelAlarm" style="height: 18px; width: 80px;" value="���� ����" onclick="func_setActionBySelected(1)">
	                  	<% } %>
	                  </td>
	              </tr>
			  </table>
			</td>
		</tr>
		  <tr>
			<td>


			<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="margin:8 0 0 0 ">

				<tr>
					<td width="700" height="35" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" >

					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td align="right" style="width: 10px; ">
							</td>
							<td height="35" align="right" style="font-size: 13px; font-weight: bolder ; color: #303030; ">
								���� FTP ���� ����
								<%-- <img src="<%=StaticString.ContextRoot%>/imgs/content_title_backup_img.gif" width="134" height="20"> --%>
							</td>
							<td width="15"></td>
						</tr>
					</table>
					</td>
				</tr>

				<tr>
				  <td style="padding-top:16; padding-bottom:10; background:#eeeff0; border-bottom:1 solid #cdcecf; height:405" valign="top" >
				  <table width="700" border="0" cellspacing="0" cellpadding="1	" align="center" style="margin:0 0 0 0 ">
					<tr>
					  <td style="padding-bottom:5 ">
					  <!--���̺�-->
					  <table id=box width="700" border="0" cellspacing="0" cellpadding="0" align="center" >

							<tr>
								<td height="26px" >�� FTP ����</td>
							</tr>

							<tr>
								<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr><td width="10"></td>
										<td width="110">IP�ּ�</td>
										<td><input name="ftphost" type="text" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:100" value="<%=ftpHost%>" maxlength="30" <%=ftpStr%>></td>
									</tr>
									<tr>
										<td height="6" colspan="3"></td>
									</tr>
									<tr><td width="10"></td>
										<td width="110">���� ���</td>
										<td><input name="ftpdir" type="text" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:250" value="<%=ftpdir%>" maxlength="30" ></td>
									</tr>
									<tr>
										<td height="6" colspan="3"></td>
									</tr>
									<tr><td width="10"></td>
										<td>�����</td>
										<td><input name="ftpuser" type="text" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:100" value="<%=ftpUser%>" <%=ftpStr%>></td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>��й�ȣ</td>
										<td><input name="ftppassword" type="text" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:100" value="<%=ftpPassword%>" <%=ftpStr%>></td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>��� ���</td>
										<td>
											<select id="backuptype" name="backuptype" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:150px;" >
												<option value="0" <%if(0==backuptrans)out.print("selected");%>>��� �̻��</option>
										        <option value="1" <%if(1==backuptrans)out.print("selected");%>>���� FTP</option>
										        <option value="2" <%if(2==backuptrans)out.print("selected");%>>�ý��� HDD</option>
										        <option value="3" <%if(3==backuptrans)out.print("selected");%>>����FTP, �ý��� HDD</option>
										    </select>											
										</td>
									</tr>
								</table>

								</td>

							</tr>


							<tr>
								<td height="10">&nbsp;</td>
							</tr>

<input type="hidden" id="leftSelectBoxGlobal4" name="typeuse" value="">
							
<input type="hidden" id="checklan" name="checklan" value="">
<input type="hidden" id="checkwan" name="checkwan" value="">
<input type="hidden" id="checkgw" name="checkgw" value="">

<input type="hidden" name="checklanvalue" id="checklanvalue" value="<%//=strLanCheckValue%>" />
<input type="hidden" name="checkwanvalue" id="checkwanvalue" value="<%//=strWanCheckValue%>" />
<input type="hidden" name="checkgwvalue" id="checkgwvalue" value="<%//=strGwCheckValue%>" />
<%-- 
							<tr>
								<td height="10">&nbsp;</td>
							</tr>
							<tr>
								<td>�� NIC ����</td>
							</tr>

							<tr>
								<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr>
                                        <td width="10"></td>
										<td>
                                            <input type="checkbox" name="checklan" id="checklan" style="width:20px" value="Y" <%=strLanCheck%> /> lan
                                            <input type="checkbox" name="checkwan" id="checkwan" style="width:20px" value="Y" <%=strWanCheck%> /> wan
                                            <input type="checkbox" name="checkgw" id="checkgw" style="width:20px" value="Y" <%=strGwCheck%> /> gw

                                            <input type="hidden" name="checklanvalue" id="checklanvalue" value="<%=strLanCheckValue%>" />
                                            <input type="hidden" name="checkwanvalue" id="checkwanvalue" value="<%=strWanCheckValue%>" />
                                            <input type="hidden" name="checkgwvalue" id="checkgwvalue" value="<%=strGwCheckValue%>" />
                                        </td>
									</tr>
                                </table>
                                </td>
                            </tr>
 --%>
							<tr>
								<td height="10">&nbsp;</td>
							</tr>
							<tr align="center">
								<td>
								<table border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onclick="javascript:edit();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="cursor:pointer;"  width="40" height="20" align="absmiddle" ></td>
										<!--td width="6"></td>
										<td><img src="../imgs/Content_cancel_n_btn.gif"></td-->
									</tr>
								</table>
								</td>
							</tr>

					  </table>
					  <!--���̺�-->
					  </td>
					</tr>
				  </table>
				  </td>
				</tr>
				<!--����-->

			</table>

			</td>
		  </tr>
		</table>
		</form>
		<!--������������ end-->
    </td>
  </tr>

<!--footer �̹��� �߰� start-->
<%-- 
<tr>
    <td ><img src="<%=StaticString.ContextRoot%>/imgs/main_footer_img.gif" width="700" height="30"></td>
</tr>
 --%>
<!--footer �̹��� �߰� end-->
<iframe name="procframe" src="" width="0" height="0" style="display: none;"></iframe>

</table>
</div>
</body>
</html>

<!-- �˾� ���̾� -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>

<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>

