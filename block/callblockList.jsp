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

<%@ page import="dto.MrbtDTO" %>
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
   	
    String authGroupid = null, groupCode="" ;
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
		ArrayList 		blockList = null;
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
				        
				        MrbtDTO mrbtDTO;
						blockList = new ArrayList<MrbtDTO>();
				        sql = "\n select a.e164 as e164, ";
				        sql = sql +  "\n 	a.extensionnumber as extnum,  ";
				        sql = sql +  "\n 	b.name as name,  "; 
				        sql = sql +  "\n 	(Select deptname from table_dept where deptid = b.department) as dept,  ";
				        sql = sql +  "\n 	b.position as position,  ";
				        sql = sql +  "\n 	substring(a.callerservice,2,1) as userparam  ";
				        sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum "; 
				        if(authGroupid!=null) sql = sql +  "\n WHERE a.checkgroupid='"+authGroupid+"' ";
				        sql = sql +  "\n order by a.e164 ";
				        
				        if(nModePaging==1){
							sql		+= " LIMIT "+nMaxitemcnt+" ";
							sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
						}
				        
				        try {
				        	
				                rs = stmt.executeQuery(sql);
				                System.out.println("MRBT : "+sql);
				                while (rs.next()) {
				                	mrbtDTO = new MrbtDTO();
				                	mrbtDTO.setE164(Str.CheckNullString(rs.getString("e164")));
				                	mrbtDTO.setName(Str.CheckNullString(rs.getString("extnum")));
// 				                	mrbtDTO.setDept(Str.CheckNullString(rs.getString("dept")));
// 				                	mrbtDTO.setPosition(Str.CheckNullString(rs.getString("position")));
				                	mrbtDTO.setFilename(Str.CheckNullString(rs.getString("userparam")));
				                	blockList.add(mrbtDTO);
				                }
				        }catch(Exception ex){
				        }finally{
							if(rs!=null) rs.close();			        	
				        }
				        
				      	/** 
				      	*그룹 코드
				      	**/
				        try {
				        	sql = "SELECT groupid, extensiongroupnum FROM table_subscriberGroup WHERE groupid='"+authGroupid+"' "; 
			                rs = stmt.executeQuery(sql);
			                System.out.println("GroupCode : "+sql);
			                while (rs.next()) {
			                	groupCode = Str.CheckNullString(rs.getString("extensiongroupnum")) ;
			                }
				        }catch(Exception ex){
				        }finally{
							if(rs!=null) rs.close();			        	
				        }
						
						//int 		iCount 			= blockList.size();
				        try{
				        	if(nModePaging==1){
				        		sql = "\n select count(*) ";
					        	sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum "; 
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
			blockList = new ArrayList<MrbtDTO>() ;
//	 		HashMap smpitem;
			MrbtDTO mrbtDTO = null;
			for(int z=0; z<nMaxitemcnt; z++){
				mrbtDTO = new MrbtDTO();
				mrbtDTO.setE164("0101111222"+z) ;
				mrbtDTO.setName("0101111222"+z) ;
				mrbtDTO.setPosition("test_"+z) ;
				mrbtDTO.setDept("testDept_"+z) ;
				mrbtDTO.setFilename(z%5==0?"3":(z%3==0)?"1":"0");//0:사용안함, 1:전체번호, 3:특정번호
				mrbtDTO.setUsechk(z%2==0?1:0) ;
				//mrbtDTO.put("totalcnt", "25") ;
				blockList.add(mrbtDTO);
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
        SetCookie("id_cookie_callblock",document.loginForm.id.value, 90); //쿠키값 하루 설정
      }else{
        delCookie("id_cookie_callblock",document.loginForm.id.value);
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
	//if(groupid) SetCookie("id_cookie_callblock", groupid, 90); //쿠키값 하루 설정
	//delCookie("id_cookie_callblock", '');
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
				f2.txtE164.value		= "<%=groupCode%>";//"99";
				f2.txtNote.value		= "내선번호";
				f2.txtNote.focus();
				f2.txtE164.disabled		= false;//true;
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
		 * 신규입력 화면으로 이동
		 */
		function goInsert(p_E164, p_file, p_Mode){
		    var parm 	= (p_E164?'&e164='+p_E164:'')+(p_Mode?'&procmode='+p_Mode:'');
		    var url 	= 'callblockEdit.jsp';
		    if(p_file == 0 || p_file == "0"){
				alert("발신제한을 사용하지 않고 있습니다!");
				return;
			}
		    
		    getPage(url,parm);			
		}

		/**
		 * 수정 처리
		 */
		function goInsertPro(){
			var f  = document.frm;
            var f2 = document.editForm;
            
            var str = f2.e164.value;
            str = str?str:"";
            //alert("e164s="+str?str:"false");
            if(!str && f.chkOpt != undefined){
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
            }
            
            var str2 = "";
            var chk_Value 	= document.getElementsByName("radioType1");
            if(chk_Value != undefined){
                for(var i=0; i<chk_Value.length; i++){
                    if(chk_Value[i].checked){
                        str2 = chk_Value[i].value;
                    }
                }
            }else{
            	alert("발신제한 유형을 선택하지 않았습니다!");
            	return;
            }
    		
    		if(str2=="3"){
    			if(f2.txtE164.value == ""){
    	        	alert("발신제한/허용 번호를 입력하지 않았습니다!");
    	        	return;
    			}
    		}

    		var idtype 		= f2.blockType.value;
    		var strResult 	= f2.txtE164.value;					
    		var value 		= strResult.replace(/\s/g, "");	// 공백제거
    		
    		if(value!=""&&idtype=="3"){
    	        var ChkText=/^([0-9*]{1,20})$/
    	        if(ChkText.test(f2.txtE164.value)==false){
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
    		
    	    // 신규 부서대표번호 저장
    	    var parm 	= '&insertStr='+str+'&blockE164='+f2.txtE164.value;		//get형식으로 변수 전달.
    	    var url 	= 'callBlockChk.jsp';
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;
    				var value = tempResult.replace(/\s/g, "");	// 공백제거
    		    	if(value=='OK'){ 
    					f.hiCallBlockType.value 	= str2;
    			        editPro(str, str2);
    			        return ;
    		    	}else if(value=='NO'){
    			    	alert("이미 등록된 발신제한 번호입니다!");
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
		
		/**
	     * 수정 저장
	     */
	    function editPro(e164s, callblockType){
	    	var f  = document.frm;
	    	var f2  = document.editForm;
	    	
	    	//f.hiCallBlockType.value = callblockType;
	        f.prefixType.value 		= f2.prefixType.value;
	        f.blockE164.value 		= f2.txtE164.value;
	        if(f2.blockType.value=="9"){
		        f.blockType.value 		= "2";
	        }else{
		        f.blockType.value 		= f2.blockType.value;
	        }
	        f.note.value 			= f2.txtNote.value;
	        
			//f.insertStr.value 		= e164s;
			//f.hiE164.value 			= f2.e164.value;
	    	var parm 	= '&e164='+e164s+'&callBlockType='+callblockType+'&prefixType='+f.prefixType.value+'&blockType='+f.blockType.value+'&blockE164='+f.blockE164.value+'&note='+f.note.value+'&userID='+f.hiUserID.value;		//get형식으로 변수 전달.
	    	parm 	+= '&procmode='+f2.procMode.value;
	    	var url 	= 'callblockEditPro.jsp';
	    	Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// 공백제거
			    	if(value=='OK'){ 
						goInsert(e164s, callblockType);
			    	}else if(value=='NO'){
			    		alert("실패!");
			    		return;
			    	}else{
				    	var objJSON = eval("(function(){return " + value + ";})()");
			    		goInsertDone(objJSON);
			    		hiddenAdCodeDiv();
			    		return;
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
				} 
			});	
		}
		/**
		 * 신규입력 후 출력
		 */
		function goInsertDone(datas){
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					_td = document.getElementById("h"+_i+"_2") ;
	 					if("0"==datas[z].params[1]){
	                		_td.innerHTML = "사용안함&nbsp;";
	                	}else if("1"==datas[z].params[1]){
	                		_td.innerHTML = "<FONT color=\"red\">전체번호</FONT>&nbsp;";
	                	}else if("3"==datas[z].params[1]){
	                		_td.innerHTML = "<FONT color=\"blue\">특정번호</FONT>&nbsp;";
	                	}else _td.innerHTML = "&nbsp;";
	 					
	                	_td = document.getElementById("h"+_i+"_3") ;
	                	if(_td) _td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction('"+_e164+"', "+datas[z].params[1]+", 0)\" >";
	 					//document.getElementById("h"+_i+"_4").innerHTML = datas[z].params[1] ;
	 					//document.getElementById("h"+_i+"_3").innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction('"+_e164+"', '"+datas[z].params[1]+"', 1)\" >";
	 					if(++_idx == _len){
		 					if(1!=1) goInsert(datas[z].params[0], datas[z].params[1]) ;
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
        function goDelete(p_E164, p_startPrefix){
        	if(p_startPrefix == ""){
    			alert("삭제할 발신제한 번호가 없습니다!");
    			return;
    		}
            var parm 	= '';//'&e164='+p_E164 + (p_startPrefix?'&prefix='+p_startPrefix:'');		//get형식으로 변수 전달.;
            var url 	= 'callblockDelete.jsp';
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
            f.action = "<%=StaticString.ContextRoot+pageDir%>/block/callblockDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					_td = document.getElementById("h"+_i+"_2") ;
	 					if(_td) _td.innerHTML = "사용안함&nbsp;";
	                	_td = document.getElementById("h"+_i+"_3") ;
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
		* 수정 창에서 삭제
		**/
		function goDeletePro2(p_E164, p_startPrefix){
        	if(p_startPrefix == ""){
    			alert("삭제할 발신제한 번호가 없습니다!");
    			return;
    		}
            
            var parm 	= '&e164='+p_E164+'&prefix='+p_startPrefix
	    	var url 	= 'callblockDeletePro.jsp';
	    	Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// 공백제거
					 
			    	if(value=='NO'){
			    		alert("실패!");
			    		return;
			    	}else{
				    	var objJSON = eval("(function(){return " + value + ";})()");
			    		//goInsertDone(objJSON);
			    		//var f2 = document.editForm;
						var _tb = document.getElementById("tb_prefix_list");
						var count_tr = _tb.getElementsByTagName("TR").length;
						for(var _j=0; _j<count_tr; _j++){
							if( _tb.rows[_j].id == objJSON[0].params[1] ){
								//var i = _tb.rows[_j].parentNode.rowIndex;
								document.getElementById("tb_prefix_list").deleteRow(_j);
								return ;
							};
						}
			    		return;
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
				} 
			});	
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
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/block/callblockSavePro.jsp";
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
                var parm = '&titlemsg='+'발신제한 설정'+'&msg='+'검색 목록이 없습니다.';
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
                    var parm = '&titlemsg='+'발신제한 설정'+'&msg='+processname+'할 항목을 선택하여 주십시오.';
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
		function func_setAction(num, state, action) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1){
				goDelete();
				//window.open("callblockDelete.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
			}
			else{
				goInsert(num, state);
				//window.open("callblockInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
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
				goInsert(document.frm.e164.value, null, '1') ;
        	}
		}
		
		function func_logoutCommit(type) {
// 		 	document.cookie = "id_cookie_callblock" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  //document.rtcForm.rtcInput.value = getTimeStamp();
			  document.location.href = 'callblockList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==nField )	document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				else				document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
				document.getElementById('memname').innerHTML = "내선번호<font size='1px'>▽</font>";//△
				document.getElementById('status').innerHTML = "발신제한 상태<font size='1px'>▽</font>";
			}
			else if(nField==1){
				if( lastSort==nField ) 	document.getElementById('memname').innerHTML = "<b>내선번호▲</b>";
				else				document.getElementById('memname').innerHTML = "<b>내선번호▼</b>";							
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
				document.getElementById('status').innerHTML = "발신제한 상태<font size='1px'>▽</font>";
			}
			else if(nField==2){
				if( lastSort==nField )	document.getElementById('status').innerHTML = "<b>발신제한 상태▲</b>";
				else					document.getElementById('status').innerHTML = "<b>발신제한 상태▼</b>";							
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
				document.getElementById('memname').innerHTML = "내선번호<font size='1px'>▽</font>";							
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
		<% int menu = 3, submenu = 1; %>
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'callblockList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'callblockList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="선택 등록" onclick="func_setActionBySelected(0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="선택 해제" onclick="func_setActionBySelected(1)">
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
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="130" onclick="sortNow(0,true);changeTitle(0);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>전화번호▲</b></td>
                  <td width="230" onclick="sortNow(1,false);changeTitle(1);" id="memname" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">내선번호<font size='1px'>▽</font></td>
                  <td width="110" onclick="sortNow(2,false);changeTitle(2);" id="status" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">발신제한 상태<font size='1px'>▽</font></td>
                  <td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"> </td>
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
		MrbtDTO dto= null;
		if(blockList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (MrbtDTO)blockList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="130" id='h<%=idx%>_0' class="table_column"><%=dto.getE164()%></td>
		                <td width="230" id='h<%=idx%>_1' class="table_column"><%=dto.getName()%></td>
		                <td width="100" id='h<%=idx%>_2' class="table_column">
		                <%
		                	if("0".equals(dto.getFilename())){
		                		out.print("사용안함&nbsp;");
		                	}else if("1".equals(dto.getFilename())){
		                		out.print("<FONT color=\"red\">전체번호</FONT>&nbsp;");
		                	}else if("3".equals(dto.getFilename())){
		                		out.print("<FONT color=\"blue\">특정번호</FONT>&nbsp;");
		                	}else out.print("&nbsp;");
		                %>
		                </td>
		                <td width="80" id='h<%=idx%>_3' class="table_column"><input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction('<%=dto.getE164()%>', <%=dto.getFilename()%>, 0)"></td>
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
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="callblockList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="callblockList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"callblockList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="callblockList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="callblockList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
