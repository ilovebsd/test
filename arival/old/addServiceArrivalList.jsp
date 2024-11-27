<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.AddServiceArrivalDTO" %>
<%@ page import="dto.UserE164DTO" %>
<%@ page import="useconfig.AddServiceList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>
<%@ page import="business.CommonData"%>
<%@ page import="system.SystemConfigSet"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String 	userName 	= Str.CheckNullString(scDTO.getName()).trim();
String 	userID 		= Str.CheckNullString(scDTO.getSubsID()).trim();
//String 	e164 		= Str.CheckNullString(scDTO.getPhoneNum()).trim();

String 	loginLevel 	= Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
String 	menu       	= "11";  // 부가서비스 설정
String 	submenu    	= "1";  // 부가서비스 설정

String new_menu     = "C";  		// 부가설정
String new_submenu  = "3";  		// 부가서비스 설정

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");

//발신제한
AddServiceList 	addServiceList = new AddServiceList();

CommonData	commonData		= new CommonData();
List 		userList 		= commonData.getUserList(stmt);
int 		userCount 		= userList.size();

List 		iList 			= addServiceList.getArrivalList(stmt);		// 데이타 조회
int 		iCount 			= iList.size();


//도메인 조회
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
%>

<!-- saved from url=(0022)http://internet.e-mail -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: <%=domainid%>, Ver: <%=strVersion%></title>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/function_ivr.js'></script>

<script type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}
//-->

    /**
     * 메세지 팝업 보여주기
     */
    function getMsgPage(url, parm){
		    inf('hidden');
		    engine.execute("POST", url, parm, "ResgetMsgPage");
    }
    
    function ResgetMsgPage(data){
        if(data){		    	
            document.getElementById('popup_layer').innerHTML = data;
            showAdCodeDivMsg();
        }else{
            alert("에러") ;
        }
    }

    /**
     * 클릭시 메세지 팝업 보여주기
     */    
    function showAdCodeDivMsg() {		
        try{
            setShadowDivVisible(false); //배경 layer
        }catch(e){
        }
        setShadowDivVisible(true); //배경 layer
    
        var d_id 	= 'popup_layer';
        var obj 	= document.getElementById(d_id);
    
        obj.style.zIndex=998;
        obj.style.display = "";
        obj.style.top =200;
        obj.style.left = 400;
    
        SET_DHTML('popup_layer');
    }

	
	
</script>
</head>

<body onLoad="MM_preloadImages('imgs/menu_calllist_select_btn.gif','imgs/menu_premium_select_btn.gif')">
<link href="css/td_style.css" rel="stylesheet" type="text/css">
<div>
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>

<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-base.js"></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-all.js"></script>

<script language="JavaScript" type="text/JavaScript">
    function getPage(url, parm){
		    inf('hidden');
		    engine.execute("POST", url, parm, "ResgetPage");
    }
    
    function ResgetPage(data){
        if(data){		    	
            document.getElementById('popup_layer').innerHTML = data;
            showAdCodeDiv(1);
        }else{
            alert("에러") ;
        }
    }

    function getPage2(url, parm){
		    inf('hidden');
		    engine.execute("POST", url, parm, "ResgetPage2");
    }
    
    function ResgetPage2(data){
        if(data){		    	
            document.getElementById('popup_layer').innerHTML = data;
            showAdCodeDiv(2);
        }else{
            alert("에러") ;
        }
    }
    
    /**
     * 클릭시 팝업 보여주기
     */
    
    function showAdCodeDiv(type) {		
        try{
            setShadowDivVisible(false); //배경 layer
        }catch(e){
        }
        setShadowDivVisible(true); //배경 layer
    
        var d_id 	= 'popup_layer';
        var obj 	= document.getElementById(d_id);
    
		if(type == 1){
	        obj.style.zIndex=998;
	        obj.style.display = "";
	        obj.style.top =200;
	        obj.style.left = 400;
		}else{
		    obj.style.zIndex=998;
		    obj.style.display = "";
		    obj.style.top =200;
		    obj.style.left = 200;			
		}    
    
        SET_DHTML('popup_layer');
    }
    
    /**
     * 등록 클릭시 팝업 숨기기
     */
    function hiddenAdCodeDiv() {
        inf('visible'); //select box 보이기
        //setShadowDivVisible(false); //배경 layer 숨김
    
        document.getElementById('popup_layer').style.display="none";
    }

    /**
     * 탭페이지 이동
     */
    function goTabPage(gubun){
        if(gubun == "1"){
            location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceCallBlockList.jsp";
        }else if(gubun == "2"){
            location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceVirtualList.jsp";
        }else if(gubun == "3"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceNewMRBTList2.jsp";
        }else if(gubun == "4"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceDeptMRBTList.jsp";
        }else if(gubun == "5"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceNewMOHList2.jsp";
        }else if(gubun == "6"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceVmsList.jsp";
        }else if(gubun == "7"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceBlfList.jsp";
        }else if(gubun == "8"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceAlertInfoList.jsp";
        }else if(gubun == "9"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceSecretaryList.jsp";
        }else if(gubun == "10"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceFmcList.jsp";
        }else if(gubun == "11"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceCallChangeList.jsp";
        }else if(gubun == "12"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceForkingList.jsp";
        }else if(gubun == "13"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceArrivalList.jsp";
        }else if(gubun == "14"){
        	location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceAlarmList.jsp";
        }
    }
      
	/**
	 * 수정 화면으로 이동
	 */
	function showEdit(p_e164){
	    var parm 	= '&hiEi64='+p_e164;
	    //var url 	= 'addServiceArrivalEdit.jsp';		    
		var url 	= 'addServiceArrivalEdit_New.jsp';
		
	    getPage2(url,parm);			
	}


	// ++++++++++++++++++++++++++++++++++++++++++++++++++++
    function getPage2(url, parm){
        inf('hidden');
        engine.execute("POST", url, parm, "ResgetPage2");
    }

    function ResgetPage2(data){
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
		setShadowDivVisible(false); //배경 layer 숨김
        document.getElementById('popup_layer2').style.display="none";
        
        hiddenAdCodeDiv3();
    }    
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++

    function getPage3(url, parm){
        inf('hidden');
        
        engine.execute("POST", url, parm, "ResgetPage3");
    }

    function ResgetPage3(data){
        if(data){
            document.getElementById('popup_layer3').innerHTML = data;
            showAdCodeDiv3();
        }else{
            alert("에러") ;
        }
    }

    function showAdCodeDiv3() {
        try{
            setShadowDivVisible(false); //배경 layer
        }catch(e){
        }
        setShadowDivVisible(true); //배경 layer

        var d_id 	= 'popup_layer3';
        var obj 	= document.getElementById(d_id);

        obj.style.zIndex=998;
        obj.style.display = "";
        obj.style.left = document.body.scrollLeft + (document.body.clientWidth / 2) - obj.offsetWidth/2;
        obj.style.top = document.body.scrollTop + (document.body.clientHeight / 2) - obj.offsetHeight/2;

        SET_DHTML('popup_layer3');
        //document.getElementById('popup_layer').style.display="none";	    //
    }
	
    function hiddenAdCodeDiv3() {
        inf('visible'); //select box 보이기
		//setShadowDivVisible(false); //배경 layer 숨김
        document.getElementById('popup_layer3').style.display="none";
    }
    
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
	function selectType(){
		var selectType1 	= document.getElementById("selectType1");
		var txtNumber1 		= document.getElementById("txtNumber1");
		
		if(selectType1.value=="1"){
			txtNumber1.disabled	= false;
		}else{
			txtNumber1.disabled	= true;
		}
	}
	
    function forwardType(no){
        var selectType1 	= document.getElementById("selectType1");
        var txtNumber1 		= document.getElementById("txtNumber1");
        var chkForward_0 	= document.getElementById("chkForward_0");
        var chkForward_1 	= document.getElementById("chkForward_1");
        var chkForward_2 	= document.getElementById("chkForward_2");
        var chkForward_3 	= document.getElementById("chkForward_3");
        var toTime1 		= document.getElementById("toTime1");
        var toTime2 		= document.getElementById("toTime2");
        var toTime3 		= document.getElementById("toTime3");
        var fromTime1 		= document.getElementById("fromTime1");
        var fromTime2 		= document.getElementById("fromTime2");
        var fromTime3 		= document.getElementById("fromTime3");
        var waitTime 		= document.getElementById("waitTime");
        var txtNumber2 		= document.getElementById("txtNumber2");
        var txtNumber3 		= document.getElementById("txtNumber3");
        var txtNumber4 		= document.getElementById("txtNumber4");
        var txtNumber5 		= document.getElementById("txtNumber5");
            
        if(no==1){
	        selectType1.disabled	= true;
	        txtNumber1.disabled		= true;
	        chkForward_0.disabled	= true;
	        chkForward_1.disabled	= true;
	        chkForward_2.disabled	= true;
	        chkForward_3.disabled	= true;
	        toTime1.disabled		= true;
	        toTime2.disabled		= true;
	        toTime3.disabled		= true;
	        fromTime1.disabled		= true;
	        fromTime2.disabled		= true;
	        fromTime3.disabled		= true;
	        waitTime.disabled		= true;
	        txtNumber2.disabled		= true;
	        txtNumber3.disabled		= true;
	        txtNumber4.disabled		= true;
	        txtNumber5.disabled		= true;
		}else if(no==2){
	        selectType1.disabled	= false;
	        txtNumber1.disabled		= false;
	        chkForward_0.disabled	= true;
	        chkForward_1.disabled	= true;
	        chkForward_2.disabled	= true;
	        chkForward_3.disabled	= true;
	        toTime1.disabled		= true;
	        toTime2.disabled		= true;
	        toTime3.disabled		= true;
	        fromTime1.disabled		= true;
	        fromTime2.disabled		= true;
	        fromTime3.disabled		= true;
	        waitTime.disabled		= true;
	        txtNumber2.disabled		= true;
	        txtNumber3.disabled		= true;
	        txtNumber4.disabled		= true;
	        txtNumber5.disabled		= true;	        		
		}else if(no==3){
	        selectType1.disabled	= true;
	        txtNumber1.disabled		= true;
	        chkForward_0.disabled	= false;
	        chkForward_1.disabled	= false;
	        chkForward_2.disabled	= false;
	        chkForward_3.disabled	= false;
	        toTime1.disabled		= false;
	        toTime2.disabled		= false;
	        toTime3.disabled		= false;
	        fromTime1.disabled		= false;
	        fromTime2.disabled		= false;
	        fromTime3.disabled		= false;
	        waitTime.disabled		= false;
			txtNumber2.disabled		= false;
	        txtNumber3.disabled		= false;
	        txtNumber4.disabled		= false;
	        txtNumber5.disabled		= false;
		}       
    }

	/**
	 * 착신전환 유형 등록
	 */ 
    function goUpdate(){
        var f 				= document.frm;
        var f2 				= document.frmPopup;
        var arrivalType_1	= document.getElementById("arrivalType_1");
  		var arrivalType_2	= document.getElementById("arrivalType_2");
  		var arrivalType_3	= document.getElementById("arrivalType_3");
  		var selectType1		= document.getElementById("selectType1");
  		var txtNumber1		= document.getElementById("txtNumber1");
  		
  		var chkForward_0	= document.getElementById("chkForward_0");
  		var toTime1			= document.getElementById("toTime1");
  		var toTime2			= document.getElementById("toTime2");
  		var toTime3			= document.getElementById("toTime3");
  		var fromTime1		= document.getElementById("fromTime1");
  		var fromTime2		= document.getElementById("fromTime2");
  		var fromTime3		= document.getElementById("fromTime3");
  		var txtNumber2		= document.getElementById("txtNumber2");
  		
  		var chkForward_1	= document.getElementById("chkForward_1");
  		var waitTime		= document.getElementById("waitTime");
  		var txtNumber3		= document.getElementById("txtNumber3");
  		
  		var chkForward_2	= document.getElementById("chkForward_2");
  		var txtNumber4		= document.getElementById("txtNumber4");
  		var chkForward_3	= document.getElementById("chkForward_3");
  		var txtNumber5		= document.getElementById("txtNumber5");
  		
  		f.hiE164.value			= f2.hiEi64.value;
		f.hifromTime1.value 	= fromTime1.value;
		f.hifromTime2.value 	= fromTime2.value;
		f.hifromTime3.value 	= fromTime3.value;		
		f.hitoTime1.value 		= toTime1.value;
		f.hitoTime2.value 		= toTime2.value;
		f.hitoTime3.value 		= toTime3.value;
		f.hiwaitTime.value 		= waitTime.value;				
		
		// 시간대별 착신전환 시간 체크
		if(chkForward_0.checked==true && toTime1.value=="2"){
			if(toTime2.value=="00"){
				var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'시간대별 착신전환은 오후 시간으로</BR>00시를 사용할수 없습니다!';
				var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
				getMsgPage(url,parm);					
				return;
			}
		}
		if(chkForward_0.checked==true && fromTime1.value=="2"){
			if(fromTime2.value=="00"){
				var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'시간대별 착신전환은 오후 시간으로</BR>00시를 사용할수 없습니다!';
				var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
				getMsgPage(url,parm);					
				return;
			}
		}
		
		
  		// 착신전환 지정번호가 입력 되었는지 체크
		if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				if(txtNumber1.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);
					return;
				}else{
					f.hiTxtNumber1.value = txtNumber1.value;
				}
			}
		}else if(arrivalType_3.checked==true){
			if(chkForward_0.checked==true){
				if(txtNumber2.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber2.value 	= txtNumber2.value;
					f.hiChkForward_0.value 	= "1";
				}				
			}else{
				f.hiChkForward_0.value 	= "0";
			} 
			if(chkForward_1.checked==true){
				if(txtNumber3.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber3.value = txtNumber3.value;
					f.hiChkForward_1.value 	= "1";
				}				
			}else{
				f.hiChkForward_1.value 	= "0";
			}
			if(chkForward_2.checked==true){
				if(txtNumber4.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber4.value = txtNumber4.value;
					f.hiChkForward_2.value 	= "1";
				}				
			}else{
				f.hiChkForward_2.value 	= "0";
			}
			if(chkForward_3.checked==true){
				if(txtNumber5.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber5.value = txtNumber5.value;
					f.hiChkForward_3.value 	= "1";
				}				
			}else{
				f.hiChkForward_3.value 	= "0";
			}
			if(chkForward_0.checked==false && chkForward_1.checked==false && chkForward_2.checked==false && chkForward_3.checked==false){
				//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
				var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
				var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
				getMsgPage(url,parm);				
				return;				
			}			
		}
  		  		
		if(arrivalType_1.checked==true){
			f.hiArrivalType.value 		= "0";
		}else if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				f.hiArrivalType.value 	= "1";
			}else{
				f.hiArrivalType.value 	= "3";
			}
		}else if(arrivalType_3.checked==true){
			f.hiArrivalType.value 		= "2";
		}

	   	f.action="<%=StaticString.ContextRoot%>/arrivalSwitchInsert_02.do";
	   	f.method="post";
	   	f.submit();
    }
    
	function chkTimeArrival(p_e164){
    	var f2 		= document.frmPopup;
		var div1 	= document.getElementById("div1");
		
        if(f2.chkForward_0.checked){
            div1.style.display 	= "block";
            if(p_e164 != ""){
            	goEditPopup(p_e164);
            }
        }else{        	            
            div1.style.display 	= "none";
        }	
	}
	
	/**
	 * 특정시간 입력 화면으로 이동
	 */
	function goEditPopup(p_e164){
	    var parm 	= '&e164='+p_e164;
		var url 	= 'addServiceArrivalTimeEdit.jsp';
		
	    getPage3(url,parm);			
	}
	
    /**
     * 수정 처리
     */
    function goAddPro2(){        
        var f   	= document.frm;
        var f3   	= document.editForm;
        var str 	= "";
        var srt1;
        var value1;
        
		f.hiToTime.value 	= document.getElementById("toTimeSi").value+document.getElementById("toTimeBun").value;
		f.hiFromTime.value 	= document.getElementById("fromTimeSi").value+document.getElementById("fromTimeBun").value;
		
		if(f.hiToTime.value*1.0 > f.hiFromTime.value*1.0){
			alert("시간이 잘못 선택 되었습니다.");
			return;
		}
        
    	srt1	= f3.txtNumber2.value;
		value1 	= srt1.replace(/\s/g, "");	// 공백제거
	        
		if(value1==""){
			alert("착신전환 번호를 입력하지 않았습니다.");
			return;
		}
		if(f3.txtNumber2.value!=""){
			if(isNaN(f3.txtNumber2.value)){
				alert("착신전환 번호가 숫자가 아닙니다.");
				return;
			}
		}
        
		var urlStart	= "arrivalTimeChk.jsp";
		var parmStart 	= '&e164='+f3.hiE164_Edit.value+'&startTime='+f.hiToTime.value+'&endTime='+f.hiFromTime.value;
		
		Ext.Ajax.request({
			url : urlStart , 
			params : parmStart,
			method: 'POST',
			timeout :600000,
			success: function ( result, request ) {
				var tempResult = result.responseText;					
				var value = tempResult.replace(/\s/g, "");	// 공백제거
				
		    	if(value=='OK'){ 
			        goUpdate_Time();
			        //alert("저장...");
			        return;
		    	}else if(value=='NO'){
			    	alert("특정 시간대 착신전환 번호를 3건 이상 등록할수 없습니다!");
			    	return;
			    }else if(value=='NO2'){
			    	alert("선택한 시간이 이미 사용중인 시간입니다!");
			    	return;
		    	}else{
			    	alert("오류가 발생했습니다.");
			    	return;			
		    	}			
				
			},
			failure: function ( result, request) { 
				Ext.MessageBox.alert('Failed', "<div style='width:380px;'>에러 발생</div>");
			} 
		});

    }

	function forwardType_New(no){
        var selectType1 	= document.getElementById("selectType1");
        var txtNumber1 		= document.getElementById("txtNumber1");
        var chkForward_0 	= document.getElementById("chkForward_0");
        var chkForward_1 	= document.getElementById("chkForward_1");
        var chkForward_2 	= document.getElementById("chkForward_2");
        var chkForward_3 	= document.getElementById("chkForward_3");
        var waitTime 		= document.getElementById("waitTime");
        var txtNumber3 		= document.getElementById("txtNumber3");
        var txtNumber4 		= document.getElementById("txtNumber4");
        var txtNumber5 		= document.getElementById("txtNumber5");        
        var div1 			= document.getElementById("div1");
            
        if(no==1){
	        selectType1.disabled	= true;
	        txtNumber1.disabled		= true;
	        
	        chkForward_0.checked 	= false
	        chkForward_1.checked 	= false
	        chkForward_2.checked 	= false
	        chkForward_3.checked 	= false
	        
	        chkForward_0.disabled	= true;
	        chkForward_1.disabled	= true;
	        chkForward_2.disabled	= true;
	        chkForward_3.disabled	= true;

	        div1.style.display 		= "none";
	        txtNumber3.value		= "";
	        txtNumber4.value		= "";
	        txtNumber5.value		= "";
	        
	        waitTime.disabled		= true;
	        txtNumber3.disabled		= true;
	        txtNumber4.disabled		= true;
	        txtNumber5.disabled		= true;
		}else if(no==2){
	        selectType1.disabled	= false;
	        txtNumber1.disabled		= false;
	        
	        chkForward_0.checked 	= false
	        chkForward_1.checked 	= false
	        chkForward_2.checked 	= false
	        chkForward_3.checked 	= false
	        
	        chkForward_0.disabled	= true;
	        chkForward_1.disabled	= true;
	        chkForward_2.disabled	= true;
	        chkForward_3.disabled	= true;

	        div1.style.display 		= "none";
	        txtNumber3.value		= "";
	        txtNumber4.value		= "";
	        txtNumber5.value		= "";

			waitTime.disabled		= true;
	        txtNumber3.disabled		= true;
	        txtNumber4.disabled		= true;
	        txtNumber5.disabled		= true;	        		
		}else if(no==3){
	        selectType1.disabled	= true;
	        txtNumber1.disabled		= true;
	        chkForward_0.disabled	= false;
	        chkForward_1.disabled	= false;
	        chkForward_2.disabled	= false;
	        chkForward_3.disabled	= false;
	        waitTime.disabled		= false;
	        txtNumber3.disabled		= false;
	        txtNumber4.disabled		= false;
	        txtNumber5.disabled		= false;
		}       
    }
    
	/**
	 * 착신전환 유형 등록
	 */ 
    function goUpdate_New(){
        var f 				= document.frm;
        var f2 				= document.frmPopup;
        var f3 				= document.editForm;
        var arrivalType_1	= document.getElementById("arrivalType_1");
  		var arrivalType_2	= document.getElementById("arrivalType_2");
  		var arrivalType_3	= document.getElementById("arrivalType_3");
  		var selectType1		= document.getElementById("selectType1");
  		var txtNumber1		= document.getElementById("txtNumber1");
  		
  		var chkForward_0	= document.getElementById("chkForward_0");
  		var txtNumber2		= document.getElementById("txtNumber2");
  		
  		var chkForward_1	= document.getElementById("chkForward_1");
  		var waitTime		= document.getElementById("waitTime");
  		var txtNumber3		= document.getElementById("txtNumber3");
  		
  		var chkForward_2	= document.getElementById("chkForward_2");
  		var txtNumber4		= document.getElementById("txtNumber4");
  		var chkForward_3	= document.getElementById("chkForward_3");
  		var txtNumber5		= document.getElementById("txtNumber5");
  		
  		var time_Count 		= f2.hiTimeCount.value;
  		var time_Count2 	= 0;
  		
  		if(txtNumber2 != null){
  			time_Count2 = f3.hiTimeCount2.value;
  		}
  		
  		f.hiE164.value		= f2.hiEi64.value;
		f.hiwaitTime.value 	= waitTime.value;				
		
		if(chkForward_0.checked==true){
			if(txtNumber2 != null && txtNumber2 != ""){
				f.hiToTime.value 	= document.getElementById("toTimeSi").value+document.getElementById("toTimeBun").value;
				f.hiFromTime.value 	= document.getElementById("fromTimeSi").value+document.getElementById("fromTimeBun").value;
			}else{
				f.hiToTime.value 	= "";
				f.hiFromTime.value 	= "";
			}
		}else{
			f.hiToTime.value 	= "";
			f.hiFromTime.value 	= "";
		}
		
  		// 착신전환 지정번호가 입력 되었는지 체크
		if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				if(txtNumber1.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);
					return;
				}else{
					f.hiTxtNumber1.value = txtNumber1.value;
				}
			}
		}else if(arrivalType_3.checked==true){
			if(chkForward_0.checked==true){
//				alert("time_Count : "+time_Count);
//				alert("time_Count2 : "+time_Count2);
//				alert("txtNumber2.value : "+txtNumber2.value);
				
				if(time_Count*1.0 == 0 && time_Count2*1.0 == 0){
					if(txtNumber2.value==""){
						//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
						var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
						var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
						getMsgPage(url,parm);					
						return;
					}else{
						f.hiTxtNumber2.value 	= txtNumber2.value;
						f.hiChkForward_0.value 	= "1";
					}
				}else{
					f.hiChkForward_0.value 	= "1";
				}
			}else{
				f.hiChkForward_0.value 	= "0";
			} 
			if(chkForward_1.checked==true){
				if(txtNumber3.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber3.value = txtNumber3.value;
					f.hiChkForward_1.value 	= "1";
				}				
			}else{
				f.hiChkForward_1.value 	= "0";
			}
			if(chkForward_2.checked==true){
				if(txtNumber4.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber4.value = txtNumber4.value;
					f.hiChkForward_2.value 	= "1";
				}				
			}else{
				f.hiChkForward_2.value 	= "0";
			}
			if(chkForward_3.checked==true){
				if(txtNumber5.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber5.value = txtNumber5.value;
					f.hiChkForward_3.value 	= "1";
				}				
			}else{
				f.hiChkForward_3.value 	= "0";
			}
			if(chkForward_0.checked==false && chkForward_1.checked==false && chkForward_2.checked==false && chkForward_3.checked==false){
				//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
				var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
				var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
				getMsgPage(url,parm);				
				return;				
			}			
		}
  		  		
		if(arrivalType_1.checked==true){
			f.hiArrivalType.value 		= "0";
		}else if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				f.hiArrivalType.value 	= "1";
			}else{
				f.hiArrivalType.value 	= "3";
			}
		}else if(arrivalType_3.checked==true){
			f.hiArrivalType.value 		= "2";
		}

	   	f.action="<%=StaticString.ContextRoot%>/arrivalSwitchUpdate_New.do";
	   	f.method="post";
	   	f.submit();
    }
    
    /**
     * 삭제 처리
     */
    function goDeletePro2(p_E164, p_ForwardNumber, p_Start, p_End){
        var f   	= document.frm;
	    var parm 	= '&forwardNumber='+p_ForwardNumber+'&e164='+p_E164+'&startTime='+p_Start+'&endTime='+p_End+'&userID='+f.hiUserID.value;		//get형식으로 변수 전달.
	    var url 	= 'addServiceArrivalDelete.jsp';

		Ext.Ajax.request({
			url : url , 
			params : parm,
			method: 'POST',
			success: function ( result, request ) {
				var tempResult = result.responseText;					
				var value = tempResult.replace(/\s/g, "");	// 공백제거
				
		    	if(value=='OK'){ 
					//alert("성공2....!");
					goEditPopup(p_E164);
		    	}else{
			    	alert("삭제실패!");
			    	return;
		    	}
			},
			failure: function ( result, request) { 
				Ext.MessageBox.alert('Failed', result.responseText); 
			} 
		});
    }

	/**
	 * 특정시간별 착신전환 유형 등록
	 */ 
    function goUpdate_Time(){
        var f 				= document.frm;
        var f2 				= document.frmPopup;
        var f3 				= document.editForm;
        var arrivalType_1	= document.getElementById("arrivalType_1");
  		var arrivalType_2	= document.getElementById("arrivalType_2");
  		var arrivalType_3	= document.getElementById("arrivalType_3");
  		var selectType1		= document.getElementById("selectType1");
  		var txtNumber1		= document.getElementById("txtNumber1");
  		
  		var chkForward_0	= document.getElementById("chkForward_0");
  		var txtNumber2		= document.getElementById("txtNumber2");
  		
  		var chkForward_1	= document.getElementById("chkForward_1");
  		var waitTime		= document.getElementById("waitTime");
  		var txtNumber3		= document.getElementById("txtNumber3");
  		
  		var chkForward_2	= document.getElementById("chkForward_2");
  		var txtNumber4		= document.getElementById("txtNumber4");
  		var chkForward_3	= document.getElementById("chkForward_3");
  		var txtNumber5		= document.getElementById("txtNumber5");
  		
  		var time_Count 		= f2.hiTimeCount.value;
  		var time_Count2 	= 0;
  		
  		if(txtNumber2 != null){
  			time_Count2 = f3.hiTimeCount2.value;
  		}
  		
  		f.hiE164.value		= f2.hiEi64.value;
		f.hiwaitTime.value 	= waitTime.value;				
		
		if(chkForward_0.checked==true){
			if(txtNumber2 != null && txtNumber2 != ""){
				f.hiToTime.value 	= document.getElementById("toTimeSi").value+document.getElementById("toTimeBun").value;
				f.hiFromTime.value 	= document.getElementById("fromTimeSi").value+document.getElementById("fromTimeBun").value;
			}else{
				f.hiToTime.value 	= "";
				f.hiFromTime.value 	= "";
			}
		}else{
			f.hiToTime.value 	= "";
			f.hiFromTime.value 	= "";
		}
		
  		// 착신전환 지정번호가 입력 되었는지 체크
		if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				if(txtNumber1.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);
					return;
				}else{
					f.hiTxtNumber1.value = txtNumber1.value;
				}
			}
		}else if(arrivalType_3.checked==true){
			if(chkForward_0.checked==true){
				if(txtNumber2.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber2.value 	= txtNumber2.value;
					f.hiChkForward_0.value 	= "1";
				}
			}else{
				f.hiChkForward_0.value 	= "0";
			} 
			if(chkForward_1.checked==true){
				if(txtNumber3.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber3.value = txtNumber3.value;
					f.hiChkForward_1.value 	= "1";
				}				
			}else{
				f.hiChkForward_1.value 	= "0";
			}
			if(chkForward_2.checked==true){
				if(txtNumber4.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber4.value = txtNumber4.value;
					f.hiChkForward_2.value 	= "1";
				}				
			}else{
				f.hiChkForward_2.value 	= "0";
			}
			if(chkForward_3.checked==true){
				if(txtNumber5.value==""){
					//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
					var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
					var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
					getMsgPage(url,parm);					
					return;
				}else{
					f.hiTxtNumber5.value = txtNumber5.value;
					f.hiChkForward_3.value 	= "1";
				}				
			}else{
				f.hiChkForward_3.value 	= "0";
			}
			if(chkForward_0.checked==false && chkForward_1.checked==false && chkForward_2.checked==false && chkForward_3.checked==false){
				//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
				var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
				var url  = '<%=StaticString.ContextRoot%>/msgPopup.jsp';
				getMsgPage(url,parm);				
				return;				
			}			
		}
  		  		
		if(arrivalType_1.checked==true){
			f.hiArrivalType.value 		= "0";
		}else if(arrivalType_2.checked==true){			
			if(selectType1.value=="1"){
				f.hiArrivalType.value 	= "1";
			}else{
				f.hiArrivalType.value 	= "3";
			}
		}else if(arrivalType_3.checked==true){
			f.hiArrivalType.value 		= "2";
		}

	   	f.action="<%=StaticString.ContextRoot%>/arrivalSwitchUpdate_New.do";
	   	f.method="post";
	   	f.submit();
    }

</script>

<script type="text/javascript" src="js/selcet.js"></script>

<form name="frm" method="post">
<input type='hidden' name ='hiE164' 			value=""/>
<input type='hidden' name ='deleteStr' 			value=""/>
<input type='hidden' name ='insertStr' 			value=""/>

<input type='hidden' name = 'hiUserID'			value="<%=userID%>">

<input type='hidden' name ='hiArrivalType'	value="">
<input type='hidden' name ='hiTxtNumber1'	value="">
<input type='hidden' name ='hiChkForward_0'	value="">
<input type='hidden' name ='hitoTime1'		value="">
<input type='hidden' name ='hitoTime2'		value="">
<input type='hidden' name ='hitoTime3'		value="">
<input type='hidden' name ='hifromTime1'	value="">
<input type='hidden' name ='hifromTime2'	value="">
<input type='hidden' name ='hifromTime3'	value="">
<input type='hidden' name ='hiTxtNumber2'	value="">
<input type='hidden' name ='hiChkForward_1'	value="">  		
<input type='hidden' name ='hiwaitTime'		value="">
<input type='hidden' name ='hiTxtNumber3'	value="">
<input type='hidden' name ='hiChkForward_2'	value="">  		
<input type='hidden' name ='hiTxtNumber4'	value="">
<input type='hidden' name ='hiChkForward_3'	value="">
<input type='hidden' name ='hiTxtNumber5'	value="">

<input type='hidden' name ='hiToTime'		value="">
<input type='hidden' name ='hiFromTime'		value="">

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
		<table width="810" border="0" cellspacing="0" cellpadding="0" align="center">
		    <tr>
		        <td>
		        	<!--start_검색부분-->
		            <table width="810" border="0" cellspacing="0" cellpadding="0" align="left" style="margin:8 0 8 0 ">		
		                <tr>
						    <td width="127" height="35" align="right" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_addser_img.gif" width="120" height="20"></td>
						    <td style="color:#524458; padding-top:4" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"></td>		                    
		                </tr>
		            </table>	
					<!--end_검색부분-->
		        </td>
		    </tr>
		  
		  <tr>
		  	<td style="padding-top:10; padding-bottom:5; background:eeeff0; border-bottom:1 solid #cdcecf; height:405" valign="top" align="center">
	
				<table width="800" border="0" cellspacing="0" cellpadding="0" bgcolor="d6d9dc">
				  <tr>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(1)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_setuplimitcall2_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(2)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_virtualnumber2_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(11)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_callChang_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(3)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_mrbt01_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(4)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_mrbt02_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(5)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_moh2_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(6)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_vms2_n_btn.gif" width="110" height="20"></td>
				  	<td bgcolor="eeeff0" width="16">&nbsp;</td>
				  </tr>
				  <tr><td bgcolor="eeeff0" colspan="8" height="2"></td></tr>
				  <tr>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(7)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_blf2_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(8)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_alert2_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(9)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_secretary_n_btn.gif" width="110" height="20"></td>
				    <td bgcolor="eeeff0" width="112" onclick="goTabPage(10)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_fmc_n_btn.gif" width="110" height="20"></td>
				  	<td bgcolor="eeeff0" width="112" onclick="goTabPage(12)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_forking_n_btn.gif" width="110" height="20"></td>
				  	<td bgcolor="eeeff0" width="112" onclick="goTabPage(13)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_arrival_p_btn.gif" width="110" height="20"></td>
				  	<td bgcolor="eeeff0" width="112" onclick="goTabPage(14)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_New_alarm_n_btn.gif" width="110" height="20"></td>
				  	<td bgcolor="eeeff0" width="16">&nbsp;</td>
				  </tr>
				</table>
				<table width="800" border="0" cellspacing="0" cellpadding="0" bgcolor="d6d9dc">
				  <tr>
				    <td bgcolor="d6d9dc" align="center" valign="top" height="360" >	
					
					  <!--start_가상발신번호01-->	
					  <table width="775" border="0" cellspacing="0" cellpadding="1">

                                        <tr>
                                        	<td width="721" style="padding-top:5px">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table width=761 border=0 cellspacing=0 cellpadding=0 align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) "> 
                                                    <tr height=20 bgcolor="rgb(243,247,245)" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="rgb(243,247,245)">  
                                                        <td width=142 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                                                        <td width=143 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">이름</td> 
                                                        <td width=167 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">부서</td> 
                                                        <td width=110 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">직급</td> 
                                                        <td width=130 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">사용유무</td>
                                                        <td width=73 class='table_header01' background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
                                                    </tr> 
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div style="width:781; height:262; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">
                                                <table width=761 border=0 cellspacing=0 cellpadding=0 align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) "> 
												<% 
												AddServiceArrivalDTO mrbtDTO = null;
												int chk = 0;
												for (int idx = 0; idx < iCount; idx++ ) {
													mrbtDTO = (AddServiceArrivalDTO)iList.get(idx);
													
                                                	String 	commonservice = mrbtDTO.getUsechk().substring(3, 4);
                                                	
                                                	if(chk == 0){
												%>                                                    
                                                    <tr height=20 bgcolor="rgb(243,247,245)" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="rgb(243,247,245)"> 
                                                        <%if(userCount>0){%> 
	                                                        <td width=142 class='table_column'><%=mrbtDTO.getE164()%>&nbsp;</td>
	                                                        <td width=143 class=table_column><%=mrbtDTO.getName()%>&nbsp;</td> 
	                                                        <td width=167 class='table_column'><%=mrbtDTO.getDept()%>&nbsp;</td> 
	                                                        <td width=110 class='table_column'><%=mrbtDTO.getPosition()%>&nbsp;</td> 
	                                                        <%if(!"0".equals(commonservice)){%>
	                                                        	<td width=130 class=table_column><FONT color="blue">사용중</FONT>&nbsp;</td>
	                                                        <%}else{%>
	                                                        	<td width=130 class=table_column>사용안함&nbsp;</td>
	                                                        <%}%>
	                                                        <td width=73 class=table_column><a href="#" onclick="javascript:showEdit('<%=mrbtDTO.getE164()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0"></a></td>
                                                        <%}else{%>
	                                                        <td width=142 class='table_column'>&nbsp;</td>
	                                                        <td width=143 class=table_column>&nbsp;</td> 
	                                                        <td width=167 class='table_column'>&nbsp;</td> 
	                                                        <td width=110 class='table_column'>&nbsp;</td> 
	                                                        <td width=130 class=table_column>사용안함&nbsp;</td>
	                                                        <td width=73 class=table_column></td>
                                                        <%}%> 
                                                    </tr>
												<%
											            chk = 1;
											        }else{    
												%>
                                                    <tr height=20 align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff"> 
                                                        <%if(userCount>0){%>
	                                                        <td width=142 class='table_column'><%=mrbtDTO.getE164()%>&nbsp;</td>
	                                                        <td width=143 class=table_column><%=mrbtDTO.getName()%>&nbsp;</td> 
	                                                        <td width=167 class='table_column'><%=mrbtDTO.getDept()%>&nbsp;</td> 
	                                                        <td width=110 class='table_column'><%=mrbtDTO.getPosition()%>&nbsp;</td> 
	                                                        <%if(!"0".equals(commonservice)){%>
	                                                        	<td width=130 class=table_column><FONT color="blue">사용중</FONT>&nbsp;</td>
	                                                        <%}else{%>
	                                                        	<td width=130 class=table_column>사용안함&nbsp;</td>
	                                                        <%}%>
	                                                        <td width=73 class=table_column><a href="#" onclick="javascript:showEdit('<%=mrbtDTO.getE164()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0"></a></td>
                                                        <%}else{%>
	                                                        <td width=142 class='table_column'>&nbsp;</td>
	                                                        <td width=143 class=table_column>&nbsp;</td> 
	                                                        <td width=167 class='table_column'>&nbsp;</td> 
	                                                        <td width=110 class='table_column'>&nbsp;</td> 
	                                                        <td width=130 class=table_column>사용안함&nbsp;</td>
	                                                        <td width=73 class=table_column></td>
                                                        <%}%> 
                                                    </tr>												
												<% 
											            chk = 0;
											        }
											    }
												%>
                                                    <!--<tr> 
                                                        <td colspan=6><img src='<%//=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif' width='545' height='2'></td> 
                                                    </tr>--> 
                                                </table>
                                                </div>
                                            </td>
                                        </tr>

				      </table>
					  <!--end_가상발신번호01-->
					  
					  <div align="center"><!--a href="javascript:goInsert_1();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%//=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%//=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image2" width="40" height="20" border="0"></a-->
	          		
	          		</div>
					</td>
				  </tr>
				</table>
	        </td>
	      </tr>
	    </table>
		<!--end--콘텐츠페이지-->
	
    </td>
  </tr>
<!----------------------- footer 이미지 추가 start ----------------------------->
<tr>
    <td ><img src="<%=StaticString.ContextRoot%>/imgs/main_footer_img.gif" width="1000" height="30"></td>
</tr>
<!----------------------- footer 이미지 추가   end ----------------------------->  
</table>
</form>

<iframe name="procframe" src="" width="0" height="0"></iframe>
<iframe name="resultdownloadframe" style="border-width:0px;" width="0" height="0" frameborder="0" scrolling="no" tabindex="-1"></iframe>

</div>	
</body>
</html>

<!-- 팝업 레이어 -->
<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer3" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>