<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.AlarmServiceDTO" %>
<%@ page import="addition.AlarmServiceList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>

<%@ page import="business.CommonData"%>
<%@ page import="system.SystemConfigSet"%>

<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userName   = Str.CheckNullString(scDTO.getName()).trim();
String userID     = Str.CheckNullString(scDTO.getSubsID()).trim();
String phoneNum   = Str.CheckNullString(scDTO.getPhoneNum()).trim();
String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // ��������(1:�����, 2:������)
String menu       = "5";  // �ΰ�����
String submenu    = "6";  // �켱 ���� ����

String new_menu     = "0";
String new_submenu  = "0";

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW");

try{
    //����Ʈ
    AlarmServiceList alarmServiceList = new AlarmServiceList();

    List alarmList = alarmServiceList.getList(stmt, phoneNum);				// ����Ÿ ��ȸ

    int count = alarmList.size();
    
    
 	// ������ ��ȸ
    CommonData		commonData	= new CommonData();
    String 			domainid 	= commonData.getDomain(stmt);						// ������ID ��ȸ
    String[]		tempDomain;
    if(!"".equals(domainid)){
    	tempDomain 	= domainid.split("[.]");
    	domainid	= tempDomain[0];			
    }
    // DDNS ���� ��ȸ
	SystemConfigSet 	systemConfig 	= new SystemConfigSet();
	String 				strVersion 		= systemConfig.getSystemVersion();					// ����
	String 				goodsName 		= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: <%=domainid%>, Ver: <%=strVersion%></title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script language="JavaScript" type="text/JavaScript">
    function stripHTML(_str)
    {
      if(!_str)return;

      var _str2;
      var _reg=/<.*?>/gi;
      while(_str.match(_reg)!=null)
      {
        _str=_str.replace(_reg,"");
      }
      return _str;
    }
    function bubbleSort(_a,c,_ud,_isNumber)
    {
      for(var i=0;i<_a.length;i++)
      {
        for(var j=i;j<_a.length;j++)
        {
          var _left=stripHTML(_a[i][c]);
          var _right=stripHTML(_a[j][c]);
          var _sign=_ud?">":"<";
          var _yes=false;
          if(_isNumber)
          {
             if(_ud && (parseInt(_left)-parseInt(_right)>0))_yes=true;
             if(!_ud && (parseInt(_left)-parseInt(_right)<0))_yes=true;
          }
          else
          {
            if(_ud && _left.toLowerCase() > _right.toLowerCase())_yes=true;
            if(!_ud && _left.toLowerCase() < _right.toLowerCase())_yes=true;
          }
          if(_yes)
          {
            /* swap rows */
            for(var x=0;x<_a[i].length;x++)
            {
              var _t=_a[i][x];
              _a[i][x]=_a[j][x];
              _a[j][x]=_t;
            }
          }
        }
      }
      return _a;
    }
    var lastSort=null;
    function sortNow(_c,_isNumber)
    {
      var _a=new Array();
      var _o=null;
      var _i=0;
      while(_o=document.getElementById("g"+_i))
      {
        _a[_i]=new Array();
        var _j=0;
        while(_p=document.getElementById("h"+_i+"_"+_j))
        {
          _a[_i][_j]=_p.innerHTML;
          _j++;
        }
        _i++;
      }
      _a=bubbleSort(_a,_c,lastSort!=_c,_isNumber);
      for(var b=0;b<_a.length;b++)
      {
        for(var c=0;c<_a[b].length;c++)
        {
          document.getElementById("h"+b+"_"+c).innerHTML=_a[b][c];
        }
      }
      if(lastSort!=_c)
        lastSort=_c;
      else
        lastSort=null;
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

</SCRIPT>

</head>

<body onLoad="MM_preloadImages('<%=StaticString.ContextRoot%>/imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')">
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<div>
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
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
		    obj.style.top =150;
		    obj.style.left = 250;
		
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
		function goInsert(){
		    var parm 	= "";
		    var url 	= 'alarmInsert.jsp';		    

		    getPage(url,parm);			
		}

		/**
		 * �ű� ���� �����ϱ�
		 */
		function goNewSave(){
			var f  = document.frm;
            var f2 = document.Savelayer;
            
            f.alarmtype.value   = f2.alarmtype.value;
            f.alarmtime_1.value = f2.alarmtime_1.value;
            f.alarmtime_2.value = f2.alarmtime_2.value;
            f.alarmtime_3.value = f2.alarmtime_3.value;
            f.alarmdate_1.value = "<%=StringUtil.getKSTDate().substring(0,4)%>";
            f.alarmdate_2.value = f2.alarmdate_1.value;
            f.alarmdate_3.value = f2.alarmdate_2.value;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot%>/addition/alarmInsertPro.jsp";
            f.method = "post";
            f.submit();	
		}
		
		/**
		 * ���� �ű��Է� ȭ������ �̵�
		 */
		function goInsert(){
		    var parm 	= "";
		    var url 	= 'alarmInsert.jsp';		    

		    getPage(url,parm);			
		}
		
        /**
         * ���� ȭ������ �̵�
         */
        function goDelete(){
            var f   = document.frm;
            var cnt = 0;
            if(f.chkOpt == undefined){
                var parm = '&titlemsg='+'�����ð��뺸 ����'+'&msg='+'�˻� ����� �����ϴ�.';
                var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
                getPage(url,parm);
                return;
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
                    var parm = '&titlemsg='+'�����ð��뺸 ����'+'&msg='+'������ �׸��� �����Ͽ� �ֽʽÿ�.';
                    var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }
            }
            
            var parm 	= '';
            var url 	= 'alarmDelete.jsp';		    
            getPage(url,parm);			
        }

		/**
		 * ����ó��
		 */
		function goDeletePro(){
            var f   = document.frm;
            var str = "";
            if(f.chkOpt != undefined){
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
                                str = str + "|" + f.chkOpt[i].value;
                            }
                        }
                    }
                }
            }

            f.deleteStr.value = str;

		   	f.target = "procframe";
            f.action = "<%=StaticString.ContextRoot%>/addition/alarmDeletePro.jsp";
            f.method = "post";
            f.submit();	
		}

        /**
		 * �����ϱ�
		 */
		function goSave(){
			var f  = document.frm;

            if(f.gubun[0].checked){     // ���� �ð� �뺸 ������� ���� 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'�����ð��뺸 ����'+'&msg='+'�����ð��뺸�� ������� �ʴ� �����Դϴ�.';
                    var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    if(confirm("��� ������ �����˴ϴ�. �����Ͻðڽ��ϱ�?")){
                        f.target = "procframe";
                        f.action = "<%=StaticString.ContextRoot%>/addition/alarmSavePro.jsp";
                        f.method = "post";
                        f.submit();	
                    }                
                }
            }else if(f.gubun[1].checked){   // ���� �ð� �뺸 ����ϱ� 
                if(f.chkOpt == undefined){
                    var parm = '&titlemsg='+'�����ð��뺸 ����'+'&msg='+'�����ð��뺸 ������ �߰��Ͽ� �ֽʽÿ�.';
                    var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }else{
                    var parm = '&titlemsg='+'�����ð��뺸 ����'+'&msg='+'�����ð��뺸�� ����ϰ� �ֽ��ϴ�.';
                    var url  = "<%=StaticString.ContextRoot%>/msgPopup.jsp";
                    getPage(url,parm);
                    return;
                }
            }

		}		

	</script>

<!--strat--���������-->
<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
	<%@ include file="/menu/topMenu.jsp"%>
	</td>
  </tr>
</table>
<!--end--���������-->
<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td >
<!--strat--����������-->
<table width="165" border="0" cellspacing="0" cellpadding="0"  align="left">
<%  if("1".equals(loginLevel)){ %>
<%@ include file="/menu/leftUserMenu.jsp"%>
<%  }else if("2".equals(loginLevel)){   %>
<%@ include file="/menu/leftAdminMenu.jsp"%>
<%  }   %>
</table>
<!--end--����������-->
<!--star--������������-->
<table width="810" border="0" cellspacing="0" cellpadding="0" align="center">
<form name="frm" method="post">
<input type='hidden' name ='e164' value="<%=phoneNum%>">
<input type='hidden' name ='alarmtype' value="">
<input type='hidden' name ='alarmtime_1' value="">
<input type='hidden' name ='alarmtime_2' value="">
<input type='hidden' name ='alarmtime_3' value="">
<input type='hidden' name ='alarmdate_1' value="">
<input type='hidden' name ='alarmdate_2' value="">
<input type='hidden' name ='alarmdate_3' value="">

<input type='hidden' name ='deleteStr' value="">
  <tr>
    <td>
	
<!--start_�˻��κ�-->
<table width="810" border="0" cellspacing="0" cellpadding="0" align="left" style="margin:8 0 8 0 ">

  <tr>
    <td width="144" height="35" align="right" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/content_title_ontime_img.gif" width="137" height="20"></td>
    <td style="color:#524458; padding-top:4" background="<%=StaticString.ContextRoot%>/imgs/Content_titlebg_img.gif">&nbsp;</td>
  </tr>

</table>	
				<!--end_�˻��κ�-->
</td>
  </tr>

  <tr>
    <td style="padding-top:14; padding-bottom:5; background:eeeff0; border-bottom:1 solid #cdcecf; height:405" valign="top" >
      <table width="775" border="0" cellspacing="0" cellpadding="0" align="right" style="margin:0 0 0 0 ">
      <tr>
        <td align="left">
           <input type="radio" name="gubun" value="1" <%if(count == 0)out.print("checked");%>>���� �ð� �뺸 ������� ����
        </td>
      </tr>
      <tr>
        <td align="left">
            <input name="gubun" type="radio" value="2" <%if(count > 0)out.print("checked");%>>���� �ð� �뺸 ����ϱ�
        </td>
      </tr>
      <tr>
        <td height="5"></td>
      </tr>
      <tr>
        <td style="padding-bottom:5 "><table width="775" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td valign="bottom"><table width="100%" border="0">
                <tr>
                  <td><a href="javascript:goInsert();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image9','','<%=StaticString.ContextRoot%>/imgs/addser_add_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/addser_add_n_btn.gif" name="Image9" width="30" height="20" border="0" alt="�����ð��뺸�����߰�"></a> <a href="javascript:goDelete();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image60','','<%=StaticString.ContextRoot%>/imgs/addser_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/addser_delete_n_btn.gif" name="Image60" width="30" height="20" border="0" alt="�����ð��뺸��������"></a></td>
                  <td>&nbsp;</td>
                  <td></td>
                </tr>
              </table></td>
              </tr>
        </table></td>
      </tr>
<TBODY>
      <tr>
        <td valign="bottom">
          <table width="775" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
              <tr align="center" height="22" >
                  <td width="58" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif"><input type="checkbox" name="chkOptAll" onClick="checkAll(this);" ></td>
                  <td width="200" onclick=sortNow(0); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">�����Ⱓ</td>
                  <td width="200" onclick=sortNow(1); class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">�����ð�</td>
                  <td class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">&nbsp;</td>
              </tr>
		  </table>
		</td>
	</tr>
	<tr>
        <td valign="top">
<div style="width:792; height:222; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0">		
          <table width="775" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
<%																																						 
    AlarmServiceDTO alarmServiceDTO = null;
    int chk = 0;
    String alarmDateStr = "";
    String alarmTimeStr = "";
    for ( int idx = 0; idx < count ; idx++ ) {
        alarmServiceDTO = (AlarmServiceDTO)alarmList.get(idx);
        if(alarmServiceDTO.getAlarmType() == 1){
            alarmDateStr = alarmServiceDTO.getAlarmDate().substring(0,4)+"��"+alarmServiceDTO.getAlarmDate().substring(4,6)+"��"+alarmServiceDTO.getAlarmDate().substring(6)+"��";
        }else if(alarmServiceDTO.getAlarmType() == 2){
            alarmDateStr = "����";
        }else if(alarmServiceDTO.getAlarmType() == 3){
            alarmDateStr = "��,ȭ,��,��,��,��";
        }else if(alarmServiceDTO.getAlarmType() == 4){
            alarmDateStr = "��,ȭ,��,��,��";
        }
        
        alarmTimeStr = alarmServiceDTO.getAlarmTime().substring(0,2)+"��"+alarmServiceDTO.getAlarmTime().substring(2)+"��";
        if(chk == 0){
%>	
			  <tr id=g<%=idx%> height="22" bgcolor="rgb(243,247,245)" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="rgb(243,247,245)">
                <td width="58" id=h<%=idx%>_3 class="table_column"><input type="checkbox" name="chkOpt" value="<%=alarmServiceDTO.getSequenceNo()%>"></td>
                <td width="200" id=h<%=idx%>_0 class="table_column"><%=alarmDateStr%>&nbsp;</td>
                <td width="200" id=h<%=idx%>_1 class="table_column"><%=alarmTimeStr%>&nbsp;</td>
                <td id=h<%=idx%>_2 class="table_column">&nbsp;</td>
              </tr>
<%
            chk = 1;
        }else{    
%>
              <tr id=g<%=idx%> height="22" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
                <td width="58" id=h<%=idx%>_3 class="table_column"><input type="checkbox" name="chkOpt" value="<%=alarmServiceDTO.getSequenceNo()%>"></td>
                <td width="200" id=h<%=idx%>_0 class="table_column"><%=alarmDateStr%>&nbsp;</td>
                <td width="200" id=h<%=idx%>_1 class="table_column"><%=alarmTimeStr%>&nbsp;</td>
                <td id=h<%=idx%>_2 class="table_column">&nbsp;</td>
              </tr>
<% 
            chk = 0;
        }
    }
%>
              
          </table>
</div>
        </td>
      </tr>
</TBODY>
      <!--<tr>
        <td><img src="<%=StaticString.ContextRoot%>/imgs/Content_undertable_img.gif" width="775" height="2"></td>
      </tr>-->
      <tr>
        <td style="padding-bottom:5; padding-top:8 "><table width="775" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td colspan="7"><div align="center"><a href="javascript:goSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image2" width="40" height="20" border="0"></a> <a href="#" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></div></td>
              </tr>
            
        </table></td>
      </tr>
    </table></td>
  </tr>
</form>
</table>
<!--end--������������-->
    </td>
  </tr>
<!----------------------- footer �̹��� �߰� start ----------------------------->
<tr>
    <td ><img src="<%=StaticString.ContextRoot%>/imgs/main_footer_img.gif" width="1000" height="30"></td>
</tr>
<!----------------------- footer �̹��� �߰�   end ----------------------------->
</table>
<iframe name="procframe" src="" width="0" height="0"></iframe>
</div>
</body>
</html>
<!-- �˾� ���̾� -->
<div id="popup_layer" style="display:none;position:absolute;width:250px;background:;border:0px solid #999999;">
<%
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		//�Ҵ���� DataStatement ��ü�� �ݳ�
		if (stmt != null ) ConnectionManager.freeStatement(stmt);
	}	
%>