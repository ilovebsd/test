<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>

<%@ page import="dto.ipcs.IpcsListDTO" %>
<%@ page import="business.ipcs.IpcsList"%>

<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>

<%@ page import="system.SystemConfigSet"%>
<%@ page import="java.util.*" %>

<%@ page import="business.CommonData"%>

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

//String userPassWord = Str.CheckNullString(scDTO.getSusbsPwd()).trim();
//String userPassWord	= request.getParameter("hiPassWord");
String userPassWord	= request.getParameter("hiPwdChk");

String userName 	= Str.CheckNullString(scDTO.getName()).trim();
String userID 		= Str.CheckNullString(scDTO.getSubsID()).trim();

String loginLevel 	= Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
String menu       	= "1";  // 번호,단말관리
String submenu    	= "1";  // 개인내선번호,단말관리
String detailmenu 	= "0";

String new_menu     = "B";  		// 기본설정
String new_submenu  = "6";  		// 개인내선번호,단말관리

String 	s_EnendPointID	= request.getParameter("hiddenEnendPointID");	// 검색조건 ID
String 	s_E164			= request.getParameter("hiddenE164");			// 검색조건 번호
String 	s_Name			= request.getParameter("hiddenName");			// 검색조건 이름
String 	sPage    		= StringUtil.null2Str(request.getParameter("PAGE_NUM"),"1") ;
String 	search_gubun	= StringUtil.null2Str(request.getParameter("hiddenSearch_gubun"),"1");	// 검색구분
String 	search_field	= new String (Str.CheckNullString(request.getParameter("hiddenSearch_field")).getBytes("8859_1"), "euc-kr");

//String 	s_provision  	= StringUtil.null2Str(request.getParameter("provision"),"") ;

int 	iPageNum		= Integer.parseInt((String)sPage);
int 	nGroup 			= Str.CheckNullInt(request.getParameter("group"));
int 	iListNum		= 12 ;		// 리스트의 목록갯수
int 	iPageSize		= 10 ; 		// 하단페이지 갯수

String 	GroupName 		= new String (Str.CheckNullString(request.getParameter("groupName")).getBytes("8859_1"), "euc-kr");
//System.out.println("############### iPageNum : "+iPageNum);

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");

//ipcs 개인내선 처리부분
IpcsList 	ipcsList = new IpcsList();

List count = ipcsList.getCount(stmt, s_EnendPointID, s_E164, s_Name, search_gubun, search_field);						// ipcs 개인내선  총건수
int iCount = count.size();
int pageNo = (iCount>0) ? (iPageNum-1)*iListNum : iPageNum;

List iList = ipcsList.getList(stmt, pageNo, iListNum, s_EnendPointID, s_E164, s_Name, search_gubun, search_field);		// 데이타 조회
int groupCount = iList.size();

// 2012.07.25 파라메터로 비밀번호 보이는 부분 수정
String admin_Pwd = ipcsList.getAdminPassword(stmt);


// 도메인 조회
CommonData		commonData	= new CommonData();
String 			domainid 	= commonData.getDomain(stmt);						// 도메인ID 조회
String[]		tempDomain;
if(!"".equals(domainid)){
	tempDomain 	= domainid.split("[.]");
	domainid	= tempDomain[0];			
}

//할당받은 DataStatement 객체는 반납
if (stmt != null ) ConnectionManager.freeStatement(stmt);


// 외부 네트워크 환경
SystemConfigSet 	systemConfig 	= new SystemConfigSet();
List 				iList2 			= systemConfig.getRcConfigList();		// 데이타 조회
int					configCount2	= iList2.size();		
String 				tempStr			= "";
String 				wanIp			= "";
int	   				nTemp 			= 0;

for(int i=0;i<configCount2;i++){
	tempStr = (String)iList2.get(i);
	
	if(tempStr.length()>=13){
		// 외부 네트워크
		if("ifconfig_wan=".equals(tempStr.substring(0,13))){
			nTemp = tempStr.indexOf("=");
			
			String temp1 = tempStr.substring(nTemp+1, tempStr.length()).replace('"',' ').trim();
				
		   	StringTokenizer tk = new StringTokenizer(temp1, " "); 		// 현재 분리단어는 " " 공백 스페이스로 나누어짐
		   	String token;
		   	int t=0;
		   	while ( tk.hasMoreTokens() ) {
		    	token = tk.nextToken();
		    	if(t==1){
		    		wanIp = token;									// IP 주소
		    	}
		    	t++;
		   }
		}			
	}
}
System.out.println("WAN IP 주소 : " + wanIp);

//DDNS 버전 조회
String 	strVersion 	= systemConfig.getSystemVersion();					// 버젼

//제품명(모델명) 버전 조회
String 	goodsName 	= systemConfig.getGoodsName();						// 제품명(모델명)
//-------------------------------------------------------------------------

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: <%=domainid%>, Ver: <%=strVersion%></title>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="<%=StaticString.ContextRoot%>/js/resources/css/ext-all.css" />

<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>

<!--
<script type="text/javascript" src="<%//=StaticString.ContextRoot%>/js/ext-base.js"></script>
<script type="text/javascript" src="<%//=StaticString.ContextRoot%>/js/ext-all.js"></script>
-->

<script>
	function initSystem(){
		var pwdChk 	= "<%=userPassWord%>";		
		var pwd 	= "<%=admin_Pwd%>";
		
		if(pwdChk == "ok"){
			if(pwd == "ipcs" || pwd == "soippbx"){
				alert("현재 패스워드가 초기값입니다. 보안을 위해서 다른 패스워드로 변경하십시요!");
				goRefresh();
			}
		}
		
		//if(pwd != "null"){
		if(pwdChk != "null"){
			//alert("이 시스템은 허가된 관리자 외에는 접속할 수 없습니다.\n만일 불법 접속시에는 법에 따라 처벌을 받을 수 있습니다\n\nYou have illegal connection to our network.\nPlease get out here as soon as possible.\nDon't you do that you might have got a disadvantage and accusation for your fault.  ");
			goRefresh();
		}
		
	}
	
	function goLeftSelectBoxMenu(thisTarget) {
		alert(thisTarget);
	}
	
	/**
	 * 개인내선번호/단말 조회
	 */ 
	function ipcsSearch(enendPointID, e164, name) 
	{
		var f = document.frm;
		var p_Search_field 	= document.getElementById("txtSearch_field");
		var p_Search_gubun 	= document.getElementById("leftSelectBoxGlobal");
		
		//alert("11 : "+p_Search_field.value);
		//alert(document.frm.txtSearch_field.value);
		//return;
		f.hiddenEnendPointID.value	= enendPointID;
		f.hiddenE164.value			= e164;
		f.hiddenName.value			= name;
		f.hiddenSearch_field.value	= p_Search_field.value;
		f.hiddenSearch_gubun.value	= p_Search_gubun.value;
		
		f.action = "<%=StaticString.ContextRoot%>/ipcs/ipcsList_New.jsp";
		f.submit();			
	}	
</script>

</head>


<body onLoad="initSystem(); MM_preloadImages('imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')">
<div>	
	<!-- ajax source file -->
	<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
	<!-- Drag and Drop source file -->
	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
	<!-- Shadow Div source file -->
	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>

	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-base.js"></script>
	<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/ext-all.js"></script>

	<script>
		/**
		 * 메세지 페이지 이동 처리부분 
		 */				
		function getMessagePage(url, parm){
			inf('hidden');
		    engine.execute("POST", url, parm, "ResgetMessagePage");
		}		
		function ResgetMessagePage(data){
		    if(data){
		        document.getElementById('popup_layer').innerHTML = data;
		        showAdCodeDiv(2);
		    }else{
		        alert("에러") ;
		    }
		}

		/**
		 * 페이지 이동 처리부분 
		 */				
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
			    obj.style.top =100;
			    obj.style.left = 400;
			}else{
			    obj.style.zIndex=998;
			    obj.style.display = "";
			    obj.style.top =250;
			    obj.style.left = 450;			
			}
		    SET_DHTML('popup_layer');
		}
		
		/**
		 * 등록 클릭시 팝업 숨기기
		 */
		function hiddenAdCodeDiv() {
		    inf('visible'); //select box 보이기
		    setShadowDivVisible(false); //배경 layer 숨김
		
		    document.getElementById('popup_layer').style.display="none";
		    
		    goRefresh();	//새로고침		    
		}

/////////////////////// Zone 관련 추가
	    function getPage5(url, parm){
	        inf('hidden');
	        engine.execute("POST", url, parm, "ResgetPage5");
	    }
	
	    function ResgetPage5(data){
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
///////////////////////

		/**
		 * 수정화면으로 이동
		 */
		function showEdit(p_EndPointId,p_E164,p_id){
//		    alert("p_EndPointId : "+p_EndPointId);
//		    alert("p_E164 : "+p_E164);
//		    alert("p_id : "+p_id);
		    
		    var parm 		= '&endPointID='+p_EndPointId+"&e164="+p_E164+"&id="+p_id;		//get형식으로 변수 전달.
		    var url 		= 'ipcsEdit_01.jsp';
			
		    getPage(url,parm);			
		}

		/**
		 * 신규입력 화면으로 이동
		 */
		function goNextSave(){
		    var parm 	= '&ownerId=';
		    var url 	= 'ipcsInsert_01.jsp';		    
			
		    getPage(url,parm);					
		}
		
		/**
		 * 신규입력 화면으로 이동
		 */
		function goInsert(iCount){
		    var parm 	= '&ownerId=';
		    var url 	= 'ipcsInsert_01.jsp';		    
			
//			if (iCount == 100){
//				alert("개인 내선번호를  100개 이상 만들수 없습니다!");
//				return;
//			}

		    getPage(url,parm);			
		}

		/**
		 * 신규 개인정보 입력화면으로 이동_01
		 */
		function goUserInfoInsert(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    var p_Extension 	= f2.txtNumber2.value;
			
			f.hiDomainID.value		= p_DomainID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiNumberType.value	= f2.numberType.value;
		    
		    // 필수 입력항목 체크
		    if(f2.numberType.value == "1"){
		    	var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64				= p_Ei64_1;
				f.hiEi64.value		= p_Ei64;
				 				    
			    if(f2.txtNumber1.value=="" || f2.txtNumber2.value==""){
			    	alert("내선번호를 입력하지 않았습니다.");
			    	return;
			    }else{
				    if(isNaN(f2.txtNumber1.value) || isNaN(f2.txtNumber2.value)){
				    	alert("내선번호 입력값이 숫자가 아닙니다.");
				    	return;
			    	}			    
			    }
			    
			    if(p_Ei64_1!=p_EndPointID){
			    	alert("아이디와 내선번호가 서로 같지 않습니다!");
			    	return;
			    }			    
			}else if(f2.numberType.value == "2"){
		    	var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64				= p_Ei64_2;
			    f.hiEi64.value		= p_Ei64;			    
			    			    
			    if(f2.txtExtension.value==""){
			    	alert("내선번호를 입력하지 않았습니다.");
			    	return;
			    }else{
				    if(isNaN(f2.txtExtension.value)){
				    	alert("내선번호 입력값이 숫자가 아닙니다.");
				    	return;
				    }			    
			    }
			    
			    if(p_Ei64_2!=p_EndPointID){
			    	alert("아이디와 번호정보가 같지 않습니다!");
			    	return;
			    }			    
	        }else{
	            alert("내선번호 유형을 선택해 주세요!");
	            return;
	        }
			
		    if(p_EndPointID==""){
		    	alert("아이디를 입력하지 않았습니다.");
		    	return;
		    }else{
				if(isNaN(f2.txtId.value)){
			    	alert("아이디 입력값이 숫자가 아닙니다.");
			    	return;
			    }
				if(p_EndPointID.length<3){
					alert("아이디는 최소 3자리 이상이어야 합니다.");
					return; 			
				}
		    }
		    		    
		    // EndPointID, Ei64 중복체크
		    var parm 	= '&fullEndPointId='+full_EndPointID+'&hiEi64='+p_Ei64;		//get형식으로 변수 전달.
		    var url 	= 'numberCheck.jsp';
		    //getPage2(url,parm);
			
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// 공백제거
					
			    	if(value=='OK'){ 
			    		goInsert_02();		    		
			    	}else if(value=='NO1'){
				    	alert("이미 등록된 아이디 입니다!");
				    	return;			
			    	}else if(value=='NO2'){
				    	alert("이미 등록된 내선번호 입니다!");
				    	return;
			    	}else if(value=='NO3'){
				    	alert("등록된 부서가 없습니다. 부서를 등록하신 후 사용하시기 바랍니다!");
				    	return;			
			    	}else if(value=='NO4'){
				    	alert("등록된 직급이 없습니다. 직급을 등록하신 후 사용하시기 바랍니다!");
				    	return;
			    	}else if(value=='NO5'){
				    	alert("등록된 도메인이 없습니다. 도메인을 등록하신 후 사용하시기 바랍니다!");
				    	return;				    	
			    	}else if(value=='NO6'){
				    	alert("음성안내 번호로 시스템에서 사용중인 번호 입니다!");
				    	return;			    	
			    	}else if(value=='NO7'){
				    	alert("부서대표 번호로 시스템에서 사용중인 번호 입니다!");
				    	return;
			    	}else{
				    	alert("등록할 수 없습니다. 관리자에게 문의하신 후 사용하시기 바랍니다!");
				    	return;			    	
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
					//Ext.MessageBox.alert('Failed', "이미 등록된 아이디 입니다!");
				} 
			});		    
		}

		function goInsert_02(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_Ei64_Route2	= f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    //var p_ZoneCode 		= f2.hiZoneCode.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    var p_Extension 	= f2.txtNumber2.value;
			var p_AreaCode		= f2.areaNo.value;			
			var p_NumberType	= f2.numberType.value;			
			
			var p_Mac			= f2.mac.value;
			var p_MacDisplay	= f2.txtdisplay.value;
			var p_MacIp			= f2.hiMacIp.value;
			var p_MacAuto		= f2.auto.value;
			var p_MacAutoNo		= f2.autoNo.value;
			var p_AddrType		= f2.addrType.value;
			
			var p_UserId		= f.hiUserID.value;	// 로그인 ID
			
			f.hiGroupID.value		= p_GroupID;
			f.hiDomainID.value		= p_DomainID;
			//f.hiZoneCode.value		= p_ZoneCode;
			f.hiPrefixID.value		= p_PrefixID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiAreaCode.value		= p_AreaCode
		    f.hiNumberType.value	= p_NumberType;
		    
		    //p_MacDisplay 	= encodeURI(p_MacDisplay);
		    f.hiMac.value			= p_Mac;
			f.hiMacDisplay.value	= p_MacDisplay;
			f.hiMacIp.value			= p_MacIp;
			f.hiMacAuto.value		= p_MacAuto;
			f.hiMacAutoNo.value		= p_MacAutoNo;
		    f.hiMacAddrType.value	= p_AddrType;
		    
		    //alert("맥주소1 : "+p_Mac);
		    
		    if(f2.numberType.value == "1"){
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64					= p_Ei64_1;
				f.hiEi64.value			= p_Ei64;
				f.hiE164Route2.value	= p_Ei64_Route2;
			}else if(f2.numberType.value == "2"){
		    	// 단축번호인 경우
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64					= p_Ei64_2;
			    f.hiEi64.value			= p_Ei64;
			    f.hiE164Route2.value	= "";
			    p_Extension				= p_Ei64;
			    f.hiExtension.value		= p_Extension;
	        }
		    
//    		if(getRadioValue(f2.numberChk) == "Y"){
	    		//var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2;		//get형식으로 변수 전달.
	    		var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2+'&hiMac='+p_Mac+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiMacAddrType='+p_AddrType;		//get형식으로 변수 전달.

	    		//alert(parm);
	    		var url 	= 'ipcsInsert_02.jsp';	
	    		//getPage(url,parm);	
	    		
	    		Ext.Ajax.request({
					url : url , 
					params : parm,
					method: 'POST',
					success: function ( result, request ) {
						inf('hidden');
						ResgetPage(result.responseText);
					},
					failure: function ( result, request) { 
						Ext.MessageBox.alert('Failed', result.responseText); 
						//Ext.MessageBox.alert('Failed', "이미 등록된 아이디 입니다!");
					} 
				});	  
	    		
//    		}else{
	    		//var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2;		//get형식으로 변수 전달.
//	    		var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2+'&hiMac='+p_Mac+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId;		//get형식으로 변수 전달.
//	    		var url 	= 'ipcsUserAfterInsert.jsp';		    			
	    		//getPage4(url,parm);
	    		
//				Ext.Ajax.request({
//					url : url , 
//					params : parm,
//					method: 'POST',
//					success: function ( result, request ) {
//						var tempResult = result.responseText;					
//						var value = tempResult.replace(/\s/g, "");	// 공백제거
						
//				    	if(value=='OK'){ 
//				    		goInsert_04();		    		
//				    	}else{
//					    	alert("개인 전화번호 저장이 정상적으로 이루어 지지 않았습니다!");
//					    	return;			
//				    	}					
//					},
//					failure: function ( result, request) { 
//						Ext.MessageBox.alert('Failed', result.responseText); 
						//Ext.MessageBox.alert('Failed', "이미 등록된 아이디 입니다!");
//					} 
//				});	    		
//    		}					
		}
		
		/**
		 * 신규 개인정보 이전 입력화면으로 이동
		 */
		function goUserBefore(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer2;
		    var p_EndPointID 	= f2.hiEndPointID.value;
		    var p_Ei64 			= f2.hiEi64.value;
		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    //var p_ZoneCode 		= f2.hiZoneCode.value;
		    var p_ZoneCode 		= f2.txtZone.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    var p_Extension 	= f2.hiExtension.value;
			var p_AreaCode		= f2.hiAreaCode.value;
			
			f.hiGroupID.value		= p_GroupID;
			f.hiDomainID.value		= p_DomainID;
			f.hiZoneCode.value		= p_ZoneCode;
			f.hiPrefixID.value		= p_PrefixID;
			f.hiEndPointID.value	= p_EndPointID;
			f.hiEi64.value			= p_Ei64;
			f.hiExtension.value		= p_Extension;
		    f.hiAreaCode.value		= p_AreaCode
		    
		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode;		//get형식으로 변수 전달.
		    var url 	= 'ipcsInsert_01.jsp';		    			
		    getPage(url,parm);			
		}

		/**
		 * 삭제처리 화면으로 이동
		 */
		function showDelete(p_EndPointId,p_E164){
		    var parm 				= '&endPointID='+p_EndPointId+"&e164="+p_E164;		//get형식으로 변수 전달.
		    var url 				= 'ipcsDelete_01.jsp';		    					    
		    getMessagePage(url,parm);
		}

		/**
		 * 삭제 처리 하기
		 */
		function goDelete(){		
			var f 				= document.frm;
		    var f2 				= document.Deletelayer1;
		    var p_EndPointID 	= f2.hiEndPointID.value;
		    var p_Ei64 			= f2.hiEi64.value;
			
//			if(getRadioValue(f2.deleteType) == "Y"){
				//alert("전체삭제...");
				var p_DeleteType = "1";
//			}else{
				//alert("사용자 정보만 삭제...");
//				var p_DeleteType = "2";
//			}
			
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiEi64.value			= p_Ei64;
			f.hiDeleteType.value	= p_DeleteType;
			
			Ext.MessageBox.show({msg: '삭제중 입니다.',progressText: '삭제중 입니다.',width:400,wait:true,waitConfig: {interval:200} });
			
		   	f.action="<%=StaticString.ContextRoot%>/ipcsDelete.do";
		   	f.method="post";
		   	f.submit();			
		} 
		 
		/**
		 * 수정 내용 저장하기
		 */
		function goSave(){
			var f 				= document.frm;
			var f2 				= document.Editlayer1;
			var p_EndPointID 	= f2.hiEndPointID.value;	// EndPointID		
			var p_Ei64 			= f2.hiEi64.value;			// Ei64
			var p_Name			= f2.txtName.value;			// 이름
			var p_Position 		= f2.position.value;		// 직위
			var p_Dept			= f2.dept.value;			// 부서
			//var p_Parent		= f2.dept.value;			// 부서
			var p_Mobile		= f2.txtMobile.value;		// 핸드폰
			var p_HomeNumber	= f2.txtHomeNumber.value;	// 집전화
			var p_Mail			= f2.txtMail.value;			// 메일주소
			var p_Pass			= f2.txtPass.value;			// 비밀번호
			var p_Extension 	= f2.txtExtension.value;	// 입력받은 내선번호
			var p_OldExtension 	= f2.hiOldExtension.value;	// 조회한 내선번호
			 
			var p_AuthE164		= "0";						// 전화번호 인증 여부
			var p_AuthIPChk		= "0";						// IP인증 여부
			var p_AuthIP		= "";						// IP인증
			var p_AuthPortChk	= "0";						// Port인증 여부
			var p_AuthPort		= "0";						// Port인증
			var p_AuthMd5		= "0";						// MD5 인증 여부
			var p_AuthRegister	= "0";						// Register 유형
			var p_AuthStale		= "0";						// Stale 여부
			var p_AuthInvite	= "0";						// Invite 여부
			var p_AuthID		= "";						// 인증ID
			var p_AuthPass		= "";						// 비밀번호
			var p_ZoneCode 		= f2.txtZone.value;
			
		    // 필수 입력항목 체크
		    if(f2.txtName.value == ""){
		    	alert("이름을 입력하지 않았습니다!");
		    	return;
	        }
			if(f2.position.value == ""){
		    	alert("직급을 선택하지 않았습니다.");
		    	return;
		    }		    			
		    if(f2.dept.value == ""){
		    	alert("부서를 선택하지 않았습니다.");
		    	return;
		    }			
			
			//숫자 체크
			if(f2.txtMobile.value!=""){
			    if(isNaN(f2.txtMobile.value)){
			    	alert("핸드폰 입력값이 숫자가 아닙니다.");
			    	return;
		        }
	        }
	        if(f2.txtHomeNumber.value!=""){
				if(isNaN(f2.txtHomeNumber.value)){
			    	alert("집번호 입력값이 숫자가 아닙니다.");
			    	return;
			    }			
			}
			
			// 메일 체크
			if(f2.txtMail.value!=""){
				if((f2.txtMail.value.indexOf("@")==-1) || (f2.txtMail.value.indexOf(".")==-1)){				  
				alert("이메일이 정확히 입력되지 않았습니다.");
				f2.txtMail.focus();
				return; 
				}
	        }
			
			// 비밀번호 체크
			if(f2.txtPass.value==""){
				alert("비밀번호가 입력되지 않았습니다.");
				return; 
	        }
			// NAT Zone 체크
//			if(f2.txtZone.value==""){
//				alert("NAT Zone 이 선택되지 않았습니다.");
//				return; 
//	        }
		    // MD5 인증인 경우 ID, 비밀번호 체크
		    //if(f2.md5Auth.checked){
				if(f2.txtid.value=="" || f2.txtpassword.value==""){
					alert("MD5  인증 ID 및 비밀번호가  입력되지 않았습니다.");
					return; 
		        }
		    //}
		    // IP 인증인 경우 IP 체크
		    if(f2.ipAuth.checked){
				if(f2.txtip.value=="" || f2.txtport.value==""){
					alert("인증 IP 및 PORT 가  입력되지 않았습니다.");
					return; 
		        }
		    }
			
			// 내선번호 체크
			if(f2.txtExtension.value==""){
				alert("내선번호가 입력되지 않았습니다.");
				return; 			
			}
			if(p_Extension.length<3){
				alert("내선번호는 최소 3자리 이상이어야 합니다.");
				return; 			
			}
		    if(isNaN(f2.txtExtension.value)){
		    	alert("내선번호 입력값이 숫자가 아닙니다.");
		    	return;
		    }			
			
			// 특수문자 체크 (2012.12.12 추가)
			var nameChk_0 = 0;	// 한글
			var nameChk_1 = 0;	// 숫자
			var nameChk_2 = 0;	// 영어
			var nameChk_3 = 0;	// 특수문자
			var nameChk_4 = 0;	// 그외에...
			for(var i=0; i < p_Name.length ; i++){
				var code2 = p_Name.charCodeAt(i);

				if(code2 >= 48 && code2 <= 57){
					nameChk_1 = 1;
				}else if(code2 >= 65 && code2 <= 122){
					nameChk_2 = 1;
				}else if(code2==32||code2==33||code2==35||code2==40||code2==41||code2==42||code2==45||code2==60||code2==61||code2==62||code2==63||code2==64||code2==91||code2==93||code2==94||code2==95){
					nameChk_3 = 1;
				}else if(code2 >= 128){
					nameChk_0 = 1;
				}else{
					nameChk_4 = 1;
				}
				if(nameChk_4 == 1){
					alert("[" + p_Name.charAt(i) + "]은(는) 한글, 영문, 숫자 또는 사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)가 아닙니다.");
					return;
				}
			}
			
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiEi64.value			= p_Ei64;			
			f.hiName.value			= p_Name;
			f.hiPosition.value		= p_Position;
			f.hiDept.value			= p_Dept;
		    f.hiMobile.value		= p_Mobile;
		    f.hiHomeNumber.value	= p_HomeNumber;
		    f.hiMail.value			= p_Mail;
			f.hiPwd.value			= p_Pass;
			f.hiExtension.value		= p_Extension;
			f.hiOldExtension.value	= p_OldExtension;
		    				    		
			// 전화번호 인증 (0: 미사용, 1: 사용)
			if(f2.e164Auth.checked){
				p_AuthE164 = "1";				
			}else{
				p_AuthE164 = "0";
			}
			f.hiAuthE164.value = p_AuthE164;

			// IP 인증 (0: 미사용, 1: 사용)
			if(f2.ipAuth.checked){
				p_AuthIPChk 		= "1";
				p_AuthIP 			= f2.txtip.value;
				p_AuthPort 			= f2.txtport.value;				
				f.hiAuthIP.value 	= p_AuthIP;
				f.hiAuthPort.value 	= p_AuthPort;
			}else{
				p_AuthIPChk 		= "0";
				f.hiAuthIP.value 	= "";
				f.hiAuthPort.value 	= "0";			
			}
			f.hiAuthIPChk.value 	= p_AuthIPChk;

			// Port 인증 (0: 미사용, 1: 사용)
			if(f2.ipPort.checked){
				p_AuthPortChk 		= "1";
			}else{
				p_AuthPortChk 		= "0";
			}
			f.hiAuthPortChk.value 	= p_AuthPortChk;

			// MD5 인증 (0: 미사용, 1: 사용)
			//if(f2.md5Auth.checked){
				// MD5 인증 비밀번호 체크 기능 추가 (IMS 용) ----------------------------------------
//			if(("ACRO-CBS"=="<%//=goodsName%>")||("ACRO-HCBS"=="<%//=goodsName%>")){
				var p_MacAuthPass = f2.txtpassword.value;
				var p_MacPass_Chk = f2.txtpass_chk.value;
				
				if(p_MacAuthPass.length<6){
					alert("MD5인증 IP단말 비밀번호는 최소 6자리 이상이어야 합니다.");
					return;
				}
	            
	            var str = f2.txtpassword.value;
				var passChk1 = 0;	// 숫자
				var passChk2 = 0;	// 영어
				var passChk3 = 0;	// 특수문자
				var passChk4 = 0;	// 그외에...
	            for(var i=0; i < str.length ; i++){
	                var code = str.charCodeAt(i);
	
					if(code >= 48 && code <= 57){
						passChk1 = 1;
					}else if(code >= 65 && code <= 122){
						passChk2 = 1;
					//}else if(code==33 || code==35 || code==36 || code==45 || code==47 || code==63 || code==64){
					}else if(code==33||code==35||code==40||code==41||code==42||code==45||code==60||code==61||code==62||code==63||code==64||code==91||code==93||code==94||code==95){
						passChk3 = 1;
					}else{
						passChk4 = 1;
					}
					
					if(passChk4 == 1){
	                    alert("[" + str.charAt(i) + "]은(는) 영문, 숫자 또는 사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)가 아닙니다.");
	                   return;
					}
	            }
				if(!(passChk1 == 1 && passChk2 == 1 && passChk3 == 1 && passChk4 == 0)){
	                    alert("IP단말 비밀번호는 영문,숫자,사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)를 조합해서 만들어야 합니다.");
	                    return;
				}
				
				if(p_MacAuthPass != p_MacPass_Chk){
					alert("IP단말 비밀번호와 IP단말 비밀번호 확인 입력값이 같지 않습니다.");
					return;
				}
//			}
				// ------------------------------------------------------------------------------
				
				p_AuthMd5 		= "1";
				p_AuthRegister 	= f2.register.value;
				p_AuthInvite 	= f2.invite.value;
				p_AuthID 		= f2.txtid.value;
				p_AuthPass 		= f2.txtpassword.value;

				f.hiAuthRegister.value 	= p_AuthRegister;
				f.hiAuthInvite.value 	= p_AuthInvite;
				f.hiAuthID.value 		= p_AuthID;
				f.hiAuthPass.value 		= p_AuthPass;
				
				if(f2.staleAuth.checked){
					p_AuthStale = "1";
				}else{
					p_AuthStale = "0";
				}
				f.hiAuthStale.value 	= p_AuthStale;
			//}else{
			//	p_AuthMd5 = "0";
			//	f.hiAuthRegister.value 	= "0";
			//	f.hiAuthInvite.value 	= "0";
			//	f.hiAuthID.value 		= "";
			//	f.hiAuthPass.value 		= "";
			//	f.hiAuthStale.value 	= "0";
			//}
			f.hiAuthMd5.value 			= p_AuthMd5;
		    f.hiZoneCode.value			= p_ZoneCode;
		    
		    f.Edit_PAGE.value			= "<%=iPageNum%>"
		    
		    if(p_Extension == p_OldExtension){
				// 부서 SMS 번호체 등록된 번호인지 체크
			    var parm_2 	= '&hiE164='+p_Ei64;		//get형식으로 변수 전달.
			    var url_2 	= 'smsKeyNumberCheck_2.jsp';
	    
				Ext.Ajax.request({
					url : url_2 , 
					params : parm_2,
					method: 'POST',
					success: function ( result_2, request ) {
						var tempResult_2 = result_2.responseText;					
						var value_2 = tempResult_2.replace(/\s/g, "");	// 공백제거
						
				    	if(value_2=='OK'){ 
						   	f.action="<%=StaticString.ContextRoot%>/ipcsEdit.do";
						   	f.method="post";
						   	f.submit();
				    	}else{
					    	alert("부서 대표번호 SMS 수신번호로  등록된 번호 입니다! SMS 수신번호 해제후 설정을 변경하세요!");
					    	return;			
				    	}
					},
					failure: function ( result, request) { 
						Ext.MessageBox.alert('Failed', result.responseText); 
					} 
				});
		   	}else{
			    var parm 	= '&hiExtension='+p_Extension+'&hiEi64='+p_Ei64;		//get형식으로 변수 전달.
			    var url 	= 'extensionCheck.jsp';
			   
				Ext.Ajax.request({
					url : url , 
					params : parm,
					method: 'POST',
					success: function ( result, request ) {
						var tempResult = result.responseText;					
						var value = tempResult.replace(/\s/g, "");	// 공백제거
						
				    	if(value=='OK'){ 
						   	f.action="<%=StaticString.ContextRoot%>/ipcsEdit.do";
						   	f.method="post";
						   	f.submit();
				    	}else if(value=='NO2'){
					    	alert("이미 사용중인 내선 번호  입니다!");
					    	return;
				    	}else if(value=='NO4'){
					    	alert("이미 내선번호 또는 특수번호로 사용중인 번호 입니다!");
					    	return;
						}else if(value=='NO5'){
					    	alert("부서 대표번호 SMS 수신번호로  등록된 번호 입니다! SMS 수신번호 해제후 설정을 변경하세요!");
					    	return;
				    	}else{
					    	alert("이미 사용중인 내선 번호  입니다!");
					    	return;			
				    	}					
					},
					failure: function ( result, request) { 
						Ext.MessageBox.alert('Failed', result.responseText); 
						//Ext.MessageBox.alert('Failed', "이미 등록된 아이디 입니다!");
					} 
				});
		   	}
		}				
		
		/**
		 * 신규 내용 저장하기
		 */
		function goNewSave(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer2;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= f2.hiEi64.value;
		    //var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    //var p_Ei64_2		= f2.txtExtension.value;
		    var p_Ei64_Route2	= f2.hiE164Route2.value;
		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    //var p_ZoneCode 		= f2.hiZoneCode.value;
		    var p_ZoneCode 		= f2.txtZone.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    var p_Extension 	= f2.txtExtension.value;
		    //var p_Extension 	= f2.hiExtension.value;
			var p_AreaCode		= f2.hiAreaCode.value;			
			var p_NumberType	= f2.hiNumberType.value;
			
			var p_Mac			= f2.hiMac.value;
			//var p_MacDisplay	= f2.hiMacDisplay.value;
			var p_MacDisplay	= f.hiMacDisplay.value;
			var p_MacIp			= f2.hiMacIp.value;
			var p_MacAuto		= f2.hiMacAuto.value;
			var p_MacAutoNo		= f2.hiMacAutoNo.value;
			var p_MacAuthId		= f2.txtId.value;
			var p_MacAuthPass	= f2.txtpassword.value;
			var p_MacPass_Chk	= f2.txtpass_chk.value;
			var p_MacAddrType	= f2.hiMacAddrType.value;
			
			var p_Pass			= f2.txtPass.value;
			var p_Name			= f2.txtName.value;
			var p_Position		= f2.position.value;
			var p_Dept			= f2.dept.value;
			var p_Mobile		= f2.txtMobile.value;
			var p_HomeNumber	= f2.txtHomeNumber.value;
			var p_Mail			= f2.txtMail.value;

			var p_AuthE164		= "0";				// 전화번호 인증 여부
			var p_AuthIPChk		= "0";				// IP인증 여부
			var p_AuthIP		= "";				// IP인증
			var p_AuthPortChk	= "0";				// Port인증 여부
			var p_AuthPort		= "0";				// Port인증
			var p_AuthMd5		= "0";				// MD5 인증 여부
			var p_AuthRegister	= "0";				// Register 유형
			var p_AuthStale		= "0";				// Stale 여부
			var p_AuthInvite	= "0";				// Invite 여부
			var p_AuthID		= "";				// 인증ID
			var p_AuthPass		= "";				// 비밀번호
			
			var p_UserId		= f.hiUserID.value;	// 로그인 ID

			// 이름 체크
			if(f2.txtName.value==""){
				alert("이름이 입력되지 않았습니다.");
				return; 
	        }			
			
			// 특수문자 체크 (2012.12.12 추가)
			var nameChk0 = 0;	// 한글
			var nameChk1 = 0;	// 숫자
			var nameChk2 = 0;	// 영어
			var nameChk3 = 0;	// 특수문자
			var nameChk4 = 0;	// 그외에...
			for(var i=0; i < p_Name.length ; i++){
				var code2 = p_Name.charCodeAt(i);
			
				if(code2 >= 48 && code2 <= 57){
					nameChk1 = 1;
				}else if(code2 >= 65 && code2 <= 122){
					nameChk2 = 1;
				}else if(code2==32||code2==33||code2==35||code2==40||code2==41||code2==42||code2==45||code2==60||code2==61||code2==62||code2==63||code2==64||code2==91||code2==93||code2==94||code2==95){
					nameChk3 = 1;
				}else if(code2 >= 128){
					nameChk0 = 1;
				}else{
					nameChk4 = 1;
				}
				if(nameChk4 == 1){
					alert("[" + p_Name.charAt(i) + "]은(는) 한글, 영문, 숫자 또는 사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)가 아닙니다.");
					return;
				}
			}
			
			// 사용자(단말기) 비밀번호 체크 기능 추가 ----------------------------------
			if(p_Pass == ""){
				alert("사용자 비밀번호를 입력하지 않았습니다.");
				return;
			}
			if(p_Pass.length<6){
				alert("사용자 비밀번호는 최소 6자리 이상이어야 합니다.");
				return;
			}

            var str_2 = f2.txtPass.value;
			var passChk1_2 = 0;	// 숫자
			var passChk2_2 = 0;	// 영어
			var passChk3_2 = 0;	// 특수문자
			var passChk4_2 = 0;	// 그외에...
            for(var i=0; i < str_2.length ; i++){
                var code_2 = str_2.charCodeAt(i);

				if(code_2 >= 48 && code_2 <= 57){
					passChk1_2 = 1;
				}else if(code_2 >= 65 && code_2 <= 122){
					passChk2_2 = 1;
				//}else if(code_2==33 || code_2==35 || code_2==36 || code_2==45 || code_2==47 || code_2==63 || code_2==64){
				}else if(code_2==33||code_2==35||code_2==40||code_2==41||code_2==42||code_2==45||code_2==60||code_2==61||code_2==62||code_2==63||code_2==64||code_2==91||code_2==93||code_2==94||code_2==95){
					passChk3_2 = 1;
				}else{
					passChk4_2 = 1;
				}
				
				if(passChk4_2 == 1){
                    alert("[" + str_2.charAt(i) + "]은(는) 영문, 숫자 또는 사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)가 아닙니다.");
                    return;
				}
            }

			if(!(passChk1_2 == 1 && passChk2_2 == 1 && passChk3_2 == 1 && passChk4_2 == 0)){
                    alert("사용자 비밀번호는 영문,숫자,사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)를 조합해서 만들어야 합니다.");
                    return;
			}
			// -----------------------------------------------------------------
			
			f.hiGroupID.value		= p_GroupID;
			f.hiDomainID.value		= p_DomainID;
			f.hiZoneCode.value		= p_ZoneCode;
			f.hiPrefixID.value		= p_PrefixID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiEi64.value			= p_Ei64;
			f.hiExtension.value		= p_Extension;
		    f.hiAreaCode.value		= p_AreaCode;
		    f.hiNumberType.value	= p_NumberType;
		    
		    f.hiPwd.value			= p_Pass;
		    f.hiName.value			= encodeURI(p_Name);
		    f.hiPosition.value		= p_Position;
		    f.hiDept.value			= p_Dept;
		    f.hiMobile.value		= p_Mobile;
		    f.hiHomeNumber.value	= p_HomeNumber;
		    f.hiMail.value			= p_Mail;
		    
		    f.hiMac.value			= p_Mac;
		    f.hiMacAuthId.value		= p_MacAuthId;
		    f.hiMacAuthPass.value	= p_MacAuthPass;
		    f.hiMacDisplay.value	= p_MacDisplay;
		    f.hiMacIp.value			= p_MacIp;
		    f.hiMacAuto.value		= p_MacAuto;
		    f.hiMacAutoNo.value		= p_MacAutoNo;
		    f.hiMacAddrType.value	= p_MacAddrType;
		    
		    //alert("내선번호 유형3 : "+p_NumberType);
		    //alert("비밀번호 : "+p_Pass);
		    
		    p_Name 		= encodeURI(p_Name);
		    p_Position 	= encodeURI(p_Position);
		    p_MacDisplay 	= encodeURI(p_MacDisplay);
		    
		    if(p_NumberType == "1"){
				f.hiE164Route2.value	= p_Ei64_Route2;
			}else if(p_NumberType == "2"){
			    f.hiE164Route2.value	= "";
	        }


			// 전화번호 인증 (0: 미사용, 1: 사용)
			if(f2.e164Auth.checked){
				p_AuthE164 = "1";				
			}else{
				p_AuthE164 = "0";
			}
			f.hiAuthE164.value = p_AuthE164;

			// IP 인증 (0: 미사용, 1: 사용)
			if(f2.ipAuth.checked){
				p_AuthIPChk 		= "1";
				p_AuthIP 			= f2.txtip.value;
				p_AuthPort 			= f2.txtport.value;				
				f.hiAuthIP.value 	= p_AuthIP;
				f.hiAuthPort.value 	= p_AuthPort;
			}else{
				p_AuthIPChk 		= "0";
				f.hiAuthIP.value 	= "";
				f.hiAuthPort.value 	= "0";			
			}
			f.hiAuthIPChk.value 	= p_AuthIPChk;

			// Port 인증 (0: 미사용, 1: 사용)
			if(f2.ipPort.checked){
				p_AuthPortChk 		= "1";
			}else{
				p_AuthPortChk 		= "0";
			}
			f.hiAuthPortChk.value 	= p_AuthPortChk;

			// MD5 인증 (0: 미사용, 1: 사용)
			//if(f2.md5Auth.checked){
				// MD5 인증 비밀번호 체크 기능 추가 ----------------------------------------
				if(p_MacAuthPass == ""){
					alert("MD5인증 IP단말 비밀번호를 입력하지 않았습니다.");
					return;
				}
				if(p_MacAuthPass.length<6){
					alert("MD5인증 IP단말 비밀번호는 최소 6자리 이상이어야 합니다.");
					return;
				}
	            
	            var str = f2.txtpassword.value;
				var passChk1 = 0;	// 숫자
				var passChk2 = 0;	// 영어
				var passChk3 = 0;	// 특수문자
				var passChk4 = 0;	// 그외에...
	            for(var i=0; i < str.length ; i++){
	                var code = str.charCodeAt(i);
	
					if(code >= 48 && code <= 57){
						passChk1 = 1;
					}else if(code >= 65 && code <= 122){
						passChk2 = 1;
					//}else if(code==33 || code==35 || code==36 || code==45 || code==47 || code==63 || code==64){
					}else if(code==33||code==35||code==40||code==41||code==42||code==45||code==60||code==61||code==62||code==63||code==64||code==91||code==93||code==94||code==95){
						passChk3 = 1;
					}else{
						passChk4 = 1;
					}
					
					if(passChk4 == 1){
	                    alert("[" + str.charAt(i) + "]은(는) 영문, 숫자 또는 사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)가 아닙니다.");
	                    return;
					}
	            }
				if(!(passChk1 == 1 && passChk2 == 1 && passChk3 == 1 && passChk4 == 0)){
	                    alert("IP단말 비밀번호는 영문,숫자,사용가능한 특수문자(!,@,#,^,*,(,),-,_,=,[,],<,>,?)를 조합해서 만들어야 합니다.");
	                    return;
				}
			
				if(p_MacAuthPass == p_MacAuthId){
					alert("MD5인증 인증ID와 IP단말 비밀번호가 같니다.");
					return;
				}
				if(p_MacAuthPass != p_MacPass_Chk){
					alert("IP단말 비밀번호와 IP단말 비밀번호 확인 입력값이 같지 않습니다.");
					return;
				}
				// ---------------------------------------------------------------------
				
				p_AuthMd5 		= "1";
				p_AuthRegister 	= f2.register.value;
				p_AuthInvite 	= f2.invite.value;
				p_AuthID 		= f2.txtid.value;
				p_AuthPass 		= f2.txtpassword.value;

				f.hiAuthRegister.value 	= p_AuthRegister;
				f.hiAuthInvite.value 	= p_AuthInvite;
				f.hiAuthID.value 		= p_AuthID;
				f.hiAuthPass.value 		= p_AuthPass;
				
				if(f2.staleAuth.checked){
					p_AuthStale = "1";
				}else{
					p_AuthStale = "0";
				}
				f.hiAuthStale.value 	= p_AuthStale;
			//}else{
			//	p_AuthMd5 = "0";
			//	f.hiAuthRegister.value 	= "0";
			//	f.hiAuthInvite.value 	= "0";
			//	f.hiAuthID.value 		= "";
			//	f.hiAuthPass.value 		= "";
			//	f.hiAuthStale.value 	= "0";
			//}
			f.hiAuthMd5.value 			= p_AuthMd5;
			
			
			// 내선번호 체크
			if(f2.txtExtension.value==""){
				alert("내선번호가 입력되지 않았습니다.");
				return; 			
			}
			if(p_Extension.length<3){
				alert("내선번호는 최소 3자리 이상이어야 합니다.");
				return; 			
			}
		    if(isNaN(f2.txtExtension.value)){
		    	alert("내선번호 입력값이 숫자가 아닙니다.");
		    	return;
		    }			
			
			// 이름 체크
//			if(f2.txtName.value==""){
//				alert("이름이 입력되지 않았습니다.");
//				return; 
//	        }			
			// 비밀번호 체크
			if(f2.txtPass.value==""){
				alert("비밀번호가 입력되지 않았습니다.");
				return; 
	        }
			// 메일 체크
			if(f2.txtMail.value!=""){
				if((f2.txtMail.value.indexOf("@")==-1) || (f2.txtMail.value.indexOf(".")==-1)){				  
				alert("이메일이 정확히 입력되지 않았습니다.");
				//f2.txtMail.focus();
				return; 
				}
	        }
			// NAT Zone 체크
//			if(f2.txtZone.value==""){
//				alert("NAT Zone 이 선택되지 않았습니다.");
//				return; 
//	        }
		    // MD5 인증인 경우 ID, 비밀번호 체크
		    //if(f2.md5Auth.checked){
				if(f2.txtid.value=="" || f2.txtpassword.value==""){
					alert("MD5  인증 ID 및 비밀번호가  입력되지 않았습니다.");
					return; 
		        }
		    //}
		    
		    // IP 인증인 경우 IP 체크
		    if(f2.ipAuth.checked){
				if(f2.txtip.value=="" || f2.txtport.value==""){
					alert("인증 IP 및 PORT 가  입력되지 않았습니다.");
					return; 
		        }
		    }
		    
			// MD5 Hash (IMS용) 사용 (0: 미사용, 1: 사용) #####################
//			var p_Hash_Chk = "";
//			if(f2.hash_Chk.checked){
//				p_Hash_Chk = "1";
//			}else{
//				p_Hash_Chk = "0";
//			}
			// #############################################################
		    
		    // 신규 내용 저장
//		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiPwd='+p_Pass+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiMobile='+p_Mobile+'&hiHomeNumber='+p_HomeNumber+'&hiMail='+p_Mail+'&hiE164Route2='+p_Ei64_Route2+'&hiAuthE164='+p_AuthE164+'&hiAuthIPChk='+p_AuthIPChk+'&hiAuthIP='+p_AuthIP+'&hiAuthPortChk='+p_AuthPortChk+'&hiAuthPort='+p_AuthPort+'&hiAuthMd5='+p_AuthMd5+'&hiAuthRegister='+p_AuthRegister+'&hiAuthStale='+p_AuthStale+'&hiAuthInvite='+p_AuthInvite+'&hiAuthID='+p_AuthID+'&hiAuthPass='+p_AuthPass+'&hiMac='+p_Mac+'&hiMacAuthId='+p_MacAuthId+'&hiMacAuthPass='+p_MacAuthPass+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId+'&hiMacAddrType='+p_MacAddrType+'&hiHash_Chk='+p_Hash_Chk;		// MD5 Hash (IMS용) get형식으로 변수 전달.
		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiPwd='+p_Pass+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiMobile='+p_Mobile+'&hiHomeNumber='+p_HomeNumber+'&hiMail='+p_Mail+'&hiE164Route2='+p_Ei64_Route2+'&hiAuthE164='+p_AuthE164+'&hiAuthIPChk='+p_AuthIPChk+'&hiAuthIP='+p_AuthIP+'&hiAuthPortChk='+p_AuthPortChk+'&hiAuthPort='+p_AuthPort+'&hiAuthMd5='+p_AuthMd5+'&hiAuthRegister='+p_AuthRegister+'&hiAuthStale='+p_AuthStale+'&hiAuthInvite='+p_AuthInvite+'&hiAuthID='+p_AuthID+'&hiAuthPass='+p_AuthPass+'&hiMac='+p_Mac+'&hiMacAuthId='+p_MacAuthId+'&hiMacAuthPass='+p_MacAuthPass+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId+'&hiMacAddrType='+p_MacAddrType;		//get형식으로 변수 전달.
		    var url 	= 'ipcsUserInsert_New.jsp';
		    //getPage3(url,parm);
		   
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// 공백제거
					
			    	if(value=='OK'){ 
			    		goInsert_03();		    		
			    	}else if(value=='NO2'){
				    	alert("이미 내선번호 또는 특수번호로 사용중인 번호 입니다!");
				    	return;			    	
			    	}else{
				    	alert("개인 내선번호 저장이 정상적으로 이루어 지지 않았습니다!");
				    	return;			
			    	}					
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
					//Ext.MessageBox.alert('Failed', "이미 등록된 아이디 입니다!");
				} 
			});
		    				   	
		}		
		
		function goInsert_03(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer2;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.hiEi64.value;			// 전체번호
		    var p_Ei64_2		= f2.txtExtension.value;	// 내선번호
		    var p_Ei64_Route2	= f2.hiE164Route2.value;	// 지역번호 제외한 번호
		    //var p_Extension 	= f2.hiExtension.value;		// 내선번호
		    var p_Extension 	= f2.txtExtension.value;		// 내선번호
			var p_NumberType	= f2.hiNumberType.value;
			var p_Pass			= f2.txtPass.value;
			var p_Name			= f2.txtName.value;
			var p_Position		= f2.position.value;
			var p_Dept			= f2.dept.value;
			
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiNumberType.value	= p_NumberType;
			f.hiPwd.value			= p_Pass;
			f.hiName.value			= p_Name;
			f.hiPosition.value		= p_Position;
			f.hiDept.value			= p_Dept;
		    
		    if(p_NumberType == "1"){
				p_Ei64					= p_Ei64_1;
				f.hiEi64.value			= p_Ei64;
			}else if(p_NumberType == "2"){
			    p_Ei64					= p_Ei64_2;
			    f.hiEi64.value			= p_Ei64;
	        }
		    
		    p_Name 		= encodeURI(p_Name);
		    p_Position 	= encodeURI(p_Position);
		    p_Dept 		= encodeURI(p_Dept);
		    
    		var parm_2 	= '&hiEndPointID='+p_EndPointID+'&hiPwd='+p_Pass+'&hiEi64='+p_Ei64+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiExtension='+p_Extension;		//get형식으로 변수 전달.
    		var url_2 	= 'ipcsInsert_03.jsp';		    			
    		getPage(url_2,parm_2);			
		    					
		}

		/**
		 * 개인 해당 내선정보에 사용자 정보 나중에 등록 처리부분 
		 */		
		function goInsert_04(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Pass			= f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_Ei64_Route2	= f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    //var p_ZoneCode 		= f2.hiZoneCode.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    var p_Extension 	= f2.txtNumber2.value;
			var p_AreaCode		= f2.areaNo.value;			
			var p_NumberType	= f2.numberType.value;
			
			f.hiGroupID.value		= p_GroupID;
			f.hiDomainID.value		= p_DomainID;
			//f.hiZoneCode.value		= p_ZoneCode;
			f.hiPrefixID.value		= p_PrefixID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiAreaCode.value		= p_AreaCode
		    f.hiNumberType.value	= p_NumberType;
		    
		    if(f2.numberType.value == "1"){
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64					= p_Ei64_1;
				f.hiEi64.value			= p_Ei64;
				f.hiE164Route2.value	= p_Ei64_Route2;
			}else if(f2.numberType.value == "2"){
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64					= p_Ei64_2;
			    f.hiEi64.value			= p_Ei64;
			    f.hiE164Route2.value	= "";
			    p_Extension				= p_Ei64;
			    f.hiExtension.value		= p_Extension;
	        }
		    
    		var parm 	= '&hiEndPointID='+p_EndPointID+'&hiPwd='+p_Pass+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension;		//get형식으로 변수 전달.
    		var url 	= 'ipcsInsert_04.jsp';		    			
    		getPage(url,parm);			

		}
		
		function AreaNoSelect(){
			var f2		= document.Insertlayer1;
			f2.txtNumber1.focus();
		}
				
		/**
		 * 내선번호 유형에 따라 입력항목이 변경
		 */		
    	function NumberTypeChange(aa){
	        var f2 = document.Insertlayer1;
	        if(f2.numberType.value == "1"){
	            f2.areaNo.disabled = false;
	            f2.txtExtension.disabled = false;
	            div1.style.display = "block";
	            div2.style.display = "none";
	            f2.txtNumber1.focus();
	        }else if(f2.numberType.value == "2"){
	            f2.areaNo.disabled = false;
	            f2.txtExtension.disabled = false;
	            div2.style.display = "block";
	            div1.style.display = "none";
	            f2.txtExtension.focus();
	        }else{
	            alert("내선번호 유형을 선택해 주세요!");
	        }
	    }
	    
		/**
		 * 라디오 버튼
		 */				
		function getRadioValue(obj){
			var v   = "";
			theObj  = eval(obj);
	
			for(i = 0; i < theObj.length; i++){
			  if(theObj[i].checked)v=theObj[i].value;
			}
			return v;
		}
	    
		/**
		 * 새로고침
		 */ 
		function goRefresh() 
		{
			var f = document.frm;
			//f.action = "<%//=StaticString.ContextRoot%>/ipcs/ipcsList_New.jsp";
			f.action = "<%=StaticString.ContextRoot%>/ipcs/ipcsList_New.jsp?provision=1";
			f.submit();			
		}
			 
	function chkIpAuth(){
		var f2 	= document.Insertlayer2;
		if(f2.ipAuth.checked){
			f2.txtip.disabled 	= false;
			f2.ipPort.disabled 	= false;			
			f2.txtport.value 	= "5060";
			f2.txtport.disabled = true;			
		}else{
			f2.ipPort.checked 	= false;
			f2.ipPort.disabled 	= true;
			f2.txtip.disabled 	= true;
			f2.txtip.value 		= "";
			f2.txtport.disabled = true;
			f2.txtport.value 	= "";			
		}	
	}

	function chkPort(){
		var f2 	= document.Insertlayer2;
		if(f2.ipPort.checked){
			f2.txtport.disabled = false;
		}else{
			f2.txtport.disabled = true;
			f2.txtport.value 	= "5060";			
		}	
	}

	function chkMd5Auth(){
		var f2 	= document.Insertlayer2;
		if(f2.md5Auth.checked){
			f2.register.disabled 			= false;
			f2.staleAuth.disabled 			= false;
			f2.invite.disabled 				= false;
			//f2.txtid.disabled 				= false;
			f2.txtpassword.disabled 		= false;
			f2.txtpass_chk.disabled 		= false;
		}else{
			f2.register.disabled 			= true;
			f2.register.options[1].selected = true;
			f2.staleAuth.disabled 			= true;
			f2.staleAuth.checked 			= false;
			f2.invite.disabled 				= true;
			f2.invite.options[0].selected 	= true;
			//f2.txtid.disabled 				= true;
			f2.txtpassword.disabled 		= true;
			//f2.txtid.value 					= "";
			f2.txtpassword.value 			= "";
			
			f2.txtpass_chk.disabled 		= true;
			f2.txtpass_chk.value 			= "";
		}	
	}

	function chkIpAuth_Edit(){
		var f2 	= document.Editlayer1;
		if(f2.ipAuth.checked){
			f2.txtip.disabled 	= false;
			f2.ipPort.disabled 	= false;			
			f2.txtport.value 	= "5060";
			f2.txtport.disabled = true;			
		}else{
			f2.ipPort.checked 	= false;
			f2.ipPort.disabled 	= true;
			f2.txtip.disabled 	= true;
			f2.txtip.value 		= "";
			f2.txtport.disabled = true;
			f2.txtport.value 	= "";			
		}	
	}

	function chkPort_Edit(){
		var f2 	= document.Editlayer1;
		if(f2.ipPort.checked){
			f2.txtport.disabled = false;
		}else{
			f2.txtport.disabled = true;
			f2.txtport.value 	= "5060";			
		}	
	}

	function chkMd5Auth_Edit(){
		var f2 	= document.Editlayer1;
		if(f2.md5Auth.checked){
			f2.register.disabled 			= false;
			f2.staleAuth.disabled 			= false;
			f2.invite.disabled 				= false;
			//f2.txtid.disabled 				= false;
			f2.txtpassword.disabled 		= false;
			f2.txtpass_chk.disabled 		= false;
		}else{
			f2.register.disabled 			= true;
			f2.register.options[1].selected = true;
			f2.staleAuth.disabled 			= true;
			f2.staleAuth.checked 			= false;
			f2.invite.disabled 				= true;
			f2.invite.options[0].selected 	= true;
			//f2.txtid.disabled 				= true;
			f2.txtpassword.disabled 		= true;
			//f2.txtid.value 					= "";
			f2.txtpassword.value 			= "";
			
			f2.txtpass_chk.disabled 		= true;
			f2.txtpass_chk.value 			= "";
		}
	}

    function goZone(action_Type){
		var f2 	= document.Insertlayer2;
		if(f2.zoneChk.value=="1"){
			alert("Zone Code가 자동설정으로 되어 있습니다.");
			return;
		}
		    
    	var p_formtype		= action_Type;
    	//var p_formtype		= "";
        var parm = '&formtype='+p_formtype;		//get형식으로 변수 전달.                
        var url = "<%=StaticString.ContextRoot%>/system/selectZone.jsp";
        getPage5(url,parm);
    }
    
    function goAddZone(obj, id, p_formtype){    	
        if(p_formtype=="I"){
	        obj.style.backgroundColor="a8d3aa";
	       	document.Insertlayer2.txtZone.value = id;
	    }else{
	        obj.style.backgroundColor="a8d3aa";
	       	document.Editlayer1.txtZone.value = id;	    
	    }          	
    }

    function selectZone(){
		var f2 	= document.Insertlayer2;
		if(f2.zoneChk.value=="1"){
			f2.txtZone.value = "";
		}
    }

    function goZone_Edit(action_Type){
		var f2 	= document.Editlayer1;
		if(f2.zoneChk.value=="1"){
			alert("Zone Code가 자동설정으로 되어 있습니다.");
			return;
		}
		    
    	var p_formtype		= action_Type;
        var parm = '&formtype='+p_formtype;		//get형식으로 변수 전달.                
        var url = "<%=StaticString.ContextRoot%>/system/selectZone.jsp";
        getPage5(url,parm);
    }

    function selectZone_Edit(){
		var f2 	= document.Editlayer1;
		if(f2.zoneChk.value=="1"){
			f2.txtZone.value = "";
		}
    }
		
	/**
	 * 자동번호  유형에 따라 자동지역번호 변경
	 */		
	function AutoNoChange(){
		var f2 = document.Insertlayer1;
		if(f2.auto.value == "0"){
			f2.autoNo.disabled = true;
		}else if(f2.auto.value == "1"){
			f2.autoNo.disabled = false;
		}
	}

	/**
	 * IP 포워딩
	 */
	function goForwarding(p_ip){
        var f 					= document.frm;
        f.hiForwardingIp2.value	= p_ip;
        
        var parm 	= '&forwardingIp='+p_ip;
        var url 	= 'ipForwarding.jsp';		    
        getPage(url,parm);
	}
	
	function ipForwarding_OK(){
		var f 		= document.frm;
		var f2 		= document.ipForwarding;
		var ip 		= f2.hiForwardingIp.value;
		var port	= f2.txtPort.value;
		
		if(f2.txtPort.value == ""){
			alert("단말 포트가 입력되지 않았습니다!");
			return;
		}
		if(isNaN(f2.txtPort.value)){
			alert("단말 포트는 숫자만 입력가능합니다!");
			return;
		}

		
		var tempIP;
		var tempip_1;
		var tempip_2;
		var port_02;
		tempIP = ip.split(".");
		tempip_1 = tempIP[0];
		tempip_2 = tempIP[3];
		port_02		= (tempip_1*1.0)*(tempip_2*1.0)
		
		
	    var parm 	= '&forwardingIp='+ip+'&forwardingPort='+port;
	    var url 	= 'ipForwardingSet.jsp';
	   
		Ext.Ajax.request({
			url : url , 
			params : parm,
			method: 'POST',
			success: function ( result, request ) {
				var tempResult = result.responseText;					
				var value = tempResult.replace(/\s/g, "");	// 공백제거
				var strIP = '<%=wanIp%>';
				
		    	if(value=='OK'){ 
		    		hiddenAdCodeDiv();
		    		window.open("http://"+strIP+":"+port_02+"/","","");
		    		//window.open("http://"+strIP+":9000/","","");
		    	}else{
			    	alert("단말접속 포트포워딩이 정상적으로 이루어 지지 않았습니다!");
			    	return;			
		    	}					
			},
			failure: function ( result, request) { 
				Ext.MessageBox.alert('Failed', result.responseText); 
			} 
		});			
	}
	
	function ipForwarding_NO(){
		var f 		= document.frm;
		var f2 		= document.ipForwarding;
		var ip 		= f2.hiForwardingIp.value;
		var port	= f2.txtPort.value;
		
//		if(f2.txtPort.value == ""){
//			alert("단말 포트가 입력되지 않았습니다!");
//			return;
//		}
//		if(isNaN(f2.txtPort.value)){
//			alert("단말 포트는 숫자만 입력가능합니다!");
//			return;
//		}
		
		hiddenAdCodeDiv();
//		window.open("http://"+ip+":"+port+"/","","");
		//window.open("http://"+ip+":9000/","","");
	}
	
	//20101025 단말 일괄등록 by JSPark
			
	function goAdd(){
		
		var parm 	= '&ownerId=';		//get형식으로 변수 전달. 전달한 변수 없음
		var url 	= 'deptPositionCheck.jsp';
			   
		Ext.Ajax.request({
			url : url , 
			params : parm,
			method: 'POST',
			success: function ( result, request ) {
				var tempResult = result.responseText;					
				var value = tempResult.replace(/\s/g, "");	// 공백제거
				//팝업전 DB연결하여 부서 및 직급의 입력이 선행되어 있는지 여부 검사	
				
		    	if(value=='OK' || value=='ENDIDERROR'){
		    		//var parm 	= '&ownerId=';
		    	    var parm 	= '&hiUserID='+'<%=userID%>';
		    	    var url 	= 'ipcsInsert_05.jsp';		//메세지 팝업창으로 이동
		    	    getPage(url,parm);
				}else if(value=='NODEPT'){
			    	alert("부서가 존재하지 않습니다. 부서를 등록하세요!");
			    	return;
		    	}else if(value=='NOPOSITION'){
			    	alert("직급이 존재하지 않습니다. 직급을 등록하세요!");
			    	return;
//		    	}else if(value=='ENDIDERROR'){
//			    	alert("초기화 값이 아닙니다. 단말을 모두 삭제하세요!");
//			    	return;
		    	}else if(value=='NODOMAIN'){
			    	alert("가입자 아이디가 존재하지 않습니다. 가입자 아이디를 등록하세요!");
			    	return;
		    	}
		    	else{
			    	alert("정의되지 않은 에러입니다. 관리자에게 문의하세요!");
			    	return;			
		    	}					
			},
			failure: function ( result, request) { 
				Ext.MessageBox.alert('Failed', result.responseText); 
			} 
		});
	}
		
	function goAddImport(){
		var f  = document.addForm;	
		var fullname = f.uploadfile.value;
		var chk      = "";
	
		if(fullname == ""){
			alert("단말 일괄등록 파일을 선택하지 않았습니다.");
			return;
			
            var parm = '&titlemsg='+'일괄등록 파일 가져오기'+'&msg='+'파일을 선택하십시오.';
            var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
        }
		
        var i = f.uploadfile.value.lastIndexOf(".");
        if(i != -1){
            chk = fullname.substring(i+1);
        }
        if(chk.toLowerCase() != "xls"){
            alert("Excel 파일만 업로드 할 수 있습니다.");
            return;
        }
        
        f.hiuploadfile.value = fullname;	

		Ext.MessageBox.show({msg: '등록중 입니다.',progressText: '등록중 입니다.',width:400,wait:true,waitConfig: {interval:200} });
//		f.action="<%//=StaticString.ContextRoot%>/ipcs/ipcsInsert_05H.jsp";
		f.action="<%=StaticString.ContextRoot%>/ipcs/ipcsInsert_05H_2.jsp";
	   	f.method="post";
	   	f.submit();			
	}

    function goSample(gubun){
        resultdownloadframe.location.href = "<%=StaticString.ContextRoot%>/ipcs/download.jsp?gubun="+gubun;
    }
    
    /**
     * 언레지 화면으로 이동
     */
    function goUnRegister(p_EndpointId){
        var parm 	= '&endpointId='+p_EndpointId;
        var url 	= 'unRegister.jsp';		    
        getMessagePage(url,parm);
    }

	function unRegisterPro(){		
		var f 			= document.frm;
	    var f2 			= document.unRegisterLayer;
	    var endpoingId 	= f2.hiUnEndpointId.value;
	    
	    var parm 	= '&endPointId='+endpoingId;		//get형식으로 변수 전달.
	    var url 	= 'unRegisterPro.jsp';
		
		Ext.Ajax.request({
			url : url , 
			params : parm,
			method: 'POST',
			success: function ( result, request ) {
				var tempResult = result.responseText;					
				var value = tempResult.replace(/\s/g, "");	// 공백제거
				
		    	if(value=='OK'){ 
		    		alert("등록해제 되었습니다!");
		    		goRefresh();		    		
		    	}else if(value=='NO'){
			    	alert("등록해제가 실패하였습니다!");
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
		
	</script>

<form name="frm" method="post" action="<%=StaticString.ContextRoot%>/ipcs/ipcsList_New.jsp">
<input type='hidden' name ='PAGE_NUM'>
<input type='hidden' name ='Edit_PAGE'			value="">
<input type='hidden' name ='hiddenSearch_field' value="">
<input type='hidden' name ='hiddenSearch_gubun'	value="">
<input type='hidden' name ='hiddenEnendPointID' value="<%=s_EnendPointID%>">
<input type='hidden' name ='hiddenE164' 		value="<%=s_E164%>">
<input type='hidden' name ='hiddenName' 		value="<%=s_Name%>">
<input type='hidden' name ='hiGroupID' 			value="">
<input type='hidden' name ='hiDomainID' 		value="">
<input type='hidden' name ='hiZoneCode' 		value="">
<input type='hidden' name ='hiPrefixID' 		value="">
<input type='hidden' name ='hiEndPointID' 		value="">
<input type='hidden' name ='hiEi64' 			value="">
<input type='hidden' name ='hiE164Route2'		value="">
<input type='hidden' name ='hiExtension' 		value="">
<input type='hidden' name ='hiAreaCode' 		value="">
<input type='hidden' name ='hiNumberType' 		value="">
<input type='hidden' name ='hiDeleteType' 		value="">

<input type='hidden' name ='hiPwd' 				value="">
<input type='hidden' name ='hiName' 			value="">
<input type='hidden' name ='hiPosition' 		value="">
<input type='hidden' name ='hiDept' 			value="">
<input type='hidden' name ='hiMobile' 			value="">
<input type='hidden' name ='hiHomeNumber' 		value="">
<input type='hidden' name ='hiMail' 			value="">

<input type='hidden' name = 'hiAuthE164'		value="">
<input type='hidden' name = 'hiAuthIPChk'		value="">
<input type='hidden' name = 'hiAuthIP'			value="">
<input type='hidden' name = 'hiAuthPortChk'		value="">
<input type='hidden' name = 'hiAuthPort'		value="">
<input type='hidden' name = 'hiAuthMd5'			value="">
<input type='hidden' name = 'hiAuthRegister'	value="">
<input type='hidden' name = 'hiAuthStale'		value="">
<input type='hidden' name = 'hiAuthInvite'		value="">
<input type='hidden' name = 'hiAuthID'			value="">
<input type='hidden' name = 'hiAuthPass'		value="">

<input type='hidden' name = 'hiMac'				value="">
<input type='hidden' name = 'hiMacAuthId'		value="">
<input type='hidden' name = 'hiMacAuthPass'		value="">
<input type='hidden' name = 'hiMacDisplay'		value="">
<input type='hidden' name = 'hiMacIp'			value="">
<input type='hidden' name = 'hiMacAuto'			value="">
<input type='hidden' name = 'hiMacAutoNo'		value="">
<input type='hidden' name = 'hiMacAddrType'		value="">

<input type='hidden' name = 'hiOldExtension'	value="">

<input type='hidden' name = 'hiForwardingIp2'	value="">

<input type='hidden' name = 'hiUserID'			value="<%=userID%>">
<input type='hidden' name = 'hiGoodsName'		value="<%=goodsName%>">

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
					<!--td width="550" height="35" background="<%//=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif" style="padding-left:8"><font color="RGB(82,86,88)"><b>사용중인 번호 </b></font> (총 <%=iCount%>개, 최대  100개)</td-->
					<td width="167" height="35" align="right" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_pline_img.gif" width="160" height="20"></td>
					<td width="348" style="color:#524458; padding-top:4" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif">(총 <%=iCount%>개)</td>					
					<td width="117" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif">
					<select id="leftSelectBoxGlobal" style="width:120;height:21px;display:none;" name="search_gubun">
						<option value="1" <%if("1".equals(search_gubun))out.print("selected");%>>아이디</option>
						<option value="2" <%if("2".equals(search_gubun))out.print("selected");%>>번호</option>
						<option value="3" <%if("3".equals(search_gubun))out.print("selected");%>>이름</option>
					</select>
					<script>
						makeSelectBoxGlobal("leftSelectBoxGlobal", "selectBoxSelectedAreaGlobal", "#e6e6e6", "<%=StaticString.ContextRoot%>/imgs/select_form.gif", "selectBoxOptionGlobal", "selectBoxSelectedAreaFocusGlobal", "selectBoxOptionOverGlobal");
					</script>
					</td>
					<td width="113" align="center" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"><input type="text" name="txtSearch_field" id="txtSearch_field" value="<%=search_field%>" style="width:100 " onKeyUp="if((window.event.keyCode)==13)ipcsSearch('<%=s_EnendPointID%>','<%=s_E164%>','<%=s_Name%>');"></td>
					<td width="55" style="color:#524458;" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"><a href="#" onclick="ipcsSearch('<%=s_EnendPointID%>','<%=s_E164%>','<%=s_Name%>')" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image65','','<%=StaticString.ContextRoot%>/imgs/Content_search_select_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_normal_btn.gif" name="Image65" width="40" height="20" border="0"></a></td>
				  </tr>

				</table>	
				<!--end_검색부분-->
			</td>
		  </tr>

		  <tr>
			<td style="padding-top:16; padding-bottom:10; background:eeeff0; border-bottom:1 solid #cdcecf; height:405" valign="top" >
			  <table width="775" border="0" cellspacing="0" cellpadding="0" align="center" style="margin:0 0 0 0 ">
				<tr>
				  <td style="padding-bottom:5 ">
				  
				  <table width="775" border="0" cellspacing="0" cellpadding="0" align="left">
					<tr>
					  <td width="173"><a href="#" onclick="javascript:goInsert(<%=iCount%>);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image73','','<%=StaticString.ContextRoot%>/imgs/id_add_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/id_add_n_btn.gif" name="Image73" width="30" height="20" border="0" alt="개인내선번호 추가"></a> <a href="#" onclick="javascript:goRefresh();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_reset_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_reset_n_btn.gif" name="Image74" width="30" height="20" border="0" alt="새로고침"></a>
					  </td>
					  <td width="154" valign="top"></td>
					  <td width="67">&nbsp;</td>
					  <td width="67">&nbsp;</td>
					  <td width="214" valign="bottom" align="right">&nbsp;
					  <td bgcolor="eeeff0" width="100" valign="top" align="right"><a href="#" onclick="javascript:goAdd();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image81','','<%=StaticString.ContextRoot%>/imgs/Content_ipcs_bulk_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ipcs_bulk_n_btn.gif" name="Image81" width="64" height="20" border="0" alt="단말일괄등록"></a></td>
					</tr>
				  </table>
				  
				  
				  </td>
				</tr>
				<tr>
				  <td>
				  
				  <table id=box width="775" border="0" cellspacing="0" cellpadding="0" align="left" style="border:0 solid rgb(160,160,160)">
					<!--TBODY-->
					<tr>
						<td>
						<div style='width:775px;'>
							<table width="775" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
								<tr align="center" height="22" >
								  <td width="33" class="table_header01" style="cursor:hand" onclick=sortNow(0); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">상태</td>
								  <td width="120" class="table_header01" style="cursor:hand" onclick=sortNow(1); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">이름</td>
								  <td width="70" class="table_header01" style="cursor:hand" onclick=sortNow(2); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">직급</td>
								  <td width="110" class="table_header01" style="cursor:hand" onclick=sortNow(3); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">부서</td>
								  <td width="57" class="table_header01" style="cursor:hand" onclick=sortNow(4); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">내선번호</td>
								  <td width="81" class="table_header01" style="cursor:hand" onclick=sortNow(5); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호/아이디</td>
								  <td width="92" class="table_header01" style="cursor:hand" onclick=sortNow(6); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">IP주소</td>			  
								  <td width="102" class="table_header01" style="cursor:hand" onclick=sortNow(7); background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"> MAC 주소&#13;&#13;</td>
								  <td width="110" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"></td>			  
								</tr>
							</table>
						</div>
						</td>
					</tr>
					
					<tr>
						<td height="316">
							<div style='overflow-x:hidden; overflow-y:auto; width:775px; height:316px; border:0px solid red;'>
								<table width="775" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
									<%																																						 
									IpcsListDTO ipcsListDTO = null;
									int chk = 0;
									for ( int idx = 0; idx < groupCount ; idx++ ) {
										ipcsListDTO = (IpcsListDTO)iList.get(idx);
										
										String 	strCallTime = "";
										String 	answerService = ipcsListDTO.getAnswerservice().substring(3, 4);
										int kk = ipcsListDTO.getStarttime().lastIndexOf(".");
										if(ipcsListDTO.getCallState()>0) strCallTime = ipcsListDTO.getStarttime().substring(0, kk);
										
										if(chk == 0){
									%>					
											<tr id=g<%=idx%> height="20" bgcolor="rgb(243,247,245)" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="rgb(243,247,245)">
											  <td width="33" id=h<%=idx%>_0 class="table_column">
												<%if(ipcsListDTO.getSignalAddress()!=null && !"".equals(ipcsListDTO.getSignalAddress())){%>
													<%if(ipcsListDTO.getCallState()>0){%>
														<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/call_img.png" alt="통화시작 시간 : <%=strCallTime%>"></a>
													<%}else{%>
														<%if("1".equals(answerService)||"3".equals(answerService)){%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/forward_img.png" alt="무조건 착신전환"></a>
														<%}else if("2".equals(answerService)){%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/forward_img.png" alt="조건부 착신전환"></a>
														<%}else{%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/on_img.png" alt="등록완료"></a>
														<%}%>
													<%}%>
												<%}else{%>
													<img src="<%=StaticString.ContextRoot%>/imgs/off_img.png" alt="미등록">
												<%}%>
											  </td>
											  <td width="120" id=h<%=idx%>_1 class="table_column"><%=ipcsListDTO.getName()%>&nbsp;</td>
											  <td width="70" id=h<%=idx%>_2 class="table_column"><%=ipcsListDTO.getPosition()%>&nbsp;</td>
											  <td width="110" id=h<%=idx%>_3 class="table_column"><%=ipcsListDTO.getDeptName()%>&nbsp;</td>
											  <!--td id=h<%//=idx%>_4 class="table_column"><%//=ipcsListDTO.getId()%>&nbsp;</td-->
											  <td width="57" id=h<%=idx%>_4 class="table_column"><%=ipcsListDTO.getExtensionnumber()%>&nbsp;</td>
											  <td width="81" id=h<%=idx%>_5 class="table_column"><%=ipcsListDTO.getE164()%>&nbsp;</td>
											  
											  <!--td id=h<%//=idx%>_6 class="table_column"><a href="javascript:goForwarding('<%//=ipcsListDTO.getSignalAddress()%>')"><%//=ipcsListDTO.getSignalAddress()%>&nbsp;</a></td-->
											  <%if(ipcsListDTO.getSignalAddress()!=null && !"".equals(ipcsListDTO.getSignalAddress())){%>
											  	<td width="92" id=h<%=idx%>_6 class="table_column"><a href="javascript:goForwarding('<%=ipcsListDTO.getSignalAddress()%>')"><%=ipcsListDTO.getSignalAddress()%>&nbsp;</a></td>
											  <%}else{%>
											  	<td width="92" id=h<%=idx%>_6 class="table_column"><%=ipcsListDTO.getSignalAddress()%>&nbsp;</td>
											  <%}%>
											  
											  <td width="100" id=h<%=idx%>_7 class="table_column"><%=ipcsListDTO.getPhysicalAddress()%>&nbsp;</td>
											  <td width="112" id=h<%=idx%>_8 class="table_column"><a href="#" onclick="javascript:showEdit('<%=ipcsListDTO.getEndPointId()%>', '<%=ipcsListDTO.getE164()%>','<%=ipcsListDTO.getId()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0"></a> <a href="#" onclick="javascript:showDelete('<%=ipcsListDTO.getEndPointId()%>', '<%=ipcsListDTO.getE164()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx+100%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image<%=idx+100%>" width="34" height="18" border="0"></a></td>			  			  
											</tr>
										<% 
											chk = 1;
										}else{
										%>
											<tr id=g<%=idx%> height="20" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
											  <td width="33" id=h<%=idx%>_0 class="table_column">
												<%if(ipcsListDTO.getSignalAddress()!=null && !"".equals(ipcsListDTO.getSignalAddress())){%>
													<%if(ipcsListDTO.getCallState()>0){%>
														<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/call_img.png" alt="통화시작 시간 : <%=strCallTime%>"></a>
													<%}else{%>
														<%if("1".equals(answerService)||"3".equals(answerService)){%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/forward_img.png" alt="무조건 착신전환"></a>
														<%}else if("2".equals(answerService)){%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/forward_img.png" alt="조건부 착신전환"></a>
														<%}else{%>
															<a href="javascript:goUnRegister('<%=ipcsListDTO.getEndPointId()%>');"><img src="<%=StaticString.ContextRoot%>/imgs/on_img.png" alt="등록완료"></a>
														<%}%>
													<%}%>
												<%}else{%>
													<img src="<%=StaticString.ContextRoot%>/imgs/off_img.png" alt="미등록">
												<%}%>
											  </td>
											  <td width="120" id=h<%=idx%>_1 class="table_column"><%=ipcsListDTO.getName()%>&nbsp;</td>
											  <td width="70" id=h<%=idx%>_2 class="table_column"><%=ipcsListDTO.getPosition()%>&nbsp;</td>
											  <td width="110" id=h<%=idx%>_3 class="table_column"><%=ipcsListDTO.getDeptName()%>&nbsp;</td>
											  <!--td id=h<%//=idx%>_4 class="table_column"><%//=ipcsListDTO.getId()%>&nbsp;</td-->
											  <td width="57" id=h<%=idx%>_4 class="table_column"><%=ipcsListDTO.getExtensionnumber()%>&nbsp;</td>
											  <td width="81" id=h<%=idx%>_5 class="table_column"><%=ipcsListDTO.getE164()%>&nbsp;</td>
											  
											  <!--td id=h<%//=idx%>_6 class="table_column"><a href="javascript:goForwarding('<%//=ipcsListDTO.getSignalAddress()%>')"><%//=ipcsListDTO.getSignalAddress()%>&nbsp;</a></td-->
											  <%if(ipcsListDTO.getSignalAddress()!=null && !"".equals(ipcsListDTO.getSignalAddress())){%>
											  	<td width="92" id=h<%=idx%>_6 class="table_column"><a href="javascript:goForwarding('<%=ipcsListDTO.getSignalAddress()%>')"><%=ipcsListDTO.getSignalAddress()%>&nbsp;</a></td>
											  <%}else{%>
											  	<td width="92" id=h<%=idx%>_6 class="table_column"><%=ipcsListDTO.getSignalAddress()%>&nbsp;</td>
											  <%}%>
											  
											  <td width="100" id=h<%=idx%>_7 class="table_column"><%=ipcsListDTO.getPhysicalAddress()%>&nbsp;</td>
											  <td width="112" id=h<%=idx%>_8 class="table_column"><a href="#" onclick="javascript:showEdit('<%=ipcsListDTO.getEndPointId()%>', '<%=ipcsListDTO.getE164()%>','<%=ipcsListDTO.getId()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0"></a> <a href="#" onclick="javascript:showDelete('<%=ipcsListDTO.getEndPointId()%>', '<%=ipcsListDTO.getE164()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx+100%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image<%=idx+100%>" width="34" height="18" border="0"></a></td>			  			  
											</tr>						
										<%
											chk = 0;
										}
										%>
									<% 
									}
									%>					
									
									<tr>
									  <td colspan="9"><img src="<%=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif" width="775" height="2"></td>
									</tr>
								</table>
							</div>
						</td>
					</tr>	
					<!--/TBODY-->						
				  </table>
				  
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
</div>
<iframe name="resultdownloadframe" style="border-width:0px;" width="0" height="0" frameborder="0" scrolling="no" tabindex="-1"></iframe>
</body>
</html>

<!-- 팝업 레이어 -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>