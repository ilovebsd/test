<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="sun.misc.BASE64Encoder"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"  pageEncoding="EUC-KR"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="waf.*"%>
<%@ page import="acromate.common.util.LanguageMode"%>
<%@ page import="webuser.ServerLogin"%>
<%@ page import="java.util.Properties"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="system.SystemConfigSet" %>

<%@ page import="dao.system.CommonDAO"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="java.util.*" %>
<%@ page import="acromate.common.util.*" %>
<%@ page import="java.sql.ResultSet"%>

<%
	String pageDir = "";//"/ems";
	int nModeDebug = 0, nModePaging = 1;//config option

	int nNowpage = 0, nTotalpage = 0, nBlockcnt = 10, nMaxitemcnt = 1000;
	try{
		nNowpage 			= Integer.valueOf( request.getParameter("page") );
	}catch (Exception e){
		nNowpage = 0;
	}

	String loginFail 	= request.getParameter("err");
	String hiPWD 		= request.getParameter("hiPWD");
    int nLangType = 0;
   	
    String authGroupid = null ;
    int nAllowUser = 0;//0: unauth, 1:auth, -1:DB err
   	HttpSession ses = request.getSession(false);
	authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
	String userID = ses != null?(String)ses.getAttribute("login.user") : null;
	int userLevel = ses != null? Str.CheckNullInt((String)ses.getAttribute("login.level")) : -1;
	
   	if(authGroupid!=null && authGroupid.trim().length()>0){
		nAllowUser = 1;
		nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
	}
   	else if(userID!=null&&userID.trim().length()>0){
   	   nAllowUser = 1; authGroupid = "";
   	} else{
   		response.sendRedirect(StaticString.ContextRoot+pageDir) ;
   		return ;
   	}
    
	/* 
	LanguageMode lang = new LanguageMode(nLangType);
  	//제품명(모델명) 버전 조회
  	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				goodsName 		= systemConfig.getGoodsName();						// 제품명(모델명)
	 */
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
<link href="olleh.ico" rel="icon" type="image/x-icon" />
<link href="olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>통화수신음</title>

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

function func_loginCommit() {
 
  if (document.loginForm.id.value == "") {
     alert("<%=LanguageMode.x("아이디를 입력하세요.","Please insert ID.")%>");
     document.loginForm.id.focus();
  } else if (document.loginForm.pwd.value == "") {
     alert("<%=LanguageMode.x("패스워드를 입력하세요.","Please insert password.")%>");
     document.loginForm.pwd.focus();
  } else {
      if(document.loginForm.id_save.checked){
        SetCookie("id_cookie_alarm",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_alarm",document.loginForm.id.value);
      }
      
//      alert(document.loginForm.pwd.value);
//      document.loginForm.passWord.value = document.loginForm.pwd.value;
//      alert(document.loginForm.passWord.value);
      
      document.loginForm.submit();
  }
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

//3. cookie에 저장된 정보에서 name을 삭제하는 함수
//여기에서 삭제한다는 의미는 cookie 정보의 expires 날짜를 과거로 바꾼다는 것을 의미한다.
function delCookie(name,value) {
   var todayDate = new Date();
   todayDate.setDate( todayDate.getDate() + (-1) );
   if(value != ""){
       document.cookie = name + '=' + escape( value ) + '; path=/; expires=' + todayDate.toGMTString() + ';'
   }
}

function goEnterSubmit(){
 if((window.event.keyCode)==13){ 
  func_loginCommit();
 }
}

function func_init_alarm() {
	var groupid = <%=authGroupid%>;
	//if(groupid) SetCookie("id_cookie_alarm", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_alarm", '');
}

function func_find(){
	//location.href="http://acromate.anyhelp.net/";
	window.open("http://remote.callbox.kt.com/", "_blank", "width=900,height=700,resizable=1,scrollbars=1") ;
}

/**
 * 체크박스 전체 선택/제거
 */ 
function checkAll(obj){
     var f = document.frm;
     if(f.chkOpt != undefined){
        if(f.chkOpt.length == undefined){
            if(obj.checked){
                f.chkOpt.checked = true;
            }else{
                f.chkOpt.checked = false;
            }
        }else{
            for(var i=0; i<f.chkOpt.length; i++){
                if(obj.checked){
                    f.chkOpt[i].checked = true;
                }else{
                    f.chkOpt[i].checked = false;
                }
            }
        }
     }
}

//-->
</script>

<!-- function file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/common.js"></script>
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>
<script language="JavaScript" type="text/JavaScript">
		function getPage(url, parm){
			inf('hidden');
		    engine.execute("POST", url, parm, "ResgetPage");
		}
		
		function ResgetPage(data){
		    if(data){
		        document.getElementById('popup_layer').innerHTML = data;
		        showAdCodeDiv();
		    }else{
		        alert("에러") ;
		    }
		}
		
		/**
		 * 클릭시 팝업 보여주기
		 */		
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
		    obj.style.top = '150px';
		    obj.style.left = '250px';

		    SET_DHTML('popup_layer');
		}
		
		/**
		 * 등록 클릭시 팝업 숨기기
		 */
		function hiddenAdCodeDiv() {
		    inf('visible'); //select box 보이기
		    setShadowDivVisible(false); //배경 layer 숨김
		
		    document.getElementById('popup_layer').style.display="none";
		}
		
		function base64_encode(input) {
			if (typeof input !== 'string' || input == "") return input;	
			//if (typeof $this.btoa !== 'undefined') return $this.btoa(input); // moved
			var output = "", chr1, chr2, chr3, enc1, enc2, enc3, enc4 ;
		    var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
			  var i = 0;
			  input = utf8_encode(input);
			  while (i < input.length) {
			      chr1 = input.charCodeAt(i++);
			      chr2 = input.charCodeAt(i++);
			      chr3 = input.charCodeAt(i++);
			      enc1 = chr1 >> 2;
			      enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			      enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			      enc4 = chr3 & 63;
			      if (isNaN(chr2)) {
			          enc3 = enc4 = 64;
			      } else if (isNaN(chr3)) {
			          enc4 = 64;
			      }
			      output = output +
			      keyStr.charAt(enc1) + keyStr.charAt(enc2) +
			      keyStr.charAt(enc3) + keyStr.charAt(enc4);
			  }
			 return output;
		}
		
		function utf8_encode(string) {
			if (typeof string !== 'string') return string;
			  string = string.replace(/\r\n/g,"\n");
			     var utftext = "";
			     for (var n = 0; n < string.length; n++) {
			         var c = string.charCodeAt(n);
			         if (c < 128) {
			             utftext += String.fromCharCode(c);
			         }
			         else if((c > 127) && (c < 2048)) {
			             utftext += String.fromCharCode((c >> 6) | 192);
			             utftext += String.fromCharCode((c & 63) | 128);
			         }
			         else {
			             utftext += String.fromCharCode((c >> 12) | 224);
			             utftext += String.fromCharCode(((c >> 6) & 63) | 128);
			             utftext += String.fromCharCode((c & 63) | 128);
			         }
			     }
			     return utftext;
		}

		/**
		 * 로그인 화면으로 이동
		 */
		function goLogin(){
		    var parm 	= "";
		    var url 	= 'alarmLogin.jsp';		    

		    getPage(url,parm);			
		}
		function onLoginPro(){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
            if(f2.loginid.value)
            	f.linid.value = base64_encode(f2.loginid.value);
            if(f2.psword.value)
            	f.linps.value = base64_encode(f2.psword.value);
            
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/alarm/alarmLoginPro.jsp";
            f.method = "post";
            f.submit();	
		}	
		
		/**
		 * 신규입력 화면으로 이동
		 */
		function goInsert(){
		    var parm 	= "";
		    var url 	= 'alertInfoInsert.jsp';		    

		    getPage(url,parm);			
		}

		/**
		 * 신규 내용 저장하기
		 */
		function goNewSave(){
			
			var str2 = "";
			var chk_Value 	= document.Savelayer.alertInfo;
	        if(chk_Value != undefined){
	            for(var i=0; i<chk_Value.length; i++){
	                if(chk_Value[i].checked){
	                    str2 = chk_Value[i].value;
	                }
	            }
	        }else{
	        	alert("통화수신음을 선택하지 않았습니다!");
	        	return;
	        }
			
			if(str2 == ""){
	        	alert("통화수신음을 선택하지 않았습니다!");
	        	hiddenAdCodeDiv();
	        	return;
			}
			
	        var f   = document.frm;
	        f.hiAlertIntoType.value = str2;
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/alertInfo/alertInfoInsertPro.jsp";
            f.method = "post";
            f.submit();	
		}		
		/**
		 * 신규입력 후 출력
		 */
		function goInsertDone(datas){
			var _o=null, _p=null;
			var _i=0;
			while(_o=document.getElementById("g"+_i))
			{
			  var _e164;
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					document.getElementById("h"+_i+"_2").innerHTML = "<FONT color=\"blue\">사용중</FONT>&nbsp;" ;
	 					document.getElementById("h"+_i+"_3").innerHTML = "<input type=\"button\" name=\"btnAlarm\" style=\"height: 18px\" value=\"해제\" onclick=\"func_setAlarm('"+_e164+"', 1)\" >";
	 				}
	 			}
			  }
			  _i++;
			}
		}

		/**
         * 삭제 화면으로 이동
         */
        function goDelete(){
            var parm 	= '';
            var url 	= 'alertInfoDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * 삭제처리
		 */
		function goDeletePro(){
            var f   = document.frm;
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/alertInfo/alertInfoDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			var _o=null, _p=null;
			var _i=0;
			while(_o=document.getElementById("g"+_i))
			{
			  var _e164;
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					document.getElementById("h"+_i+"_2").innerHTML = "사용안함&nbsp;" ;
	 					document.getElementById("h"+_i+"_3").innerHTML = "<input type=\"button\" name=\"btnAlarm\" style=\"height: 18px\" value=\"등록\" onclick=\"func_setAlarm('"+_e164+"', 0)\" >";
	 				}
	 			}
			  }
			  _i++;
			}
		}

        /**
		 * 저장하기
		 */
		function goSave(){
			var f  = document.frm;

            if(f.gubun[0].checked){     // 지정 시간 통보 사용하지 않음 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보를 사용하지 않는 상태입니다.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("모든 설정이 삭제됩니다. 저장하시겠습니까?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/alarm/alarmSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // 지정 시간 통보 사용하기 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보 설정을 추가하여 주십시오.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보를 사용하고 있습니다.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }
            }

		}		

		/**
		 * 선택된 값이 있는지 확인
		 */
		function isChecked(processname){
			var f   = document.frm;
            var cnt = 0;
            if(f.chkOpt == undefined){
                var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'검색 목록이 없습니다.';
                var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                getPage(url,parm);
                return 0;
            }else{
                if(f.chkOpt.length == undefined){
                    if(f.chkOpt.checked){
                        cnt++;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            cnt++;
                        }
                    }
                }
                if(cnt == 0){
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+processname+'할 항목을 선택하여 주십시오.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return 0;
                }
            }
            
            return 1;
		}
		
		/**
		 * 선택된 값이 입력
		 */
		function setE164BySelected(){
			var f   = document.frm;
            var str = "";
            if(f != undefined && f.chkOpt != undefined){
                if(f.chkOpt.length == undefined){
                    if(f.chkOpt.checked){
                    	f.chkOpt.value = f.chkOpt.parentNode.parentNode.cells[2].innerHTML;
                    	str = f.chkOpt.value;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            if(str == ""){
                            	f.chkOpt[i].value = f.chkOpt[i].parentNode.parentNode.cells[2].innerHTML;
                            	str = f.chkOpt[i].value;
                            }else{
                            	f.chkOpt[i].value = f.chkOpt[i].parentNode.parentNode.cells[2].innerHTML;
                            	str = str + "|" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }
            
            return str;// document.frm.e164.value = str;
		}
		
        /**
         * 추가/해제 클릭
         */
		function func_setAlarm(num, type) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				goDelete();
				//window.open("alertInfoDelete.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
			}
			else{
				goInsert();
				//window.open("alertInfoInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
        	}
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setAlarmBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('해제')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				goDelete() ;
			}
			else{
				if( isChecked('등록')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				goInsert() ;
        	}
		}
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_alarm" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  //document.rtcForm.rtcInput.value = getTimeStamp();
			  document.location.href = '.';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==0 ){
					document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				}else{
					document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
				}
				document.getElementById('extnum').innerHTML = "내선번호<font size='1px'>▽</font>";//△
			}
			else if(nField==1){
				if( lastSort==1 ){
					document.getElementById('extnum').innerHTML = "<b>내선번호▲</b>";
				}else{
					document.getElementById('extnum').innerHTML = "<b>내선번호▼</b>";							
				}
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
			}
		}

	</script>
	
<style type="text/css">
<!--
body {
	background-color: #ffffff;
}

#menu {
      width: 180px; height: 44px;
      position: fixed; top: 5px; z-index: 900/* 999 */;
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

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" <%if(nAllowUser<1) out.println("onLoad=\"goLogin();\""); %>>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

<div>
<table align="center" border="0">
<tr>
	<td width="180" style="min-width:180px;" >
	<!--strat--왼쪽페이지-->
		<% int menu = 3, submenu = 9; %>
		<table id="menu" width="180" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	<!--end--왼쪽페이지-->
	</td>
	<td><table>
<!-- <TBODY> -->
<FORM name="frm" method="post">
	<input type='hidden' name ='grpid' value="">
	<input type='hidden' name ='e164' value="">
	<input type='hidden' name ='hiAlertIntoType' value="">
	<input type='hidden' name ='deleteStr' value="">
	<input type='hidden' name ='linid' value="">
	<input type='hidden' name ='linps' value="">
	<tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td colspan="2" align="left">
                  	<%@ include file="../topUserMenu_ems.jsp"%>
                  	<%	/*
                  		java: int nAllowUser, String authGroupid, int userLevel, String userID
                  		javascript: func_logoutCommit(1)
                  		*/
                  	%>
                  <%-- <% if(nAllowUser==1) {
                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"로그아웃\" onclick=\"func_logoutCommit(1)\">") ;
                  %>
                  		<font style="color: blue;vertical-align: bottom;"><%=authGroupid+(userLevel!=2?"":authGroupid.length()==0?userID:"("+userID+")")%></font>
                	 	<input type="button" name="btnLogout" style="height: 18px" value="로그아웃" onclick="func_logoutCommit(1)">
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = '.'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = '.'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right">
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="선택 등록" onclick="func_setAlarmBySelected(0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="선택 해제" onclick="func_setAlarmBySelected(1)">
                  	<% } %>
                  </td>
              </tr>
		  </table>
		</td>
	</tr>
      <tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td>
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="200" onclick="sortNow(0,true);changeTitle(0);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">전화번호<font size='1px'>▽</font></td>
                  <td width="80" onclick="sortNow(1,true);changeTitle(1);" id="extnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>내선번호▲</b></td>
                  <td width="200" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">사용유무</td>
                  <td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">등록/해제</td>
                  <td class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
              </tr>
		  </table>
		</td>
	</tr>
	<tr>
        <td valign="top">
<!-- <div style="width:792; height:222; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">		 -->
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
          
<%					
	int count = 0; 
	
	String[][] values = null;
	ArrayList 		envList2 = null;
	DataStatement 	stmt = null;
	String 			commonSql = "" ;
	if(1==1){
		try{
			if(1==1){	
				String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
				stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
				if(stmt!=null){
					CommonDAO		commonDao		= new CommonDAO();
									commonSql = "\n Select e164, extensionnumber "; 
									commonSql += "\n,      ( select count(*) from table_featureservice where e164 = e164.e164 and serviceno = 5451) as usechk  " ;
									commonSql += "\n,      ( SELECT count(*) FROM table_e164 WHERE groupid = '"+authGroupid+"' ) as totalcnt " ;
									commonSql += "\n From table_e164 e164 WHERE groupid = '"+authGroupid+"' " ;
					commonSql		+= " ORDER BY extensionnumber is null ASC, extensionnumber='' ASC, cast('0'||extensionnumber as int) ASC " ;
					if(nModePaging==1){
						commonSql		+= " LIMIT "+nMaxitemcnt+" ";
						commonSql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
					String 			strColNames[]	= {"e164", "extensionnumber","usechk","totalcnt"};
					
					envList2		= commonDao.select(stmt,commonSql,strColNames);
					if(envList2.size()==0){
						//out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					}
					
					ResultSet rs = null;
					try{
			        	if(nModePaging==1){
			        		commonSql = "\n select count(*) ";
			        		commonSql += "\n From table_e164 e164 WHERE groupid = '"+authGroupid+"' " ;
					        rs = stmt.executeQuery(commonSql);
			                System.out.println("totalcount : "+commonSql);
			                while (rs.next())
			                	count = rs.getInt(1) ;
			        	}	
			        }catch(Exception ex){}finally{if(rs!=null) rs.close();}
				}
			}
			if(count==0) count 			= envList2==null? 0 : envList2.size();
			
			values = new String[count][2];
		}catch(Exception ex){
			out.println("<script type=\"text/JavaScript\"> alert('"+commonSql+"');</script>") ;
			out.println("<script type=\"text/JavaScript\"> alert('"+ex.toString()+"');</script>") ;
			//out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
		}
	}
	
	int idx=0;
	if(/* envList!=null && */ count!=0){
		nTotalpage = nModePaging==0 ? 0 : (int)(count/nMaxitemcnt);
		int endidx = nModePaging==0 ? count : (nTotalpage==nNowpage? count%nMaxitemcnt : nMaxitemcnt ) ;
		HashMap temp= null;
		int flagAlarm = 0;
		String extensionnum;
		for(idx=0;idx<endidx;idx++){
			if(envList2!=null)
				temp	=	(HashMap)envList2.get(idx);
			
			if(temp!=null){
				values[idx][0] = (String)temp.get("e164");
				values[idx][1] = (String)temp.get("usechk");
				extensionnum = (String)temp.get("extensionnumber");
				nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
				flagAlarm = Str.CheckNullInt(values[idx][1]) ;
			}else{
				values[idx][0] = "0105555987"+idx;
				flagAlarm = 1;
				extensionnum = "987"+idx;
				//nTotalpage = 5;
			}
%>	
			  <tr id=g<%=idx%> height="22" bgcolor="E7F0EC" align="center" onmouseover='this.style.backgroundColor="E7F0EC"' onmouseout='this.style.backgroundColor="E7F0EC"' >
                <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" onclick="this.value=this.parentNode.parentNode.cells[2].innerHTML;" value="<%=values[idx][0].trim()%>" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
                <td width="58" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
                <td width="200" id='h<%=idx%>_0' class="table_column"><%=values[idx][0]%></td>
                <td width="80" id='h<%=idx%>_1' class="table_column"><%=extensionnum%></td>
                <%if(flagAlarm>0){%>
	            	<td width="200" id='h<%=idx%>_2' class="table_column"><FONT color="blue">사용중</FONT>&nbsp;</td>
	            <%}else{%>
					<td width="200" id='h<%=idx%>_2' class="table_column">사용안함&nbsp;</td>
	            <%}%>
                <td width="80" id='h<%=idx%>_3' class="table_column"><input type="button" name="btnAlarm" style="height: 18px" value="<%=(flagAlarm==1?"해제":"등록")%>" onclick="func_setAlarm('<%=values[idx][0]%>', <%=flagAlarm%>)"></td>
                <td class="table_column">&nbsp;</td>
              </tr>
<% 
		}//for
	}//if

    if (stmt != null){
    	out.println("<script type=\"text/JavaScript\"> sortNow(1,true); </script>") ;//내선번호 정렬
    	ConnectionManager.freeStatement(stmt);
    }
    
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="alertInfoList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="alertInfoList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       		</td>
		       		<td colspan = 3 align="center" > 
<%					
		for(int i=(nBlockidx*nBlockcnt); i<(nBlockidx+1)*nBlockcnt && i<=nTotalpage; i++){
      			if(nNowpage==i)
      				out.print(" <b>"+(i+1)+"</b> ") ;
      			else
      				out.print(" <a href=\"alertInfoList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="alertInfoList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="alertInfoList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
		       					</tr>
		       				</table> 
						<% } %> 
		         	</td>
		       </tr>
<% } %>		       
          </table>
<!-- </div> -->
        </td>
      </tr>
</FORM>
<!-- </TBODY>   -->
</table> 

</td></tr></table>
<iframe name="procframe" src="" width="0" height="0"></iframe>
</div>

</BODY>
</HTML>
<!-- 팝업 레이어 -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;">
