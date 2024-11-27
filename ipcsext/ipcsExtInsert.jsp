<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dto.ZipCodeDTO" %>
<%@ page import="business.ZipCode"%>
<%@ page import="business.CommonData"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<%@ page import="system.SystemConfigSet"%>
<%@ page import="business.ipcs.IpPhoneList"%>
<%@ page import="dto.ipcs.IpPhoneDTO"%>
<%@ page import="java.util.ArrayList"%>

<%@ page import="java.util.*, java.sql.ResultSet" %>
<%@ page import="dto.organization.DeptListDTO" %>

<% 
//System.out.println("프로그램 로그 : 11111");

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

//System.out.println("프로그램 로그 : 22222");

//System.out.println("프로그램 로그 : 33333");

HttpSession 		ses 		= request.getSession();
String checkgroupid = (String)ses.getAttribute("login.name");
String userID = Str.CheckNullString((String)ses.getAttribute("login.user")).trim();

String 	endPointID	= request.getParameter("hiEndPointID");							// SIP 단말ID
String 	ei64		= request.getParameter("hiEi64");								// 전체 전화번호
String 	extension	= request.getParameter("hiExtension");							// 내선번호
String	areacode	= StringUtil.null2Str(request.getParameter("hiAreaCode"),"070");	// 지역번호
String 	maxE164		= "";//StringUtil.null2Str(request.getParameter("maxE164"),"").trim();		// 전화번호 추가

//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("EMS");
ZipCode	zipCode		= new ZipCode();
List 	zipCodeList = zipCode.getData(stmt);	// 지역번호 데이타 조회
int zipCount = zipCodeList.size();
//할당받은 DataStatement 객체는 반납
if (stmt != null) ConnectionManager.freeStatement(stmt);

String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt2 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
CommonData		commonData	= new CommonData();
String 			groupid 	= checkgroupid;//commonData.getGroupID(stmt2);			// 가입자 그룹 조회
String 			domainID 	= "" ;
String 			zoneCode 	= commonData.getZone(stmt2);			// 망관리 조회

String sql = "";
ResultSet rs = null;
try{
	sql = "\n select max(route.E164) ";
	sql = sql + "\n  From Table_SipEndpoint ep ";
	sql = sql + "\n  LEFT JOIN  table_e164Route route ON ep.ENDPOINTID = route.ENDPOINTID and route.routingNumbertype in (1)  ";    
	sql = sql + "\n  WHERE ep.ENDPOINTID not like 'ACRO_MS_%' ";
	sql = sql + "\n    And ep.ENDPOINTID not in (select coalesce(auth_id,'') from NASA_TRUNK_SET) ";
	sql = sql + "\n    And ep.endpointclass = 33 ";		// 신규장비 때문에 추가된 부분 (2012.04.03)
	//if(checkgroupid!=null) sql = sql +  "\n AND ep.checkgroupid='"+checkgroupid+"' ";
	System.out.println("maxe164.sql : "+sql);
	rs = stmt2.executeQuery(sql);
	while (rs.next()){
		maxE164 = Str.CheckNullString(rs.getString(1)) ;
	}
}catch(Exception ex){
}finally{
	if(rs!=null) rs.close();
}

String  maxAreaNum = "", maxLocalNum = "", maxLastNum = ""; 
if(maxE164.length()>4){
	maxLastNum = maxE164.substring(maxE164.length()-4) ;
	int nMax = Str.CheckNullInt(maxLastNum)+1 ;
	if(nMax>0){
		maxLastNum = nMax +"";
		int size = maxLastNum.length() ;
		while(size<4){
			maxLastNum = "0" + maxLastNum;
			size++;
		}
	}else maxE164 = ""; 
}

//********** PrefixID **********//
//String 			prefixID 	= commonData.getPrefixTableID(stmt2);	// 번호정책 조회
String prefixID = "" ;        
sql = "select domain from table_SubscriberGroup WHERE checkgroupid = '"+checkgroupid+"' ";
try {
    if (stmt2 != null) {
        rs = stmt2.executeQuery(sql);
        if (rs.next()) domainID = rs.getString(1); 
        //rs.close();
    } else            
        System.out.println("데이터베이스에 연결할 수 없습니다.");            
} catch (Exception e) {
    System.out.println(e.getMessage());
} finally {
    try {
        if (rs != null) rs.close();
    } catch (Exception e) {}
}


// IpPhone 파일 읽어 DB 처리부분 -------------------------------------------------

IpPhoneList 		ipPhoneList 	= new IpPhoneList();
//IpPhoneDTO			ipPhoneDTO		= new IpPhoneDTO();
SystemConfigSet 	systemConfig 	= new SystemConfigSet();

//List<IpPhoneDTO> 	ipphoneList 	= new ArrayList<IpPhoneDTO>();

List 	sList 		= systemConfig.getIpPhoneList();		// 데이타 조회
int		configCount	= sList.size();
String 	tempStr		= "";
String 	beforeStr	= "";
String 	afterStr	= "";
String	tempGubun	= "";

String	physical_address	= "";
String	makename			= "";

// Mac 리스트가 있으면 기존의 등록안된 Mac정보는 삭제처리함
if(1==1&& configCount>0){
	int result = ipPhoneList.deleteIpPhone(stmt2);
}

for(int i=0;i<configCount;i++){
	tempStr 	= (String)sList.get(i);	
	beforeStr	= tempStr;
	//afterStr 	= beforeStr.replace("  "," ");
	afterStr 	= beforeStr.replace("\t"," ");
	
	while (!beforeStr.equals(afterStr)) {
		beforeStr= afterStr;
   		afterStr = afterStr.replace("  "," ");
    }
   	
   	String[]	tempInfo;
   	
   	tempInfo 	= afterStr.split(" ");
   	if(tempInfo != null && tempInfo.length>1){
   		tempGubun	= tempInfo[1];
	   	
   		if(tempGubun.length()>=14){
	   		if("00:11:a9".equals(tempGubun.substring(0,8))){
	   			makename			= "MOIMSTONE";
	   			physical_address	= tempGubun;
	   			int result = ipPhoneList.setIpPhone(stmt2, physical_address, makename);
	   		}else if("00:1a:0b".equals(tempGubun.substring(0,8))){
	   			makename			= "JUNGWOO";
	   			physical_address	= tempGubun;
	   			int result = ipPhoneList.setIpPhone(stmt2, physical_address, makename);
	   		}else if("00:1c:e0".equals(tempGubun.substring(0,8))){
	   			makename			= "DASAN";
	   			physical_address	= tempGubun;
	   			int result = ipPhoneList.setIpPhone(stmt2, physical_address, makename);
	   		}
	   	}
   	}
}
  
List 	macList 	= ipPhoneList.getIpPhone(stmt2);		// IpPhone 조회
int		macCount	= macList.size();
// -------------------------------------------------------------------------


// Wan Ip 파일 읽어 처리부분 -------------------------------------------------
	// WAN, LAN 인터페이스 확인
	String wanName		= "";
	String lanName		= "";
	String wanIp		= "";
	int	   nTemp 		= 0;
	
//	List 				nList 			= systemConfig.getNetWorkType();		// 데이타 조회
//	int					netCount		= nList.size();		
//	String				netStr			= "";
//	for(int i=0;i<netCount;i++){
//		netStr = (String)nList.get(i);		
//		if(netStr.length()>=3){
//			if("wan".equals(netStr.substring(0,3))){
//				nTemp = netStr.indexOf("=");
//				wanName = netStr.substring(nTemp+1, netStr.length()).replace('"',' ').trim();
////				System.out.println("wan 문자열 : "+wanName);
//			}
//			if("lan".equals(netStr.substring(0,3))){
//				nTemp = netStr.indexOf("=");
//				lanName = netStr.substring(nTemp+1, netStr.length()).replace('"',' ').trim();
////				System.out.println("lan 문자열 : "+lanName);
//			}
//		}
//	}
	
	// 외부 네트워크 환경
	List 				iList 			= systemConfig.getRcConfigList();		// 데이타 조회
	int					configCount2	= iList.size();		
	
	for(int i=0;i<configCount2;i++){
		tempStr = (String)iList.get(i);
		
		//if(tempStr.length()>=9){
		if(tempStr.length()>=13){
			// 외부 네트워크
			//String netType1 = "ifconfig_"+wanName;
			//if(netType1.equals(tempStr.substring(0,9+wanName.length()))){
			if("ifconfig_wan=".equals(tempStr.substring(0,13))){
				nTemp = tempStr.indexOf("=");
				
				String temp1 = tempStr.substring(nTemp+1, tempStr.length()).replace('"',' ').trim();
					
			   	StringTokenizer tk = new StringTokenizer(temp1, " "); 		// 현재 분리단어는 " " 공백 스페이스로 나누어짐
			   	String token;
			   	int t=0;
			   	while ( tk.hasMoreTokens() ) {
			    	token = tk.nextToken();
			    	if(t==1){
			    		wanIp = token;									// IP 주소
			    	}
			    	t++;
			   }
			}			
		}
	}
	System.out.println("WAN IP 주소 : " + wanIp);
// -------------------------------------------------------------------------

//********** DeptList ***********//
int nDeptParentId = 0, nDeptId=0;
List 		deptList 		= null;//commonData.getDeptList(stmt);		// 부서명 조회
DeptListDTO 		deptListDTO;
deptList 	= new ArrayList<DeptListDTO>();
sql = "Select deptid, deptname, parentid From table_dept Where deptid <> parentid AND checkgroupid='"+checkgroupid+"' ORDER BY deptid";
try {
    if (stmt2 != null) {
        rs = stmt2.executeQuery(sql);               
        while (rs.next()) {
        	deptListDTO = new DeptListDTO(
        		nDeptId = rs.getInt("deptid"),
                Str.CheckNullString(rs.getString("deptname")),
                nDeptParentId = rs.getInt("parentid")
            );

        	deptList.add(deptListDTO);
        }
        rs.close();
    } else            
        System.out.println("데이터베이스에 연결할 수 없습니다.");            
} catch (Exception e) {
    System.out.println(e.getMessage());
} finally {
    try {
        if (rs != null)
            rs.close();
    } catch (Exception e) {}
}
int 		deptCount 		= deptList.size();


//할당받은 DataStatement 객체는 반납
if (stmt2 != null) ConnectionManager.freeStatement(stmt2);

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
</head>

<body>
<form name="Insertlayer1" method="post">
<input type='hidden' name ='hiGroupID' 	value="<%=groupid%>">
<input type='hidden' name ='hiDomainID' value="<%=domainID%>">
<input type='hidden' name ='hiZoneCode' value="<%=zoneCode%>">
<input type='hidden' name ='hiPrefixID' value="<%=prefixID%>">

<input type='hidden' name ='hiMacIp' 	value="<%=wanIp%>">

<input type='hidden' name ='numberType' value="1">
<input type='hidden' name ='mac' 		value="">
<input type='hidden' name ='auto' 		value="0"> <!-- [1:auto, 0:enauto] -->
<input type='hidden' name ='autoNo' 	value="02"> <!-- auto area number -->
<input type='hidden' name ='txtdisplay' 	value=""><!-- 발신시 표기 -->
<input type='hidden' name ='addrType' 	value=""><!-- [1:ip, 2:domain] -->

<!-- goInsertPro.fields -->
<input type='hidden' name ='txtId' 			value="">			<!-- var p_EndPointID 	= f2.txtId.value; -->
<input type='hidden' name ='hiEi64' 		value="">		    <!-- var p_Ei64			= f2.hiEi64.value; -->
<!-- 
//var p_Ei64_1		= f2.areaNo.value + f2.txtNumber1.value + f2.txtNumber2.value;
//var p_Ei64_2		= f2.txtExtension.value;
 -->
<input type='hidden' name ='hiE164Route2' 	value="">		    <!-- var p_Ei64_Route2	= f2.hiE164Route2.value; -->
															    <!-- var p_GroupID 		= f2.hiGroupID.value; -->
															    <!-- var p_DomainID 		= f2.hiDomainID.value; -->

<input type='hidden' name ='txtZone' 		value="<%//=zoneCode%>">		    <!-- var p_ZoneCode 		= f2.txtZone.value; -->
															    <!-- var p_PrefixID 		= f2.hiPrefixID.value; -->
															    <!-- var p_Extension 	= f2.txtExtension.value; -->
 																	<!-- //var p_Extension 	= f2.hiExtension.value; -->
<input type='hidden' name ='hiAreaCode' 	value="">			<!-- var p_AreaCode		= f2.hiAreaCode.value; -->			
<input type='hidden' name ='hiNumberType' 	value="">			<!-- var p_NumberType	= f2.hiNumberType.value; -->

<input type='hidden' name ='hiMac' 			value="">			<!-- var p_Mac			= f2.hiMac.value; -->
<input type='hidden' name ='hiMacDisplay' 	value="">			<!-- var p_MacDisplay	= f.hiMacDisplay.value; -->
																<!-- var p_MacIp			= f2.hiMacIp.value; -->
<input type='hidden' name ='hiMacAuto' 		value="">			<!-- var p_MacAuto		= f2.hiMacAuto.value; -->
<input type='hidden' name ='hiMacAutoNo' 	value="">			<!-- var p_MacAutoNo		= f2.hiMacAutoNo.value; -->
																<!-- var p_MacAuthId		= f2.txtId.value; -->
																<!-- var p_MacAuthPass	= f2.txtpassword.value; -->
<input type='hidden' name ='txtpass_chk' 	value="">			<!-- var p_MacPass_Chk	= f2.txtpass_chk.value; -->
<input type='hidden' name ='hiMacAddrType' 	value="">			<!-- var p_MacAddrType	= f2.hiMacAddrType.value; -->

<input type='hidden' name ='txtPass' 		value="">			<!-- var p_Pass			= f2.txtPass.value; -->
<input type='hidden' name ='txtName' 		value="">			<!-- var p_Name			= f2.txtName.value; -->
<input type='hidden' name ='position' 		value="<%=checkgroupid%>">						<!-- var p_Position		= f2.position.value; -->
<input type='hidden' name ='dept' 			value="<%=nDeptId+"|"+nDeptParentId%>">			<!-- var p_Dept			= f2.dept.value; -->
<input type='hidden' name ='txtMobile' 		value="">			<!-- var p_Mobile		= f2.txtMobile.value; -->
<input type='hidden' name ='txtHomeNumber' 	value="">			<!-- var p_HomeNumber	= f2.txtHomeNumber.value; -->
<input type='hidden' name ='txtMail' 		value="">			<!-- var p_Mail			= f2.txtMail.value; -->

<input type='hidden' name ='e164Auth' value="1" checked="checked"> 	<!-- 전화번호 인증 (0: 미사용, 1: 사용) -->
<input type='hidden' name ='ipAuth' value="0" > 					<!-- IP 인증 (0: 미사용, 1: 사용) -->
<input type='hidden' name ='ipPort' value="0" > 					<!-- Port 인증 (0: 미사용, 1: 사용) -->

<input type='hidden' name ='register' value="2" > 					<!-- 인증 Register (1:IP변경시 인증, 2:항상인증)-->
<input type='hidden' name ='invite' value="1" > 					<!-- 인증 Invite (1:인증안함, 2:IP변경시 Reject, 3:IP변경시 인증, 4:항상인증)-->
<input type='hidden' name ='txtid' value="" > 						<!-- 인증 ID = endpointid -->
																	<!-- 인증 PW = txtpassword -->
<input type='hidden' name ='staleAuth' value="0" > 					<!-- stale 모드 인증 (0: 미사용, 1: 사용)-->

	<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호 추가 </strong></td>
	    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
	    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
	  </tr>
	  <tr align="right">
	    <td height="6" colspan="7" style="padding-right:10; color:RGB(82,86,88)"></td>
	  </tr>  	  
	  <tr>
	    <td width="10"></td>
	    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
	    <td width="10"></td>
	  </tr>  
	  <%-- <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>아이디 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtId" style="width:100" value="<%=StringUtil.null2Str(endPointID,"")%>"></td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>번호타입 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <select name="numberType" style="width:120 " class="select01" onChange="NumberTypeChange()">
	        <option value="">선택하세요</option>
	        <option value="1">직통번호로 등록</option>
			<option value="2">단축번호로 등록</option>
	      </select>
		</td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr> --%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>전화번호 </strong></td>
	    <td colspan="3" align="left" valign="bottom" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <!-- <div id="div1" name="div1" style="position:absolute; left:103px; top:110px; width:400px; overflow:hidden; display: none;"> -->
		  <div id="div1" name="div1" style="position:absolute; left:99px; top:50px; width:400px; overflow:hidden; display:;">
		    <select name="areaNo" style="width:60px;" class="select01"  onChange="AreaNoSelect()" ><!-- disabled -->
				<%																																						 
				ZipCodeDTO zipCodeDTO = null;
				for (int idx = 0; idx < zipCount ; idx++ ) {
					zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
					
					if(maxE164.length()>4){
						if(maxE164.startsWith(zipCodeDTO.getCodeitemcd())){
							areacode = maxAreaNum = zipCodeDTO.getCodeitemcd();
							if(maxAreaNum.length()+maxLastNum.length() > 0)
								maxLocalNum = maxE164.substring(maxAreaNum.length(), maxE164.length()-4);
						}else areacode="";
					}
				%>																											
				<option <%if(areacode.equals(zipCodeDTO.getCodeitemcd())){%> selected <%}%> value="<%=zipCodeDTO.getCodeitemcd()%>"><%=zipCodeDTO.getCodeitemcd()%></option>
				<% 
				}
				%>   							
		   	</select> - <input type="text" name="txtNumber1" style="width:40px;" value="<%=maxLocalNum%>" size="4" maxlength="4"> - <input type="text" name="txtNumber2" style="width:40px;" value="<%=maxLastNum%>" size="4" maxlength="4">
		  </div>
		  <!-- <div id="div2" name="div2" style="position:absolute; left:103px; top:110px; width:400px; overflow:hidden; display: none;">
			<input type="text" name="txtExtension" style="width:100" value="" size="4" maxlength="4" disabled>
		  </div> -->
		</td>
		<td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>비밀번호 </strong></td>
	    <td width="206" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 "><input type="password" name="txtpassword" style="width:100px" value="">
	    	<font style="font-size: 10px;"></font>
	    </td>
	    <td bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>내선번호 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtExtension" style="width:100px" value=""></td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <%-- 
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>맥어드레스 </strong></td>
	    <td width="106" bgcolor="#FFFFFF">
		  <select name="mac" style="width:122 " class="select01">
				<option value="">선택하세요</option>
			<%
			IpPhoneDTO	ipPhoneDTO	= null;
			for (int idx = 0; idx < macCount ; idx++ ) {
				ipPhoneDTO = (IpPhoneDTO)macList.get(idx);																														
			%>																											
				<option value="<%=ipPhoneDTO.getPhysicalAddress()%>"><%=ipPhoneDTO.getPhysicalAddress()%></option>
			<% 
			}
			%>
	      </select>      
	    </td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "></td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>	  
	    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>자동번호사용 </strong></td>
	    <td width="106" bgcolor="#FFFFFF">
		  <select name="auto" style="width:120 " class="select01" onChange="AutoNoChange()">
				<option value="0">미사용</option>
				<option value="1" selected>사용</option>
	      </select>      
	    </td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "></td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>	  

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>자동지역번호 </strong></td>
	    <td width="106" bgcolor="#FFFFFF">
			    <select name="autoNo" style="width:120" class="select01">
					<%																																						 
					//ZipCodeDTO zipCodeDTO = null;
					for (int idx = 0; idx < zipCount ; idx++ ) {
						zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
					%>																											
					<option value="<%=zipCodeDTO.getCodeitemcd()%>"><%=zipCodeDTO.getCodeitemdesc()%></option>
					<% 
					}
					%>   							
			   	</select>      
	    </td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "></td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>	  

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>전화기표시명 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtdisplay" style="width:120" value=""></td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="89" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>콜박스주소 </strong></td>
	    <td width="106" bgcolor="#FFFFFF">
		  <select name="addrType" style="width:122 " class="select01">
				<option value="1" selected>IP</option>
				<option value="2">DOMAIN</option>
	      </select>      
	    </td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "></td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>
	   --%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" rowspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>    
	  <!--
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF">
			<hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center">	</td>
	    <td width="10">&nbsp;</td>
	  </tr>    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="2" align="left" bgcolor="#FFFFFF" style="padding-right:5 "><strong> &nbsp;&nbsp;&nbsp;&nbsp;사용자등록 </strong></td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>     
	  <tr>
	    <td height="10">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "><input type="radio" name="numberChk" value="Y" checked></td>
	    <td colspan="3" bgcolor="#FFFFFF"><label>
	 해당 번호에 사용자 정보 등록하기</label></td>
	    <td>&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "><input type="radio" name="numberChk" value="N"></td>
	    <td colspan="3" bgcolor="#FFFFFF">		사용자 정보 나중에 등록하기 </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  -->    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td width="106" bgcolor="#FFFFFF">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>    
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	  <tr>
	    <td width="10"></td>
	    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
	    <td width="10"></td>
	  </tr>   
	  <tr align="center">
	    <td height="35" colspan="6" style="padding-top:3 ">
	    	<a href="#" onclick="javascript:goInsertPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image5','','<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif',0)"> 
		    	<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" name="Image5" width="40" height="20" border="0">
		    </a> 
		    <a href="#" onclick="javascript:goUserInfoInsert();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_next_p_btn.gif',0)"> 
		    	<img src="<%=StaticString.ContextRoot%>/imgs/Content_next_n_btn.gif" name="Image3" width="40" height="20" border="0">
		    </a>
		    <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)">
		    	<img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0">
		    </a>
	    </td>
	  </tr>
	</table>

</form>
</body>
</html>