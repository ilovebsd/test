<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="acromate.common.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO"%>
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
	String submenu    = "1";  // 음성 안내 설정

	String new_menu     = "C";  		// 부가설정
	String new_submenu  = "8";  		// 음성 안내 설정
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

	
	List modeSettingDTOList = (List)request.getAttribute("modeSettingDTOList");
	String strMsg = (String)request.getAttribute("msg");
	if(1==1){
		Connection cn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		StringBuffer sb = new StringBuffer();

		//ArrayList modeSettingDTOList = null;

		try {
			cn = this.getConnection();
			sb.append("SELECT 			                                                                            \n");
			sb.append("b.ad_index,		                                                                            \n");
			sb.append("b.tr_idx,			                                                                        \n");
			sb.append("b.am_index,		                                                                            \n");
			sb.append("b.am_mode_name,	                                                                            \n");
			sb.append("b.ad_date_type, 	                                                                            \n");
			sb.append("b.ad_sdate_day,	                                                                            \n");
			sb.append("b.ad_edate_day, 	                                                                            \n");
			sb.append("b.ad_week_mon, 	                                                                            \n");
			sb.append("b.ad_week_tue, 	                                                                            \n");
			sb.append("b.ad_week_wed, 	                                                                            \n");
			sb.append("b.ad_week_thu, 	                                                                            \n");
			sb.append("b.ad_week_fri, 	                                                                            \n");
			sb.append("b.ad_week_sat, 	                                                                            \n");
			sb.append("b.ad_week_sun, 	                                                                            \n");
			sb.append("b.ad_memo,                                                                                   \n");
			sb.append("COALESCE((select a.ivr_tel from nasa_trunk_set a where a.tr_idx = b.tr_idx), '') as ivr_tel	\n");
			sb.append("FROM nasa_answer_dateday b ORDER BY b.ad_index ASC                                             ");

			pstmt = cn.prepareStatement(sb.toString());
			rs = pstmt.executeQuery();

			modeSettingDTOList = new ArrayList();
			if(rs.next()) {
				do {
					ModeSettingDTO msDTO = new ModeSettingDTO();
					msDTO.setAdIndex(String.valueOf(rs.getInt("ad_index")));
					msDTO.setTrIdx(String.valueOf(rs.getInt("tr_idx")));
					msDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
					msDTO.setAmModeName(rs.getString("am_mode_name"));
					msDTO.setAdDateType(rs.getString("ad_date_type"));
					msDTO.setAdSDateDay(rs.getString("ad_sdate_day"));
					msDTO.setAdEDateDay(rs.getString("ad_edate_day"));
					msDTO.setAdWeekMon(rs.getString("ad_week_mon"));
					msDTO.setAdWeekTue(rs.getString("ad_week_tue"));
					msDTO.setAdWeekWed(rs.getString("ad_week_wed"));
					msDTO.setAdWeekThu(rs.getString("ad_week_thu"));
					msDTO.setAdWeekFri(rs.getString("ad_week_fri"));
					msDTO.setAdWeekSat(rs.getString("ad_week_sat"));
					msDTO.setAdWeekSun(rs.getString("ad_week_sun"));
					msDTO.setAdMemo(rs.getString("ad_memo"));
					msDTO.setIvrTel(rs.getString("ivr_tel"));
					modeSettingDTOList.add(msDTO);
				} while(rs.next());
			}

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			if(rs != null) try{ rs.close(); } catch(SQLException se) {se.printStackTrace();}
			if(pstmt != null) try{ pstmt.close(); } catch(SQLException se) {se.printStackTrace();}
			if(cn != null) try{ cn.close(); } catch(SQLException se) {se.printStackTrace();}
		}

		if(modeSettingDTOList != null) modeSettingDTOList.trimToSize();
		//return modeSettingDTOList;
	}
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

//입력화면
function goInput(){
    var parm = '';		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceGuideSettingInputForm.do2";

	getPage(url,parm);
}


//수정화면
function goEdit(adIndex){

    var parm = '&adIndex='+adIndex;		//get형식으로 변수 전달.
	var url = "<%=StaticString.ContextRoot%>/voiceGuideSettingEditForm.do2";

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
	var url = "<%=StaticString.ContextRoot%>/voiceGuideSettingDeleteForm.do2";

	getPage(url,parm);
}

//팝업
function goPopup(type){
    var parm = '&type='+type;		//get형식으로 변수 전달.
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






// 추가
function add() {
	var frm = document.addForm;

	if(frm.trIdx.value == "") {
		alert("응답대표번호를 선택하세요.")
		return;
	}

	if(frm.amIndex.value == "") {
		alert("응답스케줄을 선택하세요.")
		return;
	}

	if( frm.adDateType[1].checked ){
		var weekDay = new Array();
		weekDay[0] = "adWeekMon";
		weekDay[1] = "adWeekTue";
		weekDay[2] = "adWeekWed";
		weekDay[3] = "adWeekThu";
		weekDay[4] = "adWeekFri";
		weekDay[5] = "adWeekSat";
		weekDay[6] = "adWeekSun";

		var checkCount = 0;

		for(var i=0; i < 7; i++) {
			if( document.getElementById(weekDay[i]).checked ) {
				checkCount =+ 1;
			}
		}

		if( checkCount == 0 ) {
			alert("요일을 체크하세요");
			return;
		}
	}


	hiddenAdCodeDiv();

	frm.submit();
}



// 수정
function edit() {
	var frm = document.editForm;
	if(frm.trIdx.value == "") {
		alert("응답대표번호를 선택하세요.")
		return;
	}

	if(frm.amIndex.value == "") {
		alert("응답스케줄을 선택하세요.")
		return;
	}

	if( frm.adDateType[1].checked ){
		var weekDay = new Array();
		weekDay[0] = "adWeekMon";
		weekDay[1] = "adWeekTue";
		weekDay[2] = "adWeekWed";
		weekDay[3] = "adWeekThu";
		weekDay[4] = "adWeekFri";
		weekDay[5] = "adWeekSat";
		weekDay[6] = "adWeekSun";

		var checkCount = 0;

		for(var i=0; i < 7; i++) {
			if( document.getElementById(weekDay[i]).checked ) {
				checkCount =+ 1;
			}
		}

		if( checkCount == 0 ) {
			alert("요일을 체크하세요");
			return;
		}
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


function checkDateType(strValue){
	if(strValue == "D") {
		document.getElementById("startMonth").disabled = false;
		document.getElementById("startDay").disabled = false;
		document.getElementById("endMonth").disabled = false;
		document.getElementById("endDay").disabled = false;

		document.getElementById("adWeekMon").disabled = true;
		document.getElementById("adWeekTue").disabled = true;
		document.getElementById("adWeekWed").disabled = true;
		document.getElementById("adWeekThu").disabled = true;
		document.getElementById("adWeekFri").disabled = true;
		document.getElementById("adWeekSat").disabled = true;
		document.getElementById("adWeekSun").disabled = true;
	} else if(strValue == "W"){
		document.getElementById("startMonth").disabled = true;
		document.getElementById("startDay").disabled = true;
		document.getElementById("endMonth").disabled = true;
		document.getElementById("endDay").disabled = true;

		document.getElementById("adWeekMon").disabled = false;
		document.getElementById("adWeekTue").disabled = false;
		document.getElementById("adWeekWed").disabled = false;
		document.getElementById("adWeekThu").disabled = false;
		document.getElementById("adWeekFri").disabled = false;
		document.getElementById("adWeekSat").disabled = false;
		document.getElementById("adWeekSun").disabled = false;
	}
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
		<table width="165" border="0" cellspacing="0" cellpadding="0"  align="left">
		<%  if("1".equals(loginLevel)){ %>
		<%@ include file="/menu/leftUserMenu.jsp"%>
		<%  }else if("2".equals(loginLevel)){   %>
		<%@ include file="/menu/leftAdminMenu.jsp"%>
		<%  }   %>
		</table>
		<!--end--왼쪽페이지-->


		<!--star--콘텐츠페이지-->
		<form name="mainForm" action="<%=StaticString.ContextRoot%>/voiceGuideSettingDelete.do2" method="post">
		<table width="835" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
			<td>
<table width="803" border="0" cellspacing="0" cellpadding="0" align="center" style="margin:8 0 0 0 ">
	<tr>
		 <td width="803" height="35" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" >
			 <table border="0" cellpadding="0" cellspacing="0">
				  <tr>
				   <td height="35" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_soundset_img.gif" width="103" height="20"></td>
				   <td width="15"></td>
				  </tr>
			 </table>
		 </td>
	</tr>
  <tr>
    <td style="padding-top:16; padding-bottom:5; background:eeeff0; border-bottom:1 solid #cdcecf; border-top:0 solid #cdcecf; height:405" valign="top" >
      <table width="771" border="0" cellspacing="0" cellpadding="1" align="center">
        <tr>
          <td style="padding-bottom:5 ">

		  <table width="771" border="0" cellspacing="0" cellpadding="0" align="center">
            <tr>
              <td width="173">
				  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif" onClick="goInput();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_add_p_btn.gif");' style="CURSOR:hand;" alt="음성안내추가">

				  <img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif" onClick="goDelete();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_delete_p_btn.gif");' style="CURSOR:hand;" alt="음성안내삭제">
			  </td>
              <td width="154" valign="top">
  </td>
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
		  <table id=box width="771" border="0" cellspacing="0" cellpadding="0" align="center" class="list_table">
            <tr align="center" height="22" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">
              <td width="38" class="table_header01"><input name="allCheck" type="checkbox" value="Y" style="width:20" onclick="javascript:checkAll();"></td>
              <td width="38" class="table_header01">NO</td>
              <td width="162" class="table_header01"> 응답 대표번호 </td>
              <td width="245" class="table_header01"> 응답 일자 / 요일</td>
              <td width="201" class="table_header01"> 응답스케줄</td>
              <td width="87" style="color:#FFFFFF" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">수정</td>
            </tr>
<%
	for(int i=0; i < modeSettingDTOList.size(); i++) {
		String strTmp = "";
		if(((ModeSettingDTO)modeSettingDTOList.get(i)).getAdDateType().equals("W")) {
			strTmp = ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekMon().equals("Y") ? "월," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekTue().equals("Y") ? "화," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekWed().equals("Y") ? "수," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekThu().equals("Y") ? "목," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekFri().equals("Y") ? "금," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekSat().equals("Y") ? "토," : "";
			strTmp += ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdWeekSun().equals("Y") ? "일," : "";
			if(strTmp.length() > 0)
			    strTmp = strTmp.substring(0,strTmp.length()-1);
		} else {
			strTmp = ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdSDateDay() + " ~ " + ((ModeSettingDTO)modeSettingDTOList.get(i)).getAdEDateDay();
		}
%>
            <tr height="22" bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" align="center">
              <td class="table_column"><input name="delIndex" type="checkbox" value="<%=((ModeSettingDTO)modeSettingDTOList.get(i)).getAdIndex()%>" style="width:20"></td>
			  <td class="table_column"><%=i+1%></td>
              <td class="table_column"><%=((ModeSettingDTO)modeSettingDTOList.get(i)).getIvrTel()%><%=((ModeSettingDTO)modeSettingDTOList.get(i)).getIvrTel().equals("") ? "&nbsp;" : ""%></td>
              <td class="table_column"><%=strTmp%></td>
              <td class="table_column"><%=((ModeSettingDTO)modeSettingDTOList.get(i)).getAmModeName()%></td>
              <td style="padding-top:2">
				<img src="<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif" onClick="goEdit('<%=((ModeSettingDTO)modeSettingDTOList.get(i)).getAdIndex()%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/soundinfo_modify_p_btn.gif");' style="CURSOR:hand;"  align="absmiddle" alt="수정">
			  </td>
            </tr>
<%
	}
%>
            <tr>
              <td colspan="6"><img src="<%=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif" width="771" height="2"></td>
            </tr>
          </table>
		  </div>     <!-- 스크롤 적용 끝-->

		  </td>
        </tr>
        <tr>
          <td style="padding-bottom:0; padding-top:0 ">

		  <table width="771" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="173">&nbsp; </td>
              <td width="18" valign="top"> </td>
              <td width="131" align="right" valign="top" style="padding-top:1 ">&nbsp;</td>
              <td width="116" align="center" style="color:rgb(140,153,162) ">&nbsp;</td>
              <td width="45" style="padding-top:1" valign="top">&nbsp;</td>
              <td width="210" style="color:RGB(140,153,162) " >&nbsp;</td>
              <td width="78" valign="top"> </td>
            </tr>
          </table>

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


