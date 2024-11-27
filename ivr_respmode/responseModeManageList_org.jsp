<%@page import="acromate.common.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
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

	String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // ��������(1:�����, 2:������)
	String menu       = "5";  // ���� �ȳ�
	String submenu    = "3";  // ���� ��� ����

	String new_menu     = "C";  		// �ΰ�����
	String new_submenu  = "6";  		// ���� ��� ����
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	// �����κ��� DataStatement ��ü�� �Ҵ�
	DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);

	// ������ ��ȸ
	CommonData		commonData	= new CommonData();
	String 			domainid 	= commonData.getDomain(stmt);						// ������ID ��ȸ
	String[]		tempDomain;
	if(!"".equals(domainid)){
		tempDomain 	= domainid.split("[.]");
		domainid	= tempDomain[0];			
	}
	// DDNS ���� ��ȸ
	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				strVersion 		= systemConfig.getSystemVersion();					// ����
	//��ǰ��(�𵨸�) ���� ��ȸ
	String 				goodsName 		= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)

	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);

	
	List responseModeDTOList = (List) request.getAttribute("responseModeDTOList");
	List usedVoiceDTOList = (List) request.getAttribute("usedVoiceDTOList");
	List voiceDTOList = (List) request.getAttribute("voiceDTOList");
	String strMsg = (String) request.getAttribute("msg");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: <%=domainid%>, Ver: <%=strVersion%></title>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/function_ivr.js'></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
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
			//alert ("���ΰ�ħ ����� �����մϴ�.");
			return false;
		}
		else
		{
			return true;
		}
	}
}

//�Է�ȭ��
function goInput(){

    var parm = '';		//get�������� ���� ����.
	var url = "<%=StaticString.ContextRoot%>/responseModeManageInputForm.do2";

	getPage(url,parm);
}

//����ȭ��
function goEdit(scCode){

    var parm = '&scCode='+scCode;		//get�������� ���� ����.
	var url = "<%=StaticString.ContextRoot%>/responseModeManageEditForm.do2";

	getPage(url,parm);
}

//����ȭ��
function goDelete(){

	cbox = document.mainForm.delIndex;
	deleteCheck = "Y";

	var CheckCount = 0;
	if (cbox == null )
	{
		deleteCheck = "N";
	}

	if(cbox.length)
	{
	  for(var i = 0 ; i < cbox.length;i++)
	  {
		if(cbox[i].checked)
		{
			CheckCount = CheckCount + 1;
		}
	  }
	}
	else
	{
		if(cbox.checked)
		{
			CheckCount = CheckCount +1;
		}
		else
		{
			deleteCheck = "N";
		}
	}

	if(CheckCount == 0)
	{
		deleteCheck = "N";
	}

    var parm = 'deleteCheck='+deleteCheck;		//get�������� ���� ����.
	var url = "<%=StaticString.ContextRoot%>/responseModeManageDeleteForm.do2";

	getPage(url,parm);
}

//�˾�
function goPopup(type){

    var parm = '&type='+type;		//get�������� ���� ����.
	var url = "<%=StaticString.ContextRoot%>/voiceListPopupForm.do2";

	getPage2(url,parm);
}


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
	//document.getElementById('popup_layer').style.display="none";	    //
}


function hiddenAdCodeDiv() {
	inf('visible'); //select box ���̱�
	setShadowDivVisible(false); //��� layer ����

	document.getElementById('popup_layer').style.display="none";
}


function hiddenAdCodeDiv2() {
	inf('visible'); //select box ���̱�
	//setShadowDivVisible(false); //��� layer ����
	//document.getElementById('popup_layer').style.display="block";	// layer1 ���̱�
	document.getElementById('popup_layer2').style.display="none";

}



	var aResponseList = new Array(<%=responseModeDTOList.size()%>);

	for(var i=0; i < <%=responseModeDTOList.size()%>; i++)	{
		aResponseList[i] = new Array(2);
	}
<%
    for(int i=0; i < responseModeDTOList.size(); i++) {
%>
    aResponseList[<%=i%>][0] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>";
    aResponseList[<%=i%>][1] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%>";
<%
    }
%>






// �߰�
function add() {
	var frm = document.addForm;

	if(!blankValueMsg("addForm","scName","��������� �Է��ϼ���."))
	{
		return false;
	}


	if(!blankValueMsg("addForm","scHour","�ð��ʰ��� �Է��ϼ���."))
	{
		return false;
	}

	if(!onlyNumber("addForm","scHour"))
	{
		return false;
	}

	if(!blankValueMsg("addForm","scMakeCallTime","ȣ��ȯ�ð��� �Է��ϼ���."))
	{
		return false;
	}

	if(!onlyNumber("addForm","scMakeCallTime"))
	{
		return false;
	}

	if(!blankValueMsg("addForm","scAgain","�ڵ����Ḧ �Է��ϼ���."))
	{
		return false;
	}


	if(!onlyNumber("addForm","scAgain"))
	{
		return false;
	}

	hiddenAdCodeDiv();

	frm.submit();
}

// ����
function edit() {
	var frm = document.editForm;

	if(!blankValueMsg("editForm","scName","��������� �Է��ϼ���."))
	{
		return false;
	}


	if(!blankValueMsg("editForm","scHour","�ð��ʰ��� �Է��ϼ���."))
	{
		return false;
	}

	if(!onlyNumber("editForm","scHour"))
	{
		return false;
	}

	if(!blankValueMsg("editForm","scMakeCallTime","ȣ��ȯ�ð��� �Է��ϼ���."))
	{
		return false;
	}

	if(!onlyNumber("editForm","scMakeCallTime"))
	{
		return false;
	}

	if(!blankValueMsg("editForm","scAgain","�ڵ����Ḧ �Է��ϼ���."))
	{
		return false;
	}


	if(!onlyNumber("editForm","scAgain"))
	{
		return false;
	}

	hiddenAdCodeDiv();

	frm.submit();
}

// ����
function del() {
	var frm = document.mainForm;

	hiddenAdCodeDiv();

	frm.submit();
}

// �޺� ����� ó��
function changeOption(strValue,strName)
{
	var strNameArr;
	var objName1;
	var objName2;
	var iHtml;
	strNameArr = strName.split("key");
	objName1 = "option" + strNameArr[1];
	if(strValue == "02" || strValue == "08" || strValue == "06" || strValue == "01" || strValue == "07" || strValue == "41" || strValue == "44") {  // Edit
	    iHtml = "<input name='word" + strNameArr[1] + "' type='text' style=\"font-family:'12px Gulim'; font-size:12px;width:140; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);\" >";
	} else if(strValue == "04" || strValue == "09") {   // ������ �޺�
	    iHtml =  "<select name='word" + strNameArr[1] + "' class='input_box' style='width:130px'>";
        iHtml += "<option value='' selected></option>";
		for(var i=0; i < aResponseList.length; i++) {
			iHtml += "<option value='" + aResponseList[i][0] + "'>" + aResponseList[i][1] + "</option>";
		}
		iHtml += "</select>";
	} else if(strValue == "05") { //       ����, Q �޺�
	    iHtml =  "<select name='word" + strNameArr[1] + "' class='input_box' style='width:130px'>";
        iHtml += "<option value='' selected></option>";
        iHtml += "<option value='Q'>Quit</option>";
        iHtml += "</select>";
	} else if(strValue == "10" || strValue == "03" || strValue == "31" || strValue == "32" || strValue == "33" || strValue == "34"
              || strValue == "35" || strValue == "36" || strValue == "37" || strValue == "38" || strValue == "39" || strValue == "40"
			  || strValue == "42" || strValue == "43" || strValue == "45" || strValue == "46") {
		iHtml = "&nbsp;<input type='hidden' name ='word" + strNameArr[1] + "' value = ''>";
	}
	document.all[objName1].innerHTML = iHtml;
}


//üũ�ڽ� - ��缱��
function checkAll()
{
	cbox = document.mainForm.delIndex;
	if (cbox == null) return;
	if(cbox.length)
	{
		for(var i = 0 ; i < cbox.length;i++)
		{
			cbox[i].checked = document.mainForm.allCheck.checked;
		}
	}
	else
	{
		cbox.checked =  document.mainForm.allCheck.checked;
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

<!--strat--���������-->
<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
	<%@ include file="/menu/topMenu.jsp"%>
	</td>
  </tr>
</table>
<!--end--���������-->

<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
		<!--strat--����������-->
		<table width="165" border="0" cellspacing="0" cellpadding="0"  align="left">
		<%  if("1".equals(loginLevel)){ %>
		<%@ include file="/menu/leftUserMenu.jsp"%>
		<%  }else if("2".equals(loginLevel)){   %>
		<%@ include file="/menu/leftAdminMenu.jsp"%>
		<%  }   %>
		</table>
		<!--end--����������-->

		<!--star--������������-->
		<form name="mainForm" action="<%=StaticString.ContextRoot%>/responseModeManageDelete.do2" method="post">
		<table width="835" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
			<td>
			<table width="803" border="0" cellpadding="0" cellspacing="0" style="margin:8 0 0 0 " align="center">
	<tr>
		 <td width="803" height="35" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" >
			 <table border="0" cellpadding="0" cellspacing="0">
				  <tr>
				   <td height="35" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_respondmod_img.gif" width="103" height="20"></td>
				   <td width="15"></td>
				  </tr>
			 </table>
		 </td>
	</tr>
			   <tr>
				<td style="padding-top:16; padding-bottom:10; background:eeeff0; border-bottom:1 solid #cdcecf; border-top:0 solid #cdcecf; height:405" valign="top" >
				  <table width="771" border="0" cellspacing="0" cellpadding="1	" align="center">
					<tr>
					  <td style="padding-bottom:5 ">
					  <table width="771" border="0" cellspacing="0" cellpadding="0" align="center">
						<tr>
						  <td width="173">
							  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif" onClick="goInput();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_p_btn.gif");' style="CURSOR:hand;" alt="�������߰�">

							  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif" onClick="goDelete();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_p_btn.gif");' style="CURSOR:hand;" alt="���������">
						  </td>
						  <td width="154" valign="top"></td>
						  <td width="67">&nbsp;</td>
						  <td width="67">&nbsp;</td>
						  <td width="232">&nbsp;</td>
						  <td width="78" valign="top">
						  </td>
						</tr>
					  </table>
					  </td>
					</tr>

					<tr>
						<td>

		  <div style="width:789; height:290; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">     <!-- ��ũ�� ���� ����-->
							<!--���̺�-->
							<table id=box width="771" border="0" cellspacing="0" cellpadding="0" align="center" class="list_table">
								<tr height="22" bgcolor="rgb(190,188,182)" align="center" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">
									<td width="38" class="table_header01"><input name="allCheck" type="checkbox" value="Y" style="width:20" onclick="javascript:checkAll();"></td>
									<td width="38" class="table_header01">No.</td>
									<td width="218" class="table_header01">���� ��� �̸�</td><!--�輱�� ���� 222-->
									<td width="188" class="table_header01">����� ����</td>
									<td width="38" class="table_header01">���</td>
									<td width="160" class="table_header01">CID ǥ��</td>
									<td width="87"  style="color:#FFFFFF">����</td>
								</tr>
<%
	for (int i = 0; i < responseModeDTOList.size(); i++) {
%>
								<tr height="22" bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" align="center">
									<td class="table_column"><input name="delIndex" type="checkbox" value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>,<%=((ResponseModeDTO)responseModeDTOList.get(i)).getNwuIdx()%>" style="width:20"></td>
									<td class="table_column"><%=i+1%></td>
									<td class="table_column">&nbsp;<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></td>
									<td class="table_column"><%=usedVoiceDTOList.get(i) != null ? ((VoiceDTO)voiceDTOList.get(i)).getWName() : "&nbsp;"%></td>
									<td class="table_column"><%
											String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
											String print_html = usedVoiceDTOList.get(i) != null ? "<a style=\"color:black\" href=\""+ "/MS/"+sesSysGroupName +"/ipcs_files/fileup/" + ((UsedVoiceDTO)usedVoiceDTOList.get(i)).getNwuFileName() + "\"><img src=\"" + StaticString.ContextRoot  + "/imgs/Content_monit_play_p_btn.gif\" onmouseout='javascript:fncOverOut(this,\"" + StaticString.ContextRoot + "/imgs/Content_monit_play_p_btn.gif\");' onmouseover='javascript:fncOverOut(this,\"" + StaticString.ContextRoot + "/imgs/Content_monit_play_n_btn.gif\");' style=\"CURSOR:hand;\" width=\"14\" height=\"14\" border = \"0\"></a>" : "&nbsp;";
											out.print(print_html);
										%></td>
									<td class="table_column"><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCidRoute().equals("N") ? "���Ź�ȣ + ARS �Բ� ǥ��" : "ARS�� ǥ��"%></td>
									<td>
										<img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif" onClick="goEdit('<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_p_btn.gif");' style="CURSOR:hand;" align="absmiddle" alt="����">
									</td>
								</tr>
<%
	}
%>
								<tr>
								  <td colspan="7"><img src="<%=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif" width="771" height="2"></td>
								</tr>
							</table>
							<!--���̺�-->
		  </div>     <!-- ��ũ�� ���� ��-->

						</td>
					</tr>
				  </table>
				</td>
			  </tr>
			</table>
			</td>
		  </tr>
		</table>
		</form>
		<!--end--������������-->
    </td>
  </tr>
<!----------------------- footer �̹��� �߰� start ----------------------------->
<tr>
    <td ><img src="<%=StaticString.ContextRoot%>/imgs/main_footer_img.gif" width="1000" height="30"></td>
</tr>
<!----------------------- footer �̹��� �߰�   end ----------------------------->
</table>

</div>
</body>
</html>
<!-- �˾� ���̾� -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
