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

<%@ page import="dto.ipcs.IpcsDeptDTO" %>
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
					//iList	= (ArrayList)addServiceList.getKeyNumList(stmt, authGroupid);		// 데이타 조회
					IpcsDeptDTO deptNumberChangeDTO;
					iList = new ArrayList<IpcsDeptDTO>();
			
			        String sql ="\n Select a.startprefix as startprefix, a.prefixtype as prefixtype, a.endpointid as endpointid, ";
			        sql = sql + "\n b.KEYNUMBERID as keynumberid, b.KEYNUMBERDESC as keynumberdesc, b.groupID as groupID, b.hunt as hunt ";
			        sql = sql + "\n , b.QueueStartAnn as queuestartann, b.QueueEndAnn as aueueendann ";
			        sql = sql + "\n , (Select count(*) From table_keynumber Where keynumberid = a.endpointid) as e164Count ";
			        sql = sql + "\n FROM  table_KeyNumberID b LEFT OUTER JOIN table_localprefix a ";
			        sql = sql + "\n ON a.endpointid = b.KEYNUMBERID ";
			        //if(authGroupid!=null) sql = sql +  "\n WHERE b.groupid = '"+authGroupid+"' ";
			        if(authGroupid!=null) sql += "\n WHERE b.groupid = '"+authGroupid+"' and a.prefixtype = 4 ";
			        else sql += "\n WHERE a.prefixtype = 4 ";
			        
			        sql = sql +  "\n Order by b.keynumberid ";
			
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        ResultSet rs = null;
			        try {
			        	System.out.println("KeyNum start ");
			        	rs = stmt.executeQuery(sql);
			            System.out.println("KeyNum : "+sql);
			            while (rs.next()) {
			              	deptNumberChangeDTO = new IpcsDeptDTO();
			               	deptNumberChangeDTO.setEndpointid(Str.CheckNullString(rs.getString("endpointid")));
			               	deptNumberChangeDTO.setKeynumberdesc(Str.CheckNullString(rs.getString("keynumberdesc")));
			               	deptNumberChangeDTO.setHunt(rs.getInt("hunt"));
			               	deptNumberChangeDTO.setQueueStartAnn(Str.CheckNullString(rs.getString("queuestartann")));
			               	deptNumberChangeDTO.setQueueEndAnn(Str.CheckNullString(rs.getString("queueendann")));
			               	
			               	deptNumberChangeDTO.setK_protocol(Str.CheckNullInt(rs.getString("e164count")));
			               	iList.add(deptNumberChangeDTO);
			            }
			        }catch(Exception ex){
			        	ex.printStackTrace() ;
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
			        
			        try{
			        	if(nModePaging==1){
			        		sql = "\n select count(*) ";
			        		sql = sql +  "\n FROM  table_KeyNumberID b LEFT OUTER JOIN table_localprefix a ";
			        		sql = sql +  "\n ON a.endpointid = b.KEYNUMBERID "; 
					        //sql = sql +  "\n Where a.prefixtype = 4 "; 
					        if(authGroupid!=null) sql += "\n WHERE b.groupid = '"+authGroupid+"' and a.prefixtype = 4 ";
					        else sql += "\n WHERE a.prefixtype = 4 ";
					        
					        System.out.println("sql :"+sql);
					        rs = stmt.executeQuery(sql);
			                while (rs.next())
			                	count = rs.getInt(1) ;
			                
			                System.out.println("totalcount :"+count);
			        	}	
			        }catch(Exception ex){}finally{if(rs!=null) rs.close();}
				}
			}
			if(count==0) count = iList==null? 0 : iList.size();
		}catch(Exception ex){
		}finally{
			if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<IpcsDeptDTO>() ;
		IpcsDeptDTO dto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			dto = new IpcsDeptDTO();
			dto.setEndpointid("0101111222"+z) ;
			dto.setKeynumberdesc("Dept_"+z) ;
			dto.setHunt(z%2==0?1:0) ;
			dto.setQueueStartAnn("0601111222"+z) ;
			dto.setQueueEndAnn("0601111222"+z) ;
			dto.setK_protocol(10+z) ;//e164count
			
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
<title>대표번호</title>

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
        SetCookie("id_cookie_keyNum",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_keyNum",document.loginForm.id.value);
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

function func_init_keyNum() {
	var groupid = <%=authGroupid%>;
	//if(groupid) SetCookie("id_cookie_keyNum", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_keyNum", '');
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
	     * 부서 대표번호 중복체크 후 페이지 이동 처리부분 
	     */		
	    function getPage4(url, parm){
	        engine.execute("POST", url, parm, "ResgetPage4");
	    }		
	    function ResgetPage4(data){
	        if(data){		        
	            var value = data.replace(/\s/g, "");	// 공백제거		    	
	            if(value=='OK'){ 
	                //goDelete();
	            	goDeletePro();
	            }else{
	                alert("등록된 부서원이 있어 대표번호를 삭제할수 없습니다!") ;
	                return
	            }		        
	        }else{
	            alert("에러") ;
	            return
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
	    
	    /**
		 * 예외처리 설정
		 */
		function exceptChange(){
	    	var f2 		= document.Insertlayer1;
			var div3 	= document.getElementById("div3");
			var div4 	= document.getElementById("div4");
			var div5 	= document.getElementById("div5");
			var div5_1	= document.getElementById("div5_1");
			var div6 	= document.getElementById("div6");
			var div7 	= document.getElementById("div7");
			
	        if(f2.exceptType.value==1){
	            div3.style.display 	= "block";
	            div4.style.display 	= "none";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
	        }else if(f2.exceptType.value==3){        	            
	            div3.style.display 	= "none";
	            div4.style.display 	= "block";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
	        }else if(f2.exceptType.value==4){
	            div3.style.display 	= "none";
	            div4.style.display 	= "none";
	            div5.style.display 	= "block";
	            div5_1.style.display 	= "block";
	            div6.style.display 	= "none";//"block";
	            div7.style.display 	= "none";//"block";
	        }else{
	            div3.style.display 	= "none";
	            div4.style.display 	= "none";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
	        }
		}
	    function exceptChange2(){
	    	var f2 		= document.Editlayer1;
			var div3 	= document.getElementById("div3");
			var div4 	= document.getElementById("div4");
			var div5 	= document.getElementById("div5");
			var div5_1	= document.getElementById("div5_1");
			var div6 	= document.getElementById("div6");
			var div7 	= document.getElementById("div7");
// 			var div8 	= document.getElementById("div8");
// 			var div9 	= document.getElementById("div9");
			
	        if(f2.exceptType.value==1){
	            div3.style.display 	= "block";
	            div4.style.display 	= "none";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
// 	            div8.style.display 	= "none";
// 	            div9.style.display 	= "none";
	        }else if(f2.exceptType.value==3){        	            
	            div3.style.display 	= "none";
	            div4.style.display 	= "block";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
// 	            div8.style.display 	= "none";
// 	            div9.style.display 	= "none";
	        }else if(f2.exceptType.value==4){
	            div3.style.display 	= "none";
	            div4.style.display 	= "none";
	            div5.style.display 	= "block";
	            div5_1.style.display 	= "block";
	            div6.style.display 	= "none";//"block";
	            div7.style.display 	= "none";//"block";
// 	            div8.style.display 	= "block";
// 	            div9.style.display 	= "block";
	        }else{
	            div3.style.display 	= "none";
	            div4.style.display 	= "none";
	            div5.style.display 	= "none";
	            div5_1.style.display 	= "none";
	            div6.style.display 	= "none";
	            div7.style.display 	= "none";
// 	            div8.style.display 	= "none";
// 	            div9.style.display 	= "none";
	        }
		}
	    
	    /**
		 * 셀렉트박스 컨트롤
		 */
        function move(fbox,tbox) {
            var arrFbox = new Array();
            var arrTbox = new Array();
            var arrLookup = new Array();
            var i;
            var k;
            var str = "";
            for(i=0; i<tbox.options.length; i++) {
                arrLookup[tbox.options[i].text] = tbox.options[i].value;
                arrTbox[i] = tbox.options[i].text;
            }
            var fLength = 0;
            var tLength = arrTbox.length
            for(i=0; i<fbox.options.length; i++) {
                arrLookup[fbox.options[i].text] = fbox.options[i].value;
                if(fbox.options[i].selected && fbox.options[i].value != "") {
                    str = "";
                    for(k=0; k<tbox.options.length; k++) {
                        if(fbox.options[i].value == tbox.options[k].value){
                            str = "exist";
                        }
                    }
                    if(str == "exist"){
                        arrFbox[fLength] = fbox.options[i].text;
                        fLength++;
                    }else{
                        arrTbox[tLength] = fbox.options[i].text;
                        tLength++;
                    }
                } else {
                    arrFbox[fLength] = fbox.options[i].text;
                    fLength++;
                }
            }
            fbox.length = 0;
            tbox.length = 0;
            var c;
            for(c=0; c<arrFbox.length; c++) {
                var no = new Option();
                no.value = arrLookup[arrFbox[c]];
                no.text = arrFbox[c];
                fbox[c] = no;
            }
            for(c=0; c<arrTbox.length; c++) {
                var no = new Option();
                no.value = arrLookup[arrTbox[c]];
                no.text = arrTbox[c];
                tbox[c] = no;
            }
        }

        function move2(fbox,tbox) {
            var arrFbox = new Array();
            var arrTbox = new Array();
            var arrLookup = new Array();
            var i;
            var k;
            var str = "";
            for(i=0; i<tbox.options.length; i++) {
                arrLookup[tbox.options[i].text] = tbox.options[i].value;
                arrTbox[i] = tbox.options[i].text;
            }
            var fLength = 0;
            var tLength = arrTbox.length
            for(i=0; i<fbox.options.length; i++) {
                arrLookup[fbox.options[i].text] = fbox.options[i].value;
                if(fbox.options[i].selected && fbox.options[i].value != "") {
                    str = "";
                    for(k=0; k<tbox.options.length; k++) {
                        if(fbox.options[i].value == tbox.options[k].value){
                            str = "exist";
                        }
                    }
                    if(str == "exist"){
                        arrFbox[fLength] = fbox.options[i].text;
                        fLength++;
                    }else{
                    	var tmpList = fbox.options[i].value;
                    	var tmpDetpId;
                    	var tmpSid;
                    	var tmpDid;
                    	
                    	tmpDetpId = tmpList.split(";");
                    	tmpSid = tmpDetpId[1];
                    	tmpDid = tmpDetpId[2];
                    	
                    	if(tmpSid == tmpDid){
                    		alert("조직도에 등록 되어 이동할수 없습니다!");
                    		//Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"조직도에 등록 되어 이동할수 없습니다!");
                    		return;
                    	}
                    	
                        arrTbox[tLength] = fbox.options[i].text;
                        tLength++;
                    }
                } else {
                    arrFbox[fLength] = fbox.options[i].text;
                    fLength++;
                }
            }
            fbox.length = 0;
            tbox.length = 0;
            var c;
            for(c=0; c<arrFbox.length; c++) {
                var no = new Option();
                no.value = arrLookup[arrFbox[c]];
                no.text = arrFbox[c];
                fbox[c] = no;
            }
            for(c=0; c<arrTbox.length; c++) {
                var no = new Option();
                no.value = arrLookup[arrTbox[c]];
                no.text = arrTbox[c];
                tbox[c] = no;
            }
        }
        
		/**
		 * 신규입력 화면으로 이동
		 */
		function goNewInsert(){
		    var parm 	= '';
		    var url 	= 'keyNumInsert.jsp';
		    
		    getPage(url,parm);			
		}
	    
		function goNewSave(){
			var f 				= document.frm;
			var f2 				= document.Insertlayer1;
			var p_KeyNumber		= f2.txtKeyNumber.value;		//KeyNumber
			var p_Hunt			= f2.huntType.value;			//Hunt유형
			var p_Dcse			= f2.txtDesc.value;				//Desc
			
//			f.hiKeynumberid.value	= p_KeyNumber;			
//			f.hiHunt.value			= p_Hunt;
//		    f.hiDesc.value			= p_Dcse;
		    
			// 2010.01.08 추가 ===========================
			var p_ErrorType;
			var p_Endpointid;
			var p_StandTime;
			var p_Stand;
			var p_StandTime2;
			var p_StartFile;
			var p_EndFile;
			var p_StandType;
			
			if(f2.standChk.checked){
				p_StandType = "1";				// 무응답시 예외처리 설정함
			}else{
				p_StandType = "0";				// 무응답시 예외처리 설정 안함
			}
			
			if(f2.exceptType.value == "0"){		// 예외처리설정
				p_ErrorType 	= "A";
				p_Endpointid 	= '';
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "1"){
				p_ErrorType 	= "B";
				p_Endpointid 	= f2.root.value;
				if(p_Endpointid==''){
					alert("루트ID가 선택되지 않았습니다!");
					return;
				}
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "3"){
				p_ErrorType 	= "C";
				p_Endpointid 	= f2.e164.value;
				if(p_Endpointid==''){
					alert("전화번호가 입력되지 않았습니다!");
					return;
				}
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "4"){
				p_ErrorType 	= "D";
				p_Stand 		= f2.stand.value;
				if(p_Stand==''){
					alert("최대 대기호가 입력되지 않았습니다!");
					return;
				}
				if(isNaN(p_Stand)){
					alert("최대 대기호는 숫자만 입력이 가능합니다!");
					return;
				}
				
			}else{
				p_ErrorType 	= "E";					// 예외처리설정 안함
				p_Endpointid 	= '';
				p_Stand			= '';
				p_StandTime 	= '0';
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}
			
			f2.hiKeyNumberID_02.value 	= p_KeyNumber;
			f2.hiHunt_02.value 			= p_Hunt;
			f2.hiErrorType_02.value 	= p_ErrorType;
			f2.hiEndpointid_02.value 	= p_Endpointid;
			f2.hiStandTime_02.value 	= p_StandTime;
			f2.hiStandTime2_02.value 	= p_StandTime2;
			f2.hiStartFile_02.value 	= p_StartFile;
			f2.hiEndFile_02.value 		= p_EndFile;
			f2.hiStand_02.value 		= p_Stand;
			f2.hiStandType_02.value 	= p_StandType;
			f2.hiDesc_02.value			= p_Dcse;
			
		    // 부서대표번호 수정
	        //f2.charset = "utf-8";
	        ///*debug*/alert('InsertPro');
	        
	        f2.target="procframe";
	        f2.action="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumInsertPro.jsp";
	        f2.method="post";
	        f2.submit();			
		}			

        /**
         * 삭제 화면으로 이동
         */
        function goDelete(){
         	var f 				= document.frm;
         	var str = "";
         	if(f != undefined && f.chkOpt != undefined){
             	str = setE164BySelected();
            }else
 		       	str = "1";

            //f.hiKeynumberid.value = str;//
            goDelete(str);
        }
        function goDelete(p_Keynumberid){
        	var f 				= document.frm;
        	f.hiKeynumberid.value	= p_Keynumberid;
        	
            var parm 	= '&hiKeynumberid='+p_Keynumberid;		//get형식으로 변수 전달.;
            var url 	= 'keyNumDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * 삭제할 부서 대표번호에 부서원이 있는지 체크
		 */
		function goDeleteChk(){
			var f 				= document.frm;			
// 			var f2 				= document.Deletelayer1;
			var p_Keynumberid 	= f.hiKeynumberid.value;
			//f.hiKeynumberid.value	= p_Keynumberid;
			
            var parm 		= '&keynumberid='+p_Keynumberid;		//get형식으로 변수 전달.
		    var url 		= 'keyNumDeleteChk.jsp';
		    getPage4(url,parm);		
		}
		
		/**
		 * 삭제처리
		 */
		function goDeletePro(){
            var f   = document.frm;
            //var str = f.hiKeynumberid.value;
            //f.deleteStr.value = str;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			if(1==1) return;
			
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
		 * 수정화면으로 이동
		 */
		function showEdit(p_E164,p_hunt,p_desc, p_start, p_end){
		    var parm 		= '&eKeynumber='+p_E164+'&eHunt='+p_hunt+'&eDesc='+p_desc+'&sFile='+p_start+'&eFile='+p_end;		//get형식으로 변수 전달.
		    var url 		= 'keyNumEdit.jsp';

		    getPage(url,parm);			
		}
		
		/**
		 * 수정 내용 저장하기
		 */
		function goSave(){
			var f 				= document.frm;
			var f2 				= document.Editlayer1;
			var p_KeyNumber		= f2.txtKeyNumber.value;		//KeyNumber
			var p_Hunt			= f2.huntType.value;			//Hunt유형
			var p_Dcse			= f2.txtDesc.value;				//Desc
			
//			f.hiKeynumberid.value	= p_KeyNumber;			
//			f.hiHunt.value			= p_Hunt;
//		    f.hiDesc.value			= p_Dcse;
		    
			// 2010.01.08 추가 ===========================
			var p_ErrorType;
			var p_Endpointid;
			var p_StandTime;
			var p_Stand;
			var p_StandTime2;
			var p_StartFile;
			var p_EndFile;
			var p_StandType;
			var p_BeforeStartFile	= f2.beforeFile_1.value;
			var p_BeforeEndFile		= f2.beforeFile_2.value;
			
			if(1!=1){
				// 대기안내음 파일			
				var uploadfile_3	= document.getElementById("wFile3");
				var uploadfile03;
				var chk03      		= "";
				uploadfile03 	= uploadfile_3.value;
				var fullname03 	= uploadfile03;
		        var i3 = uploadfile_3.value.lastIndexOf(".");
		        if(i3 != -1){
		            chk03 	= fullname03.substring(i3+1);
		        }
	
				// 대기종료음 파일
				var uploadfile_4	= document.getElementById("wFile4");
				var uploadfile04;
				var chk04      		= "";
				uploadfile04 	= uploadfile_4.value;
				var fullname04 	= uploadfile04;
		        var i4 = uploadfile_4.value.lastIndexOf(".");
		        if(i4 != -1){
		            chk04 	= fullname04.substring(i4+1);
		        }
			}//UnUsed
			
			if(f2.standChk.checked){
				p_StandType = "1";				// 무응답시 예외처리 설정함
			}else{
				p_StandType = "0";				// 무응답시 예외처리 설정 안함
			}
			
			if(f2.exceptType.value == "0"){		// 예외처리설정
				p_ErrorType 	= "A";
				p_Endpointid 	= '';
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "1"){
				p_ErrorType 	= "B";
				p_Endpointid 	= f2.root.value;
				if(p_Endpointid==''){
					alert("루트ID가 선택되지 않았습니다!");
					return;
				}
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "3"){
				p_ErrorType 	= "C";
				p_Endpointid 	= f2.e164.value;
				if(p_Endpointid==''){
					alert("전화번호가 입력되지 않았습니다!");
					return;
				}
				p_Stand			= '';
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}else if(f2.exceptType.value == "4"){
				p_ErrorType 	= "D";
				p_Stand 		= f2.stand.value;
				if(p_Stand==''){
					alert("최대 대기호가 입력되지 않았습니다!");
					return;
				}
				if(isNaN(p_Stand)){
					alert("최대 대기호는 숫자만 입력이 가능합니다!");
					return;
				}
				
				/*
				if(p_BeforeStartFile==""||p_BeforeEndFile==""){
					if(uploadfile03==""){
						alert("대기안내음 파일을 선택하지 않았습니다.");
						return;
					}
					if(uploadfile04==""){
						alert("대기종료음 파일을 선택하지 않았습니다.");
						return;
					}
			        if((chk03.toLowerCase() != "wav")||(chk04.toLowerCase() != "wav")){
			            alert("wav 파일만 업로드 할 수 있습니다.");
			            return;
			        }
			        
			        var strFile01 = uploadfile03.substring(uploadfile03.lastIndexOf("\\")+1);
			        var strFile02 = uploadfile04.substring(uploadfile04.lastIndexOf("\\")+1);
			        if(strFile01==strFile02){
			        	alert("연결음, 종결음은 같은 wav 파일로 사용할수 없습니다.");
			        	return;
			        }
		        }
				p_Endpointid	= "MS";
				p_StandTime 	= f2.standTime.value;
				p_StandTime2 	= f2.standTime2.value;
				p_StartFile		= uploadfile03;
				p_EndFile		= uploadfile04;
				*/
			}else{
				p_ErrorType 	= "E";					// 예외처리설정 안함
				p_Endpointid 	= '';
				p_Stand			= '';
				p_StandTime 	= '0';
				p_StandTime2 	= '0';
				p_StartFile		= '';
				p_EndFile		= '';
			}
			
			f2.hiKeyNumberID_02.value 	= p_KeyNumber;
			f2.hiHunt_02.value 			= p_Hunt;
			f2.hiErrorType_02.value 	= p_ErrorType;
			f2.hiEndpointid_02.value 	= p_Endpointid;
			f2.hiStandTime_02.value 	= p_StandTime;
			f2.hiStandTime2_02.value 	= p_StandTime2;
			f2.hiStartFile_02.value 	= p_StartFile;
			f2.hiEndFile_02.value 		= p_EndFile;
			f2.hiStand_02.value 		= p_Stand;
			f2.hiStandType_02.value 	= p_StandType;
			f2.hiDesc_02.value			= p_Dcse;
			
		    // 부서대표번호 수정
	        //f2.charset = "utf-8";
	        
	        f2.target="procframe";
	        f2.action="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumEditPro.jsp";
	        f2.method="post";
	        f2.submit();			
		}			

		
		/**
		 * 사용자 순서변경 화면으로 이동
		 */
		function goUserSort(p_deptnumber, p_count){
		    var parm 	= '&deptnumber='+p_deptnumber;		//get형식으로 변수 전달.
		    var url 	= 'keyNumUserSort.jsp';		
			
			if(p_count=="0"){
				//Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"선택한 대표번호에는 등록된 번호가 없습니다!");
				alert('선택한 대표번호에는 등록된 번호가 없습니다!');
				return;
			}
		    getPage(url,parm);
        }
		/**
		 * 순서변경 저장하기
		 */
		function goUserSortPro(){//goSortSave()
			var f 					= document.frm;
			var f2 					= document.Sortlayer;
            var sortStr = "";

            for(var i=0; i<f2.ranking.length; i++){
                var cnt = 0;
                for(var j=0; j<f2.ranking.length; j++){
                    if(f2.ranking[i].value == f2.ranking[j].value){
                        cnt++;
                    }
                }
                if(cnt > 1){
                    alert("같은번호를 중복하여 선택하실 수 없습니다.(중복번호:"+f2.ranking[i].value+")");
                    //Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"같은번호를 중복하여 선택하실 수 없습니다.(중복번호:"+f2.ranking[i].value+")");
                    return;
                }

                if(i == 0){
                    if(f2.positionid[i] == undefined){
                    	sortStr = f2.positionid.value + "|" + f2.ranking[i].value;
                    }else{
                    	sortStr = f2.positionid[i].value + "|" + f2.ranking[i].value;
					}                   
                }else{
                    sortStr = sortStr + "" + f2.positionid[i].value + "|" + f2.ranking[i].value;
                }
            }

            f.sortStr.value 			= sortStr;
			f.hiSortDeptnumber.value 	= f2.hiSortDeptnumber.value;
			
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumUserSortPro.jsp";
            f.method = "post";
            f.submit();	
		}	
		
		/**
		 * 사용자 수정화면으로 이동
		 */
		function goUserEdit(p_EndpointId, p_name){
		    var parm 		= 'hiEndpointId='+p_EndpointId+'&hiDeptName='+p_name;		//get형식으로 변수 전달.
		    var url 		= 'keyNumUserEdit.jsp';

		    getPage(url,parm);			
		}
		
		/**
		 * 사용자 수정 내용 저장하기
		 */
		function goUserEditPro(fbox){
			var f 				= document.frm;
			var f2 				= document.Editlayer;
			var p_DeptNumber	= f2.txtDeptNumber.value;

		   	var updateStr = "";
			for(i=0; i<fbox.options.length; i++) {
                if(i == 0){
                    updateStr = fbox.options[i].value;
                }else{
                    updateStr = updateStr + "|" + fbox.options[i].value;
                }
            }

			f.hiKeynumberid.value   = p_DeptNumber;
            f.hiE164List.value   	= updateStr;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumUserEditPro.jsp";
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
		function func_setAction(key, param, action) {
			document.frm.e164.value = key;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1) goDelete();
			else goInsert(key, param);
		}
        
		/**
         * 선택 추가/해제 클릭
         */
		function func_setActionBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('삭제')==0 ) return ;
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
// 		 	document.cookie = "id_cookie_keyNum" + "=";
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
		<% int menu = 3, submenu = 31; %>
		<table id="menu" width="180" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	<!--end--왼쪽페이지-->
	</td>
  <td>
	<table border="0" >
<!-- <TBODY> -->
<FORM name="frm" method="post">
	<input type='hidden' name ='grpid' value="">
	<input type='hidden' name ='e164' value="">
	
	<input type='hidden' name ='hiKeynumberid' 		value="">
	<input type='hidden' name ='hiHunt' 			value="">
	<input type='hidden' name ='hiDesc' 			value="">
	<input type='hidden' name ='hiErrorType'		value="">
	<input type='hidden' name ='hiStandTime'		value="">
	<input type='hidden' name ='hiEndpointid'		value="">
	<input type='hidden' name ='hiE164List' 		value="">
	<input type='hidden' name ='sortStr' 			value="">
	<input type='hidden' name ='hiSortDeptnumber' 			value="">
	<input type='hidden' name ='hiUserID'				value="<%=authGroupid%>">
	
	<tr>
        <td valign="bottom">
          <table width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="#FFFFFF" style="border:1 solid rgb(160,160,160) ">
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'keyNumList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'keyNumList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnNewAlarm" style="height: 18px" value="등록" onclick="goNewInsert()">
                  	<!-- <input type="button" name="btnPutAlarm" style="height: 18px" value="선택 등록" onclick="func_setActionBySelected(0)"> -->
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
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td>
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">No<!-- 번호 --></td>
                  <td width="130" onclick="sortNow(0,true);changeTitle(0);" id="mainnum" 	class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>대표번호▲</b></td>
                  <td width="100" onclick="sortNow(1);changeTitle(1);" 		id="calltype" 	class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">착신유형<font size='1px'>▽</font></td>
                  <td width="100" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">설 명</td>
                  <td width="120" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">그룹</td>
                  <td width="100" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">사용자</td>
                  <%-- <td width="60" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td> --%>
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
		IpcsDeptDTO dto= null;
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (IpcsDeptDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					%>	
					  <%-- <tr id=g<%=idx%> height="22" bgcolor="E7F0EC" align="center" onmouseover='this.style.backgroundColor="E7F0EC"' onmouseout='this.style.backgroundColor="E7F0EC"' > --%>
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=dto.getEndpointid()%>" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="130" id='h<%=idx%>_0' class="table_column"><%=dto.getEndpointid()%></td>
		                <td width="100" id='h<%=idx%>_1' class="table_column">
		                	<%
	                		switch(dto.getHunt()){
	                			case 1: out.print("순차 착신"); break; 
	                			case 2: out.print("고정 착신"); break;
	                			case 3: out.print("자동 착신"); break; 
	                			case 4: out.print("동시 착신"); break;
	                		}
		                	%>
		                </td>
		                <td width="100" id='h<%=idx%>_2' class="table_column"><%=dto.getKeynumberdesc()%>&nbsp;</td>
		                <td width="100" id='h<%=idx%>_3' class="table_column">
		                	<!-- <td width="97" style="padding-top:2"> -->
		                		<a href="#" onclick="javascript:showEdit('<%=dto.getEndpointid()%>','<%=dto.getHunt()%>','<%=dto.getKeynumberdesc()%>','<%=dto.getQueueStartAnn()%>','<%=dto.getQueueEndAnn()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)">
		                			<img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0">
		                		</a>
		                		<a href="#" onclick="javascript:goDelete('<%=dto.getEndpointid()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"> 
		                			<img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0">
		                		</a>
						</td>
		                <td width="120" id='h<%=idx%>_4' class="table_column">
			                <%-- <input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction('<%=dto.getKeynumberId()%>', '<%=dto.getForwardType()%>', 0)"> --%>
		                	<%-- <a href="#" onclick="javascript:func_setAction('<%=dto.getEndpointid()%>', <%=""%>, 0);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=dto.getEndpointid()%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)">
		                		<img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=dto.getEndpointid()%>" width="34" height="18" border="0">
		                	</a> --%>
		                	
		                	<a href="javascript:goUserSort('<%=dto.getEndpointid()%>','<%=dto.getK_protocol()/*e164count*/%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image100','','<%=StaticString.ContextRoot%>/imgs/Content_orderchange_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_orderchange_n_btn.gif" name="Image100" width="64" height="20" border="0"></a>&nbsp;
			                <a href="#" onclick="javascript:goUserEdit('<%=dto.getEndpointid()%>','<%=dto.getKeynumberdesc()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=idx%>" width="34" height="18" border="0"></a>
		                </td>
		                <%-- <td width="80" id='h<%=idx%>_5' class="table_column">
		                </td> --%>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
	out.println("<script type=\"text/JavaScript\"> sortNow(0,true); </script>") ;//번호 정렬
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="keyNumList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="keyNumList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"keyNumList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="keyNumList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="keyNumList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
