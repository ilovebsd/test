<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="java.text.DecimalFormat"%>
<%@page import="bizportal.nasacti.ipivr.dto.ResponseTimeDTO"%>
<%@page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
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

<%@page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@page import="bizportal.nasacti.ipivr.dto.ResponseTimeDTO"%>
<%@page import="sun.misc.BASE64Encoder"%>

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
	ArrayList 		iList = null;//responseTimeDTO1List
	
	ArrayList responseModeDTOList = null;
	
	ArrayList<UsedVoiceDTO> usedVoiceDTOList = null;
	ArrayList<VoiceDTO> voiceDTOList = null;
	
	String strMsg = "";
	ArrayList hourList = null;
	ArrayList minuteList = null;
	
	DecimalFormat df = new DecimalFormat("00");
	hourList = new ArrayList();
	for(int i=0; i < 24; i++)
		hourList.add(df.format(i));
	minuteList = new ArrayList();
	for(int i=0; i < 60; i++)
		minuteList.add(df.format(i));
	
	/* 
	List responseModeDTOList = (List) request.getAttribute("responseModeDTOList");
    List usedVoiceDTOList = (List) request.getAttribute("usedVoiceDTOList");
    List voiceDTOList = (List) request.getAttribute("voiceDTOList");
	String strMsg = (String)request.getAttribute("msg");
	List hourList = (List)request.getAttribute("hourList");
	List minuteList = (List)request.getAttribute("minuteList");
	List responseTimeDTO1List = (List)request.getAttribute("responseTimeDTO1List");
	 */
	 
	String sql = "";
	ResultSet rs = null;
	DataStatement 	stmt = null;
	if(nModeDebug!=1){
		try{
			if(nAllowUser==1){	
				String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
				stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
				if(stmt!=null){
					//AddServiceList 	addServiceList = new AddServiceList();
					//iList	= (ArrayList)addServiceList.getCallChangeList(stmt, authGroupid);		// 데이타 조회
					ResponseTimeDTO rmDTO = null;
					iList = new ArrayList<ResponseTimeDTO>();
			
					sql = "SELECT am_index, am_mode_name, am_memo     \n";
					sql += "FROM nasa_answer_mode  \n";
// 					sql += "WHERE checkgroupid = '"+ authGroupid +"' ";
					sql += "ORDER BY am_index ASC ";
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					} 
			       
			        try {
			        	System.out.println("sql : \n"+sql);
			        	rs = stmt.executeQuery(sql);
			            while (rs.next()) {
			            	ResponseTimeDTO responseTimeDTO = new ResponseTimeDTO();
							responseTimeDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
							responseTimeDTO.setAmModeName(rs.getString("am_mode_name"));
							responseTimeDTO.setAmMemo(rs.getString("am_memo"));
							//responseTimeDTO1List.add(responseTimeDTO);
			               	iList.add(responseTimeDTO);
			            }
			            if(iList != null) iList.trimToSize();
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
			        		sql = "\n SELECT count(*) ";
			        		sql += "\n FROM nasa_answer_mode ";
// 			        		sql += "WHERE checkgroupid = '"+ authGroupid +"' ";
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
				
				/**
				 *
				 */
				ResponseModeDTO rmDTO = null;
				responseModeDTOList = new ArrayList<ResponseModeDTO>();
		
				sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0,     \n";
				sql += "sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc,   \n";
				sql += "sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route,                                                        \n";
				sql += "COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0)as nwu_idx                                    \n";
				sql += "FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y' ";
// 				sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
				sql += "ORDER BY sc_code ASC ";
		        try {
		        	System.out.println("sql : \n"+sql);
		        	rs = stmt.executeQuery(sql);
		            while (rs.next()) {
		            	rmDTO = new ResponseModeDTO();
						rmDTO.setScCode(String.valueOf(rs.getInt("sc_code")));
						rmDTO.setScName(rs.getString("sc_name"));
						rmDTO.setScSponsor(rs.getString("sc_sponsor"));
						rmDTO.setScNextBox(rs.getString("sc_nextbox"));
						rmDTO.setScHour(String.valueOf(rs.getInt("sc_hour")));
						rmDTO.setScMakeCallTime(String.valueOf(rs.getInt("sc_makecall_time")));
						rmDTO.setScLang(rs.getString("sc_lang"));
						rmDTO.setScLogCheck(rs.getString("sc_logcheck"));
						rmDTO.setScAgain(String.valueOf(rs.getInt("sc_again")));
						rmDTO.setScKeyTo(rs.getString("sc_keyto"));
						rmDTO.setScKey0(rs.getString("sc_key0"));
						rmDTO.setScKey1(rs.getString("sc_key1"));
						rmDTO.setScKey2(rs.getString("sc_key2"));
						rmDTO.setScKey3(rs.getString("sc_key3"));
						rmDTO.setScKey4(rs.getString("sc_key4"));
						rmDTO.setScKey5(rs.getString("sc_key5"));
						rmDTO.setScKey6(rs.getString("sc_key6"));
						rmDTO.setScKey7(rs.getString("sc_key7"));
						rmDTO.setScKey8(rs.getString("sc_key8"));
						rmDTO.setScKey9(rs.getString("sc_key9"));
						rmDTO.setScKeyAs(rs.getString("sc_keyas"));
						rmDTO.setScKeySh(rs.getString("sc_keysh"));
						rmDTO.setScKeyA(rs.getString("sc_keya"));
						rmDTO.setScKeyB(rs.getString("sc_keyb"));
						rmDTO.setScKeyC(rs.getString("sc_keyc"));
						rmDTO.setScKeyD(rs.getString("sc_keyd"));
						rmDTO.setScKeyEtc(rs.getString("sc_key_etc"));
						rmDTO.setScVoiceFile(rs.getString("sc_voicefile"));
						rmDTO.setDgCheck(rs.getString("dg_check"));
						rmDTO.setScFileChange(rs.getString("sc_file_change"));
						rmDTO.setScCidRoute(rs.getString("sc_cid_route"));
						rmDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
						responseModeDTOList.add(rmDTO);
		            }
		            if(responseModeDTOList != null) responseModeDTOList.trimToSize();
		        }catch(Exception ex){
		        	ex.printStackTrace() ;
		        }finally{
					if(rs!=null){
						rs.close(); rs = null;
					}
		        }
		        
				/**
				 * 
				 */
				usedVoiceDTOList 	= new ArrayList<UsedVoiceDTO>();
				voiceDTOList	 	= new ArrayList<VoiceDTO>();
				for(int i=0; i< responseModeDTOList.size(); i++){
					//String strScVoiceFile = ((ResponseModeDTO)iList.get(i)).getScVoiceFile();
					String strScVoiceFile = ((ResponseModeDTO)responseModeDTOList.get(i)).getScVoiceFile();
					
					sql =  "SELECT nwu_idx, w_index, nwu_type, nwu_filename, nwu_definition, ns_idx \n";
       				sql +=  "FROM nasa_wave_use \n";
       				sql +=  "WHERE nwu_filename = '"+ strScVoiceFile +"' \n";
        			
					UsedVoiceDTO uvDTO = null;
			        try {
			        	System.out.println("Query : "+sql);
			        	rs = stmt.executeQuery(sql);
		                if (rs.next()) {
		                	uvDTO = new UsedVoiceDTO();
							uvDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
							uvDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
							uvDTO.setNwuType(rs.getString("nwu_type"));
							uvDTO.setNwuFileName(rs.getString("nwu_filename"));
							uvDTO.setNwuDefinition(rs.getString("nwu_definition"));
							uvDTO.setNsIdx(String.valueOf(rs.getInt("ns_idx")));
		                }
		                usedVoiceDTOList.add(uvDTO);
			        }catch(Exception e){
			        	e.printStackTrace() ;
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
			        
			        /**
					 * 
					 */
			        if(uvDTO!=null){
	       				sql = "SELECT w_index, COALESCE(server_ip, '') as server_ip, COALESCE(w_name, '') as w_name, COALESCE(w_file, '') as w_file,          \n";
	       				sql += "COALESCE(w_memo, '') as w_memo, COALESCE(w_div, '') as w_div, COALESCE(w_send, '') as w_send, COALESCE(w_kind, '') as w_kind,  \n";
	       				sql += "COALESCE(w_sendfile, '') as w_sendfile, COALESCE(w_regdate, '') AS w_regdate, COALESCE(w_acceptdate, '') AS w_acceptdate       \n";
	       				sql += "FROM NASA_WAV WHERE w_index = %s ";
	       				sql = String.format(sql, uvDTO.getWIndex());
	       				
				        VoiceDTO vDTO = new VoiceDTO();
				        try {
				        	System.out.println("Query : "+sql);
				        	rs = stmt.executeQuery(sql);
			                if (rs.next()) {
			                	vDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
			    				vDTO.setServerIp(rs.getString("server_ip"));
			    				vDTO.setWName(rs.getString("w_name"));
			    				vDTO.setWFile(rs.getString("w_file"));
			    				vDTO.setWMemo(rs.getString("w_memo"));
			    				vDTO.setWDiv(rs.getString("w_div"));
			    				vDTO.setWSend(rs.getString("w_send"));
			    				vDTO.setWKind(rs.getString("w_kind"));
			    				vDTO.setWSendFile(rs.getString("w_sendfile"));
			    				vDTO.setWRegDate(rs.getString("w_regdate"));
			    				vDTO.setWAcceptDate(rs.getString("w_acceptdate"));
			                }
			                voiceDTOList.add(vDTO);
				        }catch(Exception e){
				        	e.printStackTrace() ;
				        }finally{
							if(rs!=null) rs.close();			        	
				        } 
			        }else
			        	voiceDTOList.add(null);
				}//for
				
				usedVoiceDTOList.trimToSize();
				voiceDTOList.trimToSize();
						
			}
			if(count==0) count = iList==null? 0 : iList.size();
		}catch(Exception ex){
		}finally{
			if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<ResponseTimeDTO>() ;
		ResponseTimeDTO dto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			dto = new ResponseTimeDTO();
// 			dto.setKeynumberId("0101111222"+z) ;
// 			dto.setDeptName("Dept_"+z) ;
// 			dto.setHunt(z%2==0?1:0) ;
// 			dto.setForwardNum("0601111222"+z) ;
// 			dto.setForwardType( z%5==0?2:(z%3==0?1:0) );//0:사용안함, 1:전체번호, 2:특정번호
// 			dto.setCallType(z%3==0?1:0) ;
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
<title>응답시간 관리</title>

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

<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/function_ivr.js'></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>

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
		/* function hiddenAdCodeDiv2() {
	        inf('visible'); //select box 보이기
	        setShadowDivVisible(false); //배경 layer 숨김
	    
	        document.getElementById('popup_layer').style.display="none";
	        
	        goRefresh();
	    } */
		
		//팝업
		function goPopup(type){

		    var parm = '&type='+type;		//get형식으로 변수 전달.
			//var url = "<%=StaticString.ContextRoot%>/voiceListPopupForm.do2";
			var url = "<%=StaticString.ContextRoot+pageDir%>/ivr_respmode/voiceListPopup.jsp";
			getPage2(url,parm);
		}
	    function goPopup2(time1,time2,scCode,trIdx,type){
	        var parm = '&time1='+time1+'&time2='+time2+'&scCode='+scCode+"&trIdx="+trIdx+"&type="+type;		//get형식으로 변수 전달.
	    	//var url = "<%=StaticString.ContextRoot%>/responseTimeEditPopupForm.do2";
	    	var url = "<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeEditPopup.jsp";
	    	getPage2(url,parm);
	    }
	    
		function getPage2(url, parm){
			inf('hidden');
			engine.execute("POST", url, parm, "ResgetPage2");
		}
		function ResgetPage2(data){
			//alert(data);
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
			obj.style.top = '170px';
		    obj.style.left = '550px';
			    
			SET_DHTML('popup_layer2');
			//document.getElementById('popup_layer').style.display="none";	    //
		}
		function hiddenAdCodeDiv2() {
			inf('visible'); //select box 보이기
			//setShadowDivVisible(false); //배경 layer 숨김
			//document.getElementById('popup_layer').style.display="block";	// layer1 보이기
			document.getElementById('popup_layer2').style.display="none";

		}
		
		/**
		 * 새로고침
		 */ 
		function goRefresh() 
		{
			//var f = document.frm;
			//f.action = "<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageList.jsp?page=<%=nNowpage%>";
			//f.submit();		
			location.href="<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageList.jsp?page=<%=nNowpage%>";
		}
		

/**
 * 
 */
		var aResponseList = new Array(<%=responseModeDTOList.size()%>);

		for(var i=0; i < <%=responseModeDTOList.size()%>; i++)	{
			aResponseList[i] = new Array(26);
		}
	<%
	    for(int i=0; i < responseModeDTOList.size(); i++) {
	%>
	    aResponseList[<%=i%>][0] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>";
	    aResponseList[<%=i%>][1] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%>";
	    aResponseList[<%=i%>][2] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScVoiceFile()%>";
	    aResponseList[<%=i%>][3] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScHour()%>";
	    aResponseList[<%=i%>][4] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScAgain()%>";
	    aResponseList[<%=i%>][5] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScMakeCallTime()%>";
	    aResponseList[<%=i%>][6] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCidRoute()%>";
	    aResponseList[<%=i%>][7] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyTo()%>";
	    aResponseList[<%=i%>][8] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyA()%>";
	    aResponseList[<%=i%>][9] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyB()%>";
	    aResponseList[<%=i%>][10] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyC()%>";
	    aResponseList[<%=i%>][11] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyD()%>";
	    aResponseList[<%=i%>][12] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getDgCheck()%>";
	    aResponseList[<%=i%>][13] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey1()%>";
	    aResponseList[<%=i%>][14] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey2()%>";
	    aResponseList[<%=i%>][15] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey3()%>";
	    aResponseList[<%=i%>][16] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey4()%>";
	    aResponseList[<%=i%>][17] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey5()%>";
	    aResponseList[<%=i%>][18] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey6()%>";
	    aResponseList[<%=i%>][19] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey7()%>";
	    aResponseList[<%=i%>][20] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey8()%>";
	    aResponseList[<%=i%>][21] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey9()%>";
	    aResponseList[<%=i%>][22] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKey0()%>";
	    aResponseList[<%=i%>][23] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeyAs()%>";
	    aResponseList[<%=i%>][24] = "<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScKeySh()%>";
	    aResponseList[<%=i%>][25] = "<%=usedVoiceDTOList.get(i) != null ? ((VoiceDTO)voiceDTOList.get(i)).getWName() : ""%>";
	<%
	    }
	%>


		var aHourList = new Array(<%=hourList.size()%>);

	<%
	    for(int i=0; i < hourList.size(); i++) {
	%>
	    aHourList[<%=i%>] = "<%=(String)hourList.get(i)%>";
	<%
	    }
	%>


		var aMinuteList = new Array(<%=minuteList.size()%>);

	<%
	    for(int i=0; i < minuteList.size(); i++) {
	%>
	    aMinuteList[<%=i%>] = "<%=(String)minuteList.get(i)%>";
	<%
	    }
	%>
		
		//시간별 응답모드 추가
		function insertTime(type){

			var time1 = document.getElementById("time1").value;
			var time2 =	document.getElementById("time2").value;
			var naScCodeValue =	document.getElementById("naScCode").value;
			var	selectIndex = document.getElementById("naScCode").options.selectedIndex;
			var naScCodeText = document.getElementById("naScCode").options[selectIndex].text;
			var totalTime = time1 + ":" + time2 + "부터";


			var tdBgcolor = document.getElementsByName("tdHidden5");
			var trTime1 = document.getElementsByName("tdHidden1");
			var trTime2 = document.getElementsByName("tdHidden2");
			var trScCode = document.getElementsByName("tdHidden4");
			var tdBgcolorCount = 0;

			var subTrCount = document.getElementsByName("subTr").length;	//tr갯수

			var creTr = document.createElement("tr");				//tr
			creTr.id = "subTr";
			creTr.setAttribute("name", "subTr");

			//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
			//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(243,247,245)";};

			for(var i=0;i<tdBgcolor.length;i++){
				if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
				{
					tdBgcolorCount = tdBgcolorCount + 1;
					if(time1 == trTime1[i].value && time2 == trTime2[i].value && naScCodeValue == trScCode[i].value) {
						alert("이미 추가된 설정입니다.");
						return;
					} else if(time1 == trTime1[i].value && time2 == trTime2[i].value) {
						alert("이미 추가된 시간입니다.");
						return;
					}

				}
			}


			if( tdBgcolorCount % 2  == 0 ){
				creTr.style.cssText = "background-color:#F3F9F5";
				//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(243,247,245)";};
				//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
			}else{
				creTr.style.cssText = "background-color:rgb(255,255,255)";
				//creTr.onmouseout = function() {creTr.style.cssText = "background-color:rgb(255,255,255)";};
				//creTr.onmouseover = function() {creTr.style.cssText = "background-color:rgb(254,209,142)";};
			}


			var creTd = document.createElement("td");				//td
			creTd.style.cssText = "border-right:1 solid #cbcbcb;padding-top:2; text-align:center";
			creTd.id = "tdIdx";
			//creTd.name = "tdIdx";
			creTd.setAttribute("name", "tdIdx");

			var creText = document.createTextNode(totalTime);		//text

			var creHidden = document.createElement("input");		//hidden
			creHidden.type = "hidden";
			creHidden.name = "tdHidden1";
			creHidden.id = "tdHidden1";
			creHidden.value = time1;

			var creHidden2 = document.createElement("input");		//hidden
			creHidden2.type = "hidden";
			creHidden2.name = "tdHidden2";
			creHidden2.id = "tdHidden2";
			creHidden2.value = time2;

			var creTd2 = document.createElement("td");				//td
			creTd2.style.cssText = "border-right:1 solid #cbcbcb;padding-top:2; text-align:center";
			creTd2.id = "tdIdx2";
			creTd2.name = "tdIdx2";
			var creText2 = document.createTextNode(naScCodeText);	//text

			var creHidden3 = document.createElement("input");		//hidden
			creHidden3.type = "hidden";
			creHidden3.name = "tdHidden3";
			creHidden3.id = "tdHidden3";
			creHidden3.value = naScCodeText;

			var creTd3 = document.createElement("td");				//td
			creTd3.align = "center";

			var creImg = document.createElement("img");				//img
			creImg.name = "editImg";
			creImg.id = "editImg";
			creImg.src = "<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif";
			creImg.width = "34";
			creImg.height = "18";
			creImg.border = "0";
			creImg.align = "absmiddle";
			//alert(document.getElementsByName("tdHidden4")[tdBgcolor.length]);
			//if(tdBgcolor.length == 0)
			    creImg.onclick = function(){goPopup2(time1,time2,naScCodeValue,subTrCount+1,type);};
			//else
			//    creImg.onclick = function(){goPopup2(time1,time2,document.getElementsByName("tdHidden4")[tdBgcolor.length].value,subTrCount+1,type);};
			creImg.onmouseout = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif");};
			creImg.onmouseover = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif");};
			creImg.style.cssText = "cursor:hand";

			var creText3 = document.createTextNode(" ");			//text

			var creImg2 = document.createElement("img");			//img
			creImg2.src = "<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif";
			creImg2.width = "34";
			creImg2.height = "18";
			creImg2.border = "0";
			creImg2.align = "absmiddle";
			creImg2.onclick = function(){deleteTime(subTrCount+1);};
			creImg2.style.cssText = "cursor:hand";
			creImg2.onmouseout = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif");};
			creImg2.onmouseover = function(){fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif");};

			var creHidden4 = document.createElement("input");		//hidden
			creHidden4.type = "hidden";
			creHidden4.name = "tdHidden4";
			creHidden4.id = "tdHidden4";
			creHidden4.value = naScCodeValue;

			var creHidden5 = document.createElement("input");		//hidden
			creHidden5.type = "hidden";
			creHidden5.name = "tdHidden5";
			creHidden5.id = "tdHidden5";
			creHidden5.value = "I";

			var creHidden6 = document.createElement("input");		//hidden
			creHidden6.type = "hidden";
			creHidden6.name = "tdHidden6";
			creHidden6.id = "tdHidden6";
			creHidden6.value = "0";


			creTd.appendChild(creText);
			creTd2.appendChild(creText2);
			creTd3.appendChild(creImg);
			creTd3.appendChild(creText3);
			creTd3.appendChild(creImg2);
			creTr.appendChild(creHidden);
			creTr.appendChild(creHidden2);
			creTr.appendChild(creHidden3);
			creTr.appendChild(creHidden4);
			creTr.appendChild(creHidden5);
			creTr.appendChild(creHidden6);

			creTr.appendChild(creTd);
			creTr.appendChild(creTd2);
			creTr.appendChild(creTd3);

			document.getElementById("subTbody").appendChild(creTr);

			//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = document.getElementById("responseTimeDiv").innerHTML;

		}
		//시간별 응답모드 삭제
		function deleteTime(num){
			document.getElementsByName("tdHidden5")[num-1].value = "D";
			document.getElementsByName("subTr")[num-1].style.display = "none";

			var tdBgcolor = document.getElementsByName("tdHidden5");

			var j = 0;
			for(var i=0;i<tdBgcolor.length;i++){

				if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
				{

					if( j % 2  == 0 ){
						document.getElementsByName("subTr")[i].style.cssText = "background-color:rgb(255,255,255)";
					}
					else{
						document.getElementsByName("subTr")[i].style.cssText = "background-color:#F3F9F5";
					}

					j = j +1

				}

			}

			//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = document.getElementById("responseTimeDiv").innerHTML;
		}
		
		//아이프레임 비우기
		function iframeClean(){
			if(1==1) return;
			responseTimeIframe.document.getElementById("responseTimeIframeDiv").innerHTML = "";
			//responseTimeIframe.document.getElementById("responseTimeIframeDiv2").innerHTML = "";
		}
		
		//아이프레임 비우기
		function editTime(strType, strTrIdx, strNewTime1, strNewTime2, strNewScCode, strNewScName) {

			var tdBgcolor = document.getElementsByName("tdHidden5");
			var trTime1 = document.getElementsByName("tdHidden1");
			var trTime2 = document.getElementsByName("tdHidden2");
			var trScCode = document.getElementsByName("tdHidden4");
			var tdBgcolorCount = 0;

			var subTrCount = document.getElementsByName("subTr").length;	//tr갯수

			var creTr = document.createElement("tr");				//tr
			creTr.id = "subTr";
			creTr.setAttribute("name", "subTr");

			for(var i=0;i<tdBgcolor.length;i++){
				if( i != strTrIdx-1) {
					if( tdBgcolor[i].value == "O" || tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
					{
						tdBgcolorCount = tdBgcolorCount + 1;
						if(strNewTime1 == trTime1[i].value && strNewTime2 == trTime2[i].value && strNewScCode == trScCode[i].value) {
							alert("이미 추가된 설정입니다.");
							return;
						} else if(strNewTime1 == trTime1[i].value && strNewTime2 == trTime2[i].value) {
							alert("이미 추가된 시간입니다.");
							return;
						}
					}
				}
			}

			document.getElementsByName("tdIdx")[strTrIdx-1].innerHTML = strNewTime1 + ":" + strNewTime2 + "부터";
			document.getElementsByName("tdIdx2")[strTrIdx-1].innerHTML = strNewScName;

			document.getElementsByName("tdHidden1")[strTrIdx-1].value = strNewTime1;
			document.getElementsByName("tdHidden2")[strTrIdx-1].value = strNewTime2;
			document.getElementsByName("tdHidden3")[strTrIdx-1].value = strNewScName;
			document.getElementsByName("tdHidden4")[strTrIdx-1].value = strNewScCode;
			if(strType == "ADD_FORM")
			    document.getElementsByName("tdHidden5")[strTrIdx-1].value = "I";
			else
				document.getElementsByName("tdHidden5")[strTrIdx-1].value = "E";

			var editImg = document.getElementsByName("editImg");
			editImg[strTrIdx-1].onclick = function() {goPopup2(strNewTime1,strNewTime2,strNewScCode,strTrIdx,strType);};

			hiddenAdCodeDiv2();
		}
		
		/**
		 * 신규입력 화면으로 이동
		 */
		function showInsert(p_E164, p_Param){
		    var parm 	= '';//(p_E164?'&e164='+p_E164:'')+(p_Param?'&userparam='+p_Param:'');
		    var url 	= 'responseTimeManageInput.jsp';

		    getPage(url,parm);
		}

		// 추가
		function add() {
			var frm = document.addForm;

			if(!blankValueMsg("addForm","amModeName","응답스케줄 이름을 입력하세요."))
			{
				return false;
			}

			var tdBgcolor = document.getElementsByName("tdHidden5");
			var totalCnt = 0;

			var rowCnt = document.getElementsByName("subTr").length;	//tr갯수

			for(var i=0; i < rowCnt; i++){
				if(tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" )
				{
					totalCnt += 1;
				}
			}

			if(totalCnt == 0) {
				alert("응답스케줄의 시간 및 응답모드 설정을 해주세요.");
				return;
			}
			
			hiddenAdCodeDiv();

			frm.target = "procframe";
			frm.action="<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageInputPro.jsp"
			frm.submit();
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
		function showEdit(p_amIndex){
			var parm 		= "&amIndex="+p_amIndex;		//get형식으로 변수 전달.
		    var url 		= 'responseTimeManageEdit.jsp';
		    getPage(url,parm);	
		}
		
		/**
	     * 수정 저장
	     */
	     function goEdit() {
	    	 var frm = document.editForm;

    		if(!blankValueMsg("editForm","amModeName","응답스케줄 이름을 입력하세요."))
    		{
    			return false;
    		}

    		var tdBgcolor = document.getElementsByName("tdHidden5");
    		var totalCnt = 0;

    		var rowCnt = document.getElementsByName("subTr").length;	//tr갯수

    		for(var i=0; i < rowCnt; i++){
    			if(tdBgcolor[i].value == "E" || tdBgcolor[i].value == "I" || tdBgcolor[i].value == "O")
    			{
    				totalCnt += 1;
    			}
    		}

    		if(totalCnt == 0) {
    			alert("응답스케줄의 시간 및 응답모드 설정을 해주세요.");
    			return;
    		}

    		hiddenAdCodeDiv();

    		frm.target = "procframe";
			frm.action="<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageEditPro.jsp";
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
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _key, _td;
			//alert('length='+_len);
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
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
        function showDelete(){
        	 var f   = document.frm;
             var str = "";
             if(f != undefined && f.chkOpt != undefined){
             	str = setE164BySelected();
             }
             
             var deleteCheck = "Y";
             if( str.length == 0 )
            	 deleteCheck = "N";
             
            var parm 	= ('&deleteStr='+str +'&deleteCheck='+deleteCheck);		//get형식으로 변수 전달.;
            //var url 	= 'responseModeManageDelete.jsp';
            var url 	= 'responseTimeManageDelete.jsp';
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
            f.action = "<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeManageDeleteAllPro.jsp";
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
	                	if(_td) _td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction(0, '"+_e164+"', 0)\" >";
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
                    var parm = '&titlemsg='+'대표번호 착신전환 설정'+'&msg='+'대표번호 착신전환을 사용하지 않는 상태입니다.';
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
                    var parm = '&titlemsg='+'대표번호 착신전환 설정'+'&msg='+'대표번호 착신전환 설정을 추가하여 주십시오.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'대표번호 착신전환 설정'+'&msg='+'대표번호 착신전환을 사용하고 있습니다.';
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
                var parm = '&titlemsg='+'대표번호 착신전환 설정'+'&msg='+'검색 목록이 없습니다.';
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
                    var parm = '&titlemsg='+'대표번호 착신전환 설정'+'&msg='+processname+'할 항목을 선택하여 주십시오.';
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
		function func_setAction(action, key, param) {
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
		<% int menu = 4, submenu = 2; %>
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'responseTimeManageList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'responseTimeManageList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="등록" onclick="func_setAction(0,'','')">
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
                  <td width="200" onclick="function(){ if(1==1)return; sortNow(0,true);changeTitle(0); };" id="mainnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">응답스케줄 이름<!-- <b>응답 대표번호 ▲</b> --></td>
                  <td width="435" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">응답스케줄 설명</td>
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
		ResponseTimeDTO dto= null;
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (ResponseTimeDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					%>	
					  <%-- <tr id=g<%=idx%> height="22" bgcolor="E7F0EC" align="center" onmouseover='this.style.backgroundColor="E7F0EC"' onmouseout='this.style.backgroundColor="E7F0EC"' > --%>
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="58" class="table_column"> 
		                	<input type="checkbox" name="chkOpt" value="" onClick="checkNonDup(this);" >
		                </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="0" id='h<%=idx%>_0' style='display: none;'><%=dto.getAmIndex()%></td>
		                <td width="200" id='h<%=idx%>_1' class="table_column"><%=dto.getAmModeName()%></td>
		                <td width="435" id='h<%=idx%>_2' class="table_column">&nbsp;<%=dto.getAmMemo()%></td>
		                <%-- <td width="100" id='h<%=idx%>_3' class="table_column"></td> --%>
		                <td width="60" id='h<%=idx%>_3' class="table_column">
		                	<%-- <input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction(0, '<%=dto.getKeynumberId()%>', '<%=dto.getForwardType()%>')"> --%>
		                	<a href="#" onclick="javascript: func_setAction(2, '<%=dto.getAmIndex()%>', '');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=dto.getAmIndex()%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)">
		                		<img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=dto.getAmIndex()%>" width="34" height="18" border="0">
		                	</a>
		                </td>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
	out.println("<script type=\"text/JavaScript\"> sortNow(1,true); </script>") ;//번호 정렬
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="responseTimeManageList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="responseTimeManageList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"responseTimeManageList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="responseTimeManageList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="responseTimeManageList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
<iframe id="responseTimeIframe" src="<%=StaticString.ContextRoot+pageDir%>/ivr_resptime/responseTimeIframe.jsp" width="0" height="0"></iframe>

