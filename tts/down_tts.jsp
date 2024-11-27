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

String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
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

// String menu       = "6";  // 프리미엄 서비스
// String submenu    = "4";  // 녹음 파일 백업 설정

String new_menu     = "E";  		// 관리
String new_submenu  = "11";  		// TTS 은원파일 생성
//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
//DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);

// // 도메인 조회
// CommonData		commonData	= new CommonData();
// String 			domainid 	= commonData.getDomain(stmt);						// 도메인ID 조회
// String[]		tempDomain;
// if(!"".equals(domainid)){
// 	tempDomain 	= domainid.split("[.]");
// 	domainid	= tempDomain[0];			
// }
// // DDNS 버전 조회
// SystemConfigSet 	systemConfig 	= new SystemConfigSet();
// String 				strVersion 		= systemConfig.getSystemVersion();					// 버젼
// //제품명(모델명) 버전 조회
// String 				goodsName 		= systemConfig.getGoodsName();						// 제품명(모델명)

// //할당받은 DataStatement 객체는 반납
// if (stmt != null ) ConnectionManager.freeStatement(stmt);

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<title>TTS 음원파일 생성</title>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>

<!--레이어-->
<script language="javascript">
<!--

function goLeftSelectBoxMenu(thisTarget) {
	//alert(thisTarget);
}
function func_logoutCommit(type) {
 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
}

//팝업
function goPopup(msg){

	var parm = '&parm='+msg;
	var url = "pop_alert.jsp";

	getPage2(url,parm);
}
//팝업


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
		alert("에러") ;
	}
}

function ResgetPage2(data){
	//alert(data);
	if(data){
		document.getElementById('popup_layer2').innerHTML = data;
		showAdCodeDiv2();
	}else{
		alert("에러") ;
	}
}

function showAdCodeDiv() {
	try{
		setShadowDivVisible(false); //배경 layer
	}catch(e){
	}
	setShadowDivVisible(true); //배경 layer

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
		setShadowDivVisible(false); //배경 layer
	}catch(e){
	}
	setShadowDivVisible(true); //배경 layer

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
	inf('visible'); //select box 보이기
	setShadowDivVisible(false); //배경 layer 숨김

	document.getElementById('popup_layer').style.display="none";
}

function hiddenAdCodeDiv2() {
	inf('visible'); //select box 보이기
	setShadowDivVisible(false); //배경 layer 숨김
	//document.getElementById('popup_layer').style.display="block";
	document.getElementById('popup_layer2').style.display="none";
}

//-->
</script>
<!--레이어-->


<script language="javascript">
<!--
	function onChangeTextSize(){
	 	var text = document.getElementById('text').value;
	 	document.getElementById('TEXT_SIZE').innerHTML = text.length; 
	}
	
	function onDownload(){
	
		var text = document.getElementById('text').value;
		var emotion = document.getElementById('emotion').value;
		var volume = document.getElementById('volume').value;
		var format = document.getElementById('format').value;
		var speaker = document.getElementById('speaker').value;
	
		if(text.trim() == ""){
			//goPopup("alertFtphost");
			alert('TEXT 내용을 입력해 주세요.');
			return;
		}
		
		var frm = document.form1;
		
		frm.target="procframe";
		frm.action="down_tts_ok.jsp";
		frm.method="post";
		frm.submit();
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
	/*가변 길이 설정 */
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
<!--왼쪽페이지 end-->

		<!--콘텐츠페이지 star-->
		<form name="form1" method="post" accept-charset="utf-8">
		
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
	                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"로그아웃\" onclick=\"func_logoutCommit(1)\">") ;
	                  %>
	                  		<font style="color: blue;vertical-align: bottom;"><%=groupID+(userLevel!=2?"":groupID.length()==0?userID:"("+userID+")")%></font>
	                	 	<input type="button" name="btnLogout" style="height: 18px; width: 80px;" value="로그아웃" onclick="func_logoutCommit(1)">
	                	 	<input type="button" style="height: 18px; width: 50px;" value="갱신" onclick="document.location.href = 'down_tts.jsp'">
		           	  <% }
	                  	else{ 
		           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
		           	  %>
	                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'down_tts.jsp'"> 
		           	  <% } %> --%>
	                  </td>
	                  <td colspan="3"></td>
	                  <td colspan="2" width="300" align="right"> 
	                  	<% if(1!=1&& nAllowUser==1) { %>
	                  	<input type="button" name="btnNewAlarm" style="height: 18px; width: 50px;" value="등록" onclick="goNewInsert()">
	                  	<input type="button" name="btnPutAlarm" style="height: 18px; width: 80px;" value="선택 등록" onclick="func_setActionBySelected(0)">
	                  	<input type="button" name="btnDelAlarm" style="height: 18px; width: 80px;" value="선택 해제" onclick="func_setActionBySelected(1)">
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
								TTS 음원파일 생성
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
					  <!--테이블-->
					  <table id=box width="700" border="0" cellspacing="0" cellpadding="0" align="center" >
							<!-- 
							<tr>
								<td>● FTP 설정</td>
							</tr> 
							-->
							<tr>
								<td>
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<!--  -->
									<tr>
										<td height="6" colspan="3"></td>
									</tr>
									<tr><td width="10"></td>
										<td width="110">TEXT</td>
										<td><textarea id="text" name="text"
												cols="20" rows="5" maxlength="200"
												style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207); width:400px; height:100px; " 
												onkeyup="onChangeTextSize()"
												></textarea>
												<span style="text-align: left; "><span id="TEXT_SIZE" >0</span> 자 / 200 자</span>
										</td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>감정</td>
										<td>
											<select id="emotion" name="emotion" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:150px;" >
												<option value="0" selected >기본 음성</option>
												<option value="1" selected >어두운 음성</option>
												<option value="2" selected >밝은 음성</option>
										    </select>											
										</td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>볼륨</td>
										<td>
											<select id="volume" name="volume" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:150px;" >
												<option value="5" >5</option>
												<option value="4" >4</option>
												<option value="3" >3</option>
												<option value="2" >2</option>
												<option value="1" >1</option>
												<option value="0" selected>0</option>
										        <option value="-1" >-1</option>
										        <option value="-2" >-2</option>
										        <option value="-3" >-3</option>
										        <option value="-4" >-4</option>
										        <option value="-5" >-5</option>
										    </select>											
										</td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>포멧</td>
										<td>
											<select id="format" name="format" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:150px;" >
												<option value="wav" >wav</option>
										        <option value="mp3" selected>mp3</option>
										    </select>											
										</td>
									</tr>
									<tr> <td height="6" colspan="3"></td> </tr>
									<tr><td width="10"></td>
										<td>스피커</td>
										<td>
											<select id="speaker" name="speaker" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);margin:0 0 2 0;width:150px;" >
												<option value="nara" selected >한국어-여성</option>
										    </select>											
										</td>
									</tr>
								</table>
								</td>
							</tr>
							
							<tr>
								<td height="10">&nbsp;</td>
							</tr>
							<tr>
								<td height="10">&nbsp;</td>
							</tr>
							<tr align="center">
								<td>
								<table border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onclick="javascript: onDownload();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="cursor:pointer;"  width="40" height="20" align="absmiddle" ></td>
										<!--td width="6"></td>
										<td><img src="../imgs/Content_cancel_n_btn.gif"></td-->
									</tr>
								</table>
								</td>
							</tr>

					  </table>
					  <!--테이블-->
					  </td>
					</tr>
				  </table>
				  </td>
				</tr>
				<!--내용-->

			</table>

			</td>
		  </tr>
		</table>
		</form>
		<!--콘텐츠페이지 end-->
    </td>
  </tr>

<iframe name="procframe" src="" width="0" height="0" style="display: none;"></iframe>

</table>
</div>
</body>
</html>

<!-- 팝업 레이어 -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>

<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>

