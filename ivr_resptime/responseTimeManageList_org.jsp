<%@ page language="java" contentType="text/html; charset=EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseTimeDTO"%>
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
	String menu       = "5";  // 음성안내
	String submenu    = "2";  // 응답 시간 관리

	String new_menu     = "C";  		// 부가설정
	String new_submenu  = "7";  		// 응답 시간 관리
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

	
	List responseModeDTOList = (List) request.getAttribute("responseModeDTOList");
	List modeSettingDTOList = (List)request.getAttribute("modeSettingDTOList");
    List usedVoiceDTOList = (List) request.getAttribute("usedVoiceDTOList");
    List voiceDTOList = (List) request.getAttribute("voiceDTOList");
	String strMsg = (String)request.getAttribute("msg");
	List hourList = (List)request.getAttribute("hourList");
	List minuteList = (List)request.getAttribute("minuteList");
	List responseTimeDTO1List = (List)request.getAttribute("responseTimeDTO1List");

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
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/function_ivr.js'></script>
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

function addResponseMode(strType) {
	var frm;
	var formName;
	if(strType == "ADD_FORM") {
	    frm = document.addForm;
		formName = "addForm";
	} else {
	    frm = document.editForm;
		formName = "editForm";
	}

	if(!blankValueMsg(formName,"scName","응답모드명을 입력하세요."))
	{
		return false;
	}

	if(!blankValueMsg(formName,"scHour","시간초과를 입력하세요."))
	{
		return false;
	}

	if(!onlyNumber(formName,"scHour"))
	{
		return false;
	}

	if(!blankValueMsg(formName,"scMakeCallTime","호전환시간을 입력하세요."))
	{
		return false;
	}

	if(!onlyNumber(formName,"scMakeCallTime"))
	{
		return false;
	}

	if(!blankValueMsg(formName,"scAgain","자동종료를 입력하세요."))
	{
		return false;
	}


	if(!onlyNumber(formName,"scAgain"))
	{
		return false;
	}

    var parm = "";		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/responseModeInput.do2";

	parm += "&scName=" + encodeURIComponent(frm.scName.value);
	parm += "&scHour=" + frm.scHour.value;
	parm += "&scMakeCallTime=" + frm.scMakeCallTime.value;
	parm += "&scLang=" + frm.scLang.value;
	parm += "&scLogCheck=" + frm.scLogCheck.value;
	parm += "&scAgain=" + frm.scAgain.value;
	parm += "&keyto=" + frm.keyto.value;
	parm += "&wordto=" + frm.wordto.value;
	parm += "&key0=" + frm.key0.value;
	parm += "&word0=" + frm.word0.value;
	parm += "&key1=" + frm.key1.value;
	parm += "&word1=" + frm.word1.value;
	parm += "&key2=" + frm.key2.value;
	parm += "&word2=" + frm.word2.value;
	parm += "&key3=" + frm.key3.value;
	parm += "&word3=" + frm.word3.value;
	parm += "&key4=" + frm.key4.value;
	parm += "&word4=" + frm.word4.value;
	parm += "&key5=" + frm.key5.value;
	parm += "&word5=" + frm.word5.value;
	parm += "&key6=" + frm.key6.value;
	parm += "&word6=" + frm.word6.value;
	parm += "&key7=" + frm.key7.value;
	parm += "&word7=" + frm.word7.value;
	parm += "&key8=" + frm.key8.value;
	parm += "&word8=" + frm.word8.value;
	parm += "&key9=" + frm.key9.value;
	parm += "&word9=" + frm.word9.value;
	parm += "&keya=" + frm.keya.value;
	parm += "&worda=" + frm.worda.value;
	parm += "&keyb=" + frm.keyb.value;
	parm += "&wordb=" + frm.wordb.value;
	parm += "&keyc=" + frm.keyc.value;
	parm += "&wordc=" + frm.wordc.value;
	parm += "&keyd=" + frm.keyd.value;
	parm += "&wordd=" + frm.wordd.value;
	parm += "&keyas=" + frm.keyas.value;
	parm += "&wordas=" + frm.wordas.value;
	parm += "&keysh=" + frm.keysh.value;
	parm += "&wordsh=" + frm.wordsh.value;
	parm += "&dgCheck=" + frm.dgCheck.value;
	parm += "&wfile=" + frm.wfile.value;
	parm += "&wcode=" + frm.wcode.value;
	parm += "&scCidRoute=" + frm.scCidRoute.value;
	parm += "&type=" + strType;

	engine.execute("POST", url, parm, "ResponseModeAddResult");

}

function trim(strSource) {
    re = /^\s+|\s+$/g;
    return strSource.replace(re, '');
}

function ResponseModeAddResult(data){
	var result = trim(data);
	var params = result.split("^");
	if(params[0] != "-1") {
	    responseModeInput(params[0], params[1], params[2], params[3], params[4]);
		alert("응답모드가 추가되었습니다.")
	} else {
	    alert(params[1]);
	}
}



//입력화면
function goInput(){

    var parm = '';		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/responseTimeManageInputForm.do2";

	getPage(url,parm);
}

//수정화면
function goEdit(amIndex){

    var parm = '&amIndex='+amIndex;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/responseTimeManageEditForm.do2";

	getPage(url,parm);
}

//삭제화면
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

    var parm = 'deleteCheck='+deleteCheck;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/responseTimeManageDeleteForm.do2";

	getPage(url,parm);
}


//팝업
function goPopup(type){
    var parm = '&type='+type;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceListPopupForm.do2";
	getPage2(url,parm);
}

function goPopup2(time1,time2,scCode,trIdx,type){
    var parm = '&time1='+time1+'&time2='+time2+'&scCode='+scCode+"&trIdx="+trIdx+"&type="+type;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/responseTimeEditPopupForm.do2";
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
}


function hiddenAdCodeDiv() {
	inf('visible'); //select box 보이기
	setShadowDivVisible(false); //배경 layer 숨김

	document.getElementById('popup_layer').style.display="none";
}

function hiddenAdCodeDiv2() {
	inf('visible'); //select box 보이기
	//setShadowDivVisible(false); //배경 layer 숨김

	document.getElementById('popup_layer2').style.display="none";
}

//추가
///////////////////////////////////////////////////////////
//응답모드 추가//
function responseModeInput(strScCode, strScName, strType, strVoiceFile, strWName){

	var frm;
    if(strType == "ADD_FORM") {
		frm = document.addForm;
    } else {
		frm = document.editForm;
    }

	var naScCodeLength;		//셀렉트갯수
	var scName;				//응답모드 이름
	var iframeResponseTime;	//아이프레임


	var iHtml = "";
	document.all["voiceTitle"].innerHTML = " 적용된 음성 ";
	if(strVoiceFile == "NON")
	    iHtml = "없음";
	else
	    iHtml = "<a style=\"color:black\" href=\"<%=StaticString.ContextRoot%>/ivr/fileup/" + strVoiceFile + "\">" + strWName + "</a>";
	document.all["voiceContent"].innerHTML = iHtml;

	naScCodeLength = frm.naScCode.length;

	//수정20090210
	//scName = frm.scName.value;

	iframeResponseTime = responseTimeIframe.document.getElementById("responseTimeIframeDiv");

	//옵션 추가
	frm.naScCode.options[naScCodeLength] = new Option(strScName, strScCode);

	div1 = "<div id='responseDiv"+strScCode+"'>";
	div2 = "</div>";

	//아이프렘임에 추가
	iframeResponseTime.innerHTML =iframeResponseTime.innerHTML + div1 + document.getElementById("responseMode").innerHTML + div2;

	clearElement(strType);




}
//응답모드 추가//



//아이프레임 비우기
function iframeClean(){

responseTimeIframe.document.getElementById("responseTimeIframeDiv").innerHTML = "";

//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = "";

}
//아이프레임 비우기
function editTime(strType, strTrIdx, strNewTime1, strNewTime2, strNewScCode, strNewScName) {


	var tdBgcolor = document.getElementsByName("tdHidden5");
	var trTime1 = document.getElementsByName("tdHidden1");
	var trTime2 = document.getElementsByName("tdHidden2");
	var trScCode = document.getElementsByName("tdHidden4");
	var tdBgcolorCount = 0;

	var subTrCount = document.getElementsByName("subTr").length;	//tr갯수

	var creTr = document.createElement("tr");				//tr
	creTr.id = "subTr";

	for(var i=0;i<tdBgcolor.length;i++){
		if( i != strTrIdx-1) {
			if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
			{
				tdBgcolorCount = tdBgcolorCount + 1;
				if(strNewTime1 == trTime1[i].value && strNewTime2 == trTime2[i].value && strNewScCode == trScCode[i].value) {
					alert("이미 추가된 설정입니다.");
					return;
				} else if(strNewTime1 == trTime1[i].value && strNewTime2 == trTime2[i].value) {
					alert("이미 추가된 시간입니다.");
					return;
				}
			}
		}
	}


	document.getElementsByName("tdIdx")[strTrIdx-1].innerHTML = strNewTime1 + ":" + strNewTime2 + "부터";
	document.getElementsByName("tdIdx2")[strTrIdx-1].innerHTML = strNewScName;

	document.getElementsByName("tdHidden1")[strTrIdx-1].value = strNewTime1;
	document.getElementsByName("tdHidden2")[strTrIdx-1].value = strNewTime2;
	document.getElementsByName("tdHidden3")[strTrIdx-1].value = strNewScName;
	document.getElementsByName("tdHidden4")[strTrIdx-1].value = strNewScCode;
	if(strType == "ADD_FORM")
	    document.getElementsByName("tdHidden5")[strTrIdx-1].value = "I";
	else
		document.getElementsByName("tdHidden5")[strTrIdx-1].value = "E";



	var editImg = document.getElementsByName("editImg");
	editImg[strTrIdx-1].onclick = function() {goPopup2(strNewTime1,strNewTime2,strNewScCode,strTrIdx,strType);};


	hiddenAdCodeDiv2();
}

//시간별 응답모드 추가
function insertTime(type){

	var time1 = document.getElementById("time1").value;
	var time2 =	document.getElementById("time2").value;
	var naScCodeValue =	document.getElementById("naScCode").value;
	var	selectIndex = document.getElementById("naScCode").options.selectedIndex;
	var naScCodeText = document.getElementById("naScCode").options[selectIndex].text;
	var totalTime = time1 + ":" + time2 + "부터";


	var tdBgcolor = document.getElementsByName("tdHidden5");
	var trTime1 = document.getElementsByName("tdHidden1");
	var trTime2 = document.getElementsByName("tdHidden2");
	var trScCode = document.getElementsByName("tdHidden4");
	var tdBgcolorCount = 0;

	var subTrCount = document.getElementsByName("subTr").length;	//tr갯수

	var creTr = document.createElement("tr");				//tr
	creTr.id = "subTr";


	//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
	//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(243,247,245)";};


	for(var i=0;i<tdBgcolor.length;i++){
		if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
		{
			tdBgcolorCount = tdBgcolorCount + 1;
			if(time1 == trTime1[i].value && time2 == trTime2[i].value && naScCodeValue == trScCode[i].value) {
				alert("이미 추가된 설정입니다.");
				return;
			} else if(time1 == trTime1[i].value && time2 == trTime2[i].value) {
				alert("이미 추가된 시간입니다.");
				return;
			}

		}
	}


	if( tdBgcolorCount % 2  == 0 ){
		creTr.style.cssText = "background-color:rgb(243,247,245)";
		//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(243,247,245)";};
		//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
	}else{
		creTr.style.cssText = "background-color:rgb(255,255,255)";
		//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(255,255,255)";};
		//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
	}


	var creTd = document.createElement("td");				//td
	creTd.style.cssText = "border-right:1 solid #cbcbcb;padding-top:2; text-align:center";
	creTd.id = "tdIdx";
	creTd.name = "tdIdx";


	var creText = document.createTextNode(totalTime);		//text

	var creHidden = document.createElement("input");		//hidden
	creHidden.type = "hidden";
	creHidden.name = "tdHidden1";
	creHidden.id = "tdHidden1";
	creHidden.value = time1;

	var creHidden2 = document.createElement("input");		//hidden
	creHidden2.type = "hidden";
	creHidden2.name = "tdHidden2";
	creHidden2.id = "tdHidden2";
	creHidden2.value = time2;

	var creTd2 = document.createElement("td");				//td
	creTd2.style.cssText = "border-right:1 solid #cbcbcb;padding-top:2; text-align:center";
	creTd2.id = "tdIdx2";
	creTd2.name = "tdIdx2";
	var creText2 = document.createTextNode(naScCodeText);	//text

	var creHidden3 = document.createElement("input");		//hidden
	creHidden3.type = "hidden";
	creHidden3.name = "tdHidden3";
	creHidden3.id = "tdHidden3";
	creHidden3.value = naScCodeText;

	var creTd3 = document.createElement("td");				//td
	creTd3.align = "center";

	var creImg = document.createElement("img");				//img
	creImg.name = "editImg";
	creImg.id = "editImg";
	creImg.src = "<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif";
	creImg.width = "34";
	creImg.height = "18";
	creImg.border = "0";
	creImg.align = "absmiddle";
	//alert(document.getElementsByName("tdHidden4")[tdBgcolor.length]);
	//if(tdBgcolor.length == 0)
	    creImg.onclick = function(){goPopup2(time1,time2,naScCodeValue,subTrCount+1,type);};
	//else
	//    creImg.onclick = function(){goPopup2(time1,time2,document.getElementsByName("tdHidden4")[tdBgcolor.length].value,subTrCount+1,type);};
	creImg.onmouseout = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif");};
	creImg.onmouseover = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif");};
	creImg.style.cssText = "cursor:hand";

	var creText3 = document.createTextNode(" ");			//text

	var creImg2 = document.createElement("img");			//img
	creImg2.src = "<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif";
	creImg2.width = "34";
	creImg2.height = "18";
	creImg2.border = "0";
	creImg2.align = "absmiddle";
	creImg2.onclick = function(){deleteTime(subTrCount+1);};
	creImg2.style.cssText = "cursor:hand";
	creImg2.onmouseout = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif");};
	creImg2.onmouseover = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif");};

	var creHidden4 = document.createElement("input");		//hidden
	creHidden4.type = "hidden";
	creHidden4.name = "tdHidden4";
	creHidden4.id = "tdHidden4";
	creHidden4.value = naScCodeValue;

	var creHidden5 = document.createElement("input");		//hidden
	creHidden5.type = "hidden";
	creHidden5.name = "tdHidden5";
	creHidden5.id = "tdHidden5";
	creHidden5.value = "I";

	var creHidden6 = document.createElement("input");		//hidden
	creHidden6.type = "hidden";
	creHidden6.name = "tdHidden6";
	creHidden6.id = "tdHidden6";
	creHidden6.value = "0";


	creTd.appendChild(creText);
	creTd2.appendChild(creText2);
	creTd3.appendChild(creImg);
	creTd3.appendChild(creText3);
	creTd3.appendChild(creImg2);
	creTr.appendChild(creHidden);
	creTr.appendChild(creHidden2);
	creTr.appendChild(creHidden3);
	creTr.appendChild(creHidden4);
	creTr.appendChild(creHidden5);
	creTr.appendChild(creHidden6);

	creTr.appendChild(creTd);
	creTr.appendChild(creTd2);
	creTr.appendChild(creTd3);

	document.getElementById("subTbody").appendChild(creTr);

	//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = document.getElementById("responseTimeDiv").innerHTML;

}
//시간별 응답모드 추가


//시간별 응답모드 삭제
function deleteTime(num){
	document.getElementsByName("tdHidden5")[num-1].value = "D";
	document.getElementsByName("subTr")[num-1].style.display = "none";


	var tdBgcolor = document.getElementsByName("tdHidden5");

	var j = 0;
	for(var i=0;i<tdBgcolor.length;i++){

		if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
		{

			if( j % 2  == 0 ){
				document.getElementsByName("subTr")[i].style.cssText = "background-color:rgb(255,255,255)";
			}
			else{
				document.getElementsByName("subTr")[i].style.cssText = "background-color:rgb(243,247,245)";
			}

			j = j +1

		}

	}

	//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = document.getElementById("responseTimeDiv").innerHTML;
}

//시간별 응답모드 삭제


///////////////////////////////////////////////////////////








	var aResponseList = new Array(<%=responseModeDTOList.size()%>);

	for(var i=0; i < <%=responseModeDTOList.size()%>; i++)	{
		aResponseList[i] = new Array(26);
	}
<%
    for(int i=0; i < responseModeDTOList.size(); i++) {
%>
    aResponseList[<%=i%>][0] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>";
    aResponseList[<%=i%>][1] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%>";
    aResponseList[<%=i%>][2] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScVoiceFile()%>";
    aResponseList[<%=i%>][3] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScHour()%>";
    aResponseList[<%=i%>][4] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScAgain()%>";
    aResponseList[<%=i%>][5] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScMakeCallTime()%>";
    aResponseList[<%=i%>][6] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCidRoute()%>";
    aResponseList[<%=i%>][7] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyTo()%>";
    aResponseList[<%=i%>][8] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyA()%>";
    aResponseList[<%=i%>][9] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyB()%>";
    aResponseList[<%=i%>][10] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyC()%>";
    aResponseList[<%=i%>][11] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyD()%>";
    aResponseList[<%=i%>][12] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getDgCheck()%>";
    aResponseList[<%=i%>][13] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey1()%>";
    aResponseList[<%=i%>][14] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey2()%>";
    aResponseList[<%=i%>][15] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey3()%>";
    aResponseList[<%=i%>][16] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey4()%>";
    aResponseList[<%=i%>][17] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey5()%>";
    aResponseList[<%=i%>][18] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey6()%>";
    aResponseList[<%=i%>][19] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey7()%>";
    aResponseList[<%=i%>][20] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey8()%>";
    aResponseList[<%=i%>][21] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey9()%>";
    aResponseList[<%=i%>][22] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey0()%>";
    aResponseList[<%=i%>][23] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyAs()%>";
    aResponseList[<%=i%>][24] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeySh()%>";
    aResponseList[<%=i%>][25] = "<%=usedVoiceDTOList.get(i) != null ? ((VoiceDTO)voiceDTOList.get(i)).getWName() : ""%>";
<%
    }
%>


	var aHourList = new Array(<%=hourList.size()%>);

<%
    for(int i=0; i < hourList.size(); i++) {
%>
    aHourList[<%=i%>] = "<%=(String)hourList.get(i)%>";
<%
    }
%>


	var aMinuteList = new Array(<%=minuteList.size()%>);

<%
    for(int i=0; i < minuteList.size(); i++) {
%>
    aMinuteList[<%=i%>] = "<%=(String)minuteList.get(i)%>";
<%
    }
%>








function disableElement(bDisable, strType) {
	var frm;
	if(strType == "ADD_FORM")
	    frm = document.addForm;
	else
	    frm = document.editForm;

		frm.scName.disabled = bDisable;
		frm.scHour.disabled = bDisable;
		frm.scAgain.disabled = bDisable;
		frm.scMakeCallTime.disabled = bDisable;
		frm.scCidRoute.disabled = bDisable;
		frm.dgCheck.disabled =bDisable;

		frm.keyto.disabled = bDisable;
		frm.keya.disabled = bDisable;
		frm.keyb.disabled = bDisable;
		frm.keyc.disabled = bDisable;
		frm.keyd.disabled = bDisable;
		frm.key1.disabled = bDisable;
		frm.key2.disabled = bDisable;
		frm.key3.disabled = bDisable;
		frm.key4.disabled = bDisable;
		frm.key5.disabled = bDisable;
		frm.key6.disabled = bDisable;
		frm.key7.disabled = bDisable;
		frm.key8.disabled = bDisable;
		frm.key9.disabled = bDisable;
		frm.key0.disabled = bDisable;
		frm.keyas.disabled = bDisable;;
		frm.keysh.disabled = bDisable;
}



// 추가
function add() {
	var frm = document.addForm;

	if(!blankValueMsg("addForm","amModeName","응답스케줄 이름을 입력하세요."))
	{
		return false;
	}

	var tdBgcolor = document.getElementsByName("tdHidden5");
	var totalCnt = 0;

	var rowCnt = document.getElementsByName("subTr").length;	//tr갯수

	for(var i=0; i < rowCnt; i++){
		if(tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
		{
			totalCnt += 1;
		}
	}

	if(totalCnt == 0) {
		alert("응답스케줄의 시간 및 응답모드 설정을 해주세요.");
		return;
	}

	hiddenAdCodeDiv();

	frm.submit();
}



// 수정
function edit() {
	var frm = document.editForm;

	if(!blankValueMsg("editForm","amModeName","응답스케줄 이름을 입력하세요."))
	{
		return false;
	}

	var tdBgcolor = document.getElementsByName("tdHidden5");
	var totalCnt = 0;

	var rowCnt = document.getElementsByName("subTr").length;	//tr갯수

	for(var i=0; i < rowCnt; i++){
		if(tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" || tdBgcolor[i].value == "O")
		{
			totalCnt += 1;
		}
	}

	if(totalCnt == 0) {
		alert("응답스케줄의 시간 및 응답모드 설정을 해주세요.");
		return;
	}

	hiddenAdCodeDiv();

	frm.submit();
}

// 삭제
function del() {
	var frm = document.mainForm;

	hiddenAdCodeDiv();

	frm.submit();
}

function clearElement(strType) {
	var frm;
	var iHtml;

	if(strType == "ADD_FORM")
	    frm = document.addForm;
	else
	    frm = document.editForm;

	frm.scName.value="";
	document.all["voiceTitle"].innerHTML = " 음성 파일 ";
	iHtml =  "<input type=\"text\" name=\"wfile\" id=\"wfile\" readonly style=\"width:135;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);\"><input type=\"hidden\" name=\"wcode\" id=\"wcode\" value=\"0\">";
	if(strType == "ADD_FORM")
        iHtml += " <img align=\"absmiddle\" src=\"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif\" onClick =\"goPopup('ADD');\" onmouseout='javascript:fncOverOut(this,\"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif\");' onmouseover='javascript:fncOverOut(this,\"<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif\");' style=\"CURSOR:hand;\" width=\"40\" height=\"20\">";
	else
        iHtml += " <img align=\"absmiddle\" src=\"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif\" onClick =\"goPopup('EDIT');\" onmouseout='javascript:fncOverOut(this,\"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif\");' onmouseover='javascript:fncOverOut(this,\"<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif\");' style=\"CURSOR:hand;\" width=\"40\" height=\"20\">";
	document.all["voiceContent"].innerHTML = iHtml;
	frm.scHour.value="5";
	frm.scAgain.value="3";
	frm.scMakeCallTime.value="30";
	frm.scCidRoute.selectedIndex= 0;
	frm.dgCheck.checked= 0;
	for(var i=0; i < frm.keyto.options.length; i++) {
		if(frm.keyto.options[i].value == "10") {
			frm.keyto.selectedIndex= i;
			frm.keya.selectedIndex= i;
			frm.keyb.selectedIndex= i;
			frm.keyc.selectedIndex= i;
			frm.keyd.selectedIndex= i;
			frm.key1.selectedIndex= i;
			frm.key2.selectedIndex= i;
			frm.key3.selectedIndex= i;
			frm.key4.selectedIndex= i;
			frm.key5.selectedIndex= i;
			frm.key6.selectedIndex= i;
			frm.key7.selectedIndex= i;
			frm.key8.selectedIndex= i;
			frm.key9.selectedIndex= i;
			frm.key0.selectedIndex= i;
			frm.keyas.selectedIndex= i;
			frm.keysh.selectedIndex= i;
		}
	}
	changeOption("10", "keyto");
	changeOption("10", "keya");
	changeOption("10", "keyb");
	changeOption("10", "keyc");
	changeOption("10", "keyd");
	changeOption("10", "key1");
	changeOption("10", "key2");
	changeOption("10", "key3");
	changeOption("10", "key4");
	changeOption("10", "key5");
	changeOption("10", "key6");
	changeOption("10", "key7");
	changeOption("10", "key8");
	changeOption("10", "key9");
	changeOption("10", "key0");;
	changeOption("10", "keyas");
	changeOption("10", "keysh");
}

// 응답모드 변경에 따른 상세내용 설정
function setElement(strValue, strType) {
	var frm;
	var idx = 0;
	var iHtml;

	for(var i=0; i < aResponseList.length; i++) {
		if(aResponseList[i][0] == strValue) {
			idx = i;
			break;
		}
	}

	if(strType == "ADD_FORM")
	    frm = document.addForm;
	else
	    frm = document.editForm;

	frm.scName.value= aResponseList[idx][1];

	document.all["voiceTitle"].innerHTML = " 적용된 음성 ";
	if(aResponseList[idx][25] == "")
	    iHtml = "없음";
	else
	    iHtml = "<a style=\"color:black\" href=\"<%=StaticString.ContextRoot%>/ivr/fileup/" + aResponseList[idx][2] + "\">" + aResponseList[idx][25] + "</a>";
	document.all["voiceContent"].innerHTML = iHtml;
	frm.scHour.value= aResponseList[idx][3];
	frm.scAgain.value= aResponseList[idx][4];
	frm.scMakeCallTime.value= aResponseList[idx][5];
	if(aResponseList[idx][6] == "N")
		frm.scCidRoute.selectedIndex= 0;
	else
		frm.scCidRoute.selectedIndex= 1;

	if(aResponseList[idx][12] == "N")
		frm.dgCheck.checked= 0;
	else
		frm.dgCheck.checked= 1;

	for(var i=0; i < frm.keyto.options.length; i++)
		if(frm.keyto.options[i].value == (aResponseList[idx][7]).substring(0,2))
			frm.keyto.selectedIndex= i;
	setSubElement(aResponseList[idx][7], "keyto");

	for(var i=0; i < frm.keya.options.length; i++)
		if(frm.keya.options[i].value == (aResponseList[idx][8]).substring(0,2))
			frm.keya.selectedIndex= i;
	setSubElement(aResponseList[idx][8], "keya");

	for(var i=0; i < frm.keyb.options.length; i++)
		if(frm.keyb.options[i].value == (aResponseList[idx][9]).substring(0,2))
			frm.keyb.selectedIndex= i;
	setSubElement(aResponseList[idx][9], "keyb");

	for(var i=0; i < frm.keyc.options.length; i++)
		if(frm.keyc.options[i].value == (aResponseList[idx][10]).substring(0,2))
			frm.keyc.selectedIndex= i;
	setSubElement(aResponseList[idx][10], "keyc");

	for(var i=0; i < frm.keyd.options.length; i++)
		if(frm.keyd.options[i].value == (aResponseList[idx][11]).substring(0,2))
			frm.keyd.selectedIndex= i;
	setSubElement(aResponseList[idx][11], "keyd");

	for(var i=0; i < frm.key1.options.length; i++)
		if(frm.key1.options[i].value == (aResponseList[idx][13]).substring(0,2))
			frm.key1.selectedIndex= i;
	setSubElement(aResponseList[idx][13], "key1");

	for(var i=0; i < frm.key2.options.length; i++)
		if(frm.key2.options[i].value == (aResponseList[idx][14]).substring(0,2))
			frm.key2.selectedIndex= i;
	setSubElement(aResponseList[idx][14], "key2");

	for(var i=0; i < frm.key3.options.length; i++)
		if(frm.key3.options[i].value == (aResponseList[idx][15]).substring(0,2))
			frm.key3.selectedIndex= i;
	setSubElement(aResponseList[idx][15], "key3");

	for(var i=0; i < frm.key4.options.length; i++)
		if(frm.key4.options[i].value == (aResponseList[idx][16]).substring(0,2))
			frm.key4.selectedIndex= i;
	setSubElement(aResponseList[idx][16], "key4");

	for(var i=0; i < frm.key5.options.length; i++)
		if(frm.key5.options[i].value == (aResponseList[idx][17]).substring(0,2))
			frm.key5.selectedIndex= i;
	setSubElement(aResponseList[idx][17], "key5");

	for(var i=0; i < frm.key6.options.length; i++)
		if(frm.key6.options[i].value == (aResponseList[idx][18]).substring(0,2))
			frm.key6.selectedIndex= i;
	setSubElement(aResponseList[idx][18], "key6");

	for(var i=0; i < frm.key7.options.length; i++)
		if(frm.key7.options[i].value == (aResponseList[idx][19]).substring(0,2))
			frm.key7.selectedIndex= i;
	setSubElement(aResponseList[idx][19], "key7");

	for(var i=0; i < frm.key8.options.length; i++)
		if(frm.key8.options[i].value == (aResponseList[idx][20]).substring(0,2))
			frm.key8.selectedIndex= i;
	setSubElement(aResponseList[idx][20], "key8");

	for(var i=0; i < frm.key9.options.length; i++)
		if(frm.key9.options[i].value == (aResponseList[idx][21]).substring(0,2))
			frm.key9.selectedIndex= i;
	setSubElement(aResponseList[idx][21], "key9");

	for(var i=0; i < frm.key0.options.length; i++)
		if(frm.key0.options[i].value == (aResponseList[idx][22]).substring(0,2))
			frm.key0.selectedIndex= i;
	setSubElement(aResponseList[idx][22], "key0");

	for(var i=0; i < frm.keyas.options.length; i++)
		if(frm.keyas.options[i].value == (aResponseList[idx][23]).substring(0,2))
			frm.keyas.selectedIndex= i;
	setSubElement(aResponseList[idx][23], "keyas");

	for(var i=0; i < frm.keysh.options.length; i++)
		if(frm.keysh.options[i].value == (aResponseList[idx][24]).substring(0,2))
			frm.keysh.selectedIndex= i;
	setSubElement(aResponseList[idx][24], "keysh");

}

function setSubElement(strValue, strName) {

	var strNameArr;
	var objName1;
	var objName2;
	var iHtml;
	var strValue2;
	//alert(strName);
	//alert(strValue);
	//alert(strValue.substring(2,strValue.length));
	strNameArr = strName.split("key");
	objName1 = "option" + strNameArr[1];
	strValue2 = strValue.substring(2,strValue.length);
	strValue = strValue.substring(0,2);
	//alert(objName1);
	if(strValue == "02" || strValue == "08" || strValue == "06" || strValue == "01" || strValue == "07" || strValue == "41" || strValue == "44") {  // Edit
	    iHtml = "<input name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' value='" + strValue2 + "' type='text' style=\"font-family:'12px Gulim'; font-size:12px;width:140; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);\" disabled>";
	} else if(strValue == "04" || strValue == "09") {   // 응답모드 콤보
	    iHtml =  "<select name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' class='input_box' style='width:130px' disabled>";
		iHtml += "<option value=''";
		if(strValue2 == "")
		    iHtml += " selected";
        iHtml += "></option>";
		for(var i=0; i < aResponseList.length; i++) {
			iHtml += "<option value='" + aResponseList[i][0] + "'";
			if(aResponseList[i][0] == strValue2)
			    iHtml += " selected";
			iHtml += ">" + aResponseList[i][1] + "</option>";
		}
		iHtml += "</select>";
	} else if(strValue == "05") { //       공백, Q 콤보
	    iHtml =  "<select name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' class='input_box' style='width:130px' disabled>";
        iHtml += "<option value=''";
		if(strValue2 == "")
		    iHtml += " selected";
		iHtml += "></option>";
        iHtml += "<option value='Q' ";
		if(strValue2 == "Q")
		    iHtml += " selected";
		iHtml += ">Quit</option>";
        iHtml += "</select>";
	} else if(strValue == "10" || strValue == "03" || strValue == "31" || strValue == "32" || strValue == "33" || strValue == "34"
              || strValue == "35" || strValue == "36" || strValue == "37" || strValue == "38" || strValue == "39" || strValue == "40"
			  || strValue == "42" || strValue == "43" || strValue == "45" || strValue == "46") {
		iHtml = "&nbsp;<input type='hidden' name ='word" + strNameArr[1] + "' id ='word" + strNameArr[1] + "' value = '" + strValue2 + "'>";
	}
	document.all[objName1].innerHTML = iHtml;
}

function changeResponseMode(strValue, strName, strType) {
	//alert(strValue);
	//alert(strName);
	//alert(strType);

	//추가
	///////////////////////////////////////////////////////////////////////////////////
	var naScCodeLength;			//현재갯수
	var	naScCodeSelectedIndex;  //인덱스
	var responseModeSize;		//월래갯수
	var iframeDiv;				//불러올 div

	//naScCodeLength = document.addForm.naScCode.length;
	naScCodeLength =document.getElementById("naScCode").length;
	//naScCodeSelectedIndex = document.addForm.naScCode.options.selectedIndex;
	naScCodeSelectedIndex = document.getElementById("naScCode").options.selectedIndex;
	responseModeSize = document.getElementById("responseModeSize").value


	//alert ( naScCodeLength + "," + naScCodeSelectedIndex + "," + responseModeSize);
	if( responseModeSize < naScCodeSelectedIndex )
	{
		iframeDiv = "responseDiv" + strValue;

		document.getElementById("responseMode").innerHTML = responseTimeIframe.document.getElementById(iframeDiv).innerHTML;

		disableElement(true, strType);

		document.getElementById("addImg").style.display = "none";
		//document.addForm.scName.disabled = true;

		return;
	}
	///////////////////////////////////////////////////////////////////////////////////



	if(strValue == "ADD") { // 새 응답모드 추가
	    clearElement(strType);
		disableElement(false, strType);

		//추가
		//추가버튼 이미지 보이기
		document.getElementById("addImg").style.display = "block";

	} else {
		setElement(strValue, strType);
		disableElement(true, strType);

		//추가
		//추가버튼 이미지 안보이기
		document.getElementById("addImg").style.display = "none";
	}
}


// 콤보 변경시 처리
function changeOption(strValue,strName)
{
	var strNameArr;
	var objName1;
	var objName2;
	var iHtml;
	strNameArr = strName.split("key");
	objName1 = "option" + strNameArr[1];
	//alert(objName1);
	if(strValue == "02" || strValue == "08" || strValue == "06" || strValue == "01" || strValue == "07" || strValue == "41" || strValue == "44") {  // Edit
	    iHtml = "<input name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' type='text' style=\"font-family:'12px Gulim'; font-size:12px;width:140; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);\" >";
	} else if(strValue == "04" || strValue == "09") {   // 응답모드 콤보
	    iHtml =  "<select name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' class='input_box' style='width:130px'>";
        iHtml += "<option value='' selected></option>";
		for(var i=0; i < aResponseList.length; i++) {
			iHtml += "<option value='" + aResponseList[i][0] + "'>" + aResponseList[i][1] + "</option>";
		}
		iHtml += "</select>";
	} else if(strValue == "05") { //       공백, Q 콤보
	    iHtml =  "<select name='word" + strNameArr[1] + "' id='word" + strNameArr[1] + "' class='input_box' style='width:130px'>";
        iHtml += "<option value='' selected></option>";
        iHtml += "<option value='Q'>Quit</option>";
        iHtml += "</select>";
	} else if(strValue == "10" || strValue == "03" || strValue == "31" || strValue == "32" || strValue == "33" || strValue == "34"
              || strValue == "35" || strValue == "36" || strValue == "37" || strValue == "38" || strValue == "39" || strValue == "40"
			  || strValue == "42" || strValue == "43" || strValue == "45" || strValue == "46") {
		iHtml = "&nbsp;<input type='hidden' name ='word" + strNameArr[1] + "' id ='word" + strNameArr[1] + "' value = ''>";
	}
	document.all[objName1].innerHTML = iHtml;
}

function changeDay(strValue) {
	var iHtml;
	if(strValue == "1") {
		iHtml =  "<select name=\"naDayDiv\" id=\"naDayDiv\" class=\"select01\" style=\"width:50\" onChange=\"javascript:changeDay(this.value);\" selected>";
		iHtml += "<option value=\"1\">요일</option>";
		iHtml += "<option value=\"2\">일자</option>";
		iHtml += "</select> &nbsp;";
		iHtml += "<select name=\"startWeek\" id=\"startWeek\" class=\"select01\" style=\"width:62\">";
		iHtml += "  <option value=\"월\" selected>월요일</option>";
		iHtml += "  <option value=\"화\">화요일</option>";
		iHtml += "  <option value=\"수\">수요일</option>";
		iHtml += "  <option value=\"목\">목요일</option>";
		iHtml += "  <option value=\"금\">금요일</option>";
		iHtml += "  <option value=\"토\">토요일</option>";
		iHtml += "  <option value=\"일\">일요일</option>";
		iHtml += "</select>";
		iHtml += "부터&nbsp;";
		iHtml += "<select name=\"endWeek\" id=\"endWeek\" class=\"select01\" style=\"width:62\">";
		iHtml += "  <option value=\"월\">월요일</option>";
		iHtml += "  <option value=\"화\">화요일</option>";
		iHtml += "  <option value=\"수\">수요일</option>";
		iHtml += "  <option value=\"목\">목요일</option>";
		iHtml += "  <option value=\"금\">금요일</option>";
		iHtml += "  <option value=\"토\">토요일</option>";
		iHtml += "  <option value=\"일\" selected>일요일</option>";
		iHtml += "</select>";
		iHtml += "까지&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		iHtml += " <select name=\"time1\" id=\"time1\" style=\"width:40\" class=\"select01\">";
		for(var i=0; i < aHourList.length; i++) {
			iHtml += "<option value=\"" + aHourList[i] + "\">" + aHourList[i] + "</option>";
		}
		iHtml += "</select>시 ";
		iHtml += "<select name=\"time2\" id=\"time2\" style=\"width:40\" class=\"select01\">";
		for(var i=0; i < aMinuteList.length; i++) {
			iHtml += "<option value=\"" + aMinuteList[i] + "\">" + aMinuteList[i] + "</option>";
		}
		iHtml += "</select>분 부터";
	} else {

		iHtml =  "<select name=\"naDayDiv\" id=\"naDayDiv\" class=\"select01\" style=\"width:50\" onChange=\"javascript:changeDay(this.value);\">";
		iHtml += "<option value=\"1\">요일</option>";
		iHtml += "<option value=\"2\" selected>일자</option>";
		iHtml += "</select> &nbsp;";
		iHtml += "<select name=\"startMonth\" id=\"startMonth\" style=\"width:50\" class=\"select01\">"
		for(var i=1 ; i < 13; i++) {
		    iHtml += "<option value=\"" + i + "\">" + i +"월</option>";
		}
		iHtml += "</select>";
		iHtml += "월&nbsp;";
		iHtml += "<select name=\"startDay\" id=\"startDay\" style=\"width:50\" class=\"select01\">";
		for(var i=1; i < 32; i++) {
		iHtml += "<option value=\"" + i + "\">" + i +"일</option>";
		}
		iHtml += "</select>";
		iHtml += "일 부터&nbsp;";
		iHtml += "<select name=\"endMonth\" id=\"endMonth\" style=\"width:50\" class=\"select01\">";
		for(var i=1 ; i < 13; i++) {
		    iHtml += "<option value=\"" + i + "\">" + i +"월</option>";
		}
		iHtml += "</select>";
		iHtml += "월&nbsp;";
		iHtml += "<select name=\"endDay\" id=\"endDay\" style=\"width:50\" class=\"select01\">";
		for(var i=1; i < 32; i++) {
		    iHtml += "<option value=\"" + i + "\">" + i +"일</option>";
		}
		iHtml += "</select>";
		iHtml += "일 까지&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		iHtml += " <select name=\"time1\" id=\"time1\" style=\"width:40\" class=\"select01\">";
		for(var i=0; i < aHourList.length; i++) {
			iHtml += "<option value=\"" + aHourList[i] + "\">" + aHourList[i] + "</option>";
		}
		iHtml += "</select>시 ";
		iHtml += "<select name=\"time2\" id=\"time2\" style=\"width:40\" class=\"select01\">";
		for(var i=0; i < aMinuteList.length; i++) {
			iHtml += "<option value=\"" + aMinuteList[i] + "\">" + aMinuteList[i] + "</option>";
		}
		iHtml += "</select>분 부터";
	}
	document.all["time_setting"].innerHTML = iHtml;
}




//체크박스 - 모든선택
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
		<table width="165" border="0" cellspacing="0" cellpadding="0" align="left">
		<%  if("1".equals(loginLevel)){ %>
		<%@ include file="/menu/leftUserMenu.jsp"%>
		<%  }else if("2".equals(loginLevel)){   %>
		<%@ include file="/menu/leftAdminMenu.jsp"%>
		<%  }   %>
		</table>
		<!--end--왼쪽페이지-->

		<!--star--콘텐츠페이지-->
		<form name="mainForm" action="<%=StaticString.ContextRoot%>/responseTimeManageDelete.do2" method="post">
		<table width="835" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
			<td>
<table width="803" border="0" cellspacing="0" cellpadding="0" align="center" style="margin:8 0 0 0 ">
	<tr>
		 <td width="803" height="35" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" >
			 <table border="0" cellpadding="0" cellspacing="0">
				  <tr>
				   <td height="35" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_respond_img.gif" width="103" height="20"></td>
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
							  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif" onClick="goInput();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_p_btn.gif");' style="CURSOR:hand;" alt="응답시간추가">

							  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif" onClick="goDelete();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_p_btn.gif");' style="CURSOR:hand;" alt="응답시간삭제">
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
					  <td height="327" valign="top">



		  <div style="width:789; height:290; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">     <!-- 스크롤 적용 시작-->
								<!--테이블-->
								<table id=box width="771" border="0" cellspacing="0" cellpadding="0" align="center" class="list_table">
									<!--header-->
									<tr height="22" bgcolor="rgb(190,188,182)" align="center" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">
										<td width="38" class="table_header01"><input name="allCheck" id="allCheck" type="checkbox" value="Y" style="width:20" onclick="javascript:checkAll();"></td>
										<td width="38" class="table_header01">No.</td>
										<td width="200" class="table_header01">응답스케줄 이름</td>
										<td width="435" class="table_header01">응답스케줄 설명</td>
										<td width="100" style="color:#FFFFFF">수정</td>
									</tr>

<%
	for (int i = 0; i < responseTimeDTO1List.size(); i++) {
%>
									<!--header-->
									<tr height="22" bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "rgb(243,247,245)"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "rgb(243,247,245)"%>'" align="center">
										<td class="table_column"><input name="delIndex" id="delIndex" type="checkbox" value="<%=((ResponseTimeDTO)responseTimeDTO1List.get(i)).getAmIndex()%>" style="width:20"></td>
										<td class="table_column"><%=i+1%></td>
										<td align="left" class="table_column"><%=((ResponseTimeDTO)responseTimeDTO1List.get(i)).getAmModeName()%></td>
										<td class="table_column">&nbsp;<%=((ResponseTimeDTO)responseTimeDTO1List.get(i)).getAmMemo()%></td>
										<td>
											<img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif" onClick="goEdit('<%=((ResponseTimeDTO)responseTimeDTO1List.get(i)).getAmIndex()%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_p_btn.gif");' style="CURSOR:hand;" align="absmiddle" alt="수정">
										</td>
									</tr>
<%
	}
%>
						<tr>
						  <td colspan="5"><img src="<%=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif" width="771" height="2"></td>
						</tr>
								</table>
								<!--테이블-->
		  </div>




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

<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>

<iframe id="responseTimeIframe" src="<%=StaticString.ContextRoot%>/ivr/responseTimeIframe.jsp" width="0" height="0"></iframe>
