<%@ page language="java" contentType="text/html; charset=EUC-KR"  pageEncoding="EUC-KR"%>
<%@ page import="waf.*"%>
<%@ page import="acromate.common.util.LanguageMode"%>
<%@ page import="webuser.ServerLogin"%>
<%@ page import="java.util.Properties"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="system.SystemConfigSet" %>
<%

	String loginFail 	= request.getParameter("err");
	String hiPWD 		= request.getParameter("hiPWD");
    int nLangType = 0;
   
    LanguageMode lang = new LanguageMode(nLangType);
  
  	//��ǰ��(�𵨸�) ���� ��ȸ
  	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				goodsName 		= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>������Ż</title>

<script type="text/JavaScript">
<!--
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
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

function SetCookie(name, value, expiredays) 
 { 
    var todayDate = new Date(); 
    todayDate.setDate( todayDate.getDate() + expiredays ); 
    document.cookie = name + "=" + escape( value ) + "; path=/; expires=" + todayDate.toGMTString() + ";" 
 } 

function getCookieVal (offset) 
{
    var endstr = document.cookie.indexOf (";", offset);
    if (endstr == -1)
    endstr = document.cookie.length;
    return unescape(document.cookie.substring(offset, endstr));
}

function GetCookie (name) 
{
    var arg = name + "=";
    var alen = arg.length;
    var clen = document.cookie.length;
    var i = 0;
    while (i < clen) 
    {
        var j = i + alen;
        if (document.cookie.substring(i, j) == arg)
        return getCookieVal (j);
        i = document.cookie.indexOf(" ", i) + 1;
        if (i == 0) 
        break; 
    }
    return null;
}

//3. cookie�� ����� �������� name�� �����ϴ� �Լ�
//���⿡�� �����Ѵٴ� �ǹ̴� cookie ������ expires ��¥�� ���ŷ� �ٲ۴ٴ� ���� �ǹ��Ѵ�.
function delCookie(name,value) {
    var todayDate = new Date();
    todayDate.setDate( todayDate.getDate() + (-1) );
    if(value != ""){
        document.cookie = name + '=' + escape( value ) + '; path=/; expires=' + todayDate.toGMTString() + ';'
    }
}

function func_loginCommit() {
 
  if (document.loginForm.id.value == "") {
     alert("<%=LanguageMode.x("���̵� �Է��ϼ���.","Please insert ID.")%>");
     document.loginForm.id.focus();
  } else if (document.loginForm.pwd.value == "") {
     alert("<%=LanguageMode.x("�н����带 �Է��ϼ���.","Please insert password.")%>");
     document.loginForm.pwd.focus();
  } else {
      if(document.loginForm.id_save.checked){
        SetCookie("id_cookie",document.loginForm.id.value, 90); //��Ű�� �Ϸ� ����
      }else{
        delCookie("id_cookie",document.loginForm.id.value);
      }
      
//      alert(document.loginForm.pwd.value);
//      document.loginForm.passWord.value = document.loginForm.pwd.value;
//      alert(document.loginForm.passWord.value);
      
      document.loginForm.submit();
  }
}

function goEnterSubmit(){
 if((window.event.keyCode)==13){ 
  func_loginCommit();
 }
}

function func_init() {
    if(GetCookie("id_cookie") == null || GetCookie("id_cookie") == ""){
    }else{
        document.loginForm.id.value = GetCookie("id_cookie");
        document.loginForm.id_save.checked = true;
    }
	<%
		SessionManager manager = SessionManager.getInstance();
		boolean login = manager.isLogin(request);
		System.out.println("login: " + login);
		int loginState = 0;
		if (login)
			loginState = 1;
		
		String sessionState = request.getParameter("session");
		
		System.out.println("session: " + sessionState);
		
		String updateResult = request.getParameter("updateResult");
	%>
	
	
    if (<%=updateResult%> == "-1")
      alert("<%=LanguageMode.x("�ý��� ������ ���Ͽ� ����Ǿ����ϴ�.","It is exited for System Error.")%>"+"\n" +"<%=LanguageMode.x("�ٽ� �α����� �ֽʽÿ�." ,"Please enter to try again.")%>" );

	if (<%=sessionState%> == "0")
		alert("<%=LanguageMode.x("������ ����Ǿ����ϴ�.","Session Timeout.")%>" + "\n" + "<%=LanguageMode.x("�ٽ� �α����� �ֽʽÿ�." ,"Please enter to try again.")%>" );
		
	loginFail="<%=loginFail%>";
	if (loginFail == "loginFail"){
		alert("<%=LanguageMode.x("���̵� Ȥ�� �н����尡 ��ġ���� �ʽ��ϴ�.","Please check ID and password.")%>");
	}else if (loginFail == "loginOk1"){
        top.location.href = "/bizportal/buddy/userBuddyList.jsp";
    }else if (loginFail == "loginOk2"){
        //top.location.href = "/bizportal/ipcs/ipcsList.jsp";
        //top.location.href = "/bizportal/ipcs/ipcsList_New.jsp";
        //top.location.href = "/bizportal/ipcs/ipcsList_New.jsp?hiPassWord="+"<%//=hiPWD%>";
        
        top.location.href = "/bizportal/ipcs/ipcsList_New.jsp?hiPwdChk=ok";
        //top.location.href = "/bizportal/system/systemInfo.jsp";					// �ű� �޴��ÿ� ���.(IMS �޴��� ���)
    }
}

function func_find(){
	//location.href="http://acromate.anyhelp.net/";
	window.open("http://remote.callbox.kt.com/", "_blank", "width=900,height=700,resizable=1,scrollbars=1") ;
}
//-->
</script>

<style type="text/css">
<!--
body {
	background-color: #ffffff;
}
-->
</style>
</head>

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="func_init();">
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<form name = "loginForm" method="post" action="<%=StaticString.ContextRoot%>/mainLogin.do" >
<input type='hidden' name ='passWord' value="">
    <table width="1000" cellpadding="0" cellspacing="0" border="0" align="center">
        <tr>
            <td height="215"><img src="<%=StaticString.ContextRoot%>/imgs/Login_mainbg_img.gif" width="1000" height="215" border="0"></td>
        </tr>
        <tr>
            <td height="152">
                <table width="100%" cellpadding="0" cellspacing="0" border="0" >
                    <tr>
                        <td width="296"></td>
                        <td width="260">
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" >
                                <tr height="0">
                                    <td></td>
                                </tr>
                                <tr height="100">
                                    <!-- ######################### IMS ��� ���� �̹��� ����  ######################### -->
                                    <%if("ACRO-CBS".equals(goodsName)||"ACRO-HCBS".equals(goodsName)){%>
                                    	<td><img src="<%=StaticString.ContextRoot%>/imgs/Login_ktlogo_x13_img.gif" width="280" height="90" border="0"></td>
                                    <%}else if("ACRO-CBS-IMS".equals(goodsName)||"ACRO-HCBS-IMS".equals(goodsName)){%>
                                    	<td><img src="<%=StaticString.ContextRoot%>/imgs/Login_ims_ktlogo_x13_img.gif" width="280" height="90" border="0"></td>
                                    <%}%>
                                    <!-- ######################################################################## -->
                                </tr>
                                <tr height="0">
                                    <td></td>
                                </tr>
                            </table>
                        </td>
                        <td width="30"></td>
                        <td width="3"><img src="<%=StaticString.ContextRoot%>/imgs/Login_devider_img.gif" width="3" height="104" border="0"></td>
                        <td width="20"></td>
                        <td width="391">
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" >
                                <tr height="30">
                                    <td colspan="2"></td>
                                </tr>
                                <!--<tr height="20">
                                    <td colspan="2">
                                        <table width="100%" cellpadding="0" cellspacing="0" border="0" >
                                            <tr>
                                                <td width="10"><input type="radio" name="userlog" value="0" checked></td>
                                                <td width="75"><img src="imgs/Login_userlog_img.gif" width="75" height="20" border="0"></td>
                                                <td width="10"><input type="radio" name="userlog" value="1"></td>
                                                <td><img src="imgs/Login_adminlog_img.gif" width="75" height="20" border="0"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr height="10">
                                    <td colspan="2"></td>
                                </tr>-->
                                <tr height="42">
                                    <td>
                                        <table cellpadding="0" cellspacing="0" border="0" >
                                            <tr height="20">
                                                <td align="right" style="padding:0px 10px 0px 0px"><img src="<%=StaticString.ContextRoot%>/imgs/Login_id_img.gif" width="17" height="20" border="0"></td>
                                                <td><input type="text" name="id" onKeyUp="goEnterSubmit()" style="width:85px;height:14px; ime-mode:inactive;"></td>
                                            </tr>
                                            <tr height="2">
                                                <td colspan="2"></td>
                                            </tr>
                                            <tr height="20">
                                                <td style="padding:0px 10px 0px 0px"><img src="<%=StaticString.ContextRoot%>/imgs/Login_password_img.gif" width="69" height="20" border="0"></td>
                                                <td><input type="password" name="pwd" onKeyUp="goEnterSubmit()" style="width:85px;height:14px;font-size:7px; ime-mode:inactive;"></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td align="left" width="203"><a href="javascript:func_loginCommit();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image17','','imgs/Login_login_p_btn.gif',1)">
                                    	<img src="<%=StaticString.ContextRoot%>/imgs/Login_login_n_btn.gif"  name="Image17" width="48" height="42" border="0"></a>
                                    </td>
                                </tr>
                                <tr height="10">
                                    <td colspan="2"></td>
                                </tr>
                                <tr height="20">
                                    <td colspan="2">
                                        <table width="100%" cellpadding="0" cellspacing="0" border="0" >
                                            <tr>
                                            	<td valign="middle">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="id_save">���̵� ���� </td>
                                                <td width="203" align="left" valign="bottom"><a href="javascript:func_find();">�������� </a></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr height="10">
                                    <td colspan="2"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            <td>
        </tr>
        <tr>
            <!--td height="22"><img src="imgs/Login_copybg_img.gif" width="1000" height="22" border="0"></td-->
            <td height="100"><img src="<%=StaticString.ContextRoot%>/imgs/Login_copybg_img_03.gif" width="1000" height="100" border="0"></td>
        </tr>
    </table>
</form>    
</BODY>
</HTML>
