<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
<%@page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
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

<%@ page import="java.sql.ResultSet"%>

<%
	String pageDir = "";//"/ems";
	int nModeDebug = 0, nModePaging = 0/* 1 : paging */;//config option

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
	 
	 int count = 0; 
	
	String 	s_EnendPointID	= "";//request.getParameter("hiddenEnendPointID");	// 검색조건 ID
	String 	s_E164			= "";//request.getParameter("hiddenE164");			// 검색조건 번호
	String 	s_Name			= "";//request.getParameter("hiddenName");			// 검색조건 이름
 	String 	search_gubun	= "";//StringUtil.null2Str(request.getParameter("hiddenSearch_gubun"),"1");	// 검색구분
 	String 	search_field	= "";//new String (Str.CheckNullString(request.getParameter("hiddenSearch_field")).getBytes("8859_1"), "euc-kr");
 	String  goodsName = "", maxE164="";
 	
		ArrayList 		iList = null;
		ArrayList<ArrayList<UsedVoiceDTO>> usedVoiceDTOList = null;
		
		String sql="";
        ResultSet rs = null;
		DataStatement 	stmt = null;
		if(nModeDebug!=1){
			try{
				if(nAllowUser==1){		
			        
					VoiceDTO 		ipcsListDTO;
					iList 	= new ArrayList<VoiceDTO>();
					//if (GroupID == 0) return addrBookList;
			        //System.out.println("받은 endpointid : "+endpointid);
			        
// 			        sql = "SELECT sc_company, ivr_tel, auth_id from NASA_TRUNK_SET ";
//         			sql = sql + " Where ivr_tel <> 'anonymous' AND trunk_type = 'N' ";
//         			sql = sql + " Order by tr_idx ";
        			
        			sql =  "SELECT w_index, COALESCE(server_ip, '') as server_ip, COALESCE(w_name, '') as w_name, COALESCE(w_file, '') as w_file,           \n";
        			sql +=  "COALESCE(w_memo, '') as w_memo, COALESCE(w_div, '') as w_div, COALESCE(w_send, '') as w_send, COALESCE(w_kind, '') as w_kind,  \n";
        			sql +=  "COALESCE(w_sendfile, '') as w_sendfile, COALESCE(w_regdate, '') AS w_regdate, COALESCE(w_acceptdate, '') AS w_acceptdate       \n";
        			sql +=  "FROM NASA_WAV   \n";
       				sql +=  "WHERE w_div LIKE '%U%' \n";
        			sql +=  "order by w_index  ";
        			
			        /* 
			        if(authGroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+authGroupid+"' ";
			        */
			        
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        try {
			        	 System.out.println("Query : "+sql);
			        	 String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
			        	 stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID) ;
			        	 rs = stmt.executeQuery(sql);
						/* for (int i = 0 ; i < 3 ; i++ ) {
							stmt = ConnectionManager.allocStatement("SSW") ;
							if (stmt == null) {
								Thread.sleep(100) ;
								System.out.println("stmt is null");
								continue ;
							}
			                rs = stmt.executeQuery(sql);
							if ( rs == null ) {
						    	ConnectionManager.freeStatement(stmt);
								Thread.sleep(100) ;
								System.out.println("======>00");
								continue ; 
							}
							break ;
						} */
			                
// 			                String[]    strOpt  = null;
// 			                String 		loginID	= "";
			                while (rs.next()) {
			                	ipcsListDTO = new VoiceDTO();
								ipcsListDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
								ipcsListDTO.setServerIp(rs.getString("server_ip"));
								ipcsListDTO.setWName(rs.getString("w_name"));
								ipcsListDTO.setWFile(rs.getString("w_file"));
								ipcsListDTO.setWMemo(rs.getString("w_memo"));
								ipcsListDTO.setWDiv(rs.getString("w_div"));
								ipcsListDTO.setWSend(rs.getString("w_send"));
								ipcsListDTO.setWKind(rs.getString("w_kind"));
								ipcsListDTO.setWSendFile(rs.getString("w_sendfile"));
								ipcsListDTO.setWRegDate(rs.getString("w_regdate"));
								ipcsListDTO.setWAcceptDate(rs.getString("w_acceptdate"));
								//voiceDTOList.add(ipcsListDTO);
			                	iList.add(ipcsListDTO);
			                }
			        }catch(Exception e){
			        	e.printStackTrace() ;
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
			        
					//int 		iCount 			= iList.size();
			        try{
			        	if(nModePaging==1){
			                sql =  "SELECT count(*) \n";
		        			sql +=  "FROM NASA_WAV   \n";
		       				sql +=  "WHERE w_div LIKE '%U%' \n";
		        			sql +=  "order by w_index  ";
		        			
					        //if(authGroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+authGroupid+"' ";
					        System.out.println("totalcount.sql : "+sql);
					        rs = stmt.executeQuery(sql);
			                while (rs.next()){
			                	count = rs.getInt(1) ;
			                }
			                System.out.println("totalcount="+count);
			                if(rs!=null) rs.close();
			        	}	
			        }catch(Exception ex){}finally{if(rs!=null) rs.close();}
			        
					usedVoiceDTOList 	= new ArrayList<ArrayList<UsedVoiceDTO>>();
					ArrayList usedWaveList;
					for(int i=0; i< iList.size(); i++){
						sql =  "SELECT nwu_idx, w_index, nwu_type, nwu_filename, nwu_definition, ns_idx \n";
	       				sql +=  "FROM nasa_wave_use \n";
	       				sql +=  "WHERE w_index = "+ ((VoiceDTO)iList.get(i)).getWIndex() +" \n";
	        			sql +=  "ORDER BY nwu_type ";
	        			
	        			usedWaveList = new ArrayList();
				        try {
				        	 System.out.println("Query : "+sql);
				        	 rs = stmt.executeQuery(sql);
			                while (rs.next()) {
			                	UsedVoiceDTO uvDTO = new UsedVoiceDTO();
								uvDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
								uvDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
								uvDTO.setNwuType(rs.getString("nwu_type"));
								uvDTO.setNwuFileName(rs.getString("nwu_filename"));
								uvDTO.setNwuDefinition(rs.getString("nwu_definition"));
								uvDTO.setNsIdx(String.valueOf(rs.getInt("ns_idx")));
								usedWaveList.add(uvDTO);
			                }
			                usedVoiceDTOList.add(usedWaveList);
				        }catch(Exception e){
				        	e.printStackTrace() ;
				        }finally{
							if(rs!=null) rs.close();			        	
				        }
					}//for
					usedVoiceDTOList.trimToSize();
				}
				if(count==0) count = iList==null? 0 : iList.size();
//	 			values = new String[count][3];
			}catch(Exception ex){
				ex.printStackTrace() ;
			}finally{
				if (stmt != null) ConnectionManager.freeStatement(stmt);
			}
		}else if(nAllowUser==1){
			iList = new ArrayList<VoiceDTO>() ;
//	 		HashMap smpitem;
			VoiceDTO mrbtDTO = null;
			for(int z=0; z<nMaxitemcnt; z++){
				mrbtDTO = new VoiceDTO();
// 				mrbtDTO.setScCompany("0101111222"+z) ;
// 				mrbtDTO.setIvrTel("0101111222"+z) ;
// 				mrbtDTO.setAuthId("test_"+z) ;
// 				mrbtDTO.setDept("testDept_"+z) ;
// 				mrbtDTO.setFilename(z%5==0?"3":(z%3==0)?"1":"0");//0:사용안함, 1:전체번호, 3:특정번호
// 				mrbtDTO.setUsechk(z%2==0?1:0) ;
				//mrbtDTO.put("totalcnt", "25") ;
				iList.add(mrbtDTO);
			}
			count = iList.size();//nMaxitemcnt ;
			nTotalpage = 25;
			if(nNowpage >= nTotalpage) count = 4;
//	 		values = new String[count][3];
		}
		
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
<link href="olleh.ico" rel="icon" type="image/x-icon" />
<link href="olleh.ico" rel="shortcut icon" type="image/x-icon" />

<title>음성파일 관리</title>

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
        SetCookie("id_cookie_ipcs",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_ipcs",document.loginForm.id.value);
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

function func_init_ipcs() {
	var groupid = <%=authGroupid%>;
	//if(groupid) SetCookie("id_cookie_ipcs", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_ipcs", '');
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

function onlyNumber(event) {
    var key = window.event ? event.keyCode : event.which;    

    if ((event.shiftKey == false) && ((key  > 47 && key  < 58) || (key  > 95 && key  < 106)
    || key  == 35 || key  == 36 || key  == 37 || key  == 39  // 방향키 좌우,home,end  
    || key  == 8  || key  == 46 ) // del, back space
    ) {
        return true;
    }else
        return false;
}

//-->
</script>
<!-- function file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
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
		

		/////////////////////// Edit

		/**
		 * 수정화면으로 이동
		 */
		function showEdit(p_windex){
			var parm 		= '&wIndex='+p_windex;		//get형식으로 변수 전달.
		    var url 		= 'voiceFileManageEdit.jsp';

		    getPage(url,parm);			
		}

		/**
		 * 수정 내용 저장하기
		 */
		function goEdit(){
			var f = document.editForm;
		    			
			f.action="<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageEditPro.jsp";

			f.target = "procframe";
			f.method="post";
			f.submit();
		}
		
		function goEditDone(datas){//paramWIndex, paramWName, paramFileName (, paramStarttime)
			if(1==1){
				goRefresh(); return;
			}
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _key, _td;
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))//paramWIndex
			  {
			  	_key = _p.innerHTML ;
			  	
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_key) {
	 					<%-- _td = document.getElementById("imgStus"+_i) ;//state
 						if(_td){
 							if(datas[z].params[3] && datas[z].params[3].length>0){
 								_td.onclick = "javascript:goUnRegister('"+datas[z].params[1]+"');";
 					     		if(datas[z].params[5]=='1' || datas[z].params[5]=='3'){
	 		                		_td.src = "<%=StaticString.ContextRoot%>/imgs/forward_img.png";
	 		                		_td.alt = "무조건 착신전환";
 					     		}else if(datas[z].params[5]=='2'){
 		 		                	_td.src = "<%=StaticString.ContextRoot%>/imgs/forward_img.png";
 		 		                	_td.alt = "조건부 착신전환";
 	 					     	}else {
 		 		                	_td.src = "<%=StaticString.ContextRoot%>/imgs/on_img.png";
 		 		                	_td.alt = "등록완료";
 	 					     	}
 		                	}else{
 		                		_td.onclick = "";
 		                		_td.src = "<%=StaticString.ContextRoot%>/imgs/off_img.png";
 		                		_td.alt = "미등록";
 		                	}
 						} --%>
	 					_td = document.getElementById("h"+_i+"_0") ;
 						if(_td)	_td.innerHTML = datas[z].params[1];//paramWName
 						
 						_td = document.getElementById("h"+_i+"_1") ;
 						if(_td)	_td.innerHTML = "<a style='color:black' href='<%
 								if(1==1){
	 								String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
	 								String print_html = "/MS/"+sesSysGroupName;
	 								out.print(print_html);
 								}
 								%>/ipcs_files/fileupwav/"+datas[z].params[2]+"'>"+datas[z].params[2]+"</a>";//datas[z].params[2];//paramFileName
 						
 						_td = document.getElementById("h"+_i+"_2") ;
 						if(_td)	_td.innerHTML = datas[z].params[3];//paramStarttime
 						
	 					if(++_idx == _len){
		 					return ;
	 					}
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
		/////////////////////// Insert
		
		/**
		 * 신규입력 화면으로 이동
		 */
		function showInsert(/* p_E164, p_Param */){
			var parm 	= "";//(p_E164?'&maxE164='+p_E164:'')+(p_Param?'&e164='+p_Param:'');
		    var url 	= 'voiceFileManageInput.jsp';		    
			
			/* if (iCount == 100){
				alert("음성안내 번호를  100개 이상 만들수 없습니다!");
				return;
			} */

		    getPage(url,parm);			
		}
		function goInsertPro(){
			var frm = document.addForm;

			if(frm.wName.value == "")
			{
				alert("음성제목을 입력하세요.");
				return;
			}

			if(frm.wFile.value == "")
			{
				alert("음성파일을 선택하세요.");
				return;
			}
			
			frm.action="<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageInputPro.jsp";
		   	
			frm.target = "procframe";
			frm.method="post";
			frm.submit();	
		}
		
    	/** 신규입력 후 출력 **/
		function goInsertDone(datas){
    		if(1==1){
    			goRefresh(); return;
    		}
			//document.location.href = 'voiceFileManageList.jsp';
			if(datas.length > 0)
				additem(0, datas[0].params[0], datas[0].params[1], datas[0].params[2], datas[0].params[3]) ;
		}
		function additem(idx, paramWIndex, paramWName, paramFileName, paramStarttime) {
			var t_new_tr = document.createElement('TR');	
			var t_table = document.getElementById('tb_list');	//area_tb_list
			var old_items_html = t_table.innerHTML;

			var count_tr = idx>0?idx:t_table.getElementsByTagName("TR").length;
			//alert('count :'+count_tr);
				t_new_tr.id = "g"+count_tr;
				t_new_tr.height = "22px";
				t_new_tr.onmouseover = function(){ this.style.backgroundColor="#E7F0EC"; };
				if(count_tr*1%2==0)	t_new_tr.onmouseout = function(){ this.style.backgroundColor="#F3F9F5"; };
				else				t_new_tr.onmouseout = function(){ this.style.backgroundColor="#fcfcfc"; };
				//t_new_tr.bgcolor = count_tr*1%2==0?"#F3F9F5":"#fcfcfc";//"E7F0EC";
				t_new_tr.style.backgroundColor = count_tr*1%2==0?"#F3F9F5":"#fcfcfc";//"E7F0EC";
				t_new_tr.align = "center";
				t_new_tr.innerHTML = "";
			
				var strTag = "";
				//"<TR>"
		        //"<tr id=g"+count_tr+" height=\"22\" bgcolor=\"E7F0EC\" align=\"center\" >";
		        strTag += "<td width=\"45\" class=\"table_column\">"+ (count_tr+<%=nModePaging==1 ? nNowpage*nMaxitemcnt+1 : 1 %>) +"</td>";
		        strTag += "<td width=\"150\" id='h"+count_tr+"_0' class=\"table_column\">"+paramWName+"</td>";
		        strTag += "<td width=\"100\" id='h"+count_tr+"_1' class=\"table_column\"> <a style='color:black' href='<%
		        		if(1==1){
		        			String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
			        		String print_html = "/MS/"+sesSysGroupName;
			        		out.print(print_html);	
		        		}
		        		%>/ipcs_files/fileupwav/"+paramFileName+"'>"+paramFileName+"</a></td>";
		        strTag += "<td width=\"150\" id='h"+count_tr+"_2' class=\"table_column\">"+paramStarttime+"</td>"; 
		        strTag += "<td width=\"120\" id='h"+count_tr+"_3' class=\"table_column\"> </td>"; //blank
		        strTag += "<td width=\"120\" id='h"+count_tr+"_4' class=\"table_column\">"; //btn
			        strTag += " <input type=\"button\" name=\"btnActionMdi\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction(0, '"+paramWIndex+"')\"> ";
			        strTag += "&nbsp;<input type=\"button\" name=\"btnActionDel\" style=\"height: 18px\" value=\"삭제\" onclick=\"func_setAction(1, '"+paramWIndex+"', '"+paramFileName+"')\"> ";
			    strTag += "</td>";
			    strTag += "<td class=\"table_column\">&nbsp;</td>";
			  	//+ "</TR>'
	        
			  	t_new_tr.innerHTML = strTag;
				  	
			    t_table.innerHTML = '';
				t_table.appendChild(t_new_tr);	
				t_table.innerHTML = t_table.innerHTML + old_items_html;
				
			return count_tr;		
		}
		
		/////////////////////// Delete
		
		/**
		 * 삭제처리 화면으로 이동
		 */
		function showDelete(p_wIndex, p_wFile){
		    var parm 				= '&wIndex='+p_wIndex +'&wFileName='+p_wFile ;		//get형식으로 변수 전달.
		    var url 				= 'voiceFileManageDelete.jsp';
		    
		    getPage(url,parm);
		}

		/**
		 * 삭제 처리 하기
		 */
		function goDelete(){		
			var f 				= document.delForm;
			
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
            
		   	f.action="<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageDeletePro.jsp";
		   	
		   	f.target = "procframe";
		   	f.method="post";
		   	f.submit();			
		} 
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			if(1==1){
				goRefresh(); return;
			}
			var _o=null, _p=null;
			var _i = 0;
			var _table = document.getElementById("tb_list");
			var _len = _table.getElementsByTagName('tr').length;
			var _lc = _table.lastChild ;
			while(_lc)
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
				  if(datas[0].params[0]==_p.innerHTML){ //alert(_p.innerHTML);
					  //var _row =document.getElementById("h"+_i+"_0"))
					  delitem(_p); 
					  return ;
				  }
			  }
			  
			  _o=document.getElementById("g"+_i) ;
			  if(_lc==_o || _i > _len) return ;
			  
			  _i++;
			}
		}
		function delitem(td) {	
			var i = td.parentNode.rowIndex;
			document.getElementById("tb_list").deleteRow(i);
		}
		
		// 해제
		function unReg(subject, nwuIdx, wIndex)
		{
			var delstr;
			delstr = subject + "을 해제하시겠습니까?";

			if(confirm(delstr))
			{
				//document.location.href = "./voiceFileMnageUnReg.do2?nwuIdx=" + nwuIdx;
				//document.location.href = "voiceFileManageUnRegPro.jsp?nwuIdx=" + nwuIdx +"&wIndex=" + wIndex ;
				document.procframe.location.href = "<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageUnRegPro.jsp?nwuIdx="+ nwuIdx +"&wIndex="+ wIndex; 
			}
		}
		
		/////////////////////// 
		
		/**
		 * 새로고침
		 */ 
		function goRefresh() 
		{
			var f = document.frm;
			f.action = "<%=StaticString.ContextRoot+pageDir%>/ivr_mngr/voiceFileManageList.jsp";
			f.submit();
			//history.go(0);
		}
		
///////////////////////
		
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
		function func_setAction(action, num, param) {
        	if(num) document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			switch(action){
				case 0://수정
					showEdit(num, param);
					break;
				case 1://삭제
					showDelete(num, param);
					break;
				case 2://추가
					showInsert();					
					break;
				case 3://변경
					var num1 = "";
					var _p=null;
					var _i = 0;
					var _table = document.getElementById("tb_list");
					var _len = _table.getElementsByTagName('tr').length;
					while(_table)
					{
					  if(_p=document.getElementById("h"+_i+"_1"))
					  {
						  num1 = _p.innerHTML ; break;
					  }
					  if(_len < _i) break;
					  _i++;
					}
					//goExtNumUpdate(num1);
					break;
			}
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setActionBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('해제')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				goDelete(document.frm.e164.value) ;
			}
			else{
				if( isChecked('등록')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				goInsert(document.frm.e164.value) ;
        	}
		}
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_ipcs" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  //document.rtcForm.rtcInput.value = getTimeStamp();
			  document.location.href = 'voiceFileManageList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==1){
				if( lastSort==nField )	document.getElementById('sc_company').innerHTML = "<b>음성안내 그룹▲</b>";
				else					document.getElementById('sc_company').innerHTML = "<b>음성안내 그룹▼</b>";
				document.getElementById('telnum').innerHTML = "음성안내번호<font size='1px'>▽</font>";//△
			}
			else if(nField==2){
				if( lastSort==nField )	document.getElementById('telnum').innerHTML = "<b>음성안내번호▲</b>";
				else					document.getElementById('telnum').innerHTML = "<b>음성안내번호▼</b>";
				document.getElementById('sc_company').innerHTML = "음성안내 그룹<font size='1px'>▽</font>";//△
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
		<% int menu = 4, submenu = 4; %>
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

	<input type='hidden' name ='hiUserID'				value="<%=authGroupid%>">
	
	<input type='hidden' name ='PAGE_NUM'>
	<input type='hidden' name ='Edit_PAGE'			value="">
	<input type='hidden' name ='hiddenSearch_field' value="">
	<input type='hidden' name ='hiddenSearch_gubun'	value="">
	<input type='hidden' name ='hiddenEnendPointID' value="<%=s_EnendPointID%>">
	<input type='hidden' name ='hiddenE164' 		value="<%=s_E164%>">
	<input type='hidden' name ='hiddenName' 		value="<%=s_Name%>">
	
	<input type='hidden' name = 'hiGoodsName'		value="<%=goodsName%>">
	
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'voiceFileManageList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'voiceFileManageList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnModiExtNum" style="height: 18px" value="음성파일 추가" onclick="func_setAction(2, '');">
                  	<!-- <input type="button" name="btnUpdataExtNum" style="height: 18px" value="음성안내번호 변경" onclick="func_setAction(3);"> -->
                  	<!-- <input type="button" name="btnPutAlarm" style="height: 18px" value="선택 등록" onclick="func_setActionBySelected(0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="선택 해제" onclick="func_setActionBySelected(1)"> -->
                  	<% } %>
                  </td>
              </tr>
		  </table>
		</td>
	</tr>
      <tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="#ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="155" onclick="fucntion(){ if(1==1)return; sortNow(1);changeTitle(1); };" id="sc_company" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">음성제목<!-- <font size='1px'>▽</font> --></td>
                  <td width="160" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">파일명</td>
                  <td width="90" onclick="fucntion(){ if(1==1)return; sortNow(2,true);changeTitle(2); };" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">등록일<!-- <b>등록일▲</b> --></td>
                  <td width="160" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">현재설정</td>
                  <td width="10" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"> </td>
                  <td width="110" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><!-- 수정&nbsp;삭제 --></td>
                  <td class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
              </tr>
		  </table>
		</td>
	</tr>
	<tr>
        <td valign="top">
<!-- <div style="width:792; height:222; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">		 -->
          <table id="tb_list" width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="#ffffff" style="border:1 solid rgb(160,160,160) ">
          
<%					
	int idx=0;
	if(/* envList!=null && */ count!=0){
		nTotalpage = nModePaging==0 ? 0 : (int)(count/nMaxitemcnt);
		int endidx = nModePaging==0 ? count : (nTotalpage==nNowpage? count%nMaxitemcnt : nMaxitemcnt ) ;
		
		VoiceDTO dto= null;
		//String 	strCallTime = "";
		
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (VoiceDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					//nTotalpage =  (int)(count/nMaxitemcnt);
					%>	
					  <tr id=g<%=idx%> height="22px" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <%-- <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=dto.getIvrTel()%>" > </td>  --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="0" id='h<%=idx%>_0' style='display: none;'><%=Str.CheckNullString(dto.getWIndex())%></td>
		                <td width="150" id='h<%=idx%>_1' class="table_column"><%=Str.CheckNullString(dto.getWName())%></td>
						<td width="160" id='h<%=idx%>_2' class="table_column"><a style="color:black" href="<%
								String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
								String print_html = "/MS/"+sesSysGroupName;
								out.print(print_html);
							%>/ipcs_files/fileupwav/<%=((VoiceDTO)dto).getWFile()%>"><%=((VoiceDTO)dto).getWFile()%></a></td>
		                <td width="90" id='h<%=idx%>_3' class="table_column"><%=((VoiceDTO)dto).getWRegDate().substring(0, 10)%></td>
		                <td width="170" id='h<%=idx%>_4' class="table_column"  
<%
		if(((List)usedVoiceDTOList.get(idx)).size() > 0) {
%>
								colspan="3">
								
								<table width="270" border="0" cellspacing="0" cellpadding="0" ><!-- width = 170 + 100 -->
<%
			for(int j=0; j < ((List)usedVoiceDTOList.get(idx)).size(); j++) {
				String strTmpWKind = "";
				if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuType().equals("A")) {
					strTmpWKind = "IVR";
				} else if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuType().equals("F")) {
					strTmpWKind = "컬러링";
				} else if(((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuType().equals("S")) {
					strTmpWKind = "부가서비스";
				}
%>
									<tr>
										<td height="22" width="130" align="left" >
											&nbsp;<%=strTmpWKind+" ["+((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuDefinition()+"]"%>
										</td>
										<td width="40" align="center" >
											<img src="<%=StaticString.ContextRoot%>/imgs/intable_disarm_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_disarm_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_disarm_p_btn.gif");' style="CURSOR:hand;"  width="34" height="18" align="absmiddle" 
												onClick="javascript: unReg('<%=strTmpWKind+" ["+((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuDefinition()+"]"%>','<%=((UsedVoiceDTO)((List)usedVoiceDTOList.get(idx)).get(j)).getNwuIdx()%>','<%=dto.getWIndex()%>');" alt="현재설정에 적용된 음성파일을 해제합니다.">
										</td>
									</tr>
<%
				if(j < ((List)usedVoiceDTOList.get(idx)).size()-1) {
%>
									<tr bgcolor="rgb(203,203,203)">
										<td></td>
										<td></td>
									</tr>
<%
				}
			} // End of for
%>
								</table>
						</td>
<%
		} else {
%>
						colspan="2">&nbsp;
						</td>
						<%-- <td width="40" id='h<%=idx%>_4' class="table_column"> </td> --%>
		                <td width="100" id='h<%=idx%>_5' class="table_column">
<%
				if(((List)usedVoiceDTOList.get(idx)).size() > 0) {
					//out.print("&nbsp;");
				}else{
%>
					        	<input type="button" name="btnActionMdi" style="height: 18px" value="수정" onclick="func_setAction( 0, '<%=dto.getWIndex()%>')">
					        	&nbsp;<input type="button" name="btnActionDel" style="height: 18px" value="삭제" onclick="func_setAction( 1, '<%=dto.getWIndex()%>', '<%=dto.getWFile()%>')">
<%			
				}
%>
		                </td>
<%
		}
%>
		                
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
   	//out.println("<script type=\"text/JavaScript\"> sortNow(1,true); </script>") ;//번호 정렬
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="voiceFileManageList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="voiceFileManageList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
		       					</tr>
		       				</table> 
		       			<% } %>
		       		</td>
		       		<td colspan = 4 align="center" > 
<%					
		for(int i=(nBlockidx*nBlockcnt); i<(nBlockidx+1)*nBlockcnt && i<=nTotalpage; i++){
      			if(nNowpage==i)
      				out.print(" <b>"+(i+1)+"</b> ") ;
      			else
      				out.print(" <a href=\"voiceFileManageList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="voiceFileManageList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="voiceFileManageList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
