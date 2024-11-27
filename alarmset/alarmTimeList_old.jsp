<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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

<%
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
   	
    String authGroupid = null;
    int nAllowUser = 0;//0: unauth, 1:auth, -1:DB err
    if(1==1){
		//response.setContentType("text/plain");
		//PrintWriter out = response.getWriter();
		// Get Authorization header
		String auth = request.getHeader("Authorization");
		
		// Do we allow that user?
		HashMap users = new HashMap();
// 		users.put("User1:hello","allowed");
// 	    users.put("User2:xxx","allowed");
		// this user requires no password
		users.put("aaa:ccc","allowedIPCS");
		
		nAllowUser = auth==null?0:1;//allowUser(auth)
		if (auth == null) {
			nAllowUser = 0;  // no auth
	    }else	if (!auth.toUpperCase().startsWith("BASIC ")) { 
	    	nAllowUser = 0;  // we only do BASIC
		}else{
			nAllowUser = 0;
			 
		    // Get encoded user and password, comes after "BASIC "
		    String userpassEncoded = auth.substring(6);
		    // Decode it, using any base 64 decoder
		    sun.misc.BASE64Decoder dec = new sun.misc.BASE64Decoder();
		    String userpassDecoded = new String(dec.decodeBuffer(userpassEncoded));
		    
		    if(nModeDebug!=1){
		    	String[] userInfo = userpassDecoded.split(":") ;
		    	if(userInfo.length==2){
		    		
		    		String[][] 		values = null;
			    	ArrayList 		envList = null;
			    	DataStatement 	stmt = null;
			    	int count = 0;
			    		
			    	try{
			   			stmt 			= ConnectionManager.allocStatement("SSW");
			    	}catch(Exception ex){
			    		stmt = null;
			    		nAllowUser = -1 ;
			    	}
			    	
			    	if(nAllowUser > -1){
				   		CommonDAO		commonDao		= new CommonDAO();
				   		String 			commonSql		= "SELECT id, pwd, checkgroupid FROM table_subscriber WHERE id='"+userInfo[0].trim()+"' AND pwd='"+userInfo[1].trim()+"'";
				   		String 			strColNames[]	= {"id","pwd","checkgroupid"};
				   		
				   		envList			= commonDao.select(stmt,commonSql,strColNames);
				   		if (stmt != null) ConnectionManager.freeStatement(stmt);
			    	}
					count 			= envList==null? 0 : envList.size();
					if("0".equals(loginFail)){
				    	Cookie[] cookies = request.getCookies(); //쿠키값 얻어오기
				    	for(Cookie ck : cookies){
				    		if( "id_cookie_alarm".equals(ck.getName()) 
				    				//&& !authGroupid.equals(ck.getValue())
				    				&& ck.getValue().trim().length()==0
				    				){
					    		String value = ck.getValue() ;
					    		count = 0;
				    			nAllowUser = 0; break;
				    		}
				    	}
			    	}
					values = new String[count][3];
				
					if(/* envList!=null && */ count>0){
						HashMap temp= null;
						int flagAlarm = 0;
						for(int idx=0;idx<count;idx++){
							if(envList!=null)
								temp	=	(HashMap)envList.get(idx);
							
							if(temp!=null){
								values[idx][0] = (String)temp.get("id");
								values[idx][1] = (String)temp.get("pwd");
								values[idx][2] = (String)temp.get("checkgroupid");
								
					    		String authGrpid = (String)users.get(userpassDecoded) ;
							    if ( userpassDecoded!=null 
							    		&& userpassDecoded.equals(values[idx][0]+":"+values[idx][1]) ) {
							    	authGroupid = values[idx][2] ;
							    	nAllowUser = 1 ;
							    } else {
							    	authGroupid = null;
							    	nAllowUser = 0 ;
							    }
							}
						}//for
					}
					
		    	}//length
		    	
		    }else{
			 	// Check our user list to see if that user and password are "allowed"
			    //if ("allowed".equals(users.get(userpassDecoded))) {
			   	String authGrpid = (String)users.get(userpassDecoded) ;
			    if ( authGrpid!=null && authGrpid.startsWith("allowed") ) {
			    	authGroupid = authGrpid.substring(7) ;
			    	nAllowUser = 1 ;
			    	if("0".equals(loginFail)){
				    	Cookie[] cookies = request.getCookies(); //쿠키값 얻어오기
				    	for(Cookie ck : cookies){
				    		if( "id_cookie_alarm".equals(ck.getName()) 
				    				//&& !authGroupid.equals(ck.getValue())
				    				&& ck.getValue().trim().length()==0
				    				){
					    		String value = ck.getValue() ;
				    			nAllowUser = 0; break;
				    		}
				    	}
			    	}
			    } else {
			    	authGroupid = null;
			    	nAllowUser = 0 ;
			    }
		    }
	    }
		
		if (nAllowUser < 1) {
		    // Not allowed, so report he's unauthorized
		    String realm = "Biz Portal";//"로그인하고자 하는 아이디와 패스워드를 입력하거나 로그아웃을 하려면 값을 입력하지 말고 확인을 클릭하세요.";
		    response.setStatus(response.SC_UNAUTHORIZED); 
		    response.setHeader("WWW-Authenticate", "Basic realm=\""+realm+"\"");
		    //response.sendRedirect("./alarmTimeList.jsp?err=0") ;
// 		    response.setHeader("HTTP/1.0 401 Unauthorized", null);
		    //response.sendError(response.SC_UNAUTHORIZED);
		    // Could offer to add him to the allowed user list
		    if(1!=1) return ;
		} else {
			Cookie imsicookie = null;
			for(Cookie ck : request.getCookies()){
	    		if( "id_cookie_alarm".equals(ck.getName()) ){
	    			imsicookie = ck; break;
	    		}
			}
			if(imsicookie==null)
				imsicookie = new Cookie("id_cookie_alarm", authGroupid);
			imsicookie.setPath("/"); 
			imsicookie.setMaxAge(-1); //브라우저를 닫으면 쿠키가 자동소멸
			response.addCookie(imsicookie); 
		}
	
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

function func_logoutCommit() {
	document.cookie = "id_cookie_alarm" + "=";
	document.execCommand('ClearAuthenticationCache');	
	document.location.href = "alarmTimeList.jsp?err=0";
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

<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>

<style type="text/css">
<!--
body {
	background-color: #ffffff;
}
-->
</style>
</head>

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="func_init_alarm();">
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<div>
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

		/**
		 * 신규입력 화면으로 이동
		 */
		function goInsert(){
		    var parm 	= "";
		    var url 	= 'alarmInsert.jsp';		    

		    getPage(url,parm);			
		}

		/**
		 * 신규 내용 저장하기
		 */
		function goNewSave(){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
            var str = "";
            if(f.chkOpt != undefined){
                if(f.chkOpt.length == undefined){
                    if(f.chkOpt.checked){
                        str = f.chkOpt.value;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            if(str == ""){
                                str = f.chkOpt[i].value;
                            }else{
                                str = str + "|" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }
            
            f.alarmtype.value   = f2.alarmtype.value;
            f.alarmtime_1.value = f2.alarmtime_1.value;
            f.alarmtime_2.value = f2.alarmtime_2.value;
            f.alarmtime_3.value = f2.alarmtime_3.value;
            f.alarmdate_1.value = f2.alarmdate_0.value; //"<%=StringUtil.getKSTDate().substring(0,4)%>";
            f.alarmdate_2.value = f2.alarmdate_1.value;
            f.alarmdate_3.value = f2.alarmdate_2.value;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot%>/alarm/alarmInsertPro.jsp";
            f.method = "post";
            f.submit();	
		}		

        /**
         * 삭제 화면으로 이동
         */
        function goDelete(){
            var parm 	= '';
            var url 	= 'alarmDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * 삭제처리
		 */
		function goDeletePro(){
            var f   = document.frm;
            var str = "";
            if(f != undefined && f.chkOpt != undefined){
                if(f.chkOpt.length == undefined){
                    if(f.chkOpt.checked){
                        str = f.chkOpt.value;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            if(str == ""){
                                str = f.chkOpt[i].value;
                            }else{
                                str = str + "|" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }else
		       	str = "1";

            f.deleteStr.value = str;//

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot%>/alarm/alarmDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}

        /**
		 * 저장하기
		 */
		function goSave(){
			var f  = document.frm;

            if(f.gubun[0].checked){     // 지정 시간 통보 사용하지 않음 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보를 사용하지 않는 상태입니다.';
                    var url  = "<%=StaticString.ContextRoot%>/alarm/alarmMsgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("모든 설정이 삭제됩니다. 저장하시겠습니까?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot%>/alarm/alarmSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // 지정 시간 통보 사용하기 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보 설정을 추가하여 주십시오.';
                    var url  = "<%=StaticString.ContextRoot%>/alarm/alarmMsgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'알람통보 설정'+'&msg='+'알람통보를 사용하고 있습니다.';
                    var url  = "<%=StaticString.ContextRoot%>/alarm/alarmMsgPopup.jsp";
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
                var url  = "<%=StaticString.ContextRoot%>/alarm/alarmMsgPopup.jsp";
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
                    var url  = "<%=StaticString.ContextRoot%>/alarm/alarmMsgPopup.jsp";
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
                        str = f.chkOpt.value;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            if(str == ""){
                                str = f.chkOpt[i].value;
                            }else{
                                str = str + "|" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }
            
            document.frm.e164.value = str;
		}
		
        /**
         * 추가/해제 클릭
         */
		function func_setAlarm(num, type) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				goDelete();
				//window.open("alarmDelete.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
			}
			else{
				goInsert();
				//window.open("alarmInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
        	}
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setAlarmBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('해제')==0 ) return ;
				setE164BySelected() ;
				goDelete() ;
			}
			else{
				if( isChecked('등록')==0 ) return ;
				setE164BySelected() ;
				goInsert() ;
        	}
		}
		
	</script>
<table align="center"><tr><td>

<TBODY>
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
	<tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td colspan="1" width="58" style="color: blue;vertical-align: bottom;" ><% if(nAllowUser==1) out.println(authGroupid); %> </td>
                  <td colspan="1" align="left">
                  <% if(nAllowUser==1)
                	  out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"로그아웃\" onclick=\"func_logoutCommit()\">") ;
	           	  	else
	           	  	  out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
                  	//<input type="button" name="btnLogout" style="height: 18px" value="로그아웃" onclick="func_logoutCommit()"> 
	           	  %>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="500" align="right"> 
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
                  <td width="200" onclick=sortNow(0); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">전화번호</td>
                  <td width="80" onclick=sortNow(11); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">내선번호</td>
                  <td width="200" onclick=sortNow(12); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">알람시각</td>
                  <td width="80" onclick=sortNow(13); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">등록/해제</td>
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
			String 			strColNames[]	= {"e164", "extensionnumber","alarmdate","alarmtime","totalcnt"};
			
			envList2		= commonDao.select(stmt,commonSql,strColNames);
		}
		count 			= envList2==null? 0 : envList2.size();
		
		values = new String[count][3];
	}else if(nAllowUser==1){
		nTotalpage = 25;		
		count = nMaxitemcnt ;
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
                <td width="80" id='h<%=idx%>_11' class="table_column"><%=extensionnum%></td>
                <td width="200" id='h<%=idx%>_12' class="table_column"><%=values[idx][1]%></td>
                <td width="80" id='h<%=idx%>_13' class="table_column"><input type="button" name="btnAlarm" style="height: 18px" value="<%=(flagAlarm==1?"해제":"등록")%>" onclick="func_setAlarm('<%=values[idx][0]%>', <%=flagAlarm%>)"></td>
                <td class="table_column">&nbsp;</td>
              </tr>
<% 
		}//for
	}//if

    if (stmt != null) ConnectionManager.freeStatement(stmt);
		
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
</TBODY>   

</td></tr></table>
<iframe name="procframe" src="" width="0" height="0"></iframe>
</div>

</BODY>
</HTML>
<!-- 팝업 레이어 -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;">
