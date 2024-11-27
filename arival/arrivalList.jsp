<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="sun.misc.BASE64Encoder"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"  pageEncoding="EUC-KR"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="acromate.common.util.LanguageMode"%>
<%@ page import="java.util.Properties"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="system.SystemConfigSet" %>

<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="java.util.*" %>
<%@ page import="acromate.common.util.*" %>

<%@ page import="dto.AddServiceArrivalDTO" %>
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
					//iList	= (ArrayList)addServiceList.getArrivalList(stmt, authGroupid);		// 데이타 조회
					AddServiceArrivalDTO idto;
					iList = new ArrayList<AddServiceArrivalDTO>();
			        
			        String sql = "\n select a.e164 as e164, "; 
			        sql = sql +  "\n 	b.name as name,  "; 
			        sql = sql +  "\n 	(Select deptname from table_dept where deptid = b.department) as dept,  ";
			        sql = sql +  "\n 	b.position as position,  ";
			        sql = sql +  "\n 	a.answerservice as usechk ";
			        sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum ";
			        if(authGroupid!=null) sql = sql +  "\n WHERE a.checkgroupid = '"+authGroupid+"' ";
			        sql = sql +  "\n order by a.e164 "; 
			        
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        ResultSet rs = null;
			        try {
			                rs = stmt.executeQuery(sql);
			                System.out.println("Arrival : "+sql);
			                while (rs.next()) {
			                	idto = new AddServiceArrivalDTO();
			                	idto.setE164(Str.CheckNullString(rs.getString("e164")));
			                	idto.setName(Str.CheckNullString(rs.getString("name")));
			                	idto.setDept(Str.CheckNullString(rs.getString("dept")));
			                	idto.setPosition(Str.CheckNullString(rs.getString("position")));
			                	idto.setUsechk(Str.CheckNullString(rs.getString("usechk")));
			                	iList.add(idto);
			                }
			        }catch(Exception ex){
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
			        
			        try{
			        	if(nModePaging==1){
			        		sql = "\n select count(*) ";
			        		sql = sql +  "\n from table_e164 a left outer join table_subscriber b on a.e164=b.phonenum ";
					        if(authGroupid!=null) sql = sql +  "\n WHERE a.checkgroupid = '"+authGroupid+"' ";
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
			if (stmt != null) ConnectionManager.freeStatement(stmt);
// 			out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
// 			return ;
		}finally{
			if(stmt!=null) ConnectionManager.freeStatement(stmt);
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<AddServiceArrivalDTO>() ;
		AddServiceArrivalDTO tmpdto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			tmpdto = new AddServiceArrivalDTO();
			tmpdto.setE164("0101111222"+z) ;
			tmpdto.setName("0101111222"+z) ;
			tmpdto.setPosition("test_"+z) ;
			tmpdto.setDept("testDept_"+z) ;
			tmpdto.setUsechk(z%2==0?"1":"0") ;//0:사용안함, 1:사용중
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
<title>착신전환</title>

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
// 	        obj.style.left = document.body.scrollLeft + (document.body.clientWidth / 2) - obj.offsetWidth/2;
// 	        obj.style.top = document.body.scrollTop + (document.body.clientHeight / 2) - obj.offsetHeight/2;
			obj.style.top = '200px';
	        obj.style.left = '400px';

	        SET_DHTML('popup_layer3');
	        //document.getElementById('popup_layer').style.display="none";	    //
	    }
		
	    function hiddenAdCodeDiv3() {
	        inf('visible'); //select box 보이기
			//setShadowDivVisible(false); //배경 layer 숨김
	        document.getElementById('popup_layer3').style.display="none";
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
	        
			f.hiToTime.value 	= f3.toTimeSi.value + f3.toTimeBun.value;
			f.hiFromTime.value 	= f3.fromTimeSi.value + f3.fromTimeBun.value;
			
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
	        
			var parmStart 	= '&e164='+f3.hiE164_Edit.value+'&startTime='+f.hiToTime.value+'&endTime='+f.hiFromTime.value;
			var urlStart	= "chkArrivalTime.jsp";
			
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
	    /**
		 * 특정시간별 착신전환 유형 등록
		 */ 
	    function goUpdate_Time(){
	        var f 				= document.frm;
	        var f2 				= document.frmPopup;
	        var f3 				= document.editForm;

	        var arrivalType_1	= f2.arrivalType_1;//document.getElementById("arrivalType_1");
	  		var arrivalType_2	= f2.arrivalType_2;//document.getElementById("arrivalType_2");
	  		var arrivalType_3	= f2.arrivalType_3;//document.getElementById("arrivalType_3");
	  		var selectType1		= f2.selectType1;//document.getElementById("selectType1");
	  		var txtNumber1		= f2.txtNumber1;//document.getElementById("txtNumber1");
	  		
	  		var chkForward_0	= f2.chkForward_0;//document.getElementById("chkForward_0");
	  		var txtNumber2		= f3.txtNumber2;//document.getElementById("txtNumber2");
	  		
	  		var chkForward_1	= f2.chkForward_1;//document.getElementById("chkForward_1");
	  		var waitTime		= f2.waitTime;//document.getElementById("waitTime");
	  		var txtNumber3		= f2.txtNumber3;//document.getElementById("txtNumber3");
	  		
	  		var chkForward_2	= f2.chkForward_2;//document.getElementById("chkForward_2");
	  		var txtNumber4		= f2.txtNumber4;//document.getElementById("txtNumber4");
	  		var chkForward_3	= f2.chkForward_3;//document.getElementById("chkForward_3");
	  		var txtNumber5		= f2.txtNumber5;//document.getElementById("txtNumber5");
	  		
	  		var time_Count 		= f2.hiTimeCount.value;
	  		var time_Count2 	= 0;

	  		if(txtNumber2 != null){
	  			time_Count2 = f3.hiTimeCount2.value;
	  		}
	  		
	  		f.hiE164.value		= f2.hiEi64.value;
			f.hiwaitTime.value 	= waitTime.value;				
			
			if(chkForward_0.checked==true){
				if(txtNumber2 != null && txtNumber2 != ""){
					f.hiToTime.value 	= f3.toTimeSi.value + f3.toTimeBun.value;
					f.hiFromTime.value 	= f3.fromTimeSi.value + f3.fromTimeBun.value;
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
					var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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

			f.procMode.value = "update";
			f.target = "procframe";
		   	//f.action="<%=StaticString.ContextRoot%>/arrivalSwitchUpdate_New.do";
		   	f.action="<%=StaticString.ContextRoot+pageDir%>/arival/arrivalSwitchUpdatePro.jsp";
		   	f.method="post";
		   	f.submit();
	    }
	    function goPopupInsertDone(datas){
			var e164 = "";
			for(var z=0; z<datas.length; z++){
				e164 = datas[z].params[0];
			}
			goEditPopup(e164);
	    }
	    
		function forwardType_New(no){
			var f2 				= document.frmPopup;
	        var selectType1 	= f2.selectType1;//document.getElementById("selectType1");
	        var txtNumber1 		= f2.txtNumber1;//document.getElementById("txtNumber1");
	        var chkForward_0 	= f2.chkForward_0;//document.getElementById("chkForward_0");
	        var chkForward_1 	= f2.chkForward_1;//document.getElementById("chkForward_1");
	        var chkForward_2 	= f2.chkForward_2;//document.getElementById("chkForward_2");
	        var chkForward_3 	= f2.chkForward_3;//document.getElementById("chkForward_3");
	        var waitTime 		= f2.waitTime;//document.getElementById("waitTime");
	        var txtNumber3 		= f2.txtNumber3;//document.getElementById("txtNumber3");
	        var txtNumber4 		= f2.txtNumber4;//document.getElementById("txtNumber4");
	        var txtNumber5 		= f2.txtNumber5;//document.getElementById("txtNumber5");        
	        var div1 			= f2.div1;//document.getElementById("div1");
	            
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
		 * 신규입력 화면으로 이동
		 */
		function goInsert(p_E164, p_Param){
		    var parm 	= '&hiEi64='+(p_E164?p_E164:'') + (p_Param?'&type='+p_Param:'');
		    var url 	= 'arrivalEdit.jsp';
		    getPage(url,parm);			
		}

		/**
		 * 특정시간 입력 화면으로 이동
		 */
		function goEditPopup(p_e164){
		    var parm 	= '&e164='+p_e164;
			var url 	= 'arrivalTimeEdit.jsp';
			
		    getPage3(url,parm);			
		}
		
		/**
		 * 착신전환 유형 등록
		 */ 
	    function goInsertPro(){ //goUpdate_New(){
	        var f 				= document.frm;
	        var f2 				= document.frmPopup;
	        
	        /* var str = f2.e164.value;
            str = str?str:"";
            alert("e164s="+str?str:"false");
            if(!str && f.chkOpt != undefined){
                if(f.chkOpt.length == undefined){
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
                }
            } */
           
	        var f3 				= document.editForm;
	  		var arrivalType_1	= f2.arrivalType_1;//document.getElementById("arrivalType_1");
	  		var arrivalType_2	= f2.arrivalType_2;//document.getElementById("arrivalType_2");
	  		var arrivalType_3	= f2.arrivalType_3;//document.getElementById("arrivalType_3");
	  		var selectType1		= f2.selectType1;//document.getElementById("selectType1");
	  		var txtNumber1		= f2.txtNumber1;//document.getElementById("txtNumber1");

			var chkForward_0	= f2.chkForward_0;//document.getElementById("chkForward_0");
	  		var txtNumber2		= !f3?null:f3.txtNumber2;//document.getElementById("txtNumber2");
	 		
	  		var chkForward_1	= f2.chkForward_1;//document.getElementById("chkForward_1");
	  		var waitTime		= f2.waitTime;//document.getElementById("waitTime");
	  		var txtNumber3		= f2.txtNumber3;//document.getElementById("txtNumber3");
	  		
	  		var chkForward_2	= f2.chkForward_2;//document.getElementById("chkForward_2");
	  		var txtNumber4		= f2.txtNumber4;//document.getElementById("txtNumber4");
	  		var chkForward_3	= f2.chkForward_3;//document.getElementById("chkForward_3");
	  		var txtNumber5		= f2.txtNumber5;//document.getElementById("txtNumber5");
	  		
	  		var time_Count 		= f2.hiTimeCount.value;
	  		var time_Count2 	= 0;
	  		
	  		if(txtNumber2 != null){
	  			time_Count2 = f3.hiTimeCount2.value;
	  		}
	  		
	  		f.hiE164.value		= f2.hiEi64.value;
			f.hiwaitTime.value 	= waitTime.value;				
			
			if(chkForward_0.checked==true){
				if(txtNumber2 != null && txtNumber2 != ""){
					f.hiToTime.value 	= f3.toTimeSi.value + f3.toTimeBun.value;
					f.hiFromTime.value 	= f3.fromTimeSi.value + f3.fromTimeBun.value;
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
						getMsgPage(url,parm);
						return;
					}else{
						f.hiTxtNumber1.value = txtNumber1.value;
					}
				}
			}else if(arrivalType_3.checked==true){
				if(chkForward_0.checked==true){
//					alert("time_Count : "+time_Count);
//					alert("time_Count2 : "+time_Count2);
//					alert("txtNumber2.value : "+txtNumber2.value);
					
					if(time_Count*1.0 == 0 && time_Count2*1.0 == 0){
						if(txtNumber2.value==""){
							//alert("착신전환 할 지정번호를 입력하지 않았습니다!");
							var parm = '&titlemsg='+'착신전환 설정'+'&msg='+'착신전환 할 지정번호를 입력하지</BR>않았습니다!';
							var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
						var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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
					var url  = '<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp';
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

			f.procMode.value = "insert";
			f.target = "procframe";
		   	//f.action="<%=StaticString.ContextRoot%>/arrivalSwitchUpdate_New.do";
		   	f.action="<%=StaticString.ContextRoot+pageDir%>/arival/arrivalSwitchUpdatePro.jsp";
		   	f.method="post";
		   	f.submit();
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
	 					_td = document.getElementById("h"+_i+"_1") ;
	 					if(_td){
	 						if(datas[z].params[1]!="0") _td.innerHTML = "<FONT color=\"blue\">사용중</FONT>&nbsp;";
	 						else						_td.innerHTML = "사용안함&nbsp;";
	 					}
	                	//_td = document.getElementById("h"+_i+"_2") ;
	                	//if(_td) _td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"수정\" onclick=\"func_setAction(0, '"+_e164+"')\" >";
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
        /* function goDelete(){
            var parm 	= '';
            var url 	= 'arrivalDelete.jsp';		    
            getPage(url,parm);			
        } */

		/**
	     * 삭제 처리
	     */
	    function goDeletePro(p_E164, p_ForwardNumber, p_Start, p_End){
	        var f   	= document.frm;
	        /* var str = "";
            if(f != undefined && f.chkOpt != undefined){
                if(f.chkOpt.length == undefined){
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
                }
            }else
		       	str = "";

            f.e164.value = str;
             */
		    var parm 	= '&forwardNumber='+p_ForwardNumber+'&e164='+p_E164+'&startTime='+p_Start+'&endTime='+p_End+'&userID='+f.hiUserID.value;		//get형식으로 변수 전달.
		    var url 	= 'arrivalDeletePro.jsp';

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
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td) _td.innerHTML = "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_5") ;
	 					if(_td) _td.innerHTML = "&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_6") ;
	 					if(_td) _td.innerHTML = "사용안함&nbsp;";
	 					
	                	_td = document.getElementById("h"+_i+"_7") ;
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
                    var parm = '&titlemsg='+'가상발신번호 설정'+'&msg='+'가상발신번호를 사용하지 않는 상태입니다.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("모든 설정이 삭제됩니다. 저장하시겠습니까?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/vnum/arrivalSavePro.jsp";
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
		function func_setAction(action, num, virtual) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1){
				//goDelete();
			}
			else{
				goInsert(num, virtual);
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
			  document.location.href = 'arrivalList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==nField ) 	document.getElementById('telnum').innerHTML = "<b>전화번호▲</b>";
				else					document.getElementById('telnum').innerHTML = "<b>전화번호▼</b>";
				//document.getElementById('memname').innerHTML = "이름<font size='1px'>▽</font>";//△
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
		<% int menu = 3, submenu = 13; %>
		<table id="menu" width="180" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	<!--end--왼쪽페이지-->
	</td>
	<td><table>
<!-- <TBODY> -->
<FORM name="frm" method="post">
	<input type='hidden' name ='grpid' value="<%=authGroupid%>">
	<input type='hidden' name ='e164' value="">
	
	<input type='hidden' name ='procMode' value="">
	
	<input type='hidden' name ='hiE164' 			value=""/>
	<input type='hidden' name ='deleteStr' 			value=""/>
	<input type='hidden' name ='insertStr' 			value=""/>
	
	<input type='hidden' name = 'hiUserID'			value="<%=authGroupid%>">
	
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
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'arrivalList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'arrivalList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1 &&1!=1) { %>
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
                  <%-- <td width="43" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td width="100" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">번호</td>
                  <td width="500" onclick="sortNow(0,true);changeTitle(0);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>전화번호▲</b></td>
                  <td width="250" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">사용유무</td>
                  <td width="100" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
                  <td width="50" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
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
		AddServiceArrivalDTO dto= null;
		String[] strVirtuals;
		String 	commonservice; 
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (AddServiceArrivalDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					commonservice = dto.getUsechk().substring(3, 4);
					
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <%-- <td width="43" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=dto.getE164()%>" > </td> --%>
		                <td width="100" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="500" id='h<%=idx%>_0' class="table_column"><%=dto.getE164()%></td>
		                <td width="250" id='h<%=idx%>_1' class="table_column">
		                <%
		                	if( !"0".equals(commonservice) ) out.print("<FONT color=\"blue\">사용중</FONT>&nbsp;");
		                	else out.print("사용안함&nbsp;");
		                %>
		                </td>
		                <td width="100" id='h<%=idx%>_2' class="table_column">
		                	<input type="button" name="btnAction" style="height: 18px" value="수정" onclick="func_setAction(0, '<%=dto.getE164()%>')">
		                </td>
		                <td width="50" class="table_column">&nbsp;</td>
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
		       		<td colspan = 1 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="arrivalList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="arrivalList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"arrivalList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 1 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="arrivalList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="arrivalList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
<div id="popup_layer3" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
