<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="sun.misc.BASE64Encoder"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"  pageEncoding="EUC-KR"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="acromate.common.util.LanguageMode"%>
<%@ page import="java.util.Properties"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="system.SystemConfigSet" %>

<%@ page import="dao.system.CommonDAO"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="java.util.*" %>
<%@ page import="acromate.common.util.*" %>

<%
	String pageDir = "";//"/ems";
	int nModeDebug = 0, nModePaging = 0;//config option

	int nNowpage = 0, nTotalpage = 0, nBlockcnt = 10, nMaxitemcnt = 100;
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
    /* if (ServerLogin.isLogin() == false) {
    	ServletContext context = getServletContext();
    	ServerLogin.getServerLogin().login(context) ; 
    } */
    if(1==1){
    	HttpSession ses = request.getSession(false);
		authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;

    	if(authGroupid!=null && authGroupid.trim().length()>0){
			nAllowUser = 1;
		}
    	else if(nModeDebug==1){
    		ses.setAttribute("login.debug", "1");
    		//authGroupid = "DEBUG"; nAllowUser = 1;
    	}
    	
    	if(nAllowUser==1){
    		response.sendRedirect(StaticString.ContextRoot+pageDir+"/alarm/alarmTimeList.jsp") ;
    		return ;
    	}
		/* Cookie[] cks = request.getCookies(); //쿠키값 얻어오기
		if(cks!=null)
	    	for(Cookie ck : cks){
	    		if( "id_cookie_alarm".equals(ck.getName()) 
	    				&& ck.getValue().trim().length() > 0){
	    			authGroupid = ck.getValue() ;
	    			if(authGroupid!=null && authGroupid.trim().length()>0){
	    				nAllowUser = 1; break;
	    			}
	    		}
	    	} */
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
<title>알람 통보</title>

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
		    var url 	= 'conn/login.jsp';		    

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
            f.action = "<%=StaticString.ContextRoot+pageDir%>/conn/loginPro.jsp";
            f.method = "post";
            f.submit();	
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
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_alarm" + "=";
		 	document.location.href = "./conn/logout.jsp";
		}
		
	</script>
	
<style type="text/css">
<!--
body {
	background-color: #ffffff;
}

#menu {
      width: 130px; height: 44px;
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
	width:100%; min-width:130px; max-width:960px; /*** Mozilla ***/
}
-->
</style>
</head>

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" <%if(nAllowUser<1) out.println("onLoad=\"goLogin();\""); %>>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

<div>
<table align="center" border="0">
<tr>
	<td width="130" style="min-width:130px;" >
	<!--strat--왼쪽페이지-->
		<% int menu = 4, submenu = 1; %>
		<%-- <table id="menu" width="130" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="leftUserMenu_ems.jsp"%>
		</table> --%>
	<!--end--왼쪽페이지-->
	</td>
	<td><table>
<!-- <TBODY> -->
<FORM name="frm" method="post">
	<input type='hidden' name ='grpid' value="">
	<input type='hidden' name ='e164' value="">
	<input type='hidden' name ='alarmtype' value="">
	<input type='hidden' name ='alarmtime_1' value="">
	<input type='hidden' name ='alarmtime_2' value="">
	<input type='hidden' name ='alarmtime_3' value="">
	<input type='hidden' name ='alarmdate_1' value="">
	<input type='hidden' name ='alarmdate_2' value="">
	<input type='hidden' name ='alarmdate_3' value="">
	<input type='hidden' name ='deleteStr' value="">
	<input type='hidden' name ='linid' value="">
	<input type='hidden' name ='linps' value="">
	<tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td colspan="1" width="58" style="color: blue;vertical-align: bottom;" ><% if(nAllowUser==1) out.println(authGroupid); %> </td>
                  <td colspan="1" align="left">
                  <% if(nAllowUser==1) {
                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"로그아웃\" onclick=\"func_logoutCommit(1)\">") ;
                  %>
                	 	<input type="button" name="btnLogout" style="height: 18px" value="로그아웃" onclick="func_logoutCommit(1)">
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = '.'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = '.'"> 
	           	  <% } %>
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
                  <td width="200" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">알람시각</td>
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
	if(nModeDebug!=1){
		try{
			if(nAllowUser==1){		
				//서버로부터 DataStatement 객체를 할당
				//new ConnectionManager("220.73.223.12", "") ;
				//ConnectionManager.getInstance().setSysGroupID("SSW", "01") ;
		// 		stmt 			= ConnectionManager.allocStatement("(01)(SSW).active", 0);
		
		// 		stmt 			= ConnectionManager.allocStatement("EMS");
		// 		CommonDAO		commonDao		= new CommonDAO();
		// 		String 			commonSql		= "SELECT sysgroupid, sysgroupname FROM table_systemgroup";
		// 		String 			strColNames[]	= {"sysgroupid","sysgroupname"};
				stmt 			= ConnectionManager.allocStatement("SSW");
				if(stmt!=null){
					CommonDAO		commonDao		= new CommonDAO();
					String 			commonSql		= "SELECT E.e164 e164, extensionnumber, alarmdate, alarmtime " ; 
									commonSql		+= ", ( SELECT count(*) FROM table_e164 WHERE groupid = '"+authGroupid+"' ) as totalcnt ";
									commonSql		+= " FROM table_e164 as E LEFT JOIN table_alarmService as A ";
									commonSql		+= " ON E.e164=A.e164 AND SequenceNo = 1 AND AlarmType = 1";
									commonSql		+= " WHERE groupid = '"+authGroupid+"'";
					if(nModePaging==1){
									//commonSql		+= " LIMIT "+ (nNowpage*nMaxitemcnt+1) +", "+(nNowpage*nMaxitemcnt+nMaxitemcnt)+" ";
									commonSql		+= " LIMIT "+nMaxitemcnt+" ";
									commonSql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
					commonSql		+= " ORDER BY extensionnumber is null ASC, extensionnumber='' ASC, cast('0'||extensionnumber as int) ASC " ;
					String 			strColNames[]	= {"e164", "extensionnumber","alarmdate","alarmtime","totalcnt"};
					
					envList2		= commonDao.select(stmt,commonSql,strColNames);
					if(envList2.size()==0){
						out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					}
				}
			}
			count 			= envList2==null? 0 : envList2.size();
			
			values = new String[count][3];
		}catch(Exception ex){
			out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
		}
	}else if(nAllowUser==1){
		envList2 = new ArrayList<HashMap>() ;
		HashMap smpitem;
		for(int z=0; z<nMaxitemcnt; z++){
			smpitem = new HashMap();
			smpitem.put("e164", "0105555987"+z) ; smpitem.put("alarmdate", z%2==1?"2015082"+z:"") ; smpitem.put("extensionnumber", "987"+z) ;
			smpitem.put("alarmtime", z%2==1?"0700":"") ;
			smpitem.put("totalcnt", "25") ;
			envList2.add(smpitem);
		}
		count = envList2.size();//nMaxitemcnt ;
		nTotalpage = 25;
		if(nNowpage >= nTotalpage) count = 4;
		values = new String[count][3];
	}
	
	int idx=0;
	if(/* envList!=null && */ count!=0){
		HashMap temp= null;
		int flagAlarm = 0;
		String extensionnum;
		for(idx=0;idx<count;idx++){
			if(envList2!=null)
				temp	=	(HashMap)envList2.get(idx);
			
			if(temp!=null){
				values[idx][0] = (String)temp.get("e164");
				values[idx][1] = (String)temp.get("alarmdate");
				values[idx][2] = (String)temp.get("alarmtime");
				extensionnum = (String)temp.get("extensionnumber");
				nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
				flagAlarm = (values[idx][2]!=null && values[idx][2].length()>3) ? 1 : 0 ;
				if(values[idx][1].length()>7){
					values[idx][1] = values[idx][1].substring(0, 4)+"-"+values[idx][1].substring(4, 6)+"-"+values[idx][1].substring(6, 8) ;
					if(values[idx][2].length()>3)
						values[idx][1] += " "+values[idx][2].substring(0, 2)+":"+values[idx][2].substring(2, 4);
				}else 
					values[idx][1] = "미등록" ;
			}else{
				values[idx][0] = "0105555987"+idx;
				values[idx][1] = "2015-08-2"+idx+" 03:3"+idx;
				flagAlarm = "1".equals(values[idx][2] = idx%2==1?"1":"0") ? 1 : 0 ;
				extensionnum = "987"+idx;
				//nTotalpage = 5;
			}
%>	
			  <tr id=g<%=idx%> height="22" bgcolor="E7F0EC" align="center" onmouseover='this.style.backgroundColor="E7F0EC"' onmouseout='this.style.backgroundColor="E7F0EC"' >
                <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=values[idx][0].trim()%>" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
                <td width="58" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
                <td width="200" id='h<%=idx%>_0' class="table_column"><%=values[idx][0]%></td>
                <td width="80" id='h<%=idx%>_1' class="table_column"><%=extensionnum%></td>
                <td width="200" id='h<%=idx%>_2' class="table_column"><%=values[idx][1]%></td>
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
		       						<td align="left"> <a href="alarmTimeList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="alarmTimeList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       		</td>
		       		<td colspan = 2 align="center" > 
<%					
		for(int i=(nBlockidx*nBlockcnt); i<(nBlockidx+1)*nBlockcnt && i<=nTotalpage; i++){
      			if(nNowpage==i)
      				out.print(" <b>"+(i+1)+"</b> ") ;
      			else
      				out.print(" <a href=\"alarmTimeList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="alarmTimeList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="alarmTimeList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
