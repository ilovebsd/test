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

<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="java.util.*" %>
<%@ page import="acromate.common.util.*" %>

<%@ page import="dto.SubGroupDTO" %>

<%@ page import="useconfig.AddServiceList"%>
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
   	
    String authGroupid = null;//, groupCode="" ;
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
	 
	 int count = 0; 
		
//	 	String[][] values = null;
		ArrayList 		blockList = null, subIdList=null;
		DataStatement 	stmt = null;
		if(nModeDebug!=1){
			try{
				if(nAllowUser==1){		
					String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
					stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
					if(stmt!=null){
						/* CommonDAO		commonDao		= new CommonDAO();
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
						 */
						//발신제한
						//AddServiceList 	addServiceList = new AddServiceList();
						//blockList	= (ArrayList)addServiceList.getCallBlockList(stmt);		// 데이타 조회
						
				    	String sql="";
				        ResultSet rs = null;
				        
				        ///**
				        SubGroupDTO subgroupDTO;
						subIdList = new ArrayList<SubGroupDTO>();
				        sql = "\n select ";
				        sql = sql +  "\n GroupId, SubID, Description ";
				        sql = sql +  "\n from TABLE_SubGroup "; 
				        if(authGroupid!=null/* && authGroupid.length()>0 */) 
				        	//sql = sql +  "\n WHERE checkgroupid='"+authGroupid+"' ";
				        	sql = sql +  "\n WHERE groupid='"+authGroupid+"' ";
				        sql = sql +  "\n order by SubID ";
				        
				        try {
				                rs = stmt.executeQuery(sql);
				                System.out.println("SQL : SubGroup "+sql);
				                while (rs.next()) {
				                	subgroupDTO = new SubGroupDTO();
				                	subgroupDTO.setSubID(Str.CheckNullString(rs.getString("SubID")));
				                	subgroupDTO.setDescription(Str.CheckNullString(rs.getString("Description")));
				                	subIdList.add(subgroupDTO);
				                }
				        }catch(Exception ex){
				        }finally{
							if(rs!=null) rs.close();			        	
				        }
				       	// **/
				       	
				        SubGroupDTO e164DTO;
						blockList = new ArrayList<SubGroupDTO>();
						sql = "\n SELECT a.e164, a.subid, ";
				        sql = sql +  "\n        coalesce(b.id, '') AS id, " ;
				        sql = sql +  "\n        coalesce(b.name, '') AS name, " ;
				        sql = sql +  "\n        coalesce(b.phonenum, '') AS phonenum, " ;
				        sql = sql +  "\n        coalesce(b.position, '') AS position, " ;
				        sql = sql +  "\n        coalesce(c.ranking, 100) AS rank " ;
				        sql = sql +  "\n   FROM table_e164 a " ;
				        sql = sql +  "\n   LEFT OUTER JOIN table_subscriber b " ;
				        sql = sql +  "\n                ON a.e164  = b.phonenum " ;
				        sql = sql +  "\n   LEFT OUTER JOIN table_position c " ;
				        sql = sql +  "\n                ON b.position = c.positionname " ;
				        //sql = sql +  "\n  WHERE a.subid =  '" + subID + "' " ;
				        if(authGroupid!=null/* && authGroupid.length()>0 */) 
				        	sql = sql +  "\n WHERE a.checkgroupid='"+authGroupid+"' ";
				        //sql = sql +  "\n  Order By rank ASC, b.name ASC "; 
				        sql = sql +  "\n  Order By a.e164 ASC ";
				        
				        
				        if(nModePaging==1){
							sql		+= " LIMIT "+nMaxitemcnt+" ";
							sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
						}
				        
				        try {
				        	
				                rs = stmt.executeQuery(sql);
				                System.out.println("SQL : E164SubID "+sql);
				                while (rs.next()) {
				                	e164DTO = new SubGroupDTO();
				                	e164DTO.setE164(Str.CheckNullString(rs.getString("e164")));
				                	e164DTO.setE164SubID(Str.CheckNullString(rs.getString("subid")));
				                	blockList.add(e164DTO);
				                }
				        }catch(Exception ex){
				        }finally{
							if(rs!=null) rs.close();			        	
				        }
				        
				      	/** 
				      	*그룹 코드
				      	**/
				        /* try {
				        	sql = "SELECT groupid, extensiongroupnum FROM table_subscriberGroup WHERE groupid='"+authGroupid+"' "; 
			                rs = stmt.executeQuery(sql);
			                System.out.println("GroupCode : "+sql);
			                while (rs.next()) {
			                	groupCode = Str.CheckNullString(rs.getString("extensiongroupnum")) ;
			                }
				        }catch(Exception ex){
				        }finally{
							if(rs!=null) rs.close();			        	
				        } */
						
						//int 		iCount 			= blockList.size();
				        try{
				        	if(nModePaging==1){
				        		sql = "\n select count(*) ";
// 					        	sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum ";
								sql = sql +  "\n   FROM table_e164 a " ;
						        sql = sql +  "\n   LEFT OUTER JOIN table_subscriber b " ;
						        sql = sql +  "\n                ON a.e164  = b.phonenum " ;
						        sql = sql +  "\n   LEFT OUTER JOIN table_position c " ;
						        sql = sql +  "\n                ON b.position = c.positionname " ;
						        if(authGroupid!=null) sql = sql +  "\n WHERE a.checkgroupid='"+authGroupid+"' ";
						        rs = stmt.executeQuery(sql);
				                System.out.println("totalcount : "+sql);
				                while (rs.next())
				                	count = rs.getInt(1) ;
				        	}	
				        }catch(Exception ex){}finally{if(rs!=null) rs.close();}
					}
				}
				if(count==0) count = blockList==null? 0 : blockList.size();
//	 			values = new String[count][3];
			}catch(Exception ex){
			}finally{
				if (stmt != null) ConnectionManager.freeStatement(stmt);
			}
		}else if(nAllowUser==1){
			blockList = new ArrayList<SubGroupDTO>() ;
//	 		HashMap smpitem;
			SubGroupDTO e164DTO = null;
			for(int z=0; z<nMaxitemcnt; z++){
				e164DTO = new SubGroupDTO();
				e164DTO.setE164("0101111222"+z) ;
				e164DTO.setE164SubID("AAA_"+z) ;
				e164DTO.setPosition("test_"+z) ;
				//e164DTO.setFilename(z%5==0?"3":(z%3==0)?"1":"0");//0:사용안함, 1:전체번호, 3:특정번호
				//e164DTO.setUsechk(z%2==0?1:0) ;
				//e164DTO.put("totalcnt", "25") ;
				blockList.add(e164DTO);
			}
			count = blockList.size();//nMaxitemcnt ;
			nTotalpage = 25;
			if(nNowpage >= nTotalpage) count = 4;
//	 		values = new String[count][3];
		}
		
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
<!-- <link href="olleh.ico" rel="icon" type="image/x-icon" />
<link href="olleh.ico" rel="shortcut icon" type="image/x-icon" /> -->
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
        SetCookie("id_cookie_pickup",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_pickup",document.loginForm.id.value);
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

function func_init_callblock() {
	var groupid = <%=authGroupid%>;
	//if(groupid) SetCookie("id_cookie_pickup", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_pickup", '');
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
		 * 수정 처리
		 */
		function goEdit(){
			var f  = document.frm;
            var str = "";
            
            var idtype = "1";
    		var num, value ;
    		
			var tag;                 
            var i=0;
            while( tag = document.getElementById("h"+i+"_num") ){
            	num = tag.value;//tag.innerHTML;
            	tag = document.getElementById("h"+i+"_new") ;
            	value = tag.value;
            	if( !value ){
            		i++;
            		continue;
            	}
            	
                if( value.trim().length==0){
                	alert("입력되지 않은 값이 존재합니다!");
                    return;
                }else if(1!=1){
                	value = value.replace(/\s/g, "");	// 공백제거
            		if(value!=""&&idtype=="3"){
            	        var ChkText=/^([0-9*]{1,20})$/
            	        if(ChkText.test(value)==false){
            				alert("개별번호인 경우 숫자와 * 만 사용이 가능합니다.")
            				return;
            			}
            		}else{
            			if(value!=""&&idtype!="8"&&idtype!="9"){
            				if(isNaN(value)){
            		        	alert("번호는 숫자만 입력이 가능합니다!");
            		        	return;
            				}
            			}
            		}
                }
                tag = document.getElementById("h"+i+"_old") ;
                if( tag.value.trim()==value.trim() ){
                	i++;
            		continue;
            	}
                str += num+":"+tag.value+","+value.trim()+"";
                
                i++;
            }
            if(1!=1){
            	alert("result: "+str.replace("", "\n"));
            	return ;
            }
    	    // 신규 부서대표번호 저장
    	    var parm 	= '&insertStr='+str;		//get형식으로 변수 전달.
    	    var url 	= 'pickupEditPro.jsp';//'pickupChk.jsp';
    	    //alert(parm);
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;
    				var value = tempResult.replace(/\s/g, "");	// 공백제거
    		    	if(value=='OK'){ 
    			        alert("수정되었습니다.");
    			        document.location.href = 'pickupList.jsp';
    			        return ;
    		    	}else if(1!=1&& value=='NO'){
    			    	alert("이미 등록된 당겨받기 그룹가 포함되어 있습니다!");
    			    	return;
    		    	}else{
    			    	alert("실패!");
    			    	return;
    		    	}
    			},
    			failure: function ( result, request) { 
    				Ext.MessageBox.alert('Failed', result.responseText); 
    			} 
    		});
		}
	    
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_pickup" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  //document.rtcForm.rtcInput.value = getTimeStamp();
			  document.location.href = 'pickupList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==nField )	document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				else				document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
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

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" <%if(nAllowUser<1) out.println("onLoad=\"goLogin();\""); %> >
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css" />

<div>
<table align="center" border="0">
<tr>
	<td width="180" style="min-width:180px;" >
	<!--strat--왼쪽페이지-->
		<% int menu = 2, submenu = 3; %>
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
	
	<input type='hidden' name ='hiCallBlockType' 		value=""/>
	<input type='hidden' name ='hiE164' 			value=""/>
	<input type='hidden' name ='prefixType' 		value=""/>
	<input type='hidden' name ='blockType' 			value=""/>
	<input type='hidden' name ='blockE164' 			value=""/>
	<input type='hidden' name ='note' 				value=""/>
	<input type='hidden' name ='deleteStr' 			value=""/>
	<input type='hidden' name ='insertStr' 			value=""/>
	<input type='hidden' name ='hiUserID'				value="<%=authGroupid%>">
	
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'pickupList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'pickupList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2"  align="right"></td>
              </tr>
		  </table>
		</td>
	</tr>
      <tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="130" onclick="sortNow(0,true);changeTitle(0);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>전화번호▲</b></td>
                  <td width="230" id="memname" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">당겨받기 그룹</td>
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
	int idx=0;
	if(/* envList!=null && */ count!=0){
		nTotalpage = nModePaging==0 ? 0 : (int)(count/nMaxitemcnt);
		int endidx = nModePaging==0 ? count : (nTotalpage==nNowpage? count%nMaxitemcnt : nMaxitemcnt ) ;
		SubGroupDTO dto= null;
		if(blockList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (SubGroupDTO)blockList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <!-- <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="" > </td> --> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="130" id='h<%=idx%>_0' class="table_column"><%=dto.getE164()%></td>
		                <td width="230" id='h<%=idx%>_1' class="table_column">
		                	<select id='h<%=idx%>_new' >
		                		<%
		                		SubGroupDTO combodto;
		                		for(int z=0 ; z<subIdList.size(); z++){
		                			combodto = (SubGroupDTO)subIdList.get(z);
		                			out.println("<option "+(combodto.getSubID().equals(dto.getE164SubID())?"selected":"")+">"+combodto.getSubID()+"</option>");
		                		}//for
		                		%>
		                	</select>
		                	<input type='hidden' id='h<%=idx%>_old' value='<%=dto.getE164SubID()%>' />
		                	<input type='hidden' id='h<%=idx%>_num' value='<%=dto.getE164()%>' />
						</td>
		                <%-- <td width="80" id='h<%=idx%>_3' class="table_column"><input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction('<%=dto.getE164()%>', <%=dto.getFilename()%>, 0)"></td> --%>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
   	out.println("<script type=\"text/JavaScript\"> sortNow(0, true); </script>") ;//번호 정렬
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<%-- <td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="pickupList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="pickupList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       		</td> --%>
		       		<td colspan = 5 align="center" >
		       			<table>
		       				<tr>
		       					<td>
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="pickupList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="pickupList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       					</td>
		       					<td>
<%					
		for(int i=(nBlockidx*nBlockcnt); i<(nBlockidx+1)*nBlockcnt && i<=nTotalpage; i++){
      			if(nNowpage==i)
      				out.print(" <b>"+(i+1)+"</b> ") ;
      			else
      				out.print(" <a href=\"pickupList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 		       					
		       					</td>
		       					<td>
		       			<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="pickupList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="pickupList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
		       					</tr>
		       				</table> 
						<% } %> 
		       					</td>
		       				</tr>
		       			</table> 

		       		</td>
		         	<%-- <td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="pickupList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="pickupList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
		       					</tr>
		       				</table> 
						<% } %> 
		         	</td> --%>
		       </tr>
<% } %>		       
          </table>
<!-- </div> -->
        </td>
      </tr>
      <tr>
	       <td valign="bottom" align="left">
	          <table width="100" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
	              <tr align="center" height="22" >
	              	<td width="80" class="table_column">
	              		<input type="button" name="btnAction" style="height: 18px" value="수정" onclick="goEdit()">
	              	</td>
	              </tr>
			  </table>
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
