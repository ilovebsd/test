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

<%@ page import="dto.ipcs.IpcsListDTO" %>
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
  	//��ǰ��(�𵨸�) ���� ��ȸ
  	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				goodsName 		= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)
	 */
	 
	 int count = 0; 
	
	String 	s_EnendPointID	= "";//request.getParameter("hiddenEnendPointID");	// �˻����� ID
	String 	s_E164			= "";//request.getParameter("hiddenE164");			// �˻����� ��ȣ
	String 	s_Name			= "";//request.getParameter("hiddenName");			// �˻����� �̸�
 	String 	search_gubun	= "";//StringUtil.null2Str(request.getParameter("hiddenSearch_gubun"),"1");	// �˻�����
 	String 	search_field	= "";//new String (Str.CheckNullString(request.getParameter("hiddenSearch_field")).getBytes("8859_1"), "euc-kr");
 	String  goodsName = "", maxE164="";
 	
		ArrayList 		iList = null;
		DataStatement 	stmt = null;
		if(nModeDebug!=1){
			try{
				if(nAllowUser==1){		
					String sql="";
			        ResultSet rs = null;
			        
					IpcsListDTO 		ipcsListDTO;
					iList 	= new ArrayList<IpcsListDTO>();
					//if (GroupID == 0) return addrBookList;
			        //System.out.println("���� endpointid : "+endpointid);
			        
			        sql = "SELECT sub.name as name, sub.position as position, contact.SIGNALADDRESS as signalAddress, ";
			        sql = sql + "\n  e164.startFlag as startFlag, ep.ENDPOINTID as endPointId, ep.ZONECODE as zoneCode, e164.extensionnumber as extensio, ";
			        sql = sql + "\n  route.e164 as e164, contact.registerid as registerid, ";
			        sql = sql + "\n  (SELECT deptname FROM TABLE_DEPT WHERE deptid = sub.department) as deptName, ";
			        sql = sql + "\n  (SELECT physical_address FROM Table_provision WHERE e164 = route.e164 And use = 1) as physicalAddress ";
			        //sql = sql + "\n  ,(SELECT count(*) FROM table_connectedcall WHERE calleeendpointid = ep.ENDPOINTID or callerendpointid = ep.ENDPOINTID) as callState, ";
			        sql = sql + "\n  ,(SELECT count(*) FROM table_connectedcall WHERE calleee164 = route.e164 or callere164 = route.e164) as callState, ";
			        sql = sql + "\n  e164.answerservice, ";
			        //sql = sql + "\n  (SELECT starttime FROM table_connectedcall WHERE calleeendpointid = ep.ENDPOINTID or callerendpointid = ep.ENDPOINTID) as starttime ";
			        //sql = sql + "\n  (SELECT starttime FROM table_connectedcall WHERE calleee164 = route.e164 or callere164 = route.e164) as starttime ";
			        sql = sql + "\n  (SELECT starttime FROM table_connectedcall WHERE calleee164 = route.e164 or callere164 = route.e164 limit 1 ) as starttime ";
			        sql = sql + "\n  From Table_SipEndpoint ep ";
			        sql = sql + "\n  LEFT JOIN  table_e164Route route ON ep.ENDPOINTID = route.ENDPOINTID  and route.routingNumbertype in (1, 2, 5) ";
			        sql = sql + "\n  LEFT OUTER JOIN TABLE_SIPCONTACT contact ON ep.ENDPOINTID = contact.ENDPOINTID ";
			        sql = sql + "\n  JOIN  table_e164 e164 ON e164.e164 = route.e164 "; 
			        sql = sql + "\n  LEFT OUTER JOIN  table_SUBSCRIBER sub ON ep.ENDPOINTID = sub.id ";
			        sql = sql + "\n  WHERE ep.ENDPOINTID not like 'ACRO_MS_%' ";
			        sql = sql + "\n    And ep.ENDPOINTID not in (select coalesce(auth_id,'') from NASA_TRUNK_SET) ";
					
			        sql = sql + "\n    And ep.endpointclass = 33 ";		// �ű���� ������ �߰��� �κ� (2012.04.03)
			        
			        /* if(!"".equals(search_field.trim())){
			        	if("1".equals(search_gubun)){
			        		sql += "\n    and ep.ENDPOINTID like '%" + search_field + "%'";
			        	}else if("2".equals(search_gubun)){
			        		sql += "\n    and route.e164 like '%" + search_field + "%'";
			        	}else if("3".equals(search_gubun)){
			        		sql += "\n    and sub.name like '%" + search_field + "%'";
			        	}
			        } */
			        
			        if(authGroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+authGroupid+"' ";
			        
			        sql = sql + "\n  group by sub.name, sub.position, contact.SIGNALADDRESS, e164.startFlag, ep.endPointId, ep.ZONECODE, e164.extensionnumber, route.e164, contact.registerid, sub.department, e164.answerservice ";
			        //sql = sql + "\n  group by sub.name, sub.position, contact.SIGNALADDRESS, e164.startFlag, ep.endPointId, ep.ZONECODE, e164.extensionnumber, route.e164, contact.registerid, sub.department ";
			        //sql = sql + "\n  Order by ep.ZONECODE offset "+pageNo+" limit "+pageSize ;
			        //sql = sql + "\n  Order by route.e164, sub.name offset "+pageNo+" limit "+pageSize ;
			        sql = sql + "\n  Order by route.e164, sub.name ";
			    
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        try {
			        	 System.out.println("MRBT : "+sql);
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
			                
			                String[]    strOpt  = null;
			                String 		loginID	= "";
			                while (rs.next()) {
			                	strOpt = Str.CheckNullString(rs.getString("endPointId")).split("[@]");
			                    loginID = strOpt[0];
			                    
			                	ipcsListDTO = new IpcsListDTO(
			                        //OwnerID,                        
			                    	Str.CheckNullString(rs.getString("name")),
			                        Str.CheckNullString(rs.getString("position")),
			                        Str.CheckNullString(rs.getString("signalAddress")),
			                        rs.getInt("startFlag"),                            
			                        Str.CheckNullString(rs.getString("endPointId")),
			                        Str.CheckNullString(rs.getString("zoneCode")),
			                        maxE164 = Str.CheckNullString(rs.getString("e164")),
			                        Str.CheckNullString(loginID),
			                        Str.CheckNullString(rs.getString("extensio")),
			                        Str.CheckNullString(rs.getString("registerid")),
			                        Str.CheckNullString(rs.getString("deptName")),
			                        Str.CheckNullString(rs.getString("physicalAddress")),
			                        rs.getInt("callState"),
			                        Str.CheckNullString(rs.getString("answerservice")),
			                        Str.CheckNullString(rs.getString("starttime"))
			                    );
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
			        		sql = "\n select count(*) ";
			        		sql = sql + "\n  From Table_SipEndpoint ep ";
					        sql = sql + "\n  WHERE ep.ENDPOINTID not like 'ACRO_MS_%' ";
					        sql = sql + "\n    And ep.ENDPOINTID not in (select coalesce(auth_id,'') from NASA_TRUNK_SET) ";
					        sql = sql + "\n    And ep.endpointclass = 33 ";		// �ű���� ������ �߰��� �κ� (2012.04.03)
					        if(authGroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+authGroupid+"' ";
					        System.out.println("totalcount.sql : "+sql);
					        rs = stmt.executeQuery(sql);
			                while (rs.next()){
			                	count = rs.getInt(1) ;
			                }
			                System.out.println("totalcount="+count);
			                if(rs!=null) rs.close();
			                
			                /* 
			                sql = "\n select max(route.E164) ";
			        		sql = sql + "\n  From Table_SipEndpoint ep ";
			        		sql = sql + "\n  LEFT JOIN  table_e164Route route ON ep.ENDPOINTID = route.ENDPOINTID and route.routingNumbertype in (1)  ";    
					        sql = sql + "\n  WHERE ep.ENDPOINTID not like 'ACRO_MS_%' ";
					        sql = sql + "\n    And ep.ENDPOINTID not in (select coalesce(auth_id,'') from NASA_TRUNK_SET) ";
					        sql = sql + "\n    And ep.endpointclass = 33 ";		// �ű���� ������ �߰��� �κ� (2012.04.03)
					        if(authGroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+authGroupid+"' ";
					        System.out.println("maxe164.sql : "+sql);
					        rs = stmt.executeQuery(sql);
			                while (rs.next()){
			                	maxE164 = Str.CheckNullString(rs.getString(1)) ;
			                }
			                if(rs!=null) rs.close();
			                 */
			        	}	
			        }catch(Exception ex){}finally{if(rs!=null) rs.close();}
				}
				if(count==0) count = iList==null? 0 : iList.size();
//	 			values = new String[count][3];
			}catch(Exception ex){
				ex.printStackTrace() ;
			}finally{
				if (stmt != null) ConnectionManager.freeStatement(stmt);
			}
		}else if(nAllowUser==1){
			iList = new ArrayList<IpcsListDTO>() ;
//	 		HashMap smpitem;
			IpcsListDTO mrbtDTO = null;
			for(int z=0; z<nMaxitemcnt; z++){
				mrbtDTO = new IpcsListDTO();
				mrbtDTO.setE164("0101111222"+z) ;
				mrbtDTO.setName("0101111222"+z) ;
				mrbtDTO.setPosition("test_"+z) ;
// 				mrbtDTO.setDept("testDept_"+z) ;
// 				mrbtDTO.setFilename(z%5==0?"3":(z%3==0)?"1":"0");//0:������, 1:��ü��ȣ, 3:Ư����ȣ
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

<title>�˶� �뺸</title>

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
     alert("<%=LanguageMode.x("���̵� �Է��ϼ���.","Please insert ID.")%>");
     document.loginForm.id.focus();
  } else if (document.loginForm.pwd.value == "") {
     alert("<%=LanguageMode.x("�н����带 �Է��ϼ���.","Please insert password.")%>");
     document.loginForm.pwd.focus();
  } else {
      if(document.loginForm.id_save.checked){
        SetCookie("id_cookie_ipcs",document.loginForm.id.value, 90); //��Ű�� �Ϸ� ����
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

//3. cookie�� ����� �������� name�� �����ϴ� �Լ�
//���⿡�� �����Ѵٴ� �ǹ̴� cookie ������ expires ��¥�� ���ŷ� �ٲ۴ٴ� ���� �ǹ��Ѵ�.
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
	//if(groupid) SetCookie("id_cookie_ipcs", groupid, 90); //��Ű�� �Ϸ� ����
	//delCookie("id_cookie_ipcs", '');
}

function func_find(){
	//location.href="http://acromate.anyhelp.net/";
	window.open("http://remote.callbox.kt.com/", "_blank", "width=900,height=700,resizable=1,scrollbars=1") ;
}

/**
 * üũ�ڽ� ��ü ����/����
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
    || key  == 35 || key  == 36 || key  == 37 || key  == 39  // ����Ű �¿�,home,end  
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
		        alert("����") ;
		    }
		}
		
		/**
		 * �޼��� ������ �̵� ó���κ� 
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
		        alert("����") ;
		    }
		}
		
		/**
		 * Ŭ���� �˾� �����ֱ�
		 */		
		function showAdCodeDiv(type) {		
		    try{
		        setShadowDivVisible(false); //��� layer
		    }catch(e){
		    }
		    setShadowDivVisible(true); //��� layer
		
		    var d_id 	= 'popup_layer';
		    var obj 	= document.getElementById(d_id);

		    if(type == 2){
			    obj.style.zIndex=998;
			    obj.style.display = "";
			    obj.style.top = 100;
			    obj.style.left = 400;
			}else{
				obj.style.zIndex=998;
			    obj.style.display = "";
			    obj.style.top = '150px';
			    obj.style.left = '250px';	
			}
		    
		    SET_DHTML('popup_layer');
		}
		
		/**
		 * ��� Ŭ���� �˾� �����
		 */
		function hiddenAdCodeDiv() {
		    inf('visible'); //select box ���̱�
		    setShadowDivVisible(false); //��� layer ����
		
		    document.getElementById('popup_layer').style.display="none";
		}
		
/////////////////////// Zone ���� �߰�
	    function getPage5(url, parm){
	        inf('hidden');
	        engine.execute("POST", url, parm, "ResgetPage5");
	    }
	
	    function ResgetPage5(data){
	        if(data){
	            document.getElementById('popup_layer2').innerHTML = data;
	            showAdCodeDiv2();
	        }else{
	            alert("����") ;
	        }
	    }
	
	    function showAdCodeDiv2() {
	        try{
	            setShadowDivVisible(false); //��� layer
	        }catch(e){
	        }
	        setShadowDivVisible(true); //��� layer
	
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
	        inf('visible'); //select box ���̱�
			//setShadowDivVisible(false); //��� layer ����
	        document.getElementById('popup_layer2').style.display="none";
	
	    }
///////////////////////

		function AreaNoSelect(){
			var f2		= document.Insertlayer1;
			f2.txtNumber1.focus();
		}
				
		/**
		 * ������ȣ ������ ���� �Է��׸��� ����
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
	            alert("������ȣ ������ ������ �ּ���!");
	        }
	    }
	    
		/**
		 * ���� ��ư
		 */				
		function getRadioValue(obj){
			var v   = "";
			theObj  = eval(obj);
	
			for(i = 0; i < theObj.length; i++){
			  if(theObj[i].checked)v=theObj[i].value;
			}
			return v;
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
		
		function goZone(action_Type){//ipcsExtInsert2.jsp
			var f2 	= document.Insertlayer2;
			if(f2.zoneChk.value=="1"){
				alert("Zone Code�� �ڵ��������� �Ǿ� �ֽ��ϴ�.");
				return;
			}
			    
	    	var p_formtype		= action_Type;
	    	//var p_formtype		= "";
	        var parm = '&formtype='+p_formtype;		//get�������� ���� ����.                
	        var url = "<%=StaticString.ContextRoot+pageDir%>/cmn/selectZone.jsp";
	        getPage5(url,parm);
	    }
		
		function goAddZone(obj, id, p_formtype){ //selectZone.jsp  	
	        if(p_formtype=="I"){
		        obj.style.backgroundColor="a8d3aa";
		       	document.Insertlayer2.txtZone.value = id;
		    }else{
		        obj.style.backgroundColor="a8d3aa";
		       	document.Editlayer1.txtZone.value = id;	    
		    }          	
	    }
		
		function selectZone(){//ipcsExtInsert2.jsp
			var f2 	= document.Insertlayer2;
			if(f2.zoneChk.value=="1"){
				f2.txtZone.value = "";
			}
	    }
		
		function goZone_Edit(action_Type){
			var f2 	= document.Editlayer1;
			if(f2.zoneChk.value=="1"){
				alert("Zone Code�� �ڵ��������� �Ǿ� �ֽ��ϴ�.");
				return;
			}
			    
	    	var p_formtype		= action_Type;
	        var parm = '&formtype='+p_formtype;		//get�������� ���� ����.                
	        var url = "<%=StaticString.ContextRoot+pageDir%>/cmn/selectZone.jsp";
	        getPage5(url,parm);
	    }

	    function selectZone_Edit(){
			var f2 	= document.Editlayer1;
			if(f2.zoneChk.value=="1"){
				f2.txtZone.value = "";
			}
	    }
	    
		/**
	     * ���� ȭ������ �̵�
	     */
	    function goUnRegister(p_EndpointId){
	        var parm 	= '&endpointId='+p_EndpointId;
	        var url 	= 'unRegister.jsp';
	        //alert('p_EndpointId='+p_EndpointId);
	        getMessagePage(url,parm);
	    }
	    function unRegisterPro(){		
			var f 			= document.frm;
		    var f2 			= document.unRegisterLayer;
		    var endpoingId 	= f2.hiUnEndpointId.value;
		    
		    var parm 	= '&endPointId='+endpoingId;		//get�������� ���� ����.
		    var url 	= 'unRegisterPro.jsp';
			
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
					
			    	if(value=='OK'){ 
			    		alert("������� �Ǿ����ϴ�!");
			    		goRefresh();		    		
			    	}else if(value=='NO'){
				    	alert("��������� �����Ͽ����ϴ�!");
				    	return;			
			    	}else{
				    	alert("�����ڿ��� �����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;			    	
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
				} 
			});
		}
	    
	    /**
		 * ������ȣ ���� ȭ������ �̵�
		 */
		function goExtNumUpdate(num){
	    	var parm 		= '&e164='+num;
		    var url 		= 'ipcsExtNumUpdate.jsp';
			
		    getPage(url,parm);			
		}
	    
		function goExtNumUpdatePro(){
			var f   = document.frm;
			var f2   = document.Updatelayer1;

		   	f2.target = "procframe";
		   	f2.action = "<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtNumUpdatePro.jsp";
		   	f2.method = "post";
		   	f2.submit();			
		}
		function goExtNumUpdateDone(datas){
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_1"))
			  {
			  	_e164 = _p.innerHTML ;
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	                	_td = document.getElementById("h"+_i+"_2") ;
	                	if(_td) _td.innerHTML = datas[z].params[1];
	 					if(++_idx == _len){
		 					return ;
	 					}
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
	    /**
		 * ����ȭ������ �̵�
		 */
		 function showEdit(p_EndPointId, p_E164){
		    var parm 		= '&endPointID='+p_EndPointId+"&e164="+p_E164;		//get�������� ���� ����.
		    var url 		= 'ipcsExtEdit.jsp';
			
		    getPage(url,parm);			
		}
	    
		 /**
		 * ���� ���� �����ϱ�
			 */
			function goEditSave(){
			 //alert(('goSave');
				var f 				= document.frm;
				var f2 				= document.Editlayer1;
				var p_EndPointID 	= f2.hiEndPointID.value;	// EndPointID		
				var p_Ei64 			= f2.hiEi64.value;			// Ei64
				var p_Name			= f2.txtName.value;			// �̸�
				var p_Position 		= f2.position.value;		// ����
				var p_Dept			= f2.dept.value;			// �μ�
				//var p_Parent		= f2.dept.value;			// �μ�
				var p_Mobile		= f2.txtMobile.value;		// �ڵ���
				var p_HomeNumber	= f2.txtHomeNumber.value;	// ����ȭ
				var p_Mail			= f2.txtMail.value;			// �����ּ�
				var p_Pass			= f2.txtPass.value;			// ��й�ȣ
				var p_Extension 	= f2.txtExtension.value;	// �Է¹��� ������ȣ
				var p_OldExtension 	= f2.hiOldExtension.value;	// ��ȸ�� ������ȣ
				 
				var p_AuthE164		= "0";						// ��ȭ��ȣ ���� ����
				var p_AuthIPChk		= "0";						// IP���� ����
				var p_AuthIP		= "";						// IP����
				var p_AuthPortChk	= "0";						// Port���� ����
				var p_AuthPort		= "0";						// Port����
				var p_AuthMd5		= "0";						// MD5 ���� ����
				var p_AuthRegister	= "0";						// Register ����
				var p_AuthStale		= "0";						// Stale ����
				var p_AuthInvite	= "0";						// Invite ����
				var p_AuthID		= "";						// ����ID
				var p_AuthPass		= "";						// ��й�ȣ
				var p_ZoneCode 		= f2.txtZone.value;
				
			    // �ʼ� �Է��׸� üũ
			    if(f2.txtName.value == ""){
			    	alert("�̸��� �Է����� �ʾҽ��ϴ�!");
			    	return;
		        }
				if(f2.position.value == ""){
			    	alert("������ �������� �ʾҽ��ϴ�.");
			    	return;
			    }		    			
			    if(f2.dept.value == ""){
			    	alert("�μ��� �������� �ʾҽ��ϴ�.");
			    	return;
			    }			
				
				//���� üũ
				if(f2.txtMobile.value!=""){
				    if(isNaN(f2.txtMobile.value)){
				    	alert("�ڵ��� �Է°��� ���ڰ� �ƴմϴ�.");
				    	return;
			        }
		        }
		        if(f2.txtHomeNumber.value!=""){
					if(isNaN(f2.txtHomeNumber.value)){
				    	alert("����ȣ �Է°��� ���ڰ� �ƴմϴ�.");
				    	return;
				    }			
				}
				
				// ���� üũ
				if(f2.txtMail.value!=""){
					if((f2.txtMail.value.indexOf("@")==-1) || (f2.txtMail.value.indexOf(".")==-1)){				  
					alert("�̸����� ��Ȯ�� �Էµ��� �ʾҽ��ϴ�.");
					f2.txtMail.focus();
					return; 
					}
		        }
				
				// ��й�ȣ üũ
				if(1!=1&& f2.txtPass.value==""){
					alert("��й�ȣ�� �Էµ��� �ʾҽ��ϴ�.");
					return; 
		        }
				// NAT Zone üũ
//				if(f2.txtZone.value==""){
//					alert("NAT Zone �� ���õ��� �ʾҽ��ϴ�.");
//					return; 
//		        }
			    // MD5 ������ ��� ID, ��й�ȣ üũ
			    //if(f2.md5Auth.checked){
					if(f2.txtid.value=="" || f2.txtpassword.value==""){
						alert("MD5  ���� ID �� ��й�ȣ��  �Էµ��� �ʾҽ��ϴ�.");
						return; 
			        }
			    //}
			    // IP ������ ��� IP üũ
			    if(f2.ipAuth.checked){
					if(f2.txtip.value=="" || f2.txtport.value==""){
						alert("���� IP �� PORT ��  �Էµ��� �ʾҽ��ϴ�.");
						return; 
			        }
			    }
				
				// ������ȣ üũ
				if(f2.txtExtension.value==""){
					alert("������ȣ�� �Էµ��� �ʾҽ��ϴ�.");
					return; 			
				}
				if(p_Extension.length<1){
					alert("������ȣ�� �ּ� 1�ڸ� �̻��̾�� �մϴ�.");
					return; 			
				}
			    if(isNaN(f2.txtExtension.value)){
			    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
			    	return;
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
			    				    		
				// ��ȭ��ȣ ���� (0: �̻��, 1: ���)
				if(f2.e164Auth.checked){
					p_AuthE164 = "1";				
				}else{
					p_AuthE164 = "0";
				}
				f.hiAuthE164.value = p_AuthE164;

				// IP ���� (0: �̻��, 1: ���)
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

				// Port ���� (0: �̻��, 1: ���)
				if(f2.ipPort.checked){
					p_AuthPortChk 		= "1";
				}else{
					p_AuthPortChk 		= "0";
				}
				f.hiAuthPortChk.value 	= p_AuthPortChk;

				// MD5 ���� (0: �̻��, 1: ���)
				//if(f2.md5Auth.checked){
					// MD5 ���� ��й�ȣ üũ ��� �߰� (IMS ��) ----------------------------------------
//				if(("ACRO-CBS"=="<%//=goodsName%>")||("ACRO-HCBS"=="<%//=goodsName%>")){
					var p_MacAuthPass = f2.txtpassword.value;
					var p_MacPass_Chk = f2.txtpass_chk.value;
					
					if(p_MacAuthPass != p_MacPass_Chk){
						alert("IP�ܸ� ��й�ȣ�� IP�ܸ� ��й�ȣ Ȯ�� �Է°��� ���� �ʽ��ϴ�.");
						return;
					}
//				}
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
			    
			    f.Edit_PAGE.value			= "<%=nNowpage/* iPageNum */%>"
		    
		    if(p_Extension == p_OldExtension){
				// �μ� SMS ��ȣü ��ϵ� ��ȣ���� üũ
			    var parm_2 	= '&hiE164='+p_Ei64;		//get�������� ���� ����.
			    var url_2 	= 'chkSmsKeyNumber_2.jsp';
			    //alert('test='+p_Ei64);	    
				Ext.Ajax.request({
					url : url_2 , 
					params : parm_2,
					method: 'POST',
					success: function ( result_2, request ) {
						var tempResult_2 = result_2.responseText;					
						var value_2 = tempResult_2.replace(/\s/g, "");	// ��������
						
				    	if(value_2=='OK'){ 
				    		f.target = "procframe";
						   	f.action="<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtEditPro.jsp";//ipcsEdit.do
						    //alert(('action='+f.action);
						   	f.method="post";
						   	f.submit();
				    	}else{
					    	alert("�μ� ��ǥ��ȣ SMS ���Ź�ȣ��  ��ϵ� ��ȣ �Դϴ�! SMS ���Ź�ȣ ������ ������ �����ϼ���!");
					    	return;			
				    	}
					},
					failure: function ( result, request) { 
						Ext.MessageBox.alert('Failed', result.responseText); 
					} 
				});
		   	}else{
			    var parm 	= '&hiExtension='+p_Extension+'&hiEi64='+p_Ei64;		//get�������� ���� ����.
			    var url 	= 'chkExtension.jsp';
			    //alert('test2='+p_Ei64);
				Ext.Ajax.request({
					url : url , 
					params : parm,
					method: 'POST',
					success: function ( result, request ) {
						var tempResult = result.responseText;					
						var value = tempResult.replace(/\s/g, "");	// ��������
						
				    	if(value=='OK'){ 
				    		f.target = "procframe";
						   	f.action="<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtEditPro.jsp";//ipcsEdit.do;
						   	f.method="post";
						   	f.submit();
				    	}else if(value=='NO2'){
					    	alert("�̹� ������� ���� ��ȣ  �Դϴ�!");
					    	return;
				    	}else if(value=='NO4'){
					    	alert("�̹� ������ȣ �Ǵ� Ư����ȣ�� ������� ��ȣ �Դϴ�!");
					    	return;
						}else if(value=='NO5'){
					    	alert("�μ� ��ǥ��ȣ SMS ���Ź�ȣ��  ��ϵ� ��ȣ �Դϴ�! SMS ���Ź�ȣ ������ ������ �����ϼ���!");
					    	return;
				    	}else{
					    	alert("�̹� ������� ���� ��ȣ  �Դϴ�!");
					    	return;			
				    	}					
					},
					failure: function ( result, request) { 
						Ext.MessageBox.alert('Failed', result.responseText); 
						//Ext.MessageBox.alert('Failed', "�̹� ��ϵ� ���̵� �Դϴ�!");
					} 
				});
		   	}
		}	
		 
		function goEditDone(datas){
			var _o=null, _p=null;
			var _i=0, _idx=0, _len = datas.length;
			var _e164, _td;
			while(_o=document.getElementById("g"+_i))
			{
			  if(_p=document.getElementById("h"+_i+"_1"))
			  {
			  	_e164 = _p.innerHTML ;//paramE164, paramEpId, paramExtnum, paramIp (, paramMac, paramAwrSvc)
		  		for(var z=0; z<datas.length; z++){
	 				if(datas[z].params[0]==_e164) {
	 					<%-- _td = document.getElementById("imgStus"+_i) ;//state
 						if(_td){
 							if(datas[z].params[3] && datas[z].params[3].length>0){
 								_td.onclick = "javascript:goUnRegister('"+datas[z].params[1]+"');";
 					     		if(datas[z].params[5]=='1' || datas[z].params[5]=='3'){
	 		                		_td.src = "<%=StaticString.ContextRoot%>/imgs/forward_img.png";
	 		                		_td.alt = "������ ������ȯ";
 					     		}else if(datas[z].params[5]=='2'){
 		 		                	_td.src = "<%=StaticString.ContextRoot%>/imgs/forward_img.png";
 		 		                	_td.alt = "���Ǻ� ������ȯ";
 	 					     	}else {
 		 		                	_td.src = "<%=StaticString.ContextRoot%>/imgs/on_img.png";
 		 		                	_td.alt = "��ϿϷ�";
 	 					     	}
 		                	}else{
 		                		_td.onclick = "";
 		                		_td.src = "<%=StaticString.ContextRoot%>/imgs/off_img.png";
 		                		_td.alt = "�̵��";
 		                	}
 						} --%>
	 					_td = document.getElementById("h"+_i+"_2") ;
 						if(_td)	_td.innerHTML = datas[z].params[2];//extnum
 						
	 					_td = document.getElementById("h"+_i+"_3") ;
 						if(_td)	_td.innerHTML = datas[z].params[3];//ip
 						
	 					if(++_idx == _len){
		 					return ;
	 					}
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
		/**
		 * �ű��Է� ȭ������ �̵�
		 */
		function goInsert(p_E164, p_Param){
		    var parm 	= (p_E164?'&maxE164='+p_E164:'')+(p_Param?'&e164='+p_Param:'');
		    var url 	= 'ipcsExtInsert.jsp';
		    /* if(p_Param == 0 || p_Param == ""){
				alert("�߽������� ������� �ʰ� �ֽ��ϴ�!");
				return;
			} */
		    
		    getPage(url,parm);			
		}

		/**
		 * �ű� �������� �Է�ȭ������ �̵�_01
		 */
		function goUserInfoInsert(){
			//alert("goUserInfoInsert");
			
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    var p_EndPointID 	= "";//f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    var p_Extension 	= f2.txtNumber2.value;
			
		    var p_AuthPasswd 		= f2.txtpassword.value;
		    
		    f2.txtId.value		= p_EndPointID = p_Ei64_1 ;
		    p_Extension			= p_Ei64_2;
		    
			f.hiDomainID.value		= p_DomainID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiNumberType.value	= f2.numberType.value;
		    
		    // �ʼ� �Է��׸� üũ
		    if(p_Extension==""){
		    	alert("������ȣ�� �Է����� �ʾҽ��ϴ�.");
		    	return;
		    }else if(isNaN(p_Extension)){
		    	alert(p_Extension+"������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
		    	return;
		    }
		    
		    if(f2.numberType.value == "1"){
		    	var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64				= p_Ei64_1;
				f.hiEi64.value		= p_Ei64;
				 				    
			    if(f2.txtNumber1.value=="" || f2.txtNumber2.value==""){
			    	alert("��ȭ��ȣ�� �Է����� �ʾҽ��ϴ�.");
			    	return;
			    }else if(isNaN(f2.txtNumber1.value) || isNaN(f2.txtNumber2.value)){
			    	alert("��ȭ��ȣ �Է°��� ���ڰ� �ƴմϴ�.");
			    	return;
			    }
			    
			    if(p_Ei64_1!=p_EndPointID){
			    	alert("���̵�� ������ȣ�� ���� ���� �ʽ��ϴ�!");
			    	return;
			    }			    
			}else if(f2.numberType.value == "2"){//unused
		    	var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64				= p_Ei64_2;
			    f.hiEi64.value		= p_Ei64;			    
			    			    
			    if(f2.txtExtension.value==""){
			    	alert("������ȣ�� �Է����� �ʾҽ��ϴ�.");
			    	return;
			    }else{
				    if(isNaN(f2.txtExtension.value)){
				    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
				    	return;
				    }			    
			    }
			    
			    if(p_Ei64_2!=p_EndPointID){
			    	alert("���̵�� ��ȣ������ ���� �ʽ��ϴ�!");
			    	return;
			    }			    
	        }else{
	            alert("������ȣ ������ ������ �ּ���!");
	            return;
	        }
			
		    // EndPointID, Ei64 �ߺ�üũ
		    var parm 	= '&fullEndPointId='+full_EndPointID+'&hiEi64='+p_Ei64;		//get�������� ���� ����.
		    var url 	= 'chkNumber.jsp';
		    //getPage2(url,parm);
			
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
					
			    	if(value=='OK'){ 
			    		goInsert_02();		    		
			    	}else if(value=='NO1'){
				    	alert("�̹� ��ϵ� ���̵� �Դϴ�!");
				    	return;			
			    	}else if(value=='NO2'){
				    	alert("�̹� ��ϵ� ������ȣ �Դϴ�!");
				    	return;
			    	}else if(value=='NO3'){
				    	alert("��ϵ� �μ��� �����ϴ�. �μ��� ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;			
			    	}else if(value=='NO4'){
				    	alert("��ϵ� ������ �����ϴ�. ������ ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;
			    	}else if(value=='NO5'){
				    	alert("��ϵ� �������� �����ϴ�. �������� ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;				    	
			    	}else if(value=='NO6'){
				    	alert("�����ȳ� ��ȣ�� �ý��ۿ��� ������� ��ȣ �Դϴ�!");
				    	return;			    	
			    	}else if(value=='NO7'){
				    	alert("�μ���ǥ ��ȣ�� �ý��ۿ��� ������� ��ȣ �Դϴ�!");
				    	return;
			    	}else{
				    	alert("����� �� �����ϴ�. �����ڿ��� �����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;			    	
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
					//Ext.MessageBox.alert('Failed', "�̹� ��ϵ� ���̵� �Դϴ�!");
				} 
			});		    
		}
		
		function goInsert_02(){
			
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    var p_EndPointID 	= "";//f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_Ei64_Route2	= f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    var p_Passwd 		= f2.txtpassword.value;
		    
		    f2.txtId.value 		= p_EndPointID = p_Ei64_1;
		    
		    //var p_ZoneCode 		= f2.hiZoneCode.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    var p_Extension 	= p_Ei64_2;//f2.txtNumber2.value;
			var p_AreaCode		= f2.areaNo.value;			
			var p_NumberType	= f2.numberType.value;			
			
			var p_Mac			= f2.mac.value;
			var p_MacDisplay	= f2.txtdisplay.value;
			var p_MacIp			= f2.hiMacIp.value;
			var p_MacAuto		= f2.auto.value;
			var p_MacAutoNo		= f2.autoNo.value;
			var p_AddrType		= f2.addrType.value;
			
			var p_UserId		= f.hiUserID.value;	// �α��� ID
			
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
		    
		    //alert("���ּ�1 : "+p_Mac);
		    
		    if(f2.numberType.value == "1"){
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64					= p_Ei64_1;
				f.hiEi64.value			= p_Ei64;
				f.hiE164Route2.value	= p_Ei64_Route2;
			}else if(f2.numberType.value == "2"){
		    	// �����ȣ�� ���
		    	var full_EndPointID		= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64					= p_Ei64_2;
			    f.hiEi64.value			= p_Ei64;
			    f.hiE164Route2.value	= "";
			    p_Extension				= p_Ei64;
			    f.hiExtension.value		= p_Extension;
	        }
		    
	    		//var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2;		//get�������� ���� ����.
	    		var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiE164Route2='+p_Ei64_Route2+'&hiMac='+p_Mac+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiMacAddrType='+p_AddrType+'&hiPasswd='+p_Passwd;		//get�������� ���� ����.

	    		//alert(parm);
	    		var url 	= 'ipcsExtInsert2.jsp';	
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
						//Ext.MessageBox.alert('Failed', "�̹� ��ϵ� ���̵� �Դϴ�!");
					} 
				});	  
		}
		
		/**
		 * �ű� �������� ���� �Է�ȭ������ �̵�
		 */
		function goUserBefore(){
			//alert("goUserBefore");
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
		    
		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode;		//get�������� ���� ����.
		    var url 	= 'ipcsExtInsert.jsp';		    			
		    getPage(url,parm);			
		}
		
		/**
		 * �ű� ���� �����ϱ�
		 */
		function goNewSave(popupform){
			//alert("goNewSave");
			var f 				= document.frm;
		    var f2 				= popupform ? popupform : document.Insertlayer2;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= f2.hiEi64.value;
		    //alert('p_Ei64:'+p_Ei64);
		    //var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    //var p_Ei64_2		= f2.txtExtension.value;
		    var p_Ei64_Route2	= f2.hiE164Route2.value;
		    //alert('p_Ei64_Route2'+p_Ei64_Route2);
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

			var p_AuthE164		= "0";				// ��ȭ��ȣ ���� ����
			var p_AuthIPChk		= "0";				// IP���� ����
			var p_AuthIP		= "";				// IP����
			var p_AuthPortChk	= "0";				// Port���� ����
			var p_AuthPort		= "0";				// Port����
			var p_AuthMd5		= "0";				// MD5 ���� ����
			var p_AuthRegister	= "0";				// Register ����
			var p_AuthStale		= "0";				// Stale ����
			var p_AuthInvite	= "0";				// Invite ����
			var p_AuthID		= "";				// ����ID
			var p_AuthPass		= "";				// ��й�ȣ
			
			var p_UserId		= f.hiUserID.value;	// �α��� ID

			// �̸� üũ
			if(f2.txtName.value==""){
				alert("�̸��� �Էµ��� �ʾҽ��ϴ�.");
				return; 
	        }			
			
			
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
		    
		    //alert("������ȣ ����3 : "+p_NumberType);
		    //alert("��й�ȣ : "+p_Pass);
		    
		    p_Name 		= encodeURI(p_Name);
		    p_Position 	= encodeURI(p_Position);
		    p_MacDisplay 	= encodeURI(p_MacDisplay);
		    
		    if(p_NumberType == "1"){
				f.hiE164Route2.value	= p_Ei64_Route2;
			}else if(p_NumberType == "2"){
			    f.hiE164Route2.value	= "";
	        }


			// ��ȭ��ȣ ���� (0: �̻��, 1: ���)
			if(f2.e164Auth.checked){
				p_AuthE164 = "1";				
			}else{
				p_AuthE164 = "0";
			}
			f.hiAuthE164.value = p_AuthE164;

			// IP ���� (0: �̻��, 1: ���)
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

			// Port ���� (0: �̻��, 1: ���)
			if(f2.ipPort.checked){
				p_AuthPortChk 		= "1";
			}else{
				p_AuthPortChk 		= "0";
			}
			f.hiAuthPortChk.value 	= p_AuthPortChk;

			// MD5 ���� (0: �̻��, 1: ���)
			//if(f2.md5Auth.checked){
				// MD5 ���� ��й�ȣ üũ ��� �߰� ----------------------------------------
				if(p_MacAuthPass == ""){
					alert("MD5���� IP�ܸ� ��й�ȣ�� �Է����� �ʾҽ��ϴ�.");
					return;
				}

				if(p_MacAuthPass != p_MacPass_Chk){
					alert("IP�ܸ� ��й�ȣ�� IP�ܸ� ��й�ȣ Ȯ�� �Է°��� ���� �ʽ��ϴ�.");
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
			
			
			// ������ȣ üũ
			if(f2.txtExtension.value==""){
				alert("������ȣ�� �Էµ��� �ʾҽ��ϴ�.");
				return; 			
			}
			if(p_Extension.length<1){
				alert("������ȣ�� �ּ� 1�ڸ� �̻��̾�� �մϴ�.");
				return; 			
			}
		    if(isNaN(f2.txtExtension.value)){
		    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
		    	return;
		    }			
			
			// �̸� üũ
//			if(f2.txtName.value==""){
//				alert("�̸��� �Էµ��� �ʾҽ��ϴ�.");
//				return; 
//	        }			
			// ���� üũ
			if(f2.txtMail.value!=""){
				if((f2.txtMail.value.indexOf("@")==-1) || (f2.txtMail.value.indexOf(".")==-1)){				  
				alert("�̸����� ��Ȯ�� �Էµ��� �ʾҽ��ϴ�.");
				//f2.txtMail.focus();
				return; 
				}
	        }
			// NAT Zone üũ
//			if(f2.txtZone.value==""){
//				alert("NAT Zone �� ���õ��� �ʾҽ��ϴ�.");
//				return; 
//	        }
		    // MD5 ������ ��� ID, ��й�ȣ üũ
		    //if(f2.md5Auth.checked){
				if(f2.txtid.value=="" || f2.txtpassword.value==""){
					alert("MD5  ���� ID �� ��й�ȣ��  �Էµ��� �ʾҽ��ϴ�.");
					return; 
		        }
		    //}
		    
		    // IP ������ ��� IP üũ
		    if(f2.ipAuth.checked){
				if(f2.txtip.value=="" || f2.txtport.value==""){
					alert("���� IP �� PORT ��  �Էµ��� �ʾҽ��ϴ�.");
					return; 
		        }
		    }
		    
			// MD5 Hash (IMS��) ��� (0: �̻��, 1: ���) #####################
//			var p_Hash_Chk = "";
//			if(f2.hash_Chk.checked){
//				p_Hash_Chk = "1";
//			}else{
//				p_Hash_Chk = "0";
//			}
			// #############################################################
		    
		    // �ű� ���� ����
//		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiPwd='+p_Pass+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiMobile='+p_Mobile+'&hiHomeNumber='+p_HomeNumber+'&hiMail='+p_Mail+'&hiE164Route2='+p_Ei64_Route2+'&hiAuthE164='+p_AuthE164+'&hiAuthIPChk='+p_AuthIPChk+'&hiAuthIP='+p_AuthIP+'&hiAuthPortChk='+p_AuthPortChk+'&hiAuthPort='+p_AuthPort+'&hiAuthMd5='+p_AuthMd5+'&hiAuthRegister='+p_AuthRegister+'&hiAuthStale='+p_AuthStale+'&hiAuthInvite='+p_AuthInvite+'&hiAuthID='+p_AuthID+'&hiAuthPass='+p_AuthPass+'&hiMac='+p_Mac+'&hiMacAuthId='+p_MacAuthId+'&hiMacAuthPass='+p_MacAuthPass+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId+'&hiMacAddrType='+p_MacAddrType+'&hiHash_Chk='+p_Hash_Chk;		// MD5 Hash (IMS��) get�������� ���� ����.
		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiPwd='+p_Pass+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiMobile='+p_Mobile+'&hiHomeNumber='+p_HomeNumber+'&hiMail='+p_Mail+'&hiE164Route2='+p_Ei64_Route2+'&hiAuthE164='+p_AuthE164+'&hiAuthIPChk='+p_AuthIPChk+'&hiAuthIP='+p_AuthIP+'&hiAuthPortChk='+p_AuthPortChk+'&hiAuthPort='+p_AuthPort+'&hiAuthMd5='+p_AuthMd5+'&hiAuthRegister='+p_AuthRegister+'&hiAuthStale='+p_AuthStale+'&hiAuthInvite='+p_AuthInvite+'&hiAuthID='+p_AuthID+'&hiAuthPass='+p_AuthPass+'&hiMac='+p_Mac+'&hiMacAuthId='+p_MacAuthId+'&hiMacAuthPass='+p_MacAuthPass+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId+'&hiMacAddrType='+p_MacAddrType;		//get�������� ���� ����.
//		    var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID                          +'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType                                                                                                                                                     +'&hiE164Route2='+p_Ei64_Route2;		                                                                                                                                                                                                                                                                                                 +'&hiMac='+p_Mac                                                            +'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo                      +'&hiMacAddrType='+p_AddrType
			//
		    var url 	= 'ipcsExtUserInsertPro.jsp';
		    //getPage3(url,parm);
		   
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
					
					if(value.indexOf('OK:') === 0){//if(value=='OK'){
			    		var scriptArr = value.substr(3);
				    	var objJSON = eval("(function(){return " + scriptArr + ";})()");
			    		goInsertDone(objJSON);
			    		goInsert_03();		    		
			    	}else if(value=='NO2'){
				    	alert("�̹� ������ȣ �Ǵ� Ư����ȣ�� ������� ��ȣ �Դϴ�!");
				    	return;			    	
			    	}else{
				    	alert("���� ������ȣ ������ ���������� �̷�� ���� �ʾҽ��ϴ�!");
				    	return;			
			    	}					
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
					//Ext.MessageBox.alert('Failed', "�̹� ��ϵ� ���̵� �Դϴ�!");
				} 
			});
		    				   	
		}
		
		function goInsert_03(){
			var f 				= document.frm;
		    var f2 				= document.Insertlayer2;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_EndPointID 	= f2.txtId.value;
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.hiEi64.value;			// ��ü��ȣ
		    var p_Ei64_2		= f2.txtExtension.value;	// ������ȣ
		    var p_Ei64_Route2	= f2.hiE164Route2.value;	// ������ȣ ������ ��ȣ
		    //var p_Extension 	= f2.hiExtension.value;		// ������ȣ
		    var p_Extension 	= f2.txtExtension.value;		// ������ȣ
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
		    
    		var parm_2 	= '&hiEndPointID='+p_EndPointID+'&hiPwd='+p_Pass+'&hiEi64='+p_Ei64+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiExtension='+p_Extension;		//get�������� ���� ����.
    		var url_2 	= 'ipcsExtInsert3.jsp';		    			
    		getPage(url_2,parm_2);			
		    					
		}
		
		/**
		 * �ű��Է� ȭ������ �̵�
		 */
		function goNextSave(){
		    var parm 	= '';
		    var url 	= 'ipcsExtInsert.jsp';		    
			
		    getPage(url,parm);					
		}
		
		/**
		 * ���� ó��
		 */
		function goInsertPro(){
           // alert("goInsertPro") ;
			var f 				= document.frm;
		    var f2 				= document.Insertlayer1;
		    
		    var p_Ei64			= "";
		    var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
		    var p_Ei64_2		= f2.txtExtension.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    var p_Extension 	= p_Ei64_2;//f2.txtNumber2.value;
		    var p_EndPointID 	= p_Ei64_1;
		    
		    f2.txtId.value		= p_Ei64_1;
		    f2.hiEi64.value 	= p_Ei64_1;
		    f2.txtName.value	= p_Ei64_1;
		    f2.txtid.value		= p_Ei64_1;
		    f2.txtpass_chk.value= f2.txtpassword.value;
		    
		    var p_Ei64_Route2	= f2.txtNumber1.value + f2.txtNumber2.value;
		    f2.hiE164Route2.value		= p_Ei64_Route2;

		    var p_GroupID 		= f2.hiGroupID.value;
		    var p_DomainID 		= f2.hiDomainID.value;
		    var p_PrefixID 		= f2.hiPrefixID.value;
		    //var p_Extension 	= f2.txtNumber2.value;
			var p_AreaCode		= f2.areaNo.value;			
			var p_NumberType	= f2.numberType.value;			
			
			var p_Mac			= f2.mac.value;
			var p_MacDisplay	= f2.txtdisplay.value;
			var p_MacIp			= f2.hiMacIp.value;
			var p_MacAuto		= f2.auto.value;
			var p_MacAutoNo		= f2.autoNo.value;
			var p_AddrType		= f2.addrType.value;
			
			var p_UserId		= f.hiUserID.value;	// �α��� ID
			
			f.hiDomainID.value		= p_DomainID;
			f.hiEndPointID.value	= p_EndPointID;			
			f.hiExtension.value		= p_Extension;
		    f.hiNumberType.value	= f2.numberType.value;
		    
			f.hiGroupID.value		= p_GroupID;
			f.hiPrefixID.value		= p_PrefixID;
		    f.hiAreaCode.value		= p_AreaCode
		    
		    f.hiMac.value			= p_Mac;
			f.hiMacDisplay.value	= p_MacDisplay;
			f.hiMacIp.value			= p_MacIp;
			f.hiMacAuto.value		= p_MacAuto;
			f.hiMacAutoNo.value		= p_MacAutoNo;
		    f.hiMacAddrType.value	= p_AddrType;
		    
		    //alert("���ּ�1 : "+p_Mac);
		    
		    // �ʼ� �Է��׸� üũ
		    if(f2.txtNumber1.value=="" || f2.txtNumber2.value==""){
		    	alert("��ȭ��ȣ�� �Է����� �ʾҽ��ϴ�.");
		    	return;
		    }else if(isNaN(p_Ei64_1)){
		    	alert("��ȭ��ȣ �Է°��� ���ڰ� �ƴմϴ�.");
		    	return;
			}else if(p_Ei64_1.length<3){
				alert("��ȭ��ȣ�� �ּ� 3�ڸ� �̻��̾�� �մϴ�.");
				return; 			
		    }else if(p_Extension==""){
		    	alert("��ȭ��ȣ�� �Է����� �ʾҽ��ϴ�.");
		    	return;
		    }else if(isNaN(p_Extension)){
		    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
		    	return;
			}else if(f2.txtpassword.value==""){
		    	alert("��й�ȣ�� �Է����� �ʾҽ��ϴ�.");
		    	return;
		    }
		    
		    if(f2.numberType.value == "1"){
				var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";								
				p_Ei64					= p_Ei64_1;
				f.hiEi64.value			= p_Ei64;
				f.hiE164Route2.value	= p_Ei64_Route2;
				p_Extension 			= p_Ei64_2;
				
			    if(f2.txtNumber1.value=="" || f2.txtNumber2.value==""){
			    	alert("��ȭ��ȣ�� �Է����� �ʾҽ��ϴ�.");
			    	return;
			    }else if(isNaN(f2.txtNumber1.value) || isNaN(f2.txtNumber2.value)){
			    	alert("��ȭ��ȣ �Է°��� ���ڰ� �ƴմϴ�.");
			    	return;
			    }
			    
			    if(p_Extension==""){
			    	alert("������ȣ�� �Է����� �ʾҽ��ϴ�.");
			    	return;
			    }else if(isNaN(p_Extension)){
			    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
			    	return;
			    }
			    
			    /* if(p_Ei64_1!=p_EndPointID){
			    	alert("���̵�� ������ȣ�� ���� ���� �ʽ��ϴ�!");
			    	return;
			    } */		
			    
			}else if(f2.numberType.value == "2"){//unused
				// �����ȣ�� ���
				var full_EndPointID	= p_EndPointID+"@"+p_DomainID+":5060";;
			    p_Ei64				= p_Ei64_2;
			    f.hiEi64.value		= p_Ei64;
			    f.hiE164Route2.value= p_Ei64_Route2;
			    p_Extension			= p_Ei64;
			    f.hiExtension.value	= p_Extension;
			    
			    if(f2.txtExtension.value==""){
			    	alert("������ȣ�� �Է����� �ʾҽ��ϴ�.");
			    	return;
			    }else{
				    if(isNaN(f2.txtExtension.value)){
				    	alert("������ȣ �Է°��� ���ڰ� �ƴմϴ�.");
				    	return;
				    }			    
			    }
			    
			    /* if(p_Ei64_2!=p_EndPointID){
			    	alert("���̵�� ��ȣ������ ���� �ʽ��ϴ�!");
			    	return;
			    } */			    
	        }else{
	            alert("������ȣ ������ ������ �ּ���!");
	            return;
	        }
			
		    // EndPointID, Ei64 �ߺ�üũ
		    var parm 	= '&fullEndPointId='+full_EndPointID+'&hiEi64='+p_Ei64;		//get�������� ���� ����.
		    var url 	= 'chkNumber.jsp';
		    //getPage2(url,parm);
			
   		    //var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID+'&hiZoneCode='+p_ZoneCode+'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType+'&hiPwd='+p_Pass+'&hiName='+p_Name+'&hiPosition='+p_Position+'&hiDept='+p_Dept+'&hiMobile='+p_Mobile+'&hiHomeNumber='+p_HomeNumber+'&hiMail='+p_Mail+'&hiE164Route2='+p_Ei64_Route2+'&hiAuthE164='+p_AuthE164+'&hiAuthIPChk='+p_AuthIPChk+'&hiAuthIP='+p_AuthIP+'&hiAuthPortChk='+p_AuthPortChk+'&hiAuthPort='+p_AuthPort+'&hiAuthMd5='+p_AuthMd5+'&hiAuthRegister='+p_AuthRegister+'&hiAuthStale='+p_AuthStale+'&hiAuthInvite='+p_AuthInvite+'&hiAuthID='+p_AuthID+'&hiAuthPass='+p_AuthPass+'&hiMac='+p_Mac+'&hiMacAuthId='+p_MacAuthId+'&hiMacAuthPass='+p_MacAuthPass+'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo+'&hiUserID='+p_UserId+'&hiMacAddrType='+p_MacAddrType;		//get�������� ���� ����.
			//var parm 	= '&hiGroupID='+p_GroupID+'&hiDomainID='+p_DomainID                          +'&hiPrefixID='+p_PrefixID+'&hiEndPointID='+p_EndPointID+'&hiEi64='+p_Ei64+'&hiExtension='+p_Extension+'&hiAreaCode='+p_AreaCode+'&hiNumberType='+p_NumberType                                                                                                                                                     +'&hiE164Route2='+p_Ei64_Route2;		                                                                                                                                                                                                                                                                                                 +'&hiMac='+p_Mac                                                            +'&hiMacDisplay='+p_MacDisplay+'&hiMacIp='+p_MacIp+'&hiMacAuto='+p_MacAuto+'&hiMacAutoNo='+p_MacAutoNo                      +'&hiMacAddrType='+p_AddrType
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
					
			    	if(value=='OK'){ 
			    		goNewSave(f2) ;//goInsert_02();
			    	}else if(value=='NO1'){
				    	alert("�̹� ��ϵ� ���̵� �Դϴ�!");
				    	return;			
			    	}else if(value=='NO2'){
				    	alert("�̹� ��ϵ� ��ȭ��ȣ �Դϴ�!");
				    	return;
			    	}else if(value=='NO3'){
				    	alert("��ϵ� �μ��� �����ϴ�. �μ��� ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;			
			    	}else if(value=='NO4'){
				    	alert("��ϵ� ������ �����ϴ�. ������ ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;
			    	}else if(value=='NO5'){
				    	alert("��ϵ� �������� �����ϴ�. �������� ����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;				    	
			    	}else if(value=='NO6'){
				    	alert("�����ȳ� ��ȣ�� �ý��ۿ��� ������� ��ȣ �Դϴ�!");
				    	return;			    	
			    	}else if(value=='NO7'){
				    	alert("�μ���ǥ ��ȣ�� �ý��ۿ��� ������� ��ȣ �Դϴ�!");
				    	return;
			    	}else{
				    	alert("����� �� �����ϴ�. �����ڿ��� �����Ͻ� �� ����Ͻñ� �ٶ��ϴ�!");
				    	return;			    	
			    	}
				},
				failure: function ( result, request) { 
					Ext.MessageBox.alert('Failed', result.responseText); 
					//Ext.MessageBox.alert('Failed', "�̹� ��ϵ� ���̵� �Դϴ�!");
				} 
			});	
		}
		
		/**
		 * �ű��Է� �� ���
		 */
		function goInsertDone(datas){
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
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript: goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/forward_img.png\" alt=\"������ ������ȯ\">";
		       		else if(paramAwrSvc=='2')
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript: goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/forward_img.png\" alt=\"���Ǻ� ������ȯ\">";
		       		else
		       		  t_new_tr.innerHTML += "<img onclick=\"javascript: goUnRegister('"+paramEpId+"');\" id='imgStus"+count_tr+"' src=\"<%=StaticString.ContextRoot%>/imgs/on_img.png\" alt=\"��ϿϷ�\">";
	     		}else
	          		t_new_tr.innerHTML += "<img onclick=\"\" id='imgStus"+count_tr+"'  src=\"<%=StaticString.ContextRoot%>/imgs/off_img.png\" alt=\"�̵��\">";
		        t_new_tr.innerHTML += "</td>";  //state
		        t_new_tr.innerHTML += "<td width=\"120\" id='h"+count_tr+"_1' class=\"table_column\">"+paramE164+"</td>"; //e164
		        t_new_tr.innerHTML += "<td width=\"80\" id='h"+count_tr+"_2' class=\"table_column\">"+paramExtnum+"</td>";  //extnum
		        t_new_tr.innerHTML += "<td width=\"100\" id='h"+count_tr+"_3' class=\"table_column\">"+paramIp+"</td>"; //ip
		        t_new_tr.innerHTML += "<td width=\"130\" id='h"+count_tr+"_4' class=\"table_column\">"+paramMac+"</td>"; //mac
		        t_new_tr.innerHTML += "<td width=\"120\" id='h"+count_tr+"_5' class=\"table_column\">"; //btn
			        t_new_tr.innerHTML += "<input type=\"button\" name=\"btnActionMdi\" style=\"height: 18px\" value=\"����\" onclick=\"func_setAction(0, '"+paramE164+"', '"+paramEpId+"')\">";
			        t_new_tr.innerHTML += "&nbsp;<input type=\"button\" name=\"btnActionDel\" style=\"height: 18px\" value=\"����\" onclick=\"func_setAction(1, '"+paramE164+"', '"+paramEpId+"')\">";
			    t_new_tr.innerHTML += "</td>";
			    t_new_tr.innerHTML += "<td class=\"table_column\">&nbsp;</td>";
			  	//+ "</TR>'
		          
			    t_table.innerHTML = '';
			    
				t_table.appendChild(t_new_tr);	
				
				t_table.innerHTML = t_table.innerHTML + old_items_html;
				
			return count_tr;		
		}
		
        /**
         * ���� ȭ������ �̵�
         */
        function goDelete(p_EndpointId, p_E164){
            var parm 	= '&e164='+p_E164+'&endPointID='+p_EndpointId;
            var url 	= 'ipcsExtDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * ����ó��
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

		    var f2 				= document.Deletelayer1;
		    var p_EndPointID 	= f2.hiEndPointID.value;
		    var p_Ei64 			= f2.hiEi64.value;
		    var p_DeleteType = "1";
		    
		    f.hiEndPointID.value	= p_EndPointID;			
			f.hiEi64.value			= p_Ei64;
			f.hiDeleteType.value	= p_DeleteType;
            //f.deleteStr.value = str;//

            //Ext.MessageBox.show({msg: '������ �Դϴ�.',progressText: '������ �Դϴ�.',width:400,wait:true,waitConfig: {interval:200} });
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * ����ó�� �� ���
		 */
		function goDeleteDone(datas){
			var _o=null, _p=null;
			var _i = 0;
			var _table = document.getElementById("tb_list");
			var _len = _table.getElementsByTagName('tr').length;
			var _lc = _table.lastChild ;
			while(_lc)
			{
			  if(_p=document.getElementById("h"+_i+"_1"))
			  {
				  if(datas[0].params[0]==_p.innerHTML){ //alert(_p.innerHTML);
					  delitem(_p); return ;
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
		
        /**
		 * �����ϱ�
		 */
		function goSave(){
			var f  = document.frm;

            if(f.gubun[0].checked){     // ���� �ð� �뺸 ������� ���� 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'�˶��뺸 ����'+'&msg='+'�˶��뺸�� ������� �ʴ� �����Դϴ�.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("��� ������ �����˴ϴ�. �����Ͻðڽ��ϱ�?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/ipcsext/ipcsExtSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // ���� �ð� �뺸 ����ϱ� 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'�˶��뺸 ����'+'&msg='+'�˶��뺸 ������ �߰��Ͽ� �ֽʽÿ�.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'�˶��뺸 ����'+'&msg='+'�˶��뺸�� ����ϰ� �ֽ��ϴ�.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }
            }

		}		

		/**
		 * ���õ� ���� �ִ��� Ȯ��
		 */
		function isChecked(processname){
			var f   = document.frm;
            var cnt = 0;
            if(f.chkOpt == undefined){
                var parm = '&titlemsg='+'�߽����� ����'+'&msg='+'�˻� ����� �����ϴ�.';
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
                    var parm = '&titlemsg='+'�߽����� ����'+'&msg='+processname+'�� �׸��� �����Ͽ� �ֽʽÿ�.';
                    var url  = "<%=StaticString.ContextRoot+pageDir%>/msgPopup.jsp";
                    getPage(url,parm);
                    return 0;
                }
            }
            
            return 1;
		}
		
		/**
		 * ���õ� ���� �Է�
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
         * ���/���� Ŭ�� (����ȭ������ �̵�)
         */
		function func_setAction(action, num, param) {
        	if(num) document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			switch(action){
				case 0://����
					showEdit(param, num);
					break;
				case 1://����
					goDelete(param, num);
					break;
				case 2://�߰�
					goInsert(num, param);					
					break;
				case 3://����
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
					goExtNumUpdate(num1);
					break;
			}
		}
        
		/**
         * ���� �߰�/���� Ŭ��
         */
		function func_setActionBySelected(type) {
			document.frm.grpid.value = '<%=authGroupid%>';
			if(type==1){
				if( isChecked('����')==0 ) return ;
				document.frm.e164.value = setE164BySelected() ;
				goDelete(document.frm.e164.value) ;
			}
			else{
				if( isChecked('���')==0 ) return ;
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
			  document.location.href = 'ipcsExtList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==1){
				if( lastSort==nField )	document.getElementById('telnum').innerHTML = "<b>��ȣ/���̵��</b>";
				else					document.getElementById('telnum').innerHTML = "<b>��ȣ/���̵��</b>";
				document.getElementById('extnum').innerHTML = "������ȣ<font size='1px'>��</font>";//��
				document.getElementById('ipaddr').innerHTML = "IP�ּ�<font size='1px'>��</font>";
				document.getElementById('macaddr').innerHTML = "MAC�ּ�<font size='1px'>��</font>";
			}
			else if(nField==2){
				if( lastSort==nField )	document.getElementById('extnum').innerHTML = "<b>������ȣ��</b>";
				else					document.getElementById('extnum').innerHTML = "<b>������ȣ��</b>";
				document.getElementById('telnum').innerHTML = "��ȣ/���̵�<font size='1px'>��</font>";//��
				document.getElementById('ipaddr').innerHTML = "IP�ּ�<font size='1px'>��</font>";
				document.getElementById('macaddr').innerHTML = "MAC�ּ�<font size='1px'>��</font>";
			}
			else if(nField==3){
				if( lastSort==nField )	document.getElementById('ipaddr').innerHTML = "<b>IP�ּҡ�</b>";
				else					document.getElementById('ipaddr').innerHTML = "<b>IP�ּҡ�</b>";
				document.getElementById('telnum').innerHTML = "��ȣ/���̵�<font size='1px'>��</font>";//��
				document.getElementById('extnum').innerHTML = "������ȣ<font size='1px'>��</font>";
				document.getElementById('macaddr').innerHTML = "MAC�ּ�<font size='1px'>��</font>";
			}
			else if(nField==4){
				if( lastSort==nField )	document.getElementById('macaddr').innerHTML = "<b>MAC�ּҡ�</b>";
				else					document.getElementById('macaddr').innerHTML = "<b>MAC�ּҡ�</b>";
				document.getElementById('telnum').innerHTML = "��ȣ/���̵�<font size='1px'>��</font>";//��
				document.getElementById('extnum').innerHTML = "������ȣ<font size='1px'>��</font>";
				document.getElementById('ipaddr').innerHTML = "IP�ּ�<font size='1px'>��</font>";
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
	/*���� ���� ���� */
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
	<!--strat--����������-->
		<% int menu = 2, submenu = 1; %>
		<table id="menu" width="180" style="background: #FFF;" align="left" border="0" cellspacing="0" cellpadding="0" >
		<%@ include file="../leftUserMenu_ems.jsp"%>
		</table>
	<!--end--����������-->
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
                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"�α׾ƿ�\" onclick=\"func_logoutCommit(1)\">") ;
                  %>
                  		<font style="color: blue;vertical-align: bottom;"><%=authGroupid+(userLevel!=2?"":authGroupid.length()==0?userID:"("+userID+")")%></font>
                	 	<input type="button" name="btnLogout" style="height: 18px" value="�α׾ƿ�" onclick="func_logoutCommit(1)">
                	 	<input type="button" style="height: 18px" value="����" onclick="document.location.href = 'ipcsExtList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"�α���\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="�α���" onclick="document.location.href = 'ipcsExtList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnModiExtNum" style="height: 18px" value="������ȣ �߰�" onclick="func_setAction(2, '<%=maxE164%>');">
                  	<input type="button" name="btnUpdataExtNum" style="height: 18px" value="������ȣ ����" onclick="func_setAction(3);">
                  	<!-- <input type="button" name="btnPutAlarm" style="height: 18px" value="���� ���" onclick="func_setActionBySelected(0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="���� ����" onclick="func_setActionBySelected(1)"> -->
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
                  <%-- <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td> --%>
                  <td width="45" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">��ȣ</td>
                  <td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">����</td>
                  <td width="130" onclick="sortNow(1,true);changeTitle(1);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>��ȣ/���̵��</b></td>
                  <td width="80" onclick="sortNow(2,true);changeTitle(2);" id="extnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">������ȣ<font size='1px'>��</font></td>
                  <td width="100" onclick="sortNow(3);changeTitle(3);" id="ipaddr" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">IP�ּ�<font size='1px'>��</font></td>
                  <td width="130" onclick="sortNow(4);changeTitle(4);" id="macaddr" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">MAC �ּ�&#13;&#13;<font size='1px'>��</font></td>
                  <td width="120" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"> </td>
                  <td class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
              </tr>
		  </table>
		</td>
	</tr>
	<tr>
        <td valign="top">
<!-- <div style="width:792; height:222; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">		 -->
          <table id="tb_list" width="700" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
          
<%					
	int idx=0;
	if(/* envList!=null && */ count!=0){
		nTotalpage = nModePaging==0 ? 0 : (int)(count/nMaxitemcnt);
		int endidx = nModePaging==0 ? count : (nTotalpage==nNowpage? count%nMaxitemcnt : nMaxitemcnt ) ;
		
		IpcsListDTO dto= null;
		String 	strCallTime = "", answerService="";
		int kk = 0;
		
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (IpcsListDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					//nTotalpage =  (int)(count/nMaxitemcnt);
					
					answerService = dto.getAnswerservice().substring(3, 4);
					kk = dto.getStarttime().lastIndexOf(".");
					if(dto.getCallState()>0&& kk!=-1) strCallTime = dto.getStarttime().substring(0, kk);
					
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <%-- <td width="58" class="table_column"> <input type="checkbox" name="chkOpt" value="<%=dto.getE164()%>" > </td>  --%>
		                <td width="45" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="80" id='h<%=idx%>_0' class="table_column">
		                <%
		                	if(dto.getSignalAddress()!=null && !"".equals(dto.getSignalAddress())){
		                		if(dto.getCallState()>0){
		                			///out.print("<a href=\"javascript:goUnRegister('"+dto.getEndPointId()+"');\"><img id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/call_img.png\" alt=\"��ȭ���� �ð� : "+strCallTime+"\"></a>");
		                			out.print("<img onclick=\"javascript: goUnRegister('"+dto.getEndPointId()+"');\" id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/call_img.png\" alt=\"��ȭ���� �ð� : "+strCallTime+"\">");
		                		}else if("1".equals(answerService)||"3".equals(answerService)){
		                			//out.print("<a href=\"javascript:goUnRegister('"+dto.getEndPointId()+"');\"><img id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/forward_img.png\" alt=\"������ ������ȯ\"></a>");
		                			out.print("<img onclick=\"javascript: goUnRegister('"+dto.getEndPointId()+"');\" id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/forward_img.png\" alt=\"������ ������ȯ\">");
		                		}else if("2".equals(answerService)){
		                			//out.print("<a href=\"javascript:goUnRegister('"+dto.getEndPointId()+"');\"><img id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/forward_img.png\" alt=\"���Ǻ� ������ȯ\"></a>");
		                			out.print("<img onclick=\"javascript: goUnRegister('"+dto.getEndPointId()+"');\" id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/forward_img.png\" alt=\"���Ǻ� ������ȯ\">");
		                		}else{
		                			//out.print("<a href=\"javascript:goUnRegister('"+dto.getEndPointId()+"');\"><img id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/on_img.png\" alt=\"��ϿϷ�\"></a>");
		                			out.print("<img onclick=\"javascript: goUnRegister('"+dto.getEndPointId()+"');\" id='imgStus"+idx+"' src=\""+StaticString.ContextRoot+"/imgs/on_img.png\" alt=\"��ϿϷ�\">");
		                		}
		                	}else{
		                		out.print("<img onclick=\"\" id='imgStus"+idx+"'  src=\""+StaticString.ContextRoot+"/imgs/off_img.png\" alt=\"�̵��\">");
		                	}
		                %>
		                </td>
		                <td width="120" id='h<%=idx%>_1' class="table_column"><%=dto.getE164()%></td>
		                <td width="80" id='h<%=idx%>_2' class="table_column"><%=dto.getExtensionnumber()%></td>
		                <td width="100" id='h<%=idx%>_3' class="table_column"><%=dto.getSignalAddress()%></td>
		                <td width="130" id='h<%=idx%>_4' class="table_column"><%=dto.getPhysicalAddress()%></td>
		                <td width="120" id='h<%=idx%>_5' class="table_column">
		                	<input type="button" name="btnActionMdi" style="height: 18px" value="����" onclick="func_setAction(0, '<%=dto.getE164()%>', '<%=dto.getEndPointId()%>')">
		                	&nbsp;<input type="button" name="btnActionDel" style="height: 18px" value="����" onclick="func_setAction(1, '<%=dto.getE164()%>', '<%=dto.getEndPointId()%>')">
		                </td>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	//else out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
					
   	out.println("<script type=\"text/JavaScript\"> sortNow(1,true); </script>") ;//��ȣ ����
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="ipcsExtList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="ipcsExtList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"ipcsExtList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="ipcsExtList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="ipcsExtList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
<!-- �˾� ���̾� -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
<div id="popup_layer2" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;"></div>
