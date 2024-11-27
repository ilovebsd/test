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
   	
   	String 	viewType 	= new String(Str.CheckNullString(request.getParameter("viewType")).getBytes("8859_1"), "euc-kr");
  	//System.out.println("#################### 1 : "+viewType);
    
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
					//iList	= (ArrayList)addServiceList.getNewMRBTList(stmt, authGroupid);		// ����Ÿ ��ȸ
					MrbtDTO mrbtDTO;
					iList = new ArrayList<MrbtDTO>();
			        String sql = "\n select a.name as name, ";
			        sql = sql +  "\n 	a.extension as extnum,  ";
			        sql = sql +  "\n 	(Select deptname from table_dept where deptid = a.department) as dept,  "; 
			        sql = sql +  "\n 	a.position as position,  ";
			        sql = sql +  "\n 	a.phonenum as e164,  ";
			        sql = sql +  "\n 	(select max(Sound) from TABLE_AddMRBT where e164 = a.phonenum) as filename,  ";       
			        sql = sql +  "\n 	(select count(*) from table_featureservice where e164 = a.phonenum and serviceno = 5011) as usechk  ";
			        sql = sql +  "\n from table_subscriber a "; 
			        sql = sql +  "\n where a.loginlevel = 1 "; 
			        if(authGroupid!=null)
			        	sql = sql +  "\n and a.checkgroupid = '"+authGroupid+"' ";
			        sql = sql +  "\n order by a.phonenum "; 
			    
			        if(nModePaging==1){
						sql		+= " LIMIT "+nMaxitemcnt+" ";
						sql		+= " OFFSET "+ (nNowpage*nMaxitemcnt) ;
					}
			        
			        ResultSet rs = null;
			        try {
			                rs = stmt.executeQuery(sql);
			                System.out.println("MRBT : "+sql);
			                while (rs.next()) {
			                	mrbtDTO = new MrbtDTO();
			                	mrbtDTO.setName(Str.CheckNullString(rs.getString("extnum")));
// 			                	mrbtDTO.setDept(Str.CheckNullString(rs.getString("dept")));
// 			                	mrbtDTO.setPosition(Str.CheckNullString(rs.getString("position")));
			                	mrbtDTO.setE164(Str.CheckNullString(rs.getString("e164")));
			                	mrbtDTO.setFilename(Str.CheckNullString(rs.getString("filename")));
			                	mrbtDTO.setUsechk(rs.getInt("usechk"));
			                	iList.add(mrbtDTO);
			                }
			                rs.close();
			        }catch(Exception ex){
			        }finally{
						if(rs!=null) rs.close();			        	
			        }
			        
					if(1!=1&& iList.size()==0){
						out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
						return ;
					}
					
					try{
			        	if(nModePaging==1){
			        		sql = "\n select count(*) ";
			        		sql = sql +  "\n from table_subscriber a "; 
					        sql = sql +  "\n where a.loginlevel = 1 "; 
					        if(authGroupid!=null)
					        	sql = sql +  "\n and a.checkgroupid = '"+authGroupid+"' ";
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
			out.println("<script type=\"text/JavaScript\"> realtimeClock(); </script>") ;
			return ;
		}finally{
			if (stmt != null) ConnectionManager.freeStatement(stmt);
		}
	}else if(nAllowUser==1){
		iList = new ArrayList<MrbtDTO>() ;
		MrbtDTO tmpdto = null;
		for(int z=0; z<nMaxitemcnt; z++){
			tmpdto = new MrbtDTO();
			tmpdto.setName("0101111222"+z) ;
			tmpdto.setPosition("test_"+z) ;
			tmpdto.setDept("testDept_"+z) ;
			tmpdto.setE164("0101111222"+z) ;
			tmpdto.setUsechk(z%2==0?1:0) ;//0:������, 1:�����
			tmpdto.setFilename(tmpdto.getUsechk()==1?z+"_file.wav":"") ;
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
		        alert("����") ;
		    }
		}
		
		/**
		 * Ŭ���� �˾� �����ֱ�
		 */		
		function showAdCodeDiv() {		
		    try{
		        setShadowDivVisible(false); //��� layer
		    }catch(e){
		    }
		    setShadowDivVisible(true); //��� layer
		
		    var d_id 	= 'popup_layer';
		    var obj 	= document.getElementById(d_id);
		
		    obj.style.zIndex=998;
		    obj.style.display = "";
		    obj.style.top = '150px';
		    obj.style.left = '250px';

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
		
		/**
		 * �ű��Է� ȭ������ �̵�
		 */
		function goInsert(p_E164, p_file){
		    var parm 	= '&e164='+(p_E164?p_E164:'')+'&filename='+(p_file?p_file:'');
		    var url 	= 'usrMrbtEdit.jsp';//'usrMrbtInsert.jsp';
		    if(p_file == ""){
				alert("��ϵ� �������� �����ϴ�!");
				return;
			}
		    
		    getPage(url,parm);			
		}

		/**
		 * ���� ó��
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
            
            var time1 = f2.time1_2.value;
    		var time2 =	f2.time2_2.value;
    		var time3 =	f2.time3_2.value;
    		var time4 =	f2.time4_2.value;

    		var naScCodeValue 	= f2.naScCode_2.value;
    		var totalTime 		= time1 + time2;
    		var totalTime2 		= time3 + time4;

    		if((time1*1.0) > (time3*1.0)){
    			alert("���۽ð��� ����ð� ���� Ŭ�� �����ϴ�.");
    			return;		
    		}

    		var uploadfile_1	= f2.wFile_2;
    		var uploadfile;
    		var chk      = "";

    		uploadfile = uploadfile_1.value;
    		if(uploadfile==""){
    			alert("��ȭ������ ������ �������� �ʾҽ��ϴ�.");
    			return;
    		}

    		var fullname = uploadfile;
            var i = uploadfile_1.value.lastIndexOf(".");
            if(i != -1){
                chk = fullname.substring(i+1);
            }
            if(chk.toLowerCase() != "wav"){
                alert("wav ���ϸ� ���ε� �� �� �ֽ��ϴ�.");
                return;
            }

    		f.hiStartTime.value 	= totalTime;
            f.hiEndTime.value 		= totalTime2;
            f.hiDayValue.value 		= naScCodeValue;
            f.uploadfilename.value 	= uploadfile;

            // �ű� �μ���ǥ��ȣ ����
    	    var parm 	= '&hie164='+str+'&hiStartTime='+totalTime+'&hiEndTime='+totalTime2+'&hiDayValue='+naScCodeValue+'&uploadfilename='+uploadfile;		//get�������� ���� ����.
    	    var url 	= 'usrMrbtChk.jsp';
    	    
    		Ext.Ajax.request({
    			url : url , 
    			params : parm,
    			method: 'POST',
    			success: function ( result, request ) {
    				var tempResult = result.responseText;
    				var value = tempResult.replace(/\s/g, "");	// ��������
    		    	if(value=='OK'){ 
    			        editPro(str);
    			        return ;
    		    	}else if(value=='NO'){
    		    		alert("�̹� ������� ��ȭ������ ���� �Դϴ�!");
    			    	return;
    		    	}else if(value=='NO2'){
    		    		alert("�̹� ��ϵ� ��ȭ������ �ð��� ������ �ֽ��ϴ�!");
    			    	return;
    		    	}else{
    		    		Ext.MessageBox.alert('���', "<div style='width:370px;'>"+"�����ڿ��� �����Ͻñ� �ٶ��ϴ�.");
    			    	return;
    		    	}
    			},
    			failure: function ( result, request) { 
    				Ext.MessageBox.alert('Failed', result.responseText); 
    			} 
    		});
		}
		
		/**
	     * ���� ����
	     */
	    function editPro(e164s){
	    	var f  = document.frm;
	    	var f2  = document.editForm;

	    	var time1 = f2.time1_2.value;
			var time2 =	f2.time2_2.value;
			var time3 =	f2.time3_2.value;
			var time4 =	f2.time4_2.value;
			var naScCodeValue 	= f2.naScCode_2.value;
			var totalTime 		= time1 + time2;
			var totalTime2 		= time3 + time4;

			var uploadfile_1	= f2.wFile_2;
			var uploadfile;
			var chk      = "";

			uploadfile = uploadfile_1.value;
			var fullname = uploadfile;
	        var i = uploadfile_1.value.lastIndexOf(".");
	        if(i != -1){
	            chk = fullname.substring(i+1);
	        }

//			f2.insertStr_02.value 		= str;
			f2.e164.value 				= e164s;
			f2.hiStartTime_03.value 	= totalTime;
			f2.hiEndTime_03.value 		= totalTime2;
			f2.hiDayValue_03.value 		= naScCodeValue;
			f2.uploadfilename_03.value 	= uploadfile;

			//var parm 	= '&hie164='+e164s+'&hiStartTime='+totalTime+'&hiEndTime='+totalTime2+'&hiDayValue='+naScCodeValue+'&uploadfilename='+uploadfile;		//get�������� ���� ����.
	    	//var parm 	= '&e164='+f2.e164.value+'&userID='+f.hiUserID.value;	//get�������� ���� ����.
	    	var url 	= 'usrMrbtEditPro.jsp';
	    	
	    	// �ű� ����
	        f2.target="procframe";
	        f2.action="<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtEditPro.jsp";
	        f2.method="post";
	        f2.submit();
	        
	    	/* Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
			    	if(value=='NO'){
			    		alert("����!");
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
			});	 */
		}
		/**
		 * �ű��Է� �� ���
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
	 					if(_td) _td.innerHTML = "<a href='javascript:goSample('"+datas[z].params[1]+"');'>"+datas[z].params[1]+"&nbsp;</a>";
	 					
	 					_td = document.getElementById("h"+_i+"_3") ;
	 					if(_td) _td.innerHTML = "<FONT color=\"blue\">�����</FONT>&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td){
	 						//_td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"����\" onclick=\"func_setAction('"+_e164+"', '"+datas[z].params[1]+"', 0)\" >";
	 						_td.innerHTML = "<a href=\"#\" onclick=\"javascript:func_setAction('"+_e164+"', '"+datas[z].params[1]+"', 0);\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('Image"+_e164+"','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)\" >" ;
	 						_td.innerHTML += "<img src=\"<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif\" name=\"Image"+_e164+"\" width=\"34\" height=\"18\" border=\"0\">" ;
	 						_td.innerHTML +="</a>" ;
	 					}
	 					
	 					if(++_idx == _len)
		 					return ;
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
        /**
         * ���� ȭ������ �̵�
         */
        function goDelete(){
            var parm 	= '';
            var url 	= 'usrMrbtDelete.jsp';		    
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
		       	str = "";

            f.e164.value = str;

            //alert('e164s='+str);
            
		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * ����ó�� �� ���
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
	 					if(_td) _td.innerHTML = "������&nbsp;";
	 					
	 					_td = document.getElementById("h"+_i+"_4") ;
	 					if(_td){
	 						//_td.innerHTML = "<input type=\"button\" name=\"btnAction\" style=\"height: 18px\" value=\"����\" onclick=\"func_setAction('"+_e164+"', '', 0)\" >";
	 						_td.innerHTML = "<a href=\"#\" onclick=\"javascript:func_setAction('"+_e164+"', '', 0);\" onMouseOut=\"MM_swapImgRestore()\" onMouseOver=\"MM_swapImage('Image"+_e164+"','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)\" >" ;
	 						_td.innerHTML += "<img src=\"<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif\" name=\"Image"+_e164+"\" width=\"34\" height=\"18\" border=\"0\">" ;
	 						_td.innerHTML +="</a>" ;
	 					}
	 					
	 					if(++_idx == _len)
		 					return ;
	 				}
	 			}
			  }
			  _i++;
			}
		}
		
		/**
	     * add on Edit Popup
	     */
	    function editAddPro(){
	    	var f  = document.frm;
	    	var f2  = document.editForm;

	    	var time1 = f2.time1_2.value;
			var time2 =	f2.time2_2.value;
			var time3 =	f2.time3_2.value;
			var time4 =	f2.time4_2.value;
			var naScCodeValue 	= f2.naScCode_2.value;
			var totalTime 		= time1 + time2;
			var totalTime2 		= time3 + time4;

			var uploadfile_1	= f2.wFile_2;
			var uploadfile;
			var chk      = "";

			uploadfile = uploadfile_1.value;
			var fullname = uploadfile;
	        var i = uploadfile_1.value.lastIndexOf(".");
	        if(i != -1){
	            chk = fullname.substring(i+1);
	        }

//			f2.insertStr_02.value 		= str;
			//f2.e164.value 				= e164s;
			f2.hiStartTime_03.value 	= totalTime;
			f2.hiEndTime_03.value 		= totalTime2;
			f2.hiDayValue_03.value 		= naScCodeValue;
			f2.uploadfilename_03.value 	= uploadfile;

			//var parm 	= '&hie164='+e164s+'&hiStartTime='+totalTime+'&hiEndTime='+totalTime2+'&hiDayValue='+naScCodeValue+'&uploadfilename='+uploadfile;		//get�������� ���� ����.
	    	//var parm 	= '&e164='+f2.e164.value+'&userID='+f.hiUserID.value;	//get�������� ���� ����.
	    	//var url 	= 'usrMrbtEditPro.jsp';
	    	
	    	// �ű� ����
	        f2.target="procframe";
	        f2.action="<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtEditAddPro.jsp";
	        f2.method="post";
	        f2.submit();
		}
		/**
	     * �߰� ó��
	     */
	    function goEditAddPro(p_e164){        
			var time1 = document.getElementsByName("time1_2")[0].value;
			var time2 =	document.getElementsByName("time2_2")[0].value;
			var time3 =	document.getElementsByName("time3_2")[0].value;
			var time4 =	document.getElementsByName("time4_2")[0].value;
			var naScCodeValue 	= document.getElementsByName("naScCode_2")[0].value;
			var totalTime 		= time1 + time2;
			var totalTime2 		= time3 + time4;

			if((time1*1.0) > (time3*1.0)){
				alert("���۽ð��� ����ð� ���� Ŭ�� �����ϴ�.");
				return;		
			}

			var uploadfile_1	= document.getElementsByName("wFile_2")[0];
			var uploadfile;
			var chk      = "";
			
			uploadfile = uploadfile_1.value;
			if(uploadfile==""){
				alert("��ȭ������ ������ �������� �ʾҽ��ϴ�.");
				return;
			}
			
			var fullname = uploadfile;
	        var i = uploadfile_1.value.lastIndexOf(".");
	        if(i != -1){
	            chk = fullname.substring(i+1);
	        }
	        if(chk.toLowerCase() != "wav"){
	            alert("wav ���ϸ� ���ε� �� �� �ֽ��ϴ�.");
	            return;
	        }

			var f   				= document.frm;
			f.hiStartTime.value 	= totalTime;
	        f.hiEndTime.value 		= totalTime2;
	        f.hiDayValue.value 		= naScCodeValue;
	        f.uploadfilename.value 	= uploadfile;
	        
		    // �ű� �μ���ǥ��ȣ ����
		    var parm 	= '&hie164='+p_e164+'&hiStartTime='+totalTime+'&hiEndTime='+totalTime2+'&hiDayValue='+naScCodeValue+'&uploadfilename='+uploadfile;		//get�������� ���� ����.
    	    var url 	= 'usrMrbtChk.jsp';
		    
			Ext.Ajax.request({
				url : url , 
				params : parm,
				method: 'POST',
				success: function ( result, request ) {
					var tempResult = result.responseText;					
					var value = tempResult.replace(/\s/g, "");	// ��������
					
			    	if(value=='OK'){ 
			    		editAddPro();
				    	//alert("����2....!");
				    	//return;
			    	}else if(value=='NO'){
				    	alert("�̹� ������� ��ȭ������ ���� �Դϴ�!");
				    	return;
			    	}else if(value=='NO2'){
				    	alert("�̹� ��ϵ� ��ȭ������ �ð��� ������ �ֽ��ϴ�!");
				    	return;
			    	}else{
				    	alert("����!");
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
		 * ����ȭ������ �̵�
		 */
		function showEdit(p_E164, p_file){
			var parm 	= '&e164='+(p_E164?p_E164:'')+'&filename='+(p_file?p_file:'');
		    //var parm 		= '&e164='+p_E164;		//get�������� ���� ����.
		    var url 		= 'usrMrbtEdit.jsp';
			
			if(p_file == ""){
				alert("��ϵ� �������� �����ϴ�!");
				return;
			}
		    getPage(url,parm);			
		}
		/**
		 * ����ó��
		 */
		function showEditDelete(p_E164, p_day, p_start, p_end, p_file){
			var f  = document.frm;
			f.d_Ei64.value   	= p_E164;
			f.d_DayValue.value 	= p_day;
			f.d_StartTime.value = p_start;
			f.d_EndTime.value 	= p_end;
			f.d_filename.value 	= p_file;

			f.target='procframe';
	        //f.action="<%=StaticString.ContextRoot%>/mrbtDelete3.do";
	        f.action="<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtEditDeletePro.jsp";
	        f.method="post";
	        f.submit();		
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
                        f.action = "<%=StaticString.ContextRoot+pageDir%>/usrmrbt/usrMrbtSavePro.jsp";
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
                var parm = '&titlemsg='+'�Ϲ���ȭ ������ ����'+'&msg='+'�˻� ����� �����ϴ�.';
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
                    var parm = '&titlemsg='+'�Ϲ���ȭ ������ ����'+'&msg='+processname+'�� �׸��� �����Ͽ� �ֽʽÿ�.';
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
                    	f.chkOpt.value = f.chkOpt.parentNode.parentNode.cells[3].innerHTML;
                    	str = f.chkOpt.value;
                    }
                }else{
                    for(var i=0; i<f.chkOpt.length; i++){
                        if(f.chkOpt[i].checked){
                            if(str == ""){
                            	f.chkOpt[i].value = f.chkOpt[i].parentNode.parentNode.cells[3].innerHTML;
                            	str = f.chkOpt[i].value;
                            }else{
                            	f.chkOpt[i].value = f.chkOpt[i].parentNode.parentNode.cells[3].innerHTML;
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
		function func_setAction(num, virtual, action) {
			document.frm.e164.value = num;
			document.frm.grpid.value = '<%=authGroupid%>';
			if(action==1){
				goDelete();
				//window.open("usrMrbtDelete.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
			}
			else{
				goInsert(num, virtual);
				//window.open("usrMrbtInsert.jsp?num="+num, "_blank", "width=430,height=260,resizable=1,scrollbars=1,menubar=0,location=0,toolbar=0,status=0,directories=0") ;
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
// 		 	document.cookie = "id_cookie_callblock" + "=";
		 	document.location.href = "<%=StaticString.ContextRoot+pageDir%>/conn/logout.jsp";
		}
		
		function realtimeClock() {
			  document.location.href = 'usrMrbtList.jsp';
			  setTimeout("realtimeClock()", 1000);
		}
		
		function changeTitle(nField){
			if(nField==0){
				if( lastSort==nField ){
					document.getElementById('memname').innerHTML = "<b>������ȣ��</b>";
				}else{
					document.getElementById('memname').innerHTML = "<b>������ȣ��</b>";							
				}
				document.getElementById('telnum').innerHTML = "��ȭ��ȣ<font size='1px'>��</font>";
				document.getElementById('filename').innerHTML = "������ ���ϸ�<font size='1px'>��</font>";
			}
			else if(nField==1){
				if( lastSort==nField ){
					document.getElementById('telnum').innerHTML = "<b>��ȭ��ȣ��</b>";
				}else{
					document.getElementById('telnum').innerHTML = "<b>��ȭ��ȣ��</b>";
				}
				document.getElementById('memname').innerHTML = "������ȣ<font size='1px'>��</font>";//��
				document.getElementById('filename').innerHTML = "������ ���ϸ�<font size='1px'>��</font>";
			}
			else if(nField==2){
				if( lastSort==nField ){
					document.getElementById('filename').innerHTML = "<b>������ ���ϸ��</b>";
				}else{
					document.getElementById('filename').innerHTML = "<b>������ ���ϸ��</b>";							
				}
				document.getElementById('memname').innerHTML = "������ȣ<font size='1px'>��</font>";							
				document.getElementById('telnum').innerHTML = "��ȭ��ȣ<font size='1px'>��</font>";
			}
		}
		
		// ���� �ٿ�ε�
	    function goSample(filename){
	        resultdownloadframe.location.href = "<%=StaticString.ContextRoot%>/addition/download.jsp?filename="+filename;
	    }
		
	    function func_init(){
			var e164 = "<%=viewType%>";
			var strTemp= "1"; 
			if(e164!=""){
				showEdit(e164, strTemp);
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

<BODY onload="func_init();" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" <%if(nAllowUser<1) out.println("onLoad=\"goLogin();\""); %>>
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

<div>
<table align="center" border="0">
<tr>
	<td width="180" style="min-width:180px;" >
	<!--strat--����������-->
		<% int menu = 3, submenu = 4; %>
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
	
	<input type='hidden' name ='hiEi64' 			value=""/>
	<input type='hidden' name ='hiVirtualc1'		value=""/>
	<input type='hidden' name ='hiVirtualc2'		value=""/>
	<input type='hidden' name ='uploadfilename'		value=""/>
	<input type='hidden' name ='hiStartTime'		value=""/>
	<input type='hidden' name ='hiEndTime'			value=""/>
	<input type='hidden' name ='hiDayValue'			value=""/>
	<input type='hidden' name ='deleteStr' 			value=""/>
	<input type='hidden' name ='insertStr' 			value=""/>
	
	<input type='hidden' name ='d_Ei64' 			value=""/>
	<input type='hidden' name ='d_DayValue'			value=""/>
	<input type='hidden' name ='d_StartTime'		value=""/>
	<input type='hidden' name ='d_EndTime'			value=""/>
	<input type='hidden' name ='d_filename'			value=""/>
	
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
                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"�α׾ƿ�\" onclick=\"func_logoutCommit(1)\">") ;
                  %>
                  		<font style="color: blue;vertical-align: bottom;"><%=authGroupid+(userLevel!=2?"":authGroupid.length()==0?userID:"("+userID+")")%></font>
                	 	<input type="button" name="btnLogout" style="height: 18px" value="�α׾ƿ�" onclick="func_logoutCommit(1)">
                	 	<input type="button" style="height: 18px" value="����" onclick="document.location.href = 'usrMrbtList.jsp'">
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"�α���\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<input type="button" name="btnLogin" style="height: 18px" value="�α���" onclick="document.location.href = 'usrMrbtList.jsp'"> 
	           	  <% } %> --%>
                  </td>
                  <td colspan="3"></td>
                  <td colspan="2" width="300" align="right"> 
                  	<% if(nAllowUser==1) { %>
                  	<input type="button" name="btnPutAlarm" style="height: 18px" value="���� ���" onclick="func_setActionBySelected(0)">
                  	<input type="button" name="btnDelAlarm" style="height: 18px" value="���� ����" onclick="func_setActionBySelected(1)">
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
                  <td width="43" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">��ȣ</td>
                  <td width="102" onclick="sortNow(0);changeTitle(0);" id="memname" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><b>������ȣ��</b></td>
                  <td width="180" onclick="sortNow(1,true);changeTitle(1);" id="telnum" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">��ȭ��ȣ<font size='1px'>��</font></td>
                  <td width="110" onclick="sortNow(2);changeTitle(2);" id="filename" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">������ ���ϸ�<font size='1px'>��</font></td>
                  <td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">�������</td>
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
		MrbtDTO dto= null;
		//String[] strVirtuals;
		if(iList!=null)
			for(idx=0;idx<endidx;idx++){
				dto	= (MrbtDTO)iList.get(idx);
				if(dto!=null){
					//nTotalpage = (int)StringUtil.getLong((String)temp.get("totalcnt")) / nMaxitemcnt;
					nTotalpage =  (int)(count/nMaxitemcnt);
					
					//strVirtuals = 1!=dto.getUsechk()?new String[3]: (dto.getVirtual()+",a").split("[,]") ;
					%>	
					  <tr id=g<%=idx%> height="22" align="center" bgcolor="<%=idx%2==0?"#F3F9F5":"#fcfcfc"%>" onmouseover='this.style.backgroundColor="#E7F0EC"' onmouseout='<%=idx%2==0?"this.style.backgroundColor=\"#F3F9F5\"":"this.style.backgroundColor=\"#fcfcfc\"" %>' >
		                <td width="43px" class="table_column"> <input type="checkbox" name="chkOpt" onclick="this.value=this.parentNode.parentNode.cells[3].innerHTML;" value="<%=StringUtil.nvl(dto.getE164())%>" > </td> <%-- rgb(243,247,245)==3F7F5 or A8D3AA --%>
		                <td width="45px" class="table_column"><%=nModePaging==1? nNowpage*nMaxitemcnt+idx+1 : idx+1 %></td>
		                <td width="130px" id='h<%=idx%>_0' class="table_column"><%=dto.getName()%></td>
		                <td width="200px" id='h<%=idx%>_1' class="table_column"><%=dto.getE164()%></td>
		                <td width="140px" id='h<%=idx%>_2' class='table_column'><%=1>dto.getUsechk()? "&nbsp;":"<a href=\"javascript:goSample('"+dto.getFilename()+"');\">"+dto.getFilename()+"&nbsp;</a>" %></td>
		                <td width="100px" id='h<%=idx%>_3' class="table_column">
		                <%
		                	if( 1>dto.getUsechk() ) out.print("������&nbsp;");
		                	else out.print("<FONT color=\"blue\">�����</FONT>&nbsp;");
		                %>
		                </td>
		                <td width="35px" id='h<%=idx%>_4' class="table_column">
		                	<%-- <input type="button" name="btnAction" style="height: 18px" value="����" onclick="func_setAction('<%=dto.getE164()%>', '<%=0<dto.getUsechk()?"":dto.getFilename()%>', 0)"> --%>
		                	<a href="#" onclick="javascript:func_setAction('<%=dto.getE164()%>', '<%=1>dto.getUsechk()?"":dto.getFilename()%>', 0);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image<%=dto.getE164()%>','','<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif',0)">
		                		<img src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" name="Image<%=dto.getE164()%>" width="34" height="18" border="0">
		                	</a>
		                </td>
		                <td class="table_column">&nbsp;</td>
		              </tr>
					<% 
				}
			}//for
	}//if
	out.println("<script type=\"text/JavaScript\"> sortNow(1,true); </script>") ;//��ȣ ����
		
    if(nModePaging==1){
    	int nBlockidx = (nNowpage / nBlockcnt);
%>
		       <tr height="22" bgcolor="E7F0EC" align="center" >
		       		<td colspan = 2 align="right" > 
		       			<% if(nBlockidx > 0){ %>
		       				<table width="50">
		       					<tr>
		       						<td align="left"> <a href="usrMrbtList.jsp?page=0"> &#60;&#60; </a> </td>
		       						<td align="right"> <a href="usrMrbtList.jsp?page=<%=(nBlockidx-1)*nBlockcnt+nBlockcnt-1%>"> &#60; </a> </td>
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
      				out.print(" <a href=\"usrMrbtList.jsp?page="+(i)+"\"> "+(i+1)+" </a> ") ;
		}
%> 
		       		</td>
		         	<td colspan = 2 align="left" > 
						<% if( (nBlockidx+1)*nBlockcnt < nTotalpage ) { %>
							<table width="50">
		       					<tr>
		       						<td align="left"> <a href="usrMrbtList.jsp?page=<%=(nBlockidx+1)*nBlockcnt%>"> &#62; </a> </td>
		       						<td align="right"> <a href="usrMrbtList.jsp?page=<%=nTotalpage%>"> &#62;&#62; </a> </td>
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
<iframe name="resultdownloadframe" style="border-width:0px;" width="0" height="0" frameborder="0" scrolling="no" tabindex="-1"></iframe>
</div>

</BODY>
</HTML>
<!-- �˾� ���̾� -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;">
