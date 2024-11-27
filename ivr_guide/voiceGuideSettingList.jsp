<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO"%>
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

<%@ page import="useconfig.AddServiceList"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ModeSettingDTO" %>

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
    
	int count = 0; 
	ArrayList 		iList = null;
	DataStatement 	stmt = null;
	if(nModeDebug!=1){
		try{
			if(nAllowUser==1){		
				String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
				stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
				if(stmt!=null){
					//AddServiceList 	addServiceList = new AddServiceList();
					//iList	= (ArrayList)addServiceList.getCallChangeList(stmt, authGroupid);		// 데이타 조회
					ModeSettingDTO msDTO;
					iList = new ArrayList<ModeSettingDTO>();
			
			        /* String sql = "\n Select a.endpointid as endpointid, "; 
			        sql = sql +  "\n b.KEYNUMBERID as keynumberid, ";
			        sql = sql +  "\n (Select deptname From table_dept Where keynumber = b.KEYNUMBERID) as deptname, "; 
			        sql = sql +  "\n b.hunt as hunt , ";
			        //sql = sql +  "\n (Select count(*) From table_e164 Where e164 = b.forwardnum And substr(answerservice,4,1) = '3') as calltype, ";
			        sql = sql +  "\n b.vmsforward as calltype, ";
			        sql = sql +  "\n b.forwardnum as forwardnum, b.forwardtype as forwardtype ";
			        sql = sql +  "\n FROM  table_localprefix a LEFT OUTER JOIN table_KeyNumberID b  ON a.endpointid = b.KEYNUMBERID "; 
			        sql = sql +  "\n Where a.prefixtype = 4 "; 
			        if(authGroupid!=null) sql = sql +  "\n AND a.checkgroupid = '"+authGroupid+"' "; 
			        sql = sql +  "\n Order by a.endpointid ";
			        */
			        StringBuffer sb = new StringBuffer();
			        sb.append("SELECT 			                                                                            \n");
					sb.append("b.ad_index,		                                                                            \n");
					sb.append("b.tr_idx,			                                                                        \n");
					sb.append("b.am_index,		                                                                            \n");
					sb.append("b.am_mode_name,	                                                                            \n");
					sb.append("b.ad_date_type, 	                                                                            \n");
					sb.append("b.ad_sdate_day,	                                                                            \n");
					sb.append("b.ad_edate_day, 	                                                                            \n");
					sb.append("b.ad_week_mon, 	                                                                            \n");
					sb.append("b.ad_week_tue, 	                                                                            \n");
					sb.append("b.ad_week_wed, 	                                                                            \n");
					sb.append("b.ad_week_thu, 	                                                                            \n");
					sb.append("b.ad_week_fri, 	                                                                            \n");
					sb.append("b.ad_week_sat, 	                                                                            \n");
					sb.append("b.ad_week_sun, 	                                                                            \n");
					sb.append("b.ad_memo,                                                                                   \n");
					sb.append("COALESCE((select a.ivr_tel from nasa_trunk_set a where a.tr_idx = b.tr_idx), '') as ivr_tel	\n");
					sb.append("FROM nasa_answer_dateday b ");
// 					sb.append("WHERE b.checkgroupid='"+authGroupid+"' ");
					sb.append("ORDER BY b.ad_index ASC ");
					
					String sql = sb.toString(); 
							 
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					} 
			       
			        ResultSet rs = null;
			        try {
			        	System.out.println("VoiceGuide start ");
			        	System.out.println("VoiceGuide : "+sql);
			        	rs = stmt.executeQuery(sql);
			            while (rs.next()) {
			              	msDTO = new ModeSettingDTO();
			               	
			               	msDTO.setAdIndex(String.valueOf(rs.getInt("ad_index")));
							msDTO.setTrIdx(String.valueOf(rs.getInt("tr_idx")));
							msDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
							msDTO.setAmModeName(rs.getString("am_mode_name"));
							msDTO.setAdDateType(rs.getString("ad_date_type"));
							msDTO.setAdSDateDay(rs.getString("ad_sdate_day"));
							msDTO.setAdEDateDay(rs.getString("ad_edate_day"));
							msDTO.setAdWeekMon(rs.getString("ad_week_mon"));
							msDTO.setAdWeekTue(rs.getString("ad_week_tue"));
							msDTO.setAdWeekWed(rs.getString("ad_week_wed"));
							msDTO.setAdWeekThu(rs.getString("ad_week_thu"));
							msDTO.setAdWeekFri(rs.getString("ad_week_fri"));
							msDTO.setAdWeekSat(rs.getString("ad_week_sat"));
							msDTO.setAdWeekSun(rs.getString("ad_week_sun"));
							msDTO.setAdMemo(rs.getString("ad_memo"));
							msDTO.setIvrTel(rs.getString("ivr_tel"));
							
			               	iList.add(msDTO);
			            }
			        }catch(Exception ex){
			        	ex.printStackTrace() ;
			        }finally{
						if(rs!=null){
							rs.close();
							rs = null;
						}
			        }
			        
			        try{
			        	if(nModePaging==1){
			        		sql = "\n select count(*) ";
			        		sql = sql +  "\n FROM nasa_answer_dateday "; 
// 					        sql = sql +  "\n WHERE checkgroupid = '"+authGroupid+"' ";
					        System.out.println("totalcount : "+sql);
					        rs = stmt.executeQuery(sql);
			                while (rs.next())
			                	count = rs.getInt(1) ;
			        	}	
			        }catch(Exception ex){
			        }finally{
			        	if(rs!=null) rs.close();
			        	System.out.println("totalsize : "+count);
			        }
				}
			}
			if(count==0) count = iList==null? 0 : iList.size();
		}catch(Exception ex){
		}finally{
			if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<ModeSettingDTO>() ;
		ModeSettingDTO dto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			dto = new ModeSettingDTO();
// 			dto.setKeynumberId("0101111222"+z) ;
// 			dto.setDeptName("Dept_"+z) ;
// 			dto.setHunt(z%2==0?1:0) ;
// 			dto.setForwardNum("0601111222"+z) ;
// 			dto.setForwardType( z%5==0?2:(z%3==0?1:0) );//0:사용안함, 1:전체번호, 2:특정번호
// 			dto.setCallType(z%3==0?1:0) ;
			dto.setAdIndex("field_1");
			dto.setTrIdx("field_1");
			dto.setAmIndex("field_1");
			dto.setAmModeName("field_1");
			dto.setAdDateType("field_1");
			dto.setAdSDateDay("field_1");
			dto.setAdEDateDay("field_1");
			dto.setAdWeekMon("field_1");
			dto.setAdWeekTue("field_1");
			dto.setAdWeekWed("field_1");
			dto.setAdWeekThu("field_1");
			dto.setAdWeekFri("field_1");
			dto.setAdWeekSat("field_1");
			dto.setAdWeekSun("field_1");
			dto.setAdMemo("field_1");
			dto.setIvrTel("field_1");
			//dto.put("totalcnt", "25") ;
			iList.add(dto);
		}
		count = iList.size();//nMaxitemcnt ;
		nTotalpage = 25;
		if(nNowpage >= nTotalpage) count = 4;
	}
	
	//if (stmt != null) ConnectionManager.freeStatement(stmt);
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
<link href="olleh.ico" rel="icon" type="image/x-icon" />
<link href="olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>음성안내 설정</title>

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
     //alert("<%=LanguageMode.x("아이디를 입력하세요.","Please insert ID.")%>");
     document.loginForm.id.focus();
  } else if (document.loginForm.pwd.value == "") {
     alert("<%=LanguageMode.x("패스워드를 입력하세요.","Please insert password.")%>");
     document.loginForm.pwd.focus();
  } else {
      if(document.loginForm.id_save.checked){
        SetCookie("id_cookie_callChange",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_callChange",document.loginForm.id.value);
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

function func_init_callChange() {
	var groupid = <%=authGroupid%>;
	//if(groupid) SetCookie("id_cookie_callChange", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_callChange", '');
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

/**
 * 선택된 것 외의 것 선택 해제
 */
function checkNonDup(obj){
    var f = document.frm;
    if(f.chkOpt != undefined){
       if(f.chkOpt.length == undefined){
           if(obj.checked){
               f.chkOpt.checked = true;
           }else{
               f.chkOpt.checked = false;
           }
       }else{
    	   if(obj.checked)
    		   for(var i=0; i<f.chkOpt.length; i++){
    			   if(obj != f.chkOpt[i])
               			f.chkOpt[i].checked = false;
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
		function hiddenAdCodeDiv2() {
	        inf('visible'); //select box 보이기
	        setShadowDivVisible(false); //배경 layer 숨김
	    
	        document.getElementById('popup_layer').style.display="none";
	        
	        goRefresh();
	    }
		
		/**
		 * 새로고침
		 */ 
		function goRefresh() 
		{
			//var f = document.frm;
			//f.action = "<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingList.jsp?page=<%=nNowpage%>";
			//f.submit();		
			location.href="<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingList.jsp?page=<%=nNowpage%>";
		}
		

		function checkDateType(strValue){
			if(strValue == "D") {
				document.getElementById("startMonth").disabled = false;
				document.getElementById("startDay").disabled = false;
				document.getElementById("endMonth").disabled = false;
				document.getElementById("endDay").disabled = false;

				document.getElementById("adWeekMon").disabled = true;
				document.getElementById("adWeekTue").disabled = true;
				document.getElementById("adWeekWed").disabled = true;
				document.getElementById("adWeekThu").disabled = true;
				document.getElementById("adWeekFri").disabled = true;
				document.getElementById("adWeekSat").disabled = true;
				document.getElementById("adWeekSun").disabled = true;
			} else if(strValue == "W"){
				document.getElementById("startMonth").disabled = true;
				document.getElementById("startDay").disabled = true;
				document.getElementById("endMonth").disabled = true;
				document.getElementById("endDay").disabled = true;

				document.getElementById("adWeekMon").disabled = false;
				document.getElementById("adWeekTue").disabled = false;
				document.getElementById("adWeekWed").disabled = false;
				document.getElementById("adWeekThu").disabled = false;
				document.getElementById("adWeekFri").disabled = false;
				document.getElementById("adWeekSat").disabled = false;
				document.getElementById("adWeekSun").disabled = false;
			}
		}
		
		function selectType2(){
	    	var f2   		= document.editForm;
			var blockType 	= f2.blockType.value;
			
			if(blockType=="4"){
				f2.txtE164.value		= "00";
				f2.txtNote.value		= "국제전화";
				f2.txtNote.focus();
				f2.txtE164.disabled		= true;
				f2.prefixType.disabled	= false;
			}else if(blockType=="5"){
				f2.txtE164.value		= "01";
				f2.txtNote.value		= "이동전화";
				f2.txtNote.focus();
				f2.txtE164.disabled		= true;
				f2.prefixType.disabled	= false;
			}else if(blockType=="9"){
				f2.txtE164.value		= "99";
				f2.txtNote.value		= "내선번호";
				f2.txtNote.focus();
				f2.txtE164.disabled		= true;
				//f2.prefixType.options[0].selected 	= true;
				//f2.prefixType.disabled	= true;
				f2.prefixType.disabled	= false;
			}else if(blockType=="8"){
				f2.txtE164.value		= "#, *";
				f2.txtNote.value		= "특수코드";
				f2.txtNote.focus();
				f2.txtE164.disabled		= true;
				f2.prefixType.disabled	= false;
			}else{
				f2.txtE164.value		= "";			
				f2.txtE164.disabled		= false;
				f2.txtNote.value		= "";
				f2.prefixType.disabled	= false;
			}
	    }

	    /**
	     * 라디오 버튼 선택 (발신제한) 수정
	     */
	    function radio_Chk2(type){
	        var f2   		= document.editForm;
	        if(type==1){
		        f2.txtE164.focus();
	        }else if(type==3){
		        f2.txtE164.focus();
	        }
	    }
	    
	    function callTypeChange(){
	        var f2 = document.editForm;
	        if(f2.callChangeType.value == "1"){
	            f2.txtNumber.disabled = false;
	            f2.txtVmsNumber.disabled = false;
	            div1_1.style.display = "block";
	            div1_2.style.display = "none";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtNumber.focus();            
	        }else if(f2.callChangeType.value == "2"){
	            f2.txtNumber.disabled = false;
	            f2.txtVmsNumber.disabled = false;
	            div1_1.style.display = "none";
	            div1_2.style.display = "block";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtVmsNumber.focus();
	        }else{
	            alert("착신전환 유형을 선택해 주세요!");
				f2.callChangeType.selectedIndex	= 0;
				f2.callChangeType.value	= "";

	            div1_1.style.display = "none";
	            div1_2.style.display = "none";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtNumber.value 		= "";
	            f2.txtVmsNumber.value 	= "";
	        }
	    }

	   	function callTypeChange_02(){
	        var f2 = document.editForm;
	        if(f2.callChangeType_02.value == "1"){
	            f2.txtNumber_02.disabled 	= false;
	            f2.txtVmsNumber_02.disabled = false;
	            
	            div3_1.style.display 	= "block";
	            div3_2.style.display 	= "none";
	            
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	            f2.txtNumber_02.focus();            
	        }else if(f2.callChangeType_02.value == "2"){
	            f2.txtNumber_02.disabled 	= false;
	            f2.txtVmsNumber_02.disabled = false;
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "block";

	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	            f2.txtVmsNumber_02.focus();
	        }else{
	            alert("착신전환 유형을 선택해 주세요!");
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
				
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
				
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";

	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	        }
	    }

	   	function callTypeChange_Edit(){
	        var f2 = document.editForm;
	        if(f2.callChangeType.value == "1"){
	            f2.txtNumber.disabled = false;
	            f2.txtVmsNumber.disabled = false;
	            div1_1.style.display = "block";
	            div1_2.style.display = "none";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtNumber.focus();            
	        }else if(f2.callChangeType.value == "2"){
	            f2.txtNumber.disabled = false;
	            f2.txtVmsNumber.disabled = false;
	            div1_1.style.display = "none";
	            div1_2.style.display = "block";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtVmsNumber.focus();
	        }else{
	            alert("착신전환 유형을 선택해 주세요!");
				f2.callChangeType.selectedIndex	= 0;
				f2.callChangeType.value	= "";

	            div1_1.style.display = "none";
	            div1_2.style.display = "none";
	            
	            div2_1.style.display = "none";
	            div2_2.style.display = "none";
	            div2_3.style.display = "none";
	            div2_4.style.display = "none";
	            
	            f2.txtNumber.value 		= "";
	            f2.txtVmsNumber.value 	= "";
	        }
	    }


		// 호전환조건유형 (일자/시간, 요일/시간)
	   	function ForwardingTypeChange(){
	        var f2 = document.editForm;
	        if(f2.callForwarding.value == "1"){
	            div2_1.style.display 	= "block";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "block";
	            div2_4.style.display 	= "block";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	        
	        }else if(f2.callForwarding.value == "2"){
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "block";
	            div2_3.style.display 	= "block";
	            div2_4.style.display 	= "block";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	        
	        }else{
	            alert("착신전환 조건을 선택해 주세요!");
				f2.callForwarding.selectedIndex		= 0;
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
				
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";

	        }
	   	}

	   	function forwardingType_Chk(){
	        var chkOpt 	= document.getElementById("forwardingType_1");
	        var f2 		= document.editForm;
	        
	        if(chkOpt.checked){
	            f2.callChangeType.selectedIndex		= 0;
	            f2.callChangeType.value		= "";
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
				
	            f2.txtNumber.value 		= "";
	            f2.txtVmsNumber.value 	= "";
	            
	            div_1.style.display 	= "block";
	            div_2.style.display 	= "none";
	            
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
	        }else{
				f2.callForwarding.selectedIndex		= 0;
				
	            f2.callChangeType.selectedIndex		= 0;
	            f2.callChangeType.value		= "";
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value	= "";

	            div_1.style.display 	= "none";
	            div_2.style.display 	= "block";
				
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
	        }
	    }

	   	function forwardingType_Chk_Edit(){
	        var chkOpt 	= document.getElementById("forwardingType_1");
	        var f2 		= document.editForm;
	        
//	        alert("인덱스 : "+f2.callChangeType_02.selectedIndex);
//	        alert("value : "+f2.callChangeType_02.value);
	        
	        if(chkOpt.checked){
	            f2.callChangeType.selectedIndex		= 0;
	            f2.callChangeType.value		= "";
				//f2.callChangeType_02.selectedIndex	= 0;
				//f2.callChangeType_02.value	= "";
				
	            f2.txtNumber.value 		= "";
	            f2.txtVmsNumber.value 	= "";
	            
	            div_1.style.display 	= "block";
	            div_2.style.display 	= "none";
	            
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
	            
	            div4.style.display 		= "block";
	            div5.style.display 		= "none";
	            
	            div_table_01.style.display 	= "none";
	            div_table_02.style.display 	= "none";
	        }else{
				f2.callForwarding.selectedIndex		= 0;
				
	            f2.callChangeType.selectedIndex		= 0;
	            f2.callChangeType.value		= "";
				//f2.callChangeType_02.selectedIndex	= 0;
				//f2.callChangeType_02.value	= "";
	            //f2.txtNumber_02.value 		= "";
	            //f2.txtVmsNumber_02.value	= "";

	            div_1.style.display 	= "none";
	            div_2.style.display 	= "block";
				
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
	            
	            div4.style.display 		= "none";
	            div5.style.display 		= "block";
	            
	            div_table_01.style.display 	= "none";
	            div_table_02.style.display 	= "none";
	        }
	    }

		// 호전환조건유형 (일자/시간, 요일/시간)
	   	function ForwardingTypeChange_Edit(){
	        var f2 = document.editForm;
	        if(f2.callForwarding.value == "1"){
	            div2_1.style.display 	= "block";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "block";
	            div2_4.style.display 	= "block";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	        
	        }else if(f2.callForwarding.value == "2"){
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "block";
	            div2_3.style.display 	= "block";
	            div2_4.style.display 	= "block";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	        
	        }else{
	            alert("착신전환 조건을 선택해 주세요!");
				f2.callForwarding.selectedIndex		= 0;
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
				
	            div2_1.style.display 	= "none";
	            div2_2.style.display 	= "none";
	            div2_3.style.display 	= "none";
	            div2_4.style.display 	= "none";
	            
				div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";

				div_table_01.style.display 	= "none";
				div_table_02.style.display 	= "none";
	        }
	   	}

	   	function callTypeChange_02_Edit(){
	        var f2 = document.editForm;
	        if(f2.callChangeType_02.value == "1"){
	            f2.txtNumber_02.disabled 	= false;
	            f2.txtVmsNumber_02.disabled = false;
	            
	            div3_1.style.display 	= "block";
	            div3_2.style.display 	= "none";
	            
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div_table_01.style.display 	= "block";
	            div_table_02.style.display 	= "block";
	            
	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	            f2.txtNumber_02.focus();            
	        }else if(f2.callChangeType_02.value == "2"){
	            f2.txtNumber_02.disabled 	= false;
	            f2.txtVmsNumber_02.disabled = false;
	            
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "block";

	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";
	            
	            div_table_01.style.display 	= "block";
	            div_table_02.style.display 	= "block";
	            
	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	            f2.txtVmsNumber_02.focus();
	        }else{
	            alert("착신전환 유형을 선택해 주세요!");
				f2.callChangeType_02.selectedIndex	= 0;
				f2.callChangeType_02.value	= "";
				
	            div3_1.style.display 	= "none";
	            div3_2.style.display 	= "none";
				
	            div1_1.style.display 	= "none";
	            div1_2.style.display 	= "none";

	            f2.txtNumber_02.value 		= "";
	            f2.txtVmsNumber_02.value 	= "";
	            
	            div_table_01.style.display 	= "none";
	            div_table_02.style.display 	= "none";
	        }
	    }
	    
		/**
		 * 신규입력 화면으로 이동
		 */
		function showInsert(p_E164, p_Param){
		    var parm 	= '';//(p_E164?'&e164='+p_E164:'')+(p_Param?'&userparam='+p_Param:'');
		    var url 	= 'voiceGuideSettingInput.jsp';//'callChangeEdit.jsp';//'callChangeInsert.jsp';

		    /* if(p_E164 == "0" || p_E164 == ""){
		    	alert("등록된 전환 번호가 없습니다!");
				return;
			} */
		    getPage(url,parm);
		}

		// 추가
		function add() {
			var frm = document.addForm;

			if(frm.trIdx.value == "") {
				alert("응답대표번호를 선택하세요.")
				return;
			}

			if(frm.amIndex.value == "") {
				alert("응답스케줄을 선택하세요.")
				return;
			}

			if( frm.adDateType[1].checked ){
				var weekDay = new Array();
				weekDay[0] = "adWeekMon";
				weekDay[1] = "adWeekTue";
				weekDay[2] = "adWeekWed";
				weekDay[3] = "adWeekThu";
				weekDay[4] = "adWeekFri";
				weekDay[5] = "adWeekSat";
				weekDay[6] = "adWeekSun";

				var checkCount = 0;

				for(var i=0; i < 7; i++) {
					if( document.getElementById(weekDay[i]).checked ) {
						checkCount =+ 1;
					}
				}

				if( checkCount == 0 ) {
					alert("요일을 체크하세요");
					return;
				}
			}

			hiddenAdCodeDiv();

			frm.target = "procframe";
			frm.action="<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingInputPro.jsp"
			frm.submit();
		}
		
		function goInsertOk(strJson){
			var objJSON = eval("(function(){return " + strJson + ";})()");
    		goInsertDone(objJSON);
			alert("등록 되었습니다.");
			hiddenAdCodeDiv();
		}
		
		function goInsertFail(){
			alert("등록에 실패하였습니다.");
			hiddenAdCodeDiv();
		}
		
		/**
		 * 신규입력 후 출력
		 */
		function goInsertDone(datas){
			if(1==1){
				goRefresh();
				return;
			}
			document.location.href = 'ipcsExtList.jsp';
			if(datas.length > 0)
				additem(0, datas[0].params[0], datas[0].params[1], datas[0].params[2], datas[0].params[3], datas[0].params[4], datas[0].params[5]) ;
		}
		function additem(idx, paramE164, paramEpId, paramExtnum, paramIp, paramMac, paramAwrSvc) {
			var t_new_tr = document.createElement('TR');	
			var t_table = document.getElementById('tb_list');	//area_tb_list
			var old_items_html = t_table.innerHTML;
			
			var count_tr = idx>0?idx:t_table.getElementsByTagName("TR").length;
			//alert('count :'+count_tr);	
				t_new_tr.id = "g"+count_tr;
				t_new_tr.height = "22";
				t_new_tr.bgcolor = "E7F0EC";
				t_new_tr.align = "center";
				t_new_tr.innerHTML = "";
				//"<TR>"
		        //"<tr id=g"+count_tr+" height=\"22\" bgcolor=\"E7F0EC\" align=\"center\" >";
		        t_new_tr.innerHTML += "<td width=\"45\" class=\"table_column\">"+ (count_tr+<%=nModePaging==1 ? nNowpage*nMaxitemcnt+1 : 1 %>) +"</td>";
	     		t_new_tr.innerHTML += "<td width=\"80\" id='h"+count_tr+"_0' class=\"table_column\">";
	     		if(paramIp && paramIp.length>0){
	     			if(paramAwrSvc=='1' || paramAwrSvc=='3')
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript:goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/forward_img.png\" alt=\"무조건 착신전환\">";
		       		else if(paramAwrSvc=='2')
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript:goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/forward_img.png\" alt=\"조건부 착신전환\">";
		       		else
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript:goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/on_img.png\" alt=\"등록완료\">";
	     		}else
	          		t_new_tr.innerHTML += "<img onclick=\"\" id='imgStus"+count_tr+"'  src=\"<%=StaticString.ContextRoot%>/imgs/off_img.png\" alt=\"미등록\">";
		        t_new_tr.innerHTML += "</td>";  //state
		        t_new_tr.innerHTML += "<td width=\"120\" id='h"+count_tr+"_1' class=\"table_column\">"+paramE164+"</td>"; //e164
		        t_new_tr.innerHTML += "<td width=\"80\" id='h"+count_tr+"_2' class=\"table_column\">"+paramExtnum+"</td>";  //extnum
		        t_new_tr.innerHTML += "<td width=\"100\" id='h"+count_tr+"_3' class=\"table_column\">"+paramIp+"</td>"; //ip
		        t_new_tr.innerHTML += "<td width=\"130\" id='h"+count_tr+"_4' class=\"table_column\">"+paramMac+"</td>"; //mac
		        t_new_tr.innerHTML += "<td width=\"120\" id='h"+count_tr+"_5' class=\"table_column\">"; //btn
			        t_new_tr.innerHTML += "<input type=\"button\" name=\"btnActionMdi\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction(0, '"+paramE164+"', '"+paramEpId+"')\">";
			        t_new_tr.innerHTML += "&nbsp;<input type=\"button\" name=\"btnActionDel\" style=\"height: 18px\" value=\"삭제\" onclick=\"func_setAction(1, '"+paramE164+"', '"+paramEpId+"')\">";
			    t_new_tr.innerHTML += "</td>";
			    t_new_tr.innerHTML += "<td class=\"table_column\">&nbsp;</td>";
			  	//+ "</TR>'
		          
			    t_table.innerHTML = '';
			    
				t_table.appendChild(t_new_tr);	
				
				t_table.innerHTML = t_table.innerHTML + old_items_html;
				
			return count_tr;		
		}
		
		/**
		 * 수정 처리
		 */
		function showEdit(p_AdIndex){
			var parm 		= "&adIndex="+p_AdIndex;		//get형식으로 변수 전달.
		    var url 		= 'voiceGuideSettingEdit.jsp';
		    getPage(url,parm);	
		}
		
		/**
	     * 수정 저장
	     */
	     function goEdit() {
    		var frm = document.editForm;
    		if(frm.trIdx.value == "") {
    			alert("응답대표번호를 선택하세요.")
    			return;
    		}

    		if(frm.amIndex.value == "") {
    			alert("응답스케줄을 선택하세요.")
    			return;
    		}

    		if( frm.adDateType[1].checked ){
    			var weekDay = new Array();
    			weekDay[0] = "adWeekMon";
    			weekDay[1] = "adWeekTue";
    			weekDay[2] = "adWeekWed";
    			weekDay[3] = "adWeekThu";
    			weekDay[4] = "adWeekFri";
    			weekDay[5] = "adWeekSat";
    			weekDay[6] = "adWeekSun";

    			var checkCount = 0;

    			for(var i=0; i < 7; i++) {
    				if( document.getElementById(weekDay[i]).checked ) {
    					checkCount =+ 1;
    				}
    			}

    			if( checkCount == 0 ) {
    				alert("요일을 체크하세요");
    				return;
    			}
    		}

    		hiddenAdCodeDiv();

    		frm.target = "procframe";
			frm.action="<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingEditPro.jsp"
    		frm.submit();
    	}
		/**
		 * 수정 후 출력
		 */
		function goEditDone(datas){
			if(1==1){
				goRefresh();
				return;
			}
			/*
//	 		 strTrIdx
//	 			, strAmIndex
//	 			, strAmModeName
//	 			, strAdDateType
//	 			, strAdSDateDay
//	 			, strAdEDateDay
//	 			, strAdWeekMon
//	 			, strAdWeekTue
//	 			, strAdWeekWed
//	 			, strAdWeekThu
//	 			, strAdWeekFri
//	 			, strAdWeekSat
//	 			, strAdWeekSun
//	 			, strAdMemo

			*/
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _key, _td;
			//alert('length='+_len);
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_1"))
			  {
				  _key = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_key) {/* trIndex */
	 					
	 					_td = document.getElementById("h"+_i+"_1") ;
	 					if(_td){//Hunt
	 						var strTmp = "";
		 					if("W"==datas[z].params[3]){//strAdDateType
		 						strTmp += datas[z].params[6]/* strAdWeekMon */.equals("Y") ? "월," : "";
		 						strTmp += datas[z].params[7]/* strAdWeekTue */.equals("Y") ? "화," : "";
		 						strTmp += datas[z].params[8]/* strAdWeekWed */.equals("Y") ? "수," : "";
		 						strTmp += datas[z].params[9]/* strAdWeekThu */.equals("Y") ? "목," : "";
		 						strTmp += datas[z].params[10]/* strAdWeekFri */.equals("Y") ? "금," : "";
		 						strTmp += datas[z].params[11]/* strAdWeekSat */.equals("Y") ? "토," : "";
		 						strTmp += datas[z].params[12]/* strAdWeekSun */.equals("Y") ? "일," : "";
		 						if(strTmp.length > 0)
	 							    strTmp = strTmp.substring(0,strTmp.length-1);
		                		_td.innerHTML = strTmp+"&nbsp;";
		                	}else
		                		_td.innerHTML = datas[z].params[4]/* strAdSDateDay */ + " ~ " + datas[z].params[5]/* strAdEDateDay */ + "&nbsp;";
	 					}
	 					
	 					_td = document.getElementById("h"+_i+"_2") ;
	 					if(_td) _td.innerHTML = datas[z].params[2]+"&nbsp;";//amModeName
	 					
	 					if(++_idx == _len){
		 					//showInsert(datas[z].params[0], datas[z].params[1]) ;
		 					return ;
	 					}
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
        /**
         * 삭제 화면으로 이동
         */
        function showDelete(p_adIndex){
        	 var f   = document.frm;
             var str = "";
             if(f != undefined && f.chkOpt != undefined){
             	str = setE164BySelected();
             }
alert(str);             
             var deleteCheck = "Y";
             if( str.length == 0 )
            	 deleteCheck = "N";

            var parm 	= ('&adIndex='+p_adIndex +'&deleteCheck='+deleteCheck);		//get형식으로 변수 전달.;
            var url 	= 'voiceGuideSettingDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * 삭제처리
		 */
		function goDeletePro(){
            var f   = document.frm;
            var str = "";
            if(f != undefined && f.chkOpt != undefined){
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
                                str = str + "" + f.chkOpt[i].value;
                            }
                        }
                    }
                } */
            }else
		       	str = "1";

            f.deleteStr.value = str;//

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/ivr_guide/voiceGuideSettingDeleteAllPro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			if(1==1){
				goRefresh();
				return ;
			}
			
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;
			//alert('length='+_len);
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td) _td.innerHTML = "사용안함&nbsp;";
	                	//alert('Done.html='+_td.innerHTML+", e164="+_e164);
	                	_td = document.getElementById("h"+_i+"_5") ;
	                	if(_td) _td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction('"+_e164+"', 0, 0)\" >";
	 					if(++_idx == _len)
		 					return ;
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
                    var parm = '&titlemsg='+'음성안내 설정'+'&msg='+'대표번호 착신전환을 사용하지 않는 상태입니다.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("모든 설정이 삭제됩니다. 저장하시겠습니까?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/callchge/callChangeSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // 지정 시간 통보 사용하기 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'음성안내 설정'+'&msg='+'음성안내 설정을 추가하여 주십시오.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'음성안내 설정'+'&msg='+'대표번호 착신전환을 사용하고 있습니다.';
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
                var parm = '&titlemsg='+'음성안내 설정'+'&msg='+'선택 목록이 없습니다.';
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
                    var parm = '&titlemsg='+'음성안내 설정'+'&msg='+processname+'할 항목을 선택하여 주십시오.';
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
                                str = str + "" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }
            
            return str;//document.frm.e164.value = str;
		}
		
        /**
         * 등록/해제 클릭 (수정화면으로 이동)
         */
		function func_setAction(key, param, action) {
			document.frm.e164.value = key;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1) showDelete();
			else if(action==2) showEdit(key);
			else showInsert(key, param);
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setActionBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('삭제')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				showDelete(document.frm.e164.value) ;
			}
			else{
				if( isChecked('등록')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				showInsert(document.frm.e164.value) ;
        	}
		}
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_callChange" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  //document.rtcForm.rtcInput.value = getTimeStamp();
			  document.location.href = 'virtualNumList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==nField ) 	document.getElementById('mainnum').innerHTML = "<b>대표번호▲</b>";
				else					document.getElementById('mainnum').innerHTML = "<b>대표번호▼</b>";//△
				document.getElementById('calltype').innerHTML = "착신유형<font size='1px'>▽</font>";
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
				document.getElementById('fwdtype').innerHTML = "착신전환유형<font size='1px'>▽</font>";
			}
			else if(nField==1){
				if( lastSort==nField ) 	document.getElementById('calltype').innerHTML = "<b>착신유형▲</b>";
				else					document.getElementById('calltype').innerHTML = "<b>착신유형▼</b>";
				document.getElementById('mainnum').innerHTML = "대표번호<font size='1px'>▽</font>";
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
				document.getElementById('fwdtype').innerHTML = "착신전환유형<font size='1px'>▽</font>";
			}
			else if(nField==2){
				if( lastSort==nField ) 	document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				else					document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
				document.getElementById('mainnum').innerHTML = "대표번호<font size='1px'>▽</font>";
				document.getElementById('calltype').innerHTML = "착신유형<font size='1px'>▽</font>";
				document.getElementById('fwdtype').innerHTML = "착신전환유형<font size='1px'>▽</font>";
			}
			else if(nField==3){
				if( lastSort==nField ) 	document.getElementById('fwdtype').innerHTML = "<b>착신전환유형▲</b>";
				else					document.getElementById('fwdtype').innerHTML = "<b>착신전환유형▼</b>";
				document.getElementById('mainnum').innerHTML = "대표번호<font size='1px'>▽</font>";
				document.getElementById('calltype').innerHTML = "착신유형<font size='1px'>▽</font>";
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
		<% int menu = 4, submenu = 1; %>
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
	
	<input type='hidden' name ='hiE164' 			value=""/>
	<input type='hidden' name ='hiNumber'			value="">
	<input type='hidden' name ='hiOldNumber'		value="">
	<input type='hidden' name ='hiChangeType'		value="">
	<input type='hidden' name ='deleteStr' 			value=""/>
	<input type='hidden' name ='insertStr' 			value=""/>
	<input type='hidden' name ='hiForwardingType'	value="">
	<input type='hidden' name ='hiConditionType'	value="">
	<input type='hidden' name ='hiToTime'			value="">
	<input type='hidden' name ='hiFromTime'			value="">
	<input type='hidden' name ='hiDay'				value="">
	<input type='hidden' name ='hiWeek'				value="">
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'voiceGuideSettingList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'voiceGuideSettingList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="등록" onclick="func_setAction('','',0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="선택 삭제" onclick="func_setActionBySelected(1)">
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
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">
                  	<!-- <input type="checkbox" name="chkOptAll" onClick="checkAll(this);" > -->
                  </td>
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="162" onclick="if(11==1){sortNow(0,true);changeTitle(0);}" id="mainnum" 	class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">응답 대표번호<!-- <b>응답 대표번호 ▲</b> --></td>
                  <td width="245" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">응답 일자 / 요일</td>
                  <td width="201" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">응답스케줄</td>
                  <td width="60" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
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
		ModeSettingDTO dto= null;
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (ModeSettingDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					String strTmp = "";
					if(dto.getAdDateType().equals("W")) {
						strTmp = dto.getAdWeekMon().equals("Y") ? "월," : "";
						strTmp += dto.getAdWeekTue().equals("Y") ? "화," : "";
						strTmp += dto.getAdWeekWed().equals("Y") ? "수," : "";
						strTmp += dto.getAdWeekThu().equals("Y") ? "목," : "";
						strTmp += dto.getAdWeekFri().equals("Y") ? "금," : "";
						strTmp += dto.getAdWeekSat().equals("Y") ? "토," : "";
						strTmp += dto.getAdWeekSun().equals("Y") ? "일," : "";
						if(strTmp.length() > 0)
						    strTmp = strTmp.substring(0,strTmp.length()-1);
					} else {
						strTmp = dto.getAdSDateDay() + " ~ " + dto.getAdEDateDay();
					}
					%>	
					  <%-- <tr id=g<%=idx%> height="22" bgcolor="E7F0EC" align="center" onmouseover='this.style.backgroundColor="E7F0EC"' onmouseout='this.style.backgroundColor="E7F0EC"' > --%>
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="58" class="table_column"> 
		                	<input type="checkbox" name="chkOpt" value="" onClick="checkNonDup(this);" >
		                </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="0" id='h<%=idx%>_0' style='display:none;' ><%=dto.getAdIndex()%></td>
		                <td width="0" id='h<%=idx%>_1' style='display:none;' ><%=dto.getTrIdx()%></td>
		                <td width="162" id='h<%=idx%>_2' class="table_column"><%=dto.getIvrTel()%><%=dto.getIvrTel().equals("") ? "&nbsp;" : ""%></td>
		                <td width="245" id='h<%=idx%>_3' class="table_column"><%=strTmp%></td>
		                <td width="201" id='h<%=idx%>_4' class="table_column"><%=dto.getAmModeName()%>&nbsp;</td>
		                <%-- <td width="100" id='h<%=idx%>_3' class="table_column"></td> --%>
		                <td width="80" id='h<%=idx%>_5' class="table_column">
		                	<%-- <input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction('<%=dto.getKeynumberId()%>', '<%=dto.getForwardType()%>', 0)"> --%>
		                	<a href="#" onclick="javascript: func_setAction('<%=dto.getAdIndex()%>', '', 2);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=dto.getAdIndex()%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)">
		                		<img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=dto.getAdIndex()%>" width="34" height="18" border="0">
		                	</a>
		                </td>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
	out.println("<script type=\"text/JavaScript\"> sortNow(2,true); </script>") ;//번호 정렬
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="voiceGuideSettingList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="voiceGuideSettingList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       		</td>
		       		<td colspan = 5 align="center" > 
<%					
		for(int i=(nBlockidx*nBlockcnt); i<(nBlockidx+1)*nBlockcnt && i<=nTotalpage; i++){
      			if(nNowpage==i)
      				out.print(" <b>"+(i+1)+"</b> ") ;
      			else
      				out.print(" <a href=\"voiceGuideSettingList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="voiceGuideSettingList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="voiceGuideSettingList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
