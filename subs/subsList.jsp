<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="sun.misc.BASE64Encoder"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"  pageEncoding="EUC-KR"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="acromate.common.util.LanguageMode"%>
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
<title>Company 목록</title>

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

function func_init_alarm() {
	var groupid = <%=authGroupid%>;
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
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-base.js"></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-all.js"></script>
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
		
		//************************* Domain
		function getPage3(url, parm){
	        inf('hidden');
	        engine.execute("POST", url, parm, "ResgetPage3");
	    }
		
	    function ResgetPage3(data){
	        if(data){
	            document.getElementById('popup_layer2').innerHTML = data;
	            showAdCodeDiv2();
	        }else{
	            alert("에러") ;
	        }
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
	        obj.style.left = document.body.scrollLeft + (document.body.clientWidth / 2) - obj.offsetWidth/2;
	        obj.style.top = document.body.scrollTop + (document.body.clientHeight / 2) - obj.offsetHeight/2;

	        SET_DHTML('popup_layer2');
	        //document.getElementById('popup_layer').style.display="none";	    //
	    }
		
	    function hiddenAdCodeDiv2() {
	        inf('visible'); //select box 보이기
			//setShadowDivVisible(false); //배경 layer 숨김
	        document.getElementById('popup_layer2').style.display="none";

	    }
		//=========================
		
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
		    obj.style.top = '70px';
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
		 * groupid 변경
		 */
		function goChangeGrpID(groupid){
			if(groupid==''){
				alert('잘못된 Company ID 입니다.');
				return ;
			}
			
    	    var parm 	= '&groupid='+groupid;		//get형식으로 변수 전달.
    	    var url 	= 'subsChgeGrpIdPro.jsp';
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;					
    				var value = tempResult;//tempResult.replace(/\s/g, "");	// 공백제거
    				
    		    	if(value=='OK'){ 
    		    		alert("변경되었습니다.");
    		    		document.location.href = 'subsList.jsp';
    		    		return ;
    		    	}/* else if( value.indexOf('NO:') === 0 ){
    			    	alert(value.substr(3)+" 이미 존재하는 값이 있습니다!");
    			    	return;			
    		    	} */else if( value.indexOf('MSG:') === 0 ){
    			    	alert(value.substr(4));
    			    	return;			
    		    	}else{
    			    	alert("관리자에게 문의하신 후 사용하시기 바랍니다!");
    			    	return;			    	
    		    	}
    			},
    			failure: function ( result, request) { 
    				Ext.MessageBox.alert('Failed', result.responseText); 
    			} 
    		});
		}
		
		/**
		 * 중복 체크 후 저장 진행
		 */
		function goNewSaveDupCheck(actioname){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
    	    //var groupid 	= f2.groupid.value;
    	    var parm 	= '';//'&groupid='+groupid;		//get형식으로 변수 전달.
    	    var x = f2.getElementsByTagName("input");
    	    for(var i=0; i<x.length; i++){
    	    	parm += '&'+x[i].name+'='+x[i].value ;
    	    }
    	    x = f2.getElementsByTagName("select");
    	    for(var i=0; i<x.length; i++){
    	    	parm += '&'+x[i].name+'='+x[i].value ;
    	    }

    	    var url 	= '';
    		if(actioname=='group'){
    			url  = 'checkGroupidPro.jsp';
    		}else if(actioname=='num'){
    			url  = 'checkNumPro.jsp';
    		}
    		else if(actioname=='groupid'){
    			url  = 'checkCompnyidPro.jsp';
    		}else if(actioname=='regid'){
    			url  = 'checkRegiPro.jsp';
    		}
    		
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;					
    				var value = tempResult;//tempResult.replace(/\s/g, "");	// 공백제거
    				
    		    	if(value=='OK'){ 
    		    		alert("사용가능한 값입니다.");//goRefresh();
    		    		if(actioname=='group'){
    		    			goInsertPro() ;
    		    		}else if(actioname=='num'){
    		    			goNumInsertPro() ;
    		    		}
    		    		return ;
    		    	}else if( value.indexOf('NO:') === 0 ){
    			    	alert(value.substr(3)+" 이미 존재하는 값이 있습니다!");
    			    	return;			
    		    	}else if( value.indexOf('MSG:') === 0 ){
    			    	alert(value.substr(4));
    			    	return;			
    		    	}else{
    			    	alert("관리자에게 문의하신 후 사용하시기 바랍니다!");
    			    	return;			    	
    		    	}
    			},
    			failure: function ( result, request) { 
    				Ext.MessageBox.alert('Failed', result.responseText); 
    			} 
    		});
		}
		
		/**
		* 도메인 검색
		*/
		function goDomain(action_Type){
	    	var p_formtype		= action_Type;
	    	//var p_formtype		= "DOMAIN";
	        var parm = '&formtype='+p_formtype;		//get형식으로 변수 전달.
	        var url = "<%=StaticString.ContextRoot+pageDir%>/cmn/selectDomain.jsp";
	        getPage3(url,parm);
	    }

	    function goAddDomain(obj, id, p_formtype){    	
	        if(p_formtype=="I"){
		        obj.style.backgroundColor="a8d3aa";
		       	document.Savelayer.txtDomain.value = id;
		    }else{
		        obj.style.backgroundColor="a8d3aa";
		       	document.Editlayer.txtDomain.value = id;	    
		    }       	
	    }
	    
		/**
		 * 신규입력 화면으로 이동
		 */
		function goInsert(url){
		    var parm 	= "";
		    //var url 	= 'subsInsert.jsp';		    

		    getPage(url,parm);			
		}

		/**
		 * 신규 그룹 저장하기
		 */
		function goInsertPro(){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
            var str = "";
            if(f.chkOpt != undefined){
            	str = setE164BySelected();
            	/* if(f.chkOpt.length == undefined){
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
                } */
            }
            
            f.groupid.value   	= f2.groupid.value;
            
            f.loginid.value   	= f2.loginid.value;
            f.password.value   	= f2.password.value;
            
            f.domainid.value   	= f2.txtDomain.value;
            f.areanum.value   	= f2.areanum.value;
            f.localnum.value   	= f2.localnum.value;
            f.extnum.value   	= f2.extnum.value;
            f.authpasswd.value  = f2.authpasswd.value;
            f.createcount.value = f2.createcount.value;
            
            f.outproxyip.value  = f2.outproxyip.value;
            f.startprefix.value = f2.startprefix.value;
            f.endprefix.value   = f2.endprefix.value;
            f.mindigit.value  	= f2.mindigit.value;
            f.maxdigit.value 	= f2.maxdigit.value;
        	
            //f.extensiongroupnum.value = f2.extensiongroupnum.value;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/subs/subsInsertPro.jsp";
            f.method = "post";
            f.submit();	
		}	
		
		/**
		 * 번호 추가 저장하기
		 */
		function goNumInsertPro(){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
            f.groupid.value   	= f2.groupid.value;
            
            //f.domainid.value   	= f2.txtDomain.value;
            f.areanum.value   	= f2.areanum.value;
            f.localnum.value   	= f2.localnum.value;
            f.extnum.value   	= f2.extnum.value;
            f.authpasswd.value  = f2.authpasswd.value;
            f.createcount.value = f2.createcount.value;
            
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/subs/subsNumInsertPro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 신규입력 후 출력
		 */
		function goInsertDone(datas){
			if(datas.length > 0)
				additem(0, datas[0].params[0], datas[0].params[1]) ;
		}
		
		/**
		 * 전화번호 입력 후 출력
		 */
		function goNumInsertDone(datas){
			var _o=null, _p=null, _td;
			var _i = 0;
			var _lc = document.getElementById("tb_list").lastChild ;
			while(_lc)
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
				  if(datas[0].params[0]==_p.innerHTML){//alert(_p.innerHTML);
					  _td = document.getElementById("h"+_i+"_2");
					  if(_td){
						  _td.innerHTML =
						  	"<input type=\"button\" name=\"btnInsNum\" style=\"height: 18px\" value=\"번호 추가\" onclick=\"func_setAction('"+datas[0].params[0]+"', 1)\">"
						  	+" <input type=\"button\" name=\"btnDelNum\" style=\"height: 18px\" value=\"번호 삭제\" onclick=\"func_setAction('"+datas[0].params[0]+"', 2)\">"
				        	+ " <input type=\"button\" name=\"btnDelGrpid\" style=\"height: 18px\" value=\"Company 삭제\" onclick=\"func_setAction('"+datas[0].params[0]+"', 3)\">"
					  }
					  _td = document.getElementById("h"+_i+"_3");
					  if(_td){
						  _td.innerHTML =
				        	" <input type=\"button\" name=\"btnSelect\" style=\"height: 18px\" value=\"선택\" onclick=\"func_setAction('"+datas[0].params[0]+"', 5)\">"
					  }
					  return ;
				  }
			  }
			  
			  _o=document.getElementById("g"+_i) ;
			  if(_lc==_o) return ;
			  
			  _i++;
			}
		}
		
        /**
         * 삭제 화면으로 이동
         */
        function goDelete(url){
            var parm 	= '';
            //var url 	= 'subsDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * 그룹 삭제처리
		 */
		function goDeletePro(){
            var f   = document.frm;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/subs/subsDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 그룹 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			var _o=null, _p=null;
			var _i = 0;
			var _lc = document.getElementById("tb_list").lastChild ;
			while(_lc)
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
				  if(datas[0].params[0]==_p.innerHTML){//alert(_p.innerHTML);
					  delitem(_p); return ;
				  }
			  }
			  
			  _o=document.getElementById("g"+_i) ;
			  if(_lc==_o) return ;
			  
			  _i++;
			}
		}
		
		/**
		 * 번호 삭제처리
		 */
		function goNumDeletePro(){
            var f   = document.frm;
            var f2 = document.Deletelayer1;
            
	        //alert(f.groupid.value);
            f.groupid.value   	= f2.groupid.value;
          
            //f.domainid.value   	= f2.txtDomain.value;
            f.areanum.value   	= f2.areanum.value;
            f.localnum.value   	= f2.localnum.value;
            f.extnum.value   	= f2.extnum.value;
            //f.authpasswd.value  = f2.authpasswd.value;
            f.createcount.value = f2.deletecount.value;
            
          
		   	f.target = "procframe";
            //f.action = "<%=StaticString.ContextRoot+pageDir%>/subs/subsNumDeletePro.jsp";
            f.action = "subsNumDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 번호 삭제처리 후 출력
		 */
		function goNumDeleteDone(datas){
			var _o=null, _p=null;
			var _i = 0;
			var _lc = document.getElementById("tb_list").lastChild ;
			while(_lc)
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
				  if(datas[0].params[0]==_p.innerHTML){//alert(_p.innerHTML);
					  //delitem(_p);
					  var _td = document.getElementById("h"+_i+"_2");
					  if(_td){
						  _td.innerHTML =
						  	"<input type=\"button\" name=\"btnInsNum\" style=\"height: 18px\" value=\"번호 추가\" onclick=\"func_setAction('"+datas[0].params[0]+"', 1)\">"
						  	+" <input type=\"button\" name=\"btnDelNum\" style=\"height: 18px\" value=\"번호 삭제\" onclick=\"func_setAction('"+datas[0].params[0]+"', 2)\">"
				        	+ " <input type=\"button\" name=\"btnDelGrpid\" style=\"height: 18px\" value=\"Company 삭제\" onclick=\"func_setAction('"+datas[0].params[0]+"', 3)\">"
					  }
					  return ;
				  }
			  }
			  
			  _o=document.getElementById("g"+_i) ;
			  if(_lc==_o) return ;
			  
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
		function setKeysBySelected(){
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
            
            return str;//document.frm.e164.value = str;
		}
		
        /**
         * 추가/해제 클릭
         */
		function func_setAction(grpid, type) {
			if(grpid) document.frm.groupid.value = grpid;
			
			if(type==1)			goInsert('subsNumInsert.jsp?groupid='+grpid);
			else if(type==2)	goDelete('subsNumDelete.jsp?groupid='+grpid);
			else if(type==3)	goDelete('subsDelete.jsp?groupid='+grpid);
			else if(type==4)	goInsert('subsInsert.jsp');
			else if(type==5)	goChangeGrpID(grpid);

			//window.open("alarmInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setActionBySelected(type) {
			document.frm.groupid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('해제')==0 ) return ;
				document.frm.e164.value = setKeysBySelected() ;
				goDelete('subsDelete.jsp') ;
			}
			else{
				if( isChecked('등록')==0 ) return ;
				document.frm.e164.value = setKeysBySelected() ;
				goInsert('subsInsert.jsp') ;
        	}
		}
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_alarm" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		 	//document.location.href = "../conn/logout.jsp";
		}
		
		function realtimeClock() {
			if(1==1) return ;
			//document.rtcForm.rtcInput.value = getTimeStamp();
			document.location.href = 'subsList.jsp';
			setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==0 ){
				document.getElementById('groupid').innerHTML = "<b>Company ID ▲</b>";
				}else{
					document.getElementById('groupid').innerHTML = "<b>Company ID ▼</b>";
				}
				document.getElementById('extensnum').innerHTML = "Company Code <font size='1px'>▽</font>";//△
			}
			else if(nField==1){
				if( lastSort==1 ){
					document.getElementById('extensnum').innerHTML = "<b>Company Code ▲</b>";
				}else{
					document.getElementById('extensnum').innerHTML = "<b>Company Code ▼</b>";							
				}
				document.getElementById('groupid').innerHTML = "Company ID <font size='1px'>▽</font>";
			}
		}
		
		function additem(idx, param1, param2) {
			var t_new_tr = document.createElement('TR');	
			var t_table = document.getElementById('tb_list');	//area_tb_list
			var old_items_html = t_table.innerHTML;
			
			var count_tr = idx>0?idx:t_table.getElementsByTagName("TR").length;
			//alert('count :'+count_tr);	
				t_new_tr.id = "g"+count_tr;
				t_new_tr.height = "22";
				t_new_tr.bgcolor = "E7F0EC";
				t_new_tr.align = "center";
				t_new_tr.innerHTML =
				//"<TR>"
		        //"<tr id=g"+count_tr+" height=\"22\" bgcolor=\"E7F0EC\" align=\"center\" >"
		        "<td width=\"58\" class=\"table_column\">"+ (count_tr+<%=nModePaging==1 ? nNowpage*nMaxitemcnt+1 : 1 %>) +"</td>"
		        + "<td width=\"150\" id='h"+count_tr+"_0' class=\"table_column\">"+param1+"</td>"
		        + "<td width=\"150\" id='h"+count_tr+"_1' class=\"table_column\">"+param2+"</td>"
		        + "<td width=\"300\" id='h"+count_tr+"_2' class=\"table_column\">"
			        + "<input type=\"button\" name=\"btnInsNum\" style=\"height: 18px\" value=\"번호 추가\" onclick=\"func_setAction('"+param1+"', 1)\">"
			        + " <input type=\"button\" name=\"btnDelNum\" style=\"height: 18px\" value=\"번호 삭제\" onclick=\"func_setAction('"+param1+"', 2)\">"
			        + " <input type=\"button\" name=\"btnDelGrpid\" style=\"height: 18px\" value=\"Company 삭제\" onclick=\"func_setAction('"+param1+"', 3)\">"
			    + "</td>"
			    + "<td width=\"50\" id='h"+count_tr+"_3' class=\"table_column\">"
			    	+ "<input type=\"button\" name=\"btnSelect\" style=\"height: 18px\" value=\"선택\" onclick=\"func_setAction('"+param1+"', 5)\">"
			    + "</td>"
			    + "<td class=\"table_column\">&nbsp;</td>"
			  	//+ "</TR>'
              
			    t_table.innerHTML = '';
			    
				t_table.appendChild(t_new_tr);	
				
				t_table.innerHTML = t_table.innerHTML + old_items_html;
				
			return count_tr;		
		}

		function delitem(td) {	
			var i = td.parentNode.rowIndex;
			document.getElementById("tb_list").deleteRow(i);
		}
	</script>
	
<style type="text/css">
<!--
body {
	background-color: #ffffff;
}

#menu {
      width: 180px; height: 44px;
      position: fixed; top: 5px; z-index: 900;
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
		<% int menu = 1, submenu = 1; %>
		<table id="menu" width="180" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	<!--end--왼쪽페이지-->
	</td>
	<td><table>
<!-- <TBODY> -->
<FORM name="frm" method="post">
	<input type='hidden' name ='groupid' value="">
	
	<input type='hidden' name ='loginid' value="">
	<input type='hidden' name ='password' value="">
	
	<input type='hidden' name ='domainid' value="">
	<input type='hidden' name ='areanum' value="">
	<input type='hidden' name ='localnum' value="">
	<input type='hidden' name ='extnum' value="">
	<input type='hidden' name ='authpasswd' value="">
	<input type='hidden' name ='createcount' value="">
	
	<input type='hidden' name ='outproxyip' value="">
	<input type='hidden' name ='startprefix' value="">
	<input type='hidden' name ='endprefix' value="">
	<input type='hidden' name ='mindigit' value="">
	<input type='hidden' name ='maxdigit' value="">
	
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
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutItems" style="height: 18px" value="Company 등록" onclick="func_setAction('', 4)">
                  	<!-- <input type="button" name="btnDelItems" style="height: 18px" value="선택 해제" onclick="func_setActionBySelected(1)"> -->
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
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="150" onclick="sortNow(0,false);changeTitle(0);" id="groupid" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>Company ID ▲</b></td>
                  <td width="150" onclick="sortNow(1,true);changeTitle(1);" id="extensnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">Company Code <font size='1px'>▽</font></td>
                  <td width="350" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호 추가&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;번호 삭제&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;Company 삭제 </td>
                  <td width="50" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"> 선택 </td>
                  <td class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
              </tr>
		  </table>
		</td>
	</tr>
	<tr>
        <td valign="top" id="area_tb_list">
<!-- <div style="width:792; height:222; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">		 -->
          <table id="tb_list" width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
          
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

				CommonDAO		commonDao		= new CommonDAO();
				String 			commonSql		= "SELECT groupid, extensiongroupnum" ; 
								commonSql		+= ", ( SELECT count(*) FROM table_subscriberGroup ) as totalcnt ";
								commonSql		+= ", ( SELECT count(*) FROM table_e164route WHERE checkgroupid = sg.groupid) as e164cnt ";
								commonSql		+= " FROM table_subscriberGroup AS sg ";
				if(nModePaging==1){
								//commonSql		+= " LIMIT "+ (nNowpage*nMaxitemcnt+1) +", "+(nNowpage*nMaxitemcnt+nMaxitemcnt)+" ";
								commonSql		+= " LIMIT "+nMaxitemcnt+" ";
								commonSql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
				}
				commonSql		+= " ORDER BY groupid ASC " ;
				String 			strColNames[]	= {"groupid", "extensiongroupnum","totalcnt","e164cnt"} ;
				System.out.println("query : "+commonSql);
				String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
				for (int i = 0 ; i < 3 ; i++ ) {
					stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID) ;
					if (stmt == null) {
						Thread.sleep(100) ;
						System.out.println("stmt is null");
						continue ;
					}
					envList2 = commonDao.select(stmt,commonSql,strColNames) ;
					if ( envList2 == null ) {
				    	ConnectionManager.freeStatement(stmt);
						Thread.sleep(100) ;
						System.out.println("======>0");
						continue ; 
					}
					break ;
				}
			}
			count 			= envList2==null? 0 : envList2.size();
			
			values = new String[count][2];
		}catch(Exception ex){
			System.out.println(ex.toString());
			out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
		}
	}else if(nAllowUser==1){
		envList2 = new ArrayList<HashMap>() ;
		HashMap smpitem;
		for(int z=0; z<nMaxitemcnt; z++){
			smpitem = new HashMap();
			smpitem.put("groupid", "DEBUG_GRP_"+z) ; smpitem.put("extensiongroupnum", "0009"+z+"*") ;
			smpitem.put("totalcnt", "25") ;
			if(z%2==0)	smpitem.put("e164cnt", "1") ;
			else		smpitem.put("e164cnt", "0") ;
			envList2.add(smpitem);
		}
		count = envList2.size();//nMaxitemcnt ;
		nTotalpage = 25;
		if(nNowpage >= nTotalpage) count = 4;
		values = new String[count][2];
	}
	
	int idx=0, nE164cnt=0;
	if(/* envList!=null && */ count!=0){
		HashMap temp= null;
		for(idx=0;idx<count;idx++){
			if(envList2!=null)
				temp	=	(HashMap)envList2.get(idx);
			
			if(temp!=null){
				values[idx][0] = (String)temp.get("groupid");
				values[idx][1] = (String)temp.get("extensiongroupnum");
				
				nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
				nE164cnt = (int)StringUtil.getLong((String)temp.get("e164cnt")) ;
			}else continue ;
%>	
			  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
                <%-- <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=values[idx][0].trim()%>" > </td> --%> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
                <td width="58" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
                <td width="150" id='h<%=idx%>_0' class="table_column"><%=values[idx][0]%></td>
                <td width="150" id='h<%=idx%>_1' class="table_column"><%=values[idx][1]%></td>
                <td width="350" id='h<%=idx%>_2' class="table_column">
                <%//if(nE164cnt==0){ %>
                	<input type="button" name="btnInsNum" style="height: 18px" value="번호 추가" onclick="func_setAction('<%=values[idx][0]%>', 1)">
                <%//}else{ %>
                	<input type="button" name="btnDelNum" style="height: 18px" value="번호 삭제" onclick="func_setAction('<%=values[idx][0]%>', 2)">
                <%//} %>
                	<input type="button" name="btnDelGrpid" style="height: 18px" value="Company 삭제" onclick="func_setAction('<%=values[idx][0]%>', 3)">
                </td>
                <td width="50" id='h<%=idx%>_3' class="table_column">
                	<input type="button" name="btnSelect" style="height: 18px" value="선택" onclick="func_setAction('<%=values[idx][0]%>', 5)">
                </td>
                <td class="table_column">&nbsp;</td>
              </tr>
<% 
		}//for
	}//if

    if (stmt != null){
    	out.println("<script type=\"text/JavaScript\"> sortNow(0,false); </script>") ;//Company ID 정렬
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
		       						<td align="left"> <a href="subsList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="subsList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"subsList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="subsList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="subsList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
