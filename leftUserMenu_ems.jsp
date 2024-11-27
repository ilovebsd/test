<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="java.util.*" %>
<%@ page import="acromate.common.util.*" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title></title>
<% //int menu = 4, submenu = 3; String pageDir="/ems";
	int nUserLevel = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.level") );
%>
<style>
.sdmenu {
    width: 180px;
    text-indent: 5px;
    font-family: Sans-Serif;
    font-size: 12px;
    padding-bottom: 1px solid #FFF;
    /* background: #eee; */
    color: #FFF;
}

.sdmenu .pmenu, .sdmenu .pmenuhidden{
	display: block;
    padding: 0px 0;
    font-weight: bold;
    color: #655;
    /* background: #FFF url(<%=StaticString.ContextRoot%>/imgs/title.gif) repeat-x; */
}
.sdmenu .pmenu {
    border-bottom: 5px solid #FFF;
}

.sdmenu .pmenuhidden {
    border-bottom: none;
}


.sdmenu .submenu {
    overflow: hidden;
}

.sdmenu .submenu a {
    padding: 0px 0;
    text-indent: 30px;
    background: #FFF;
    display: block;
    border-bottom: 5px solid #FFF;
    /* color: #066 ; */
    color: #777 ;
    /* text-decoration: none; */
}

.sdmenu .submenu a:hover {
	<%-- background : #066 url(<%=StaticString.ContextRoot%>/imgs/linkarrow.gif) no-repeat right center; --%>
    background : #555;
    color: #FFF;
}

.sdmenu .seletedpmenu {
	display: block;
    padding: 0px 0;
    font-weight: bold;
    border-bottom: 5px solid #FFF;
    
    background: #999;
}

.sdmenu .seletedmenu {
	text-indent: 30px;
    background: #999;
}

.sdmenu .seletedmenu a, .sdmenu .seletedpmenu a {
    color: #FFF ;
}

#subsonmenu {
	text-indent: 55px;
}

</style>
<script type="text/javascript">
<!--

    function MM_swapImgRestore() { //v3.0
      var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
    }

    function MM_preloadImages() { //v3.0
      var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
        var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
        if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
    }

    function MM_findObj(n, d) { //v4.01
      var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
        d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
      if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
      for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
      if(!x && d.getElementById) x=d.getElementById(n); return x;
    }

    function MM_swapImage() { //v3.0
      var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
       if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
    }
//-->
</script>
<tr height="20">
    <td></td>
</tr>
<%-- <tr>
    <td>
    	<a href="<%=StaticString.ContextRoot%>/buddy/userBuddyList.jsp"><img id="menuimg1" src="<%=StaticString.ContextRoot%>/imgs/<%if("1".equals(menu)){out.print("menu_group_user_select_btn");}else{out.print("menu_group_user_normal_btn");}%>.gif"  class="arrow" style="cursor:hand" border="0"></a>
    </td>
</tr> --%>
<% 
if(nUserLevel==2){
%>
<tr class="sdmenu">
    <td class="<%="pmenu"/* menu==1?"seletedpmenu":"pmenu" */%>" >
      	<a href="<%=StaticString.ContextRoot+pageDir%>/subs/subsList.jsp" onMouseOut="MM_swapImgRestore()" > <font>Company 관리</font> </a>
    </td>
</tr>
<%
    if(menu==1){
%>
	<tr class="sdmenu">
	    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/subs/subsList.jsp" onMouseOut="" onMouseOver=""> <font>Company 목록</font> </a>      	
	    </td>
	</tr>
<%
    }//menu==1
}
%>
<%
if(nUserLevel==2 || nUserLevel==0){
%>
<tr class="sdmenu">
    <td class="pmenu">
      	<%-- <a href="<%=StaticString.ContextRoot%>/statistical/userLatelyList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu"> &nbsp;메뉴1</font> </a> --%>
      	<a href="<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtList.jsp" onMouseOut="MM_swapImgRestore()" > <font>번호/단말관리</font> </a>
    </td>
</tr>
<%
    if(menu==2){
%>
	<tr class="sdmenu">
	    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtList.jsp" onMouseOut="" onMouseOver=""> <font>개인내선번호</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==2?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/extnum/extnumList.jsp" onMouseOut="" onMouseOver=""> <font>전체내선번호</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==3?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/pickup/pickupList.jsp" onMouseOut="" onMouseOver=""> <font>당겨받기그룹</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==4?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/ipcsivr/ipcsIVRList_Prefix.jsp" onMouseOut="" onMouseOver=""> <font>음성안내번호관리</font> </a>      	
	    </td>
	</tr>
<%
    }            
%>

<tr class="sdmenu">
    <td class="pmenu">
      	<%-- <a href="<%=StaticString.ContextRoot%>/statistical/userLatelyList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu"> &nbsp;메뉴1</font> </a> --%>
      	<a href="<%=StaticString.ContextRoot+pageDir%>/block/callblockList.jsp" onMouseOut="MM_swapImgRestore()" > <font>부가서비스</font> </a>
    </td>
</tr>
<%
    if(menu==3){
%>
	<tr class="sdmenu">
	    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/block/callblockList.jsp" onMouseOut="" onMouseOver=""> <font>발신제한</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==2?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/vnum/virtualNumList.jsp" onMouseOut="" onMouseOver=""> <font>가상발신번호</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==3?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/callchge/callChangeList.jsp" onMouseOut="" onMouseOver=""> <font>대표번호 착신전환</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==31?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp" onMouseOut="" onMouseOver=""> <font>대표번호</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==4?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtList.jsp" onMouseOut="" onMouseOver=""> <font>일반통화 연결음</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==5?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/deptmrbt/deptMrbtList.jsp" onMouseOut="" onMouseOver=""> <font>대표통화 연결음</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==6?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/moh/mohList.jsp" onMouseOut="" onMouseOver=""> <font>통화대기음</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==7?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/vms/vmsList.jsp" onMouseOut="" onMouseOver=""> <font>음성사서함</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==8?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/blf/blfList.jsp" onMouseOut="" onMouseOver=""> <font>B L F</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==9?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/alertInfo/alertInfoList.jsp" onMouseOut="" onMouseOver=""> <font>통화수신음</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==10?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/secretary/secretaryList.jsp" onMouseOut="" onMouseOver=""> <font>인터컴</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==11?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/fmc/fmcList.jsp" onMouseOut="" onMouseOver=""> <font>F M C</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==12?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/fork/forkingList.jsp" onMouseOut="" onMouseOver=""> <font>원넘버멀티폰</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==13?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/arival/arrivalList.jsp" onMouseOut="" onMouseOver=""> <font>착신전환</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==14?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/alarm/alarmTimeList.jsp" onMouseOut="" onMouseOver=""> <font>지정시간통보</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==15?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/record/useRecordingList.jsp" onMouseOut="" onMouseOver=""> <font>번호별 녹취 설정</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==16?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/callerdp/callerdpList.jsp" onMouseOut="" onMouseOver=""> <font>발신자 번호 표시</font> </a>       	  
	    </td>
	</tr>
<%
    }            
%>

<tr class="sdmenu">
    <td class="pmenu">
      	<%-- <a href="<%=StaticString.ContextRoot%>/statistical/userLatelyList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu"> &nbsp;메뉴1</font> </a> --%>
      	<a href="<%=StaticString.ContextRoot%>/voiceIvrFirstListFormEms.do2" onMouseOut="MM_swapImgRestore()" > <font>음성안내</font> </a>
    </td>
</tr>
<%
    if(menu==4){
%>
	<tr class="sdmenu">
	    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
			    <a href="<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingList.jsp" onMouseOut="" onMouseOver=""> <font>음성안내 설정</font> </a>      	
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==2?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageList.jsp" onMouseOut="" onMouseOver=""> <font>응답시간 관리</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==3?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/ivr_respmode/responseModeManageList.jsp" onMouseOut="" onMouseOver=""> <font>응답모드 관리</font> </a>       	  
	    </td>
	</tr>
	<tr class="sdmenu">
	    <td class="<%=submenu==4?"seletedmenu":"submenu"%>">
	            <a href="<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageList.jsp" onMouseOut="" onMouseOver=""> <font>음성파일 관리</font> </a>       	  
	    </td>
	</tr>
<%
    }            
%>

<tr class="sdmenu">
    <td class="pmenu">
      	<a href="<%=StaticString.ContextRoot+pageDir%>/record/backup_setting_pbx.jsp" onMouseOut="MM_swapImgRestore()" > <font>녹취 FTP 서버 설정</font> </a>
    </td>
</tr>
<tr class="sdmenu">
    <td class="pmenu">
      	<a href="<%=StaticString.ContextRoot+pageDir%>/tts/down_tts.jsp" onMouseOut="MM_swapImgRestore()" > <font>TTS 음원파일 생성</font> </a>
    </td>
</tr>
<%
    if(menu==-1){
%>
<tr class="sdmenu">
    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
		    <a href="<%=StaticString.ContextRoot+pageDir%>/record/test.jsp" onMouseOut="" onMouseOver=""> <font>test</font> </a>      	
    </td>
</tr>
<%
    }            
%>
<% 
}
%>
