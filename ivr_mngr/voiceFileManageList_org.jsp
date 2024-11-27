<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.ipcs.IpcsListDTO" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>

<%@ page import="business.CommonData"%>
<%@ page import="system.SystemConfigSet"%>

<%
    SessionManager manager = SessionManager.getInstance();
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
	String menu       = "5";  // 음성 안내
	String submenu    = "4";  // 음성 파일 관리

	String new_menu     = "C";  		// 부가설정
	String new_submenu  = "5";  		// 음성 파일 관리
	
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// 서버로부터 DataStatement 객체를 할당
	DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);

	// 도메인 조회
	CommonData		commonData	= new CommonData();
	String 			domainid 	= commonData.getDomain(stmt);						// 도메인ID 조회
	String[]		tempDomain;
	if(!"".equals(domainid)){
		tempDomain 	= domainid.split("[.]");
		domainid	= tempDomain[0];			
	}
	// DDNS 버전 조회
	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				strVersion 		= systemConfig.getSystemVersion();					// 버젼
	//제품명(모델명) 버전 조회
	String 				goodsName 		= systemConfig.getGoodsName();						// 제품명(모델명)

	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);

	
	List voiceDTOList = (List)request.getAttribute("voiceDTOList");
	List usedVoiceDTOList = (List)request.getAttribute("usedVoiceDTOList");
	String strMsg = (String)request.getAttribute("msg");


%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: <%=domainid%>, Ver: <%=strVersion%></title>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<script>
	function goLeftSelectBoxMenu(thisTarget) {
		alert(thisTarget);
	}
</script>


<!-- ################################################### -->
<script language="javascript">
<!--

if (document.all)
{
	document.onkeydown = function()
	{
		var key_f5 = 116;
		if (key_f5 == event.keyCode)
		{
			event.keyCode = 0;
			//alert ("새로고침 사용을 금지합니다.");
			return false;
		}
		else
		{
			return true;
		}
	}
}

// 추가화면
function goInput(){

	var parm = '';		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceFileManageInputForm.do2";

	getPage(url,parm);
}

//수정화면
function goEdit(wIndex){

    var parm = '&wIndex='+wIndex;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceFileManageEditForm.do2";

	getPage(url,parm);
}

//삭제화면
function goDelete(wIndex,wFile){

    var parm = '&wIndex='+wIndex+'&wFile='+wFile;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceFileManageDeleteForm.do2";

	getPage(url,parm);
}


function getPage(url, parm){
	inf('hidden');
	engine.execute("POST", url, parm, "ResgetPage");
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

	SET_DHTML('popup_layer');
}

function hiddenAdCodeDiv() {
	inf('visible'); //select box 보이기
	setShadowDivVisible(false); //배경 layer 숨김

	document.getElementById('popup_layer').style.display="none";
}

// 음성파일 추가
function add() {


	var frm = document.addForm;

	if(frm.wName.value == "")
	{
		alert("음성제목을 입력하세요.");
		return;
	}

	if(frm.wFile.value == "")
	{
		alert("음성파일을 선택하세요.");
		return;
	}

	hiddenAdCodeDiv();

	frm.submit();
}

// 삭제
function del()
{
	var frm = document.delForm;

	hiddenAdCodeDiv();

	frm.submit();
	/*
	var delstr;
	delstr = subject + "을 정말 삭제하시겠습니까?";

	if(confirm(delstr))
	{
		document.location.href = "./voiceDel.do?wIndex=" + code + "&wFile=" + wfile;
	}*/
}

// 수정
function edit()
{
	var frm = document.editForm;

	hiddenAdCodeDiv();

	frm.submit();

}

// 해제
function unReg(subject, nwuIdx)
{
	var delstr;
	delstr = subject + "을 해제하시겠습니까?";

	if(confirm(delstr))
	{
		document.location.href = "./voiceFileMnageUnReg.do2?nwuIdx=" + nwuIdx;
	}
}

<%
    if(strMsg != null) {
%>
alert('<%=strMsg%>');
<%
    }
%>

//-->
</script>

<!-- ################################################### -->

</head>

<body onLoad="MM_preloadImages('imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')">
<div>
	<!-- ajax source file -->
	<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
	<!-- Drag and Drop source file -->
	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
	<!-- Shadow Div source file -->
	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>


<!--strat--상단페이지-->
<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
	<%@ include file="/menu/topMenu.jsp"%>
	</td>
  </tr>
</table>
<!--end--상단페이지-->

<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
		<!--strat--왼쪽페이지-->
		<table width="165" border="0" cellspacing="0" cellpadding="0"  align="left">
		<%  if("1".equals(loginLevel)){ %>
		<%@ include file="/menu/leftUserMenu.jsp"%>
		<%  }else if("2".equals(loginLevel)){   %>
		<%@ include file="/menu/leftAdminMenu.jsp"%>
		<%  }   %>
		</table>
		<!--end--왼쪽페이지-->

		<!--star--콘텐츠페이지-->
		<table width="835" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
			<td>

<!-- ################################################### -->


			<table width="803" border="0" cellspacing="0" cellpadding="0" align="center" style="margin:8 0 0 0 ">
	<tr>
		 <td width="803" height="35" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" >
			 <table border="0" cellpadding="0" cellspacing="0">
				  <tr>
				   <td height="35" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_soundfile_img.gif" width="103" height="20"></td>
				   <td width="15"></td>
				  </tr>
			 </table>
		 </td>
	</tr>
			   <tr>
				<td style="padding-top:16; padding-bottom:10; background:eeeff0; border-bottom:1 solid #cdcecf; border-top:0 solid #cdcecf; height:405" valign="top">
				  <table width="771" border="0" cellspacing="0" cellpadding="1	" align="center">
					<tr>
					  <td style="padding-bottom:5 ">

					  <table width="771" border="0" cellspacing="0" cellpadding="0" align="center">
						<tr>
						  <td width="173">
							  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif" onClick="goInput();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_p_btn.gif");' style="CURSOR:hand;" alt="음성파일추가">
						  </td>
						  <td width="150" valign="top"></td>
						  <td width="67">&nbsp;</td>
						  <td width="67">&nbsp;</td>
						  <td width="236">&nbsp;</td>
						  <td width="78" valign="top">
						  </td>
						</tr>
					  </table>


					  </td>
					</tr>
					<tr>
					  <td height="327" valign="top">

		  <div style="width:790; height:290; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">     <!-- 스크롤 적용 시작-->
					  <table id=box width="771" border="0" cellspacing="0" cellpadding="0" align="center" class="list_table">
						<tr height="22" bgcolor="rgb(190,188,182)" align="center" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">
							<td width="38" class="table_header01">No.</td>
							<td width="200" class="table_header01">음성제목</td>
							<td width="222" class="table_header01">파일명</td>
							<td width="110" class="table_header01">등록일</td>
							<td width="240" class="table_header01">현재설정</td>
							<td width="40" class="table_header01">수정</td>
							<td width="40" class="table_header01">삭제</td>
						</tr>
<%
	for(int i=0; i < voiceDTOList.size(); i++) {
%>
						<tr height="22" bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" align="center">
							<td class="table_column"><%=i+1%></td>
							<td class="table_column">&nbsp;<%=((VoiceDTO)voiceDTOList.get(i)).getWName()%></td>
							<td class="table_column">&nbsp;<a style="color:black" href="<%="/MS/"+ConnectionManager.getSysGroupName()%>/ipcs_files/fileupwav/<%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%>"><%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%></a></td>
							<td class="table_column"><%=((VoiceDTO)voiceDTOList.get(i)).getWRegDate().substring(0, 10)%></td>
							<td class="table_column">
<%
		if(((List)usedVoiceDTOList.get(i)).size() > 0) {
%>
								<table width="240" border="0" cellspacing="0" cellpadding="0" >
<%
			for(int j=0; j < ((List)usedVoiceDTOList.get(i)).size(); j++) {
				String strTmpWKind = "";
				if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuType().equals("A")) {
					strTmpWKind = "IVR";
				} else if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuType().equals("F")) {
					strTmpWKind = "컬러링";
				} else if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuType().equals("S")) {
					strTmpWKind = "부가서비스";
				}
%>
									<tr>
										<td height="22" width="200" align="left" >
											&nbsp;<%=strTmpWKind+" ["+((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuDefinition()+"]"%>
										</td>
										<td width="40" align="center" >
											<img src="<%=StaticString.ContextRoot%>/imgs/intable_disarm_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_disarm_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_disarm_p_btn.gif");' style="CURSOR:hand;"  width="34" height="18" align="absmiddle" onClick="javascript:unReg('<%=strTmpWKind+" ["+((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuDefinition()+"]"%>','<%=((UsedVoiceDTO)((List)usedVoiceDTOList.get(i)).get(j)).getNwuIdx()%>');" alt="현재설정에 적용된 음성파일을 해제합니다.">
										</td>
									</tr>
<%
				if(j < ((List)usedVoiceDTOList.get(i)).size()-1) {
%>
									<tr bgcolor="rgb(203,203,203)">
										<td></td>
										<td></td>
									</tr>
<%
				}
			} // End of for
%>
								</table>
<%
		} else {
%>
							&nbsp;
<%
		}
%>
							</td>

							<td class="table_column">
<%
		if(((List)usedVoiceDTOList.get(i)).size() > 0) {
%>
								&nbsp;
<%
		} else {
%>
								<img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif" onClick="goEdit(<%=((VoiceDTO)voiceDTOList.get(i)).getWIndex()%>);"  onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_p_btn.gif");' style="CURSOR:hand;" align="absmiddle" alt="수정">
<%
		}
%>
							</td>

							<td>
<%
		if(((List)usedVoiceDTOList.get(i)).size() > 0) {
%>
								&nbsp;
<%
		} else {
%>
								<img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif" onClick="goDelete('<%=((VoiceDTO)voiceDTOList.get(i)).getWIndex()%>','<%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_p_btn.gif");' style="CURSOR:hand;" align="absmiddle" alt="삭제">
<%
		}
%>
							</td>
						</tr>
<%
	} // End of for
%>

						<tr>
						  <td colspan="7"><img src="imgs/Content_undertable_img.gif" width="771" height="2"></td>
						</tr>
					  </table>
		  </div>     <!-- 스크롤 적용 끝-->

					  </td>
					</tr>

				  </table>

				</td>
			  </tr>

			</table>





			</td>
		  </tr>
		</table>

		<!--end--콘텐츠페이지-->
    </td>
  </tr>
<!----------------------- footer 이미지 추가 start ----------------------------->
<tr>
    <td ><img src="<%=StaticString.ContextRoot%>/imgs/main_footer_img.gif" width="1000" height="30"></td>
</tr>
<!----------------------- footer 이미지 추가   end ----------------------------->
</table>
</div>
</body>
</html>

<!-- 팝업 레이어 -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>


