<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.E164BlockDTO" %>
<%@ page import="useconfig.AddServiceList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="business.CommonData"%>

<%
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;

boolean bModify = !"1".equals( (String)request.getParameter("procmode") );
String e164 = request.getParameter("e164") ;
String 	ei64		= e164==null?"":new String(e164.getBytes("8859_1"), "euc-kr");
String[] e164s = StringUtil.getParser(ei64, "");

List 	iList=null;
int		iCount=0;
String 	strType= "1";
//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
}catch(Exception ex){ ex.printStackTrace(); }

if (stmt != null ) {
	if(bModify){
		AddServiceList 	addServiceList 	= new AddServiceList();
		iList 			= addServiceList.getAddCallBlockList(stmt, ei64);	// 데이타 조회
		iCount			= iList.size();		
		strType			= addServiceList.getCallBlockType(stmt, ei64);
		
		//할당받은 DataStatement 객체는 반납
		ConnectionManager.freeStatement(stmt);
	}
}else{
	if(nModeDebug==1){
		if(bModify){
			List<E164BlockDTO> 	e164BlockList = new ArrayList<E164BlockDTO>();
			E164BlockDTO e164BlockDTO = new E164BlockDTO();
	    	e164BlockDTO.setE164(Str.CheckNullString(ei64));
	    	e164BlockDTO.setStartPrefix("00099*");
	    	e164BlockDTO.setPrefixType("1");
	    	e164BlockDTO.setBlockIdType("3");
	    	e164BlockDTO.setDescription("내선번호");
	    	e164BlockList.add(e164BlockDTO);
	    	
			iList   = e164BlockList ;
			iCount  = iList.size();
			strType = "3";
		}
	}
}

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<form name="editForm" method="post">
<input type='hidden' name ='e164'		value="<%=ei64%>">
<input type='hidden' name ='dataType'	value="">
<input type='hidden' name ='hiUserID'	value="<%=authGroupid/* userID */%>">
<input type='hidden' name ='procMode'	value="<%=bModify?0:1%>">

<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	<tr height="30" >
	  <%-- <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
		  <table border="1" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
		   <tr>
		    <td width="10">&nbsp;</td>
		    <td colspan="2" >
		    	<span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">발신제한 수정 [번호 : <%=ei64%>]</span>
		    </td>
		    <td width="10" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
		    <td width="10">&nbsp;</td>
		   </tr>
		
		  </table>
	  </td> --%>
	   <td width="10" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" >&nbsp;</td>
		    <td colspan="2" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
		    	<span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">발신제한 <%=iList!=null?"수정 [번호 : "+ei64+"]":"등록"%></span>
		    </td>
		    <td width="10" align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
		    	<img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
		    <td width="10" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">&nbsp;</td>
	 </tr>

	<tr>
	  	<td colspan="5" height="7"></td>
	</tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10" height="10">&nbsp;</td>
    </tr>

	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
			<%if("1".equals(strType)){%>
				<input type="radio" name="radioType1" id="blockType_2" onClick="radio_Chk2(1);" value="1" checked> 전체번호 <br>
				<input type="radio" name="radioType1" id="blockType_3" onClick="radio_Chk2(3);" value="3"> 특정번호 <br>
			<%}else if("3".equals(strType)){%>
				<input type="radio" name="radioType1" id="blockType_2" onClick="radio_Chk2(1);" value="1"> 전체번호 <br>
				<input type="radio" name="radioType1" id="blockType_3" onClick="radio_Chk2(3);" value="3" checked> 특정번호 <br>
			<%}%>
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10" height="10">&nbsp;</td>
		<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="300" align="center"></td>
	    <td width="10">&nbsp;</td>
    </tr>

    <tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10">&nbsp;&nbsp;&nbsp;제한/허용
		    <select name="prefixType" style="width:55 " class="select01">
	        	<option value="0">제한</option>
	        	<option value="1">허용</option>
	        </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;번호유형
		    <select name="blockType" style="width:86 " class="select01" onChange="javascript:selectType2()">
	        	<option value="2">프리픽스</option>
	        	<option value="3">개별번호</option>
	        	<option value="4">국제전화</option>
	        	<option value="5">이동전화</option>
	        	<option value="9">내선번호</option>
	        	<option value="8">특수코드</option>
	        </select>
		</td>
		<td width="10">&nbsp;</td>
	</tr>
    
    <tr height="3">
	    <td width="10"  height="1">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10" height="1">&nbsp;</td>
    </tr>

    <tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10">&nbsp;&nbsp;&nbsp;번호
		    <input type="text" name="txtE164" id="txtE164" style="width:110" maxlength="12">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;설명
		    <input type="text" name="txtNote" id="txtNote" style="width:110" maxlength="15">
		    <%--&nbsp;&nbsp;&nbsp; <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onClick="javascript:goInsertPro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20"> --%>
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<%
if(iList!=null){
%>	
	<tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" align="right" style="padding-top: 10px; padding-right: 30px">
		    <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onClick="javascript:goInsertPro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<%
}
%>
    <tr>
	    <td width="10"  height="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">
		<table width="380" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">&nbsp;</td>
			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>

<%
if(iList!=null){
%>
    <tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10" valign="top">
		<!--div id="responseTimeDiv"-->
		<table id=box border="0" cellspacing="0" cellpadding="0" class="list_table">
			<!--tbody id="subTbody"-->
			<tr height="20" bgcolor="rgb(190,188,182)" align="center" >
				<td width="37" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">발신</td>
				<td width="65" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">번호유형</td>
				<td width="105" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">번호</td>
				<td width="115" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">설명</td>
				<td width="40" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">삭제</td>
			</tr>
			<!--/tbody-->
		</table>
		<!--/div-->
		</td>
	    <td width="10">&nbsp;</td>
  	</tr>


	<tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10" valign="top">
			
	        <table id="tb_prefix_list" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
<%
			E164BlockDTO 	e164BlockDTO 	= null;
			int chk = 0;  
		                  
	      	for ( int idx = 0; idx < iCount ; idx++ ) {
	      		e164BlockDTO = (E164BlockDTO)iList.get(idx);        	
	            if(chk == 0){
%>    
				<tr id="<%=e164BlockDTO.getStartPrefix()%>" height="22" bgcolor="#F3F9F5" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="#F3F9F5">
					<%if("0".equals(e164BlockDTO.getPrefixType())){%>
						<td width="37" class="table_column">제한&nbsp;</td>
					<%}else if("1".equals(e164BlockDTO.getPrefixType())){%>
						<td width="37" class="table_column">허용&nbsp;</td>
					<%}%>
					<%if("1".equals(e164BlockDTO.getBlockIdType())||"2".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">프리픽스&nbsp;</td>
					<%}else if("3".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">전화번호&nbsp;</td>
					<%}else if("4".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">국제전화&nbsp;</td>
					<%}else if("5".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">이동전화&nbsp;</td>
					<%}else if("9".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">내선번호&nbsp;</td>
					<%}else if("8".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">특수코드&nbsp;</td>
					<%}%>
					<td width="105" class="table_column"><%=e164BlockDTO.getStartPrefix()%>&nbsp;</td>
					<td width="115" class="table_column"><%=e164BlockDTO.getDescription()%>&nbsp;</td>
					<td width="40" class="table_column"><a href="#" onclick="javascript:goDeletePro2('<%=ei64%>','<%=e164BlockDTO.getStartPrefix()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image1<%=idx%>" width="34" height="18" border="0"></a></td>
				</tr>
<%
	                chk = 1;
	            }else{    
%>
				<tr id="<%=e164BlockDTO.getStartPrefix()%>" height="22" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
					<%if("0".equals(e164BlockDTO.getPrefixType())){%>
						<td width="37" class="table_column">제한&nbsp;</td>
					<%}else if("1".equals(e164BlockDTO.getPrefixType())){%>
						<td width="37" class="table_column">허용&nbsp;</td>
					<%}%>
					<%if("1".equals(e164BlockDTO.getBlockIdType())||"2".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">프리픽스&nbsp;</td>
					<%}else if("3".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">전화번호&nbsp;</td>
					<%}else if("4".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">국제전화&nbsp;</td>
					<%}else if("5".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">이동전화&nbsp;</td>
					<%}else if("9".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">내선번호&nbsp;</td>
					<%}else if("8".equals(e164BlockDTO.getBlockIdType())){%>
						<td width="65" class="table_column">특수코드&nbsp;</td>
					<%}%>
					<td width="105" class="table_column"><%=e164BlockDTO.getStartPrefix()%>&nbsp;</td>
					<td width="115" class="table_column"><%=e164BlockDTO.getDescription()%>&nbsp;</td>
					<td width="40" class="table_column"><a href="#" onclick="javascript:goDeletePro2('<%=ei64%>','<%=e164BlockDTO.getStartPrefix()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image1<%=idx%>" width="34" height="18" border="0"></a></td>
				</tr>
<% 
	                chk = 0;
	            }
	        }
%>
			</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<%
}// iList!=null
%>	
    <tr height="3">
	    <td width="10"  height="1">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10" height="1">&nbsp;</td>
    </tr>
	
	<tr>
	    <td height="35">&nbsp;</td>
	    <td colspan="3" align="center" style="padding-top:3 ">
<%if(iList==null){ %>	    
	      <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onClick="javascript:goInsertPro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
<%} %>	    
		  <img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onClick="hiddenAdCodeDiv();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
		</td>
	    <td>&nbsp;</td>
	</tr>

</table>
</form>
</body>
</html>
