<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>bizportal 서비스</title>
<%//int menu = 4, submenu = 3;%>
<style>
.sdmenu {
    width: 130px;
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
    /* background: #FFF url(/bizportal/imgs/title.gif) repeat-x; */
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
    background : #888;
    color: #FFF;
}

.sdmenu .seletedmenu {
	text-indent: 30px;
    background: #888;
}

.sdmenu .seletedmenu a {
    color: #FFF ;
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
    if(menu==1){
%>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/buddy/userBuddyList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image43','','<%=StaticString.ContextRoot%>/imgs/menu_group_userindex_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("1_1".equals(menu+"_"+submenu)){out.print("menu_group_userindex_select_btn");}else{out.print("menu_group_userindex_normal_btn");}%>.gif" name="Image43" border="0"></a>
    </td>
</tr>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/buddy/userBuddyExport.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image44','','<%=StaticString.ContextRoot%>/imgs/menu_group_user_export_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("1_2".equals(menu+"_"+submenu)){out.print("menu_group_user_export_select_btn");}else{out.print("menu_group_user_export_normal_btn");}%>.gif" name="Image44" border="0"></a>
    </td>
</tr>
<%
    }            
%>
<%-- <tr>
    <td>
	  	<a href="<%=StaticString.ContextRoot%>/address/userAddrList.jsp"><img id="menuimg2" src="<%=StaticString.ContextRoot%>/imgs/<%if("2".equals(menu)){out.print("menu_privatelist_user_select_btn");}else{out.print("menu_privatelist_user_normal_btn");}%>.gif" class="arrow" style="cursor:hand" border="0"></a>
    </td>
</tr> --%>
<%
    if(menu==2){
%>
<tr>
    <td>
        	<a href="<%=StaticString.ContextRoot%>/address/userAddrList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/menu_privatelists_user_manage_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("2_1".equals(menu+"_"+submenu)){out.print("menu_privatelists_user_manage_select_btn");}else{out.print("menu_privatelists_user_manage_normal_btn");}%>.gif" name="Image12" width="130" height="22" border="0"></a>
    </td>
</tr>
<tr>
    <td>
        	<a href="<%=StaticString.ContextRoot%>/address/userGroupList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image13','','<%=StaticString.ContextRoot%>/imgs/menu_privatelists_user_group_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("2_2".equals(menu+"_"+submenu)){out.print("menu_privatelists_user_group_select_btn");}else{out.print("menu_privatelists_user_group_normal_btn");}%>.gif" name="Image13" width="130" height="22" border="0"></a>       	 
    </td>
</tr>
<tr>
    <td>
    		<a href="<%=StaticString.ContextRoot%>/address/userAddrImport.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image14','','<%=StaticString.ContextRoot%>/imgs/menu_privatelists_user_import_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("2_3".equals(menu+"_"+submenu)){out.print("menu_privatelists_user_import_select_btn");}else{out.print("menu_privatelists_user_import_normal_btn");} %>.gif" name="Image14" width="130" height="22" border="0"></a>      
    </td>
</tr>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/address/userAddrExport.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image15','','<%=StaticString.ContextRoot%>/imgs/menu_privatelists_user_export_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("2_4".equals(menu+"_"+submenu)){out.print("menu_privatelists_user_export_select_btn");}else{out.print("menu_privatelists_user_export_normal_btn");}%>.gif" name="Image15" width="130" height="22" border="0"></a>			
    </td>
</tr>
<!--tr>
    <td>
			<a href="<%//=StaticString.ContextRoot%>/address/nabAddrList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image115','','<%//=StaticString.ContextRoot%>/imgs/menu_privatelists_user_nab_select_btn.gif',0)"><img src="<%//=StaticString.ContextRoot%>/imgs/<%//if("2_5".equals(menu+"_"+submenu)){out.print("menu_privatelists_user_nab_select_btn");}else{out.print("menu_privatelists_user_nab_normal_btn");}%>.gif" name="Image115" width="130" height="22" border="0"></a>			
    </td>
</tr-->
<%
    }            
%>
<tr class="sdmenu">
    <td>
      	<a href="<%=StaticString.ContextRoot%>/address/userPublicAddrList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu">메뉴0</font> </a>
    </td>
</tr>
<%-- <tr>
    <td>
		<a href="<%=StaticString.ContextRoot%>/address/userPublicAddrList.jsp"><img id="menuimg3" src="<%=StaticString.ContextRoot%>/imgs/<%if("3".equals(menu)){out.print("menu_publiclist_user_select_btn");}else{out.print("menu_publiclist_user_normal_btn");}%>.gif" class="arrow" style="cursor:hand" border="0"></a></span>
    </td>
</tr> --%>
<%
    if(menu==3){
%>
<tr>
    <td>
            <a href="<%=StaticString.ContextRoot%>/address/userPublicAddrList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image16','','<%=StaticString.ContextRoot%>/imgs/menu_public_userindex_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("3_1".equals(menu+"_"+submenu)){out.print("menu_public_userindex_select_btn");}else{out.print("menu_public_userindex_normal_btn");}%>.gif" name="Image16" width="130" height="22" border="0"></a>       	  
    </td>
</tr>
<tr>
    <td>
		    <a href="<%=StaticString.ContextRoot%>/address/userPublicAddrExport.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image17','','<%=StaticString.ContextRoot%>/imgs/menu_public_user_export_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("3_2".equals(menu+"_"+submenu)){out.print("menu_public_user_export_select_btn");}else{out.print("menu_public_user_export_normal_btn");}%>.gif" name="Image17" width="130" height="22" border="0"></a>      	
    </td>
</tr>
<%
    }            
%>
<tr class="sdmenu">
    <td>
      	<%-- <a href="<%=StaticString.ContextRoot%>/statistical/userLatelyList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu"> &nbsp;메뉴1</font> </a> --%>
      	<a href="<%=StaticString.ContextRoot%>/alarm/alarmTimeList.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu">메뉴1</font> </a>
    </td>
</tr>
<%
    if(menu==4){
%>
<tr class="sdmenu">
    <td class="<%=submenu==1?"seletedmenu":"submenu"%>">
		    <a href="<%=StaticString.ContextRoot%>/alarm/alarmTimeList.jsp" onMouseOut="" onMouseOver=""> <font>알람 설정</font> </a>      	
    </td>
</tr>
<tr class="sdmenu">
    <td class="submenu">
            <a href="<%=StaticString.ContextRoot%>/address/userPublicAddrList.jsp" onMouseOut="" onMouseOver=""> <font>메뉴 sub1</font> </a>       	  
    </td>
</tr>
<tr class="sdmenu">
    <td class="submenu">
		    <a href="<%=StaticString.ContextRoot%>/address/userPublicAddrExport.jsp" onMouseOut="" onMouseOver=""> <font>메뉴 sub2</font> </a>      	
    </td>
</tr>
<%
    }            
%>
<tr class="sdmenu">
    <td>
      	<a href="<%=StaticString.ContextRoot%>/addition/arrivalSwitch.jsp" onMouseOut="MM_swapImgRestore()" > <font class="pmenu">메뉴2</font> </a>
    </td>
</tr>
<%-- <tr>
    <td>
      	<a href="<%=StaticString.ContextRoot%>/addition/arrivalSwitch.jsp"><img id="menuimg5" src="<%=StaticString.ContextRoot%>/imgs/<%if("5".equals(menu)){out.print("menu_addservice_user_select_btn");}else{out.print("menu_addservice_user_normal_btn");}%>.gif" class="arrow" style="cursor:hand" border="0"></a>
    </td>
</tr> --%>
<%
    if(menu==5){
%>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/addition/arrivalSwitch.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image23','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_transfer_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_1".equals(menu+"_"+submenu)){out.print("menu_addservice_user_transfer_select_btn");}else{out.print("menu_addservice_user_transfer_normal_btn");}%>.gif" name="Image23" width="130" height="22" border="0"></a>      	
    </td>
</tr>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/addition/blockPrefixList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image24','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_reject_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_2".equals(menu+"_"+submenu)){out.print("menu_addservice_user_reject_select_btn");}else{out.print("menu_addservice_user_reject_normal_btn");}%>.gif" name="Image24" width="130" height="22" border="0"></a>
    </td>
</tr>
<tr>
    <td>
            <a href="<%=StaticString.ContextRoot%>/addition/firstCalleeList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image25','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_receiveed_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_3".equals(menu+"_"+submenu)){out.print("menu_addservice_user_receiveed_select_btn");}else{out.print("menu_addservice_user_received_normal_btn");}%>.gif" name="Image25" width="130" height="22" border="0"></a>		
    </td>
</tr>

<tr>
    <td>
            <a href="<%=StaticString.ContextRoot%>/addition/callConectList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image26','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_connect_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_4".equals(menu+"_"+submenu)){out.print("menu_addservice_user_connect_select_btn");}else{out.print("menu_addservice_user_connect_normal_btn");}%>.gif" name="Image26" width="130" height="22" border="0"></a>		  
    </td>
</tr>

<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/addition/callAwaitList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image27','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_wait_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_5".equals(menu+"_"+submenu)){out.print("menu_addservice_user_wait_select_btn");}else{out.print("menu_addservice_user_wait_normal_btn");}%>.gif" name="Image27" width="130" height="22" border="0"></a>  
    </td>
</tr>
<tr>
    <td>
			<a href="<%=StaticString.ContextRoot%>/addition/alarmList.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image18','','<%=StaticString.ContextRoot%>/imgs/menu_addservice_user_ontime_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("5_6".equals(menu+"_"+submenu)){out.print("menu_addservice_user_ontime_select_btn");}else{out.print("menu_addservice_user_ontime_normal_btn");}%>.gif" name="Image18" width="130" height="22" border="0"></a>  
    </td>
</tr>
<%
    }            
%>
<%-- <tr>
    <td>
		<a href="<%=StaticString.ContextRoot%>/information/profile.jsp"><img id="menuimg6" src="<%=StaticString.ContextRoot%>/imgs/<%if("6".equals(menu)){out.print("menu_privateinform_user_select_btn");}else{out.print("menu_privateinform_user_normal_btn");}%>.gif" class="arrow" style="cursor:hand" border="0"></a>  	
    </td>
</tr> --%>
<%
    if(menu==6){
%>
<tr>
    <td>
          <a href="<%=StaticString.ContextRoot%>/information/profile.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image28','','<%=StaticString.ContextRoot%>/imgs/menu_privateinform_user_profile_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("6_1".equals(menu+"_"+submenu)){out.print("menu_privateinform_user_profile_select_btn");}else{out.print("menu_privateinform_user_profile_normal_btn");}%>.gif" name="Image28" width="130" height="22" border="0"></a>      	
    </td>
</tr>
<tr>
    <td>
          <a href="<%=StaticString.ContextRoot%>/information/passwordEdit.jsp" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image29','','<%=StaticString.ContextRoot%>/imgs/menu_privateinform_user_password_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/<%if("6_2".equals(menu+"_"+submenu)){out.print("menu_privateinform_user_password_select_btn");}else{out.print("menu_privateinform_user_password_normal_btn");}%>.gif" name="Image29" width="130" height="22" border="0"></a>		  
    </td>
</tr>
<%
    }            
%>
