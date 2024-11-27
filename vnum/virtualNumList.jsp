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

<%@ page import="dto.VirtualNumberDTO" %>
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
				stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
				if(stmt!=null){
					//AddServiceList 	addServiceList = new AddServiceList();
					//iList	= (ArrayList)addServiceList.getVirtualList(stmt, authGroupid);		// 데이타 조회
					VirtualNumberDTO virtualNumberDTO;
					iList = new ArrayList<VirtualNumberDTO>();
			        
			        String sql = "\n select a.e164 as e164, ";
			        sql = sql +  "\n 	a.extensionnumber as extnum,  "; 
			        sql = sql +  "\n 	b.name as name,  "; 
			        sql = sql +  "\n 	(Select deptname from table_dept where deptid = b.department) as dept,  ";
			        sql = sql +  "\n 	b.position as position,  ";
			        sql = sql +  "\n 	(select userparam from table_featureservice where e164 = a.e164 and serviceno = 5431) as userparam,  ";
			        sql = sql +  "\n 	(select count(*) from table_featureservice where e164 = a.e164 and serviceno = 5431) as usechk  ";
			        sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum ";
			        if(authGroupid!=null)
			        	sql = sql +  "\n WHERE a.checkgroupid = '"+authGroupid+"' ";
			        sql = sql +  "\n order by a.e164 "; 
			    
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        ResultSet rs = null;
			        try {
			                rs = stmt.executeQuery(sql);
			                System.out.println("MRBT : "+sql);
			                while (rs.next()) {
			                	virtualNumberDTO = new VirtualNumberDTO();
			                	virtualNumberDTO.setE164(Str.CheckNullString(rs.getString("e164")));
			                	virtualNumberDTO.setName(Str.CheckNullString(rs.getString("extnum")));
			                	virtualNumberDTO.setVirtual(Str.CheckNullString(rs.getString("userparam")));
			                	virtualNumberDTO.setUsechk(rs.getInt("usechk"));
			                	iList.add(virtualNumberDTO);
			                }
			        }catch(Exception ex){
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
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
			if(count==0) count 			= iList==null? 0 : iList.size();
		}catch(Exception ex){
// 			out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
// 			return ;
		}finally{
			if (stmt != null) ConnectionManager.freeStatement(stmt);
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<VirtualNumberDTO>() ;
		VirtualNumberDTO tmpdto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			tmpdto = new VirtualNumberDTO();
			tmpdto.setE164("0101111222"+z) ;
			tmpdto.setName("0101111222"+z) ;
			tmpdto.setPosition("test_"+z) ;
			tmpdto.setDept("testDept_"+z) ;
			//tmpdto.setVirtual("v,0601111000"+z+",") ;
			tmpdto.setUsechk(z%2==0?1:0) ;//0:사용안함, 1:사용중
			tmpdto.setVirtual(tmpdto.getUsechk()==1?"v,0601111000"+z+",":"") ;
			//tmpdto.put("totalcnt", "25") ;
			iList.add(tmpdto);
		}
		count = iList.size();//nMaxitemcnt ;
		nTotalpage = 25;
		if(nNowpage >= nTotalpage) count = 4;
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
		 * 신규입력 화면으로 이동
		 */
		function goInsert(p_E164, p_file){
		    var parm 	= '&e164='+(p_E164?p_E164:'') + '&type='+(p_file?p_file:'');
		    var url 	= 'virtualNumEdit.jsp';//'virtualNumInsert.jsp';
		    if(p_file == ""){
				alert("등록된 가상발신번호가 없습니다!");
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
            var p_Passwd	= f2.txtPasswd.value;
            
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
            
            if(1!=1&& p_Passwd == ""){
    			Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"패스워드를 입력하지 않았습니다.");
    			return;
    		}
            else{//hc-add : 170327
    			editPro(str);
    			return ;
    		}
            
    	    var parm 	= '&hiPasswd='+p_Passwd;		//get형식으로 변수 전달.
    	    var url 	= 'virtualNumChk.jsp';
    	    
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;
    				var value = tempResult.replace(/\s/g, "");	// 공백제거
    		    	if(value=='OK'){ 
    			        editPro(str);
    			        return ;
    		    	}else if(value=='NO'){
    		    		Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"패스워드가 맞지 않습니다!");
    			    	return;
    		    	}else{
    		    		Ext.MessageBox.alert('경고', "<div style='width:370px;'>"+"관리자에게 문의하시기 바랍니다.");
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
	    function editPro(e164s){
	    	var f  = document.frm;
	    	var f2  = document.editForm;
	    	
	    	if(f2.txtDisplayNumber.value!=""){
				if(isNaN(f2.txtDisplayNumber.value)){
					alert("가상발신번호가 숫자가 아닙니다.");
					return;
				}
			}
			if(f2.txtFromNumber.value!=""){
				if(isNaN(f2.txtFromNumber.value)){
					alert("인증번호가 숫자가 아닙니다.");
					return;
				}
			}	
			
	    	var parm 	= '&e164='+f2.e164.value+'&displaynumber='+f2.txtDisplayNumber.value
	    				+'&fromnumber='+f2.txtFromNumber.value+'&userID='+f.hiUserID.value;	//get형식으로 변수 전달.
	    	var url 	= 'virtualNumEditPro.jsp';
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
			var _e164, _td;//alert('length='+_len);
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					_td = document.getElementById("h"+_i+"_2") ;
	 					if(_td) _td.innerHTML = datas[z].params[2] + "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_3") ;
	 					if(_td) _td.innerHTML = datas[z].params[3] + "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td) _td.innerHTML = "<FONT color=\"blue\">사용중</FONT>&nbsp;";
	 					
	                	_td = document.getElementById("h"+_i+"_5") ;
	                	if(_td) _td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction('"+_e164+"', '"+datas[z].params[1]+"', 0)\" >";
	 					if(++_idx == _len)
		 					return ;
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
        /**
         * 삭제 화면으로 이동
         */
        function goDelete(){
            var parm 	= '';
            var url 	= 'virtualNumDelete.jsp';		    
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
		       	str = "";

            f.e164.value = str;

            //alert('e164s='+str);
            
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/vnum/virtualNumDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * 삭제처리 후 출력
		 */
		function goDeleteDone(datas){
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;//alert('length='+_len);
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_0"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					_td = document.getElementById("h"+_i+"_2") ;
	 					if(_td) _td.innerHTML = "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_3") ;
	 					if(_td) _td.innerHTML = "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td) _td.innerHTML = "사용안함&nbsp;";
	 					
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
                    var parm = '&titlemsg='+'가상발신번호 설정'+'&msg='+'가상발신번호를 사용하지 않는 상태입니다.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("모든 설정이 삭제됩니다. 저장하시겠습니까?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/vnum/virtualNumSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // 지정 시간 통보 사용하기 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'가상발신번호 설정'+'&msg='+'가상발신번호 설정을 추가하여 주십시오.';
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
                var parm = '&titlemsg='+'가상발신번호 설정'+'&msg='+'검색 목록이 없습니다.';
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
                    var parm = '&titlemsg='+'가상발신번호 설정'+'&msg='+processname+'할 항목을 선택하여 주십시오.';
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
		function func_setAction(num, virtual, action) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1){
				goDelete();
				//window.open("virtualNumDelete.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
			}
			else{
				goInsert(num, virtual);
				//window.open("virtualNumInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
        	}
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
// 		 	document.cookie = "id_cookie_callblock" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  document.location.href = 'virtualNumList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==0 ){
					document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				}else{
					document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
				}
				document.getElementById('memname').innerHTML = "내선번호<font size='1px'>▽</font>";//△
				document.getElementById('virtual').innerHTML = "가상발신번호<font size='1px'>▽</font>";
			}
			else if(nField==1){
				if( lastSort==1 ){
					document.getElementById('memname').innerHTML = "<b>내선번호▲</b>";
				}else{
					document.getElementById('memname').innerHTML = "<b>내선번호▼</b>";							
				}
				document.getElementById('telnum').innerHTML = "전화번호<font size='1px'>▽</font>";
				document.getElementById('virtual').innerHTML = "가상발신번호<font size='1px'>▽</font>";
			}
			else if(nField==2){
				if( lastSort==nField ){
					document.getElementById('virtual').innerHTML = "<b>가상발신번호▲</b>";
				}else{
					document.getElementById('virtual').innerHTML = "<b>가상발신번호▼</b>";							
				}
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
		<% int menu = 3, submenu = 2; %>
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
	<input type='hidden' name ='hiDisplayNumber'	value=""/>
	<input type='hidden' name ='hiFromNumber' 		value=""/>
	<input type='hidden' name ='hiUserID'			value="<%=authGroupid%>">
	
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'virtualNumList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'virtualNumList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="선택 등록" onclick="func_setActionBySelected(0)">
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
                  <td width="43" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td>
                  <td width="43" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="92" onclick="sortNow(0,true);changeTitle(0);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>전화번호▲</b></td>
                  <td width="223" onclick="sortNow(1,true);changeTitle(1);" id="memname" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">내선번호<font size='1px'>▽</font></td>
                  <td width="110" onclick="sortNow(2,true);changeTitle(4);" id="virtual" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">가상발신번호<font size='1px'>▽</font></td>
                  <td width="90" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">인증번호</td>
                  <td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">사용유무</td>
                  <td width="40" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
                  <td width="10" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
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
		VirtualNumberDTO dto= null;
		String[] strVirtuals;
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (VirtualNumberDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					strVirtuals = 1!=dto.getUsechk()?new String[3]: (dto.getVirtual()+",a").split("[,]") ;
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="43" class="table_column"> <input type="checkbox" name="chkOpt" onclick="this.value=this.parentNode.parentNode.cells[2].innerHTML;" value="<%=dto.getE164()%>" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="43" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="92" id='h<%=idx%>_0' class="table_column"><%=dto.getE164()%></td>
		                <td width="207" id='h<%=idx%>_1' class="table_column"><%=dto.getName()%></td>
		                <td width=110 	id='h<%=idx%>_2' class='table_column'><%=strVirtuals[1]==null?"":strVirtuals[1]%>&nbsp;</td>
	                    <td width=90 	id='h<%=idx%>_3' class='table_column'><%=strVirtuals[2]==null?"":strVirtuals[2]%>&nbsp;</td>
		                <td width="80" id='h<%=idx%>_4' class="table_column">
		                <%
		                	if( 1>dto.getUsechk() ) out.print("사용안함&nbsp;");
		                	else out.print("<FONT color=\"blue\">사용중</FONT>&nbsp;");
		                %>
		                </td>
		                <td width="35" id='h<%=idx%>_5' class="table_column">
		                	<input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction('<%=dto.getE164()%>', '<%=1>dto.getUsechk()?"":dto.getVirtual()%>', 0)">
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
		       						<td align="left"> <a href="virtualNumList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="virtualNumList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"virtualNumList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="virtualNumList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="virtualNumList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
