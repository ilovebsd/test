<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="waf.*"%>
<%@ page import="dto.ipcs.IpcsIvrDTO" %>
<%@ page import="dao.ipcs.IpcsIvrDAO" %>
<%@ page import="dto.system.PrefixTableDTO"%>
<%@ page import="dao.system.PrefixTableDAO"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="system.SystemConfigSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.lang.StringBuffer" %>

<%@ page import="business.LogHistory"%>

<meta http-equiv='Content-type' content='text/html; charset=euc-kr'>

<%
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}
 */

 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
response.setCharacterEncoding("euc-kr"); 

boolean returnVal 	= false;

String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// 도메인
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
String 	scCompany	= request.getParameter("hiScCompany");												// 음성안내 그룹명
//String 	scCompany 	= new String(Str.CheckNullString(request.getParameter("hiScCompany")).getBytes("8859_1"), "euc-kr").trim();		//음성안내 그룹명
int		e164Leng	= ei64.length();
//String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

IpcsIvrDTO 		ipcsDTO = new IpcsIvrDTO();
PrefixTableDTO 	dto 	= new PrefixTableDTO();

String selectWan	= "";
String wanName		= "";
String tempStr		= "";
String wanIp		= "";
int    nTemp 		= 0;
String lanIp		= "";

DataStatement 	statement = null;
ResultSet rs = null;
try{
//	SystemConfigSet 	systemConfig 	= new SystemConfigSet();

	// 외부 네트워크 환경
//	List 				iList 			= systemConfig.getRcConfigList();		// 데이타 조회
//	int					configCount		= iList.size();		
	
//	for(int i=0;i<configCount;i++){
//		tempStr = (String)iList.get(i);
		
//		if(tempStr.length()>=12){
			// 내부 네트워크
//			if("ifconfig_lan".equals(tempStr.substring(0,12))){
//				nTemp = tempStr.indexOf("=");				
//				String temp1 = tempStr.substring(nTemp+1, tempStr.length()).replace('"',' ').trim();
					
//			   	StringTokenizer tk = new StringTokenizer(temp1, " "); 		// 현재 분리단어는 " " 공백 스페이스로 나누어짐
//			   	String token;
			   	//System.out.println("분리된 단어 수 : " + tk.countTokens());
//			   	int t=0;
//			   	while ( tk.hasMoreTokens() ) {
//			    	token = tk.nextToken();
			    	//System.out.println("\""+ token + "\"" + "\t");
//			    	if(t==1){
//			    		lanIp = token;									// IP 주소
			    		//System.out.println("IP 주소 : " + token);
//			    	}
//			    	t++;
//			   }
//			}
//		}
//	}
	// =============================================================================================
	String serverip = request.getLocalAddr();
		
	//String 	endPointID = "ACRO_MS_";
	String 	endPointID = ei64;			// 임시 테스트용으로 E164 으로 처리함 (090212)
	//String	prefixId	= ipcsDao.getPrefixTableID();
	
	// NASA_TRUNK_SET 테이블
	ipcsDTO.setSystemIdx(1);
	ipcsDTO.setIvrTel(ei64);
	ipcsDTO.setAuthId(endPointID);
	ipcsDTO.setSswReg("N");
	ipcsDTO.setSswDomainName(domainID);
	ipcsDTO.setSswLocalPort(5040);
	ipcsDTO.setSswRemotePort(5060);
	ipcsDTO.setSswProtocol("SIP");
	ipcsDTO.setSswProtocolType("U");
	ipcsDTO.setSswExpires(3600);
	ipcsDTO.setScCompany(scCompany);
	ipcsDTO.setUseYN("Y");
	ipcsDTO.setTrunkType("N");
//	ipcsDTO.setServerIp(wanIp);
//	ipcsDTO.setSswServerIp(wanIp);
//	ipcsDTO.setServerIp(lanIp);
//	ipcsDTO.setSswServerIp(lanIp);
	if(11==1){//hc-modify : 200424 : req-chun : redefined at code line 148
		ipcsDTO.setServerIp(1==1?serverip:"10.255.255.254");
		ipcsDTO.setSswServerIp(1==1?serverip:"10.255.255.254");
	}
	ipcsDTO.setInfoDtmf("Y");
	
	// Table_PrefixTable 테이블
//	dto.setPrefixTableId(prefixId);
	dto.setStartPrefix(ei64);
	dto.setEndPrefix(ei64);
	dto.setRouteSelectRule(1);
	dto.setRouteId("MS");
	dto.setProtocol(2);
	dto.setCallType(2);
	dto.setChargeType(0);
	dto.setDescription(scCompany);				
//	dto.setMinDigitCount(1);
//	dto.setMaxDigitCount(24);
	dto.setMinDigitCount(e164Leng);
	dto.setMaxDigitCount(e164Leng); 	
	dto.setRoutingEndpointType(1);
	
// 	IpcsIvrDAO 	ipcsDao = new IpcsIvrDAO();
// 	returnVal = ipcsDao.ipcsIvrInsertPrefix(ipcsDTO, dto);
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	try{
		statement 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
		
		if(1==1){
	    	String _sql = "select SERVER_IP from NASA_TRUNK_SET where IVR_TEL = 'anonymous' ;";
	    	System.out.println(_sql);
	    	rs = statement.executeQuery(_sql);
	        if (rs.next()) {
	        	serverip = Str.CheckNullString(rs.getString("server_ip"));
	        	ipcsDTO.setServerIp(serverip);
	        	ipcsDTO.setSswServerIp(serverip);
	        }
	        if(rs!=null){ rs.close(); }
    	}
		
    	statement.stxTransaction();	    	
    	
    	// NASA_TRUNK_SET
    	int		systemIdx			= ipcsDTO.getSystemIdx();
    	//String	serverIp			= "203.242.63.85";
    	//String	sswServerIp			= "203.242.63.85";
    	String	serverIp			= ipcsDTO.getServerIp();
    	String	sswServerIp			= ipcsDTO.getSswServerIp();	    	
    	String	ivrTel				= ipcsDTO.getIvrTel();
    	String	authId				= ipcsDTO.getAuthId();
    	String	sswReg				= ipcsDTO.getSswReg();
    	String	sswDomainName		= ipcsDTO.getSswDomainName();
    	int		sswLocalPort		= ipcsDTO.getSswLocalPort();
    	int		sswRemotePort		= ipcsDTO.getSswRemotePort();
    	String	sswProtocol			= ipcsDTO.getSswProtocol();
    	String	sswProtocolType		= ipcsDTO.getSswProtocolType();
    	int		sswExpires			= ipcsDTO.getSswExpires();
//     	String	scCompany			= ipcsDTO.getScCompany();
    	String	useYN				= ipcsDTO.getUseYN();
    	String	trunkType			= ipcsDTO.getTrunkType();
    	String	infoDtmf			= ipcsDTO.getInfoDtmf();
    	
    	int nResult = 0;
    	
        /***** NASA_TRUNK_SET ????? ???********/
        String sql   = "Insert into NASA_TRUNK_SET(";	
        sql += "	system_idx,";
        sql += "	server_ip,"; 			
        sql += "	ssw_server_ip,"; 		
        sql += "	ivr_tel,"; 				//(070-7700-1000)
        sql += "	auth_id,"; 				
        sql += "	ssw_reg,"; 				// (Y:, N:)
        sql += "	ssw_domain_name,"; 		
        sql += "	ssw_local_port,"; 		// MS
        sql += "	ssw_remote_port,"; 		
        sql += "	ssw_protocol,"; 		// H323, SIP, MGCP, MEGACO
        sql += "	ssw_protocol_type,"; 	// T:TCP, U:UDP, S:SCTP
        sql += "	ssw_expires,"; 			
        sql += "	sc_company,"; 			
        sql += "	use_yn,"; 				// (Y:, N:)
        sql += "	trunk_type, ";  		// (N:, P:Call Park)
        sql += "	info_dtmf ";  			//
        sql += "	, checkgroupid ";
        sql += "	) ";  			//
        sql += "Values(";
        sql += "	" + systemIdx + ", ";
        sql += "	'" + serverIp + "', ";
        sql += "	'" + sswServerIp + "', ";
        sql += "	'" + ivrTel + "', ";
        sql += "	'" + authId + "', ";
        sql += "	'" + sswReg + "', ";
        sql += "	'" + sswDomainName + "', ";
        sql += "	" + sswLocalPort + ", ";
        sql += "	" + sswRemotePort + ", ";
        sql += "	'" + sswProtocol + "', ";
        sql += "	'" + sswProtocolType + "', ";
        sql += "	" + sswExpires + ", ";
        sql += "	'" + scCompany + "', ";
        sql += "	'" + useYN + "', ";
        sql += "	'" + trunkType + "', ";
        sql += "	'" + infoDtmf + "' ";
        sql += "	,'" + authGroupid + "'";
        sql += "	)";
        System.out.println("1:"+sql);
        nResult = statement.executeUpdate(sql);

        if(nResult >= 1){
	        /***** nasa_systemupdate ????? Update********/
	        sql   = "update nasa_systemupdate set su_check = 'Y'";
	        System.out.println("2:"+sql);
	        int nRst = statement.executeUpdate(sql);
	        
	        System.out.println("1. Updating nasa system :"+ (nRst>=1?true:false) );
        }
        
        if(nResult >= 1){
	        /***** table_PrefixTable ????? ???********/
	        String	prefixId	= authGroupid;//getPrefixTableID(statement);
	        dto.setPrefixTableId(prefixId);
	        
	        sql = "\n INSERT INTO table_PrefixTable(PREFIXTABLEID, STARTPREFIX, ENDPREFIX, "; 
	    	sql = sql +  "\n CALLTYPE, ROUTESELECTRULE, PROTOCOL, ROUTEID, CHARGETYPE, ";
	    	sql = sql +  "\n DESCRIPTION, MINDIGITCOUNT, MAXDIGITCOUNT, ROUTINGENDPOINTTYPE ";
	    	sql = sql +  "\n , CHECKGROUPID ";
	    	sql = sql +  "\n ) values (" ;
	    	sql = sql + "'" + dto.getPrefixTableId()     	+ "' , " ;
	    	sql = sql + "'" + dto.getStartPrefix()     		+ "' , " ;
	    	sql = sql + "'" + dto.getEndPrefix()     		+ "' , " ;            	
	    	sql = sql + " " + dto.getCallType()  			+ "  , " ;            	
	    	sql = sql + " " + dto.getRouteSelectRule()  		+ "  , " ;
	    	if(dto.getRouteSelectRule()==1){
	    		sql = sql + " " + dto.getProtocol() 			+ "  , " ;
	    	}else{
	    		sql = sql + " null , " ;
	    	}
	    	sql = sql + "'" + dto.getRouteId()     			+ "' , " ;
	    	sql = sql + " " + dto.getChargeType()  			+ "  , " ;
	    	sql = sql + "'" + dto.getDescription()     		+ "' , " ;
	    	sql = sql + " " + dto.getMinDigitCount()  		+ "  , " ;
	    	sql = sql + " " + dto.getMaxDigitCount()  		+ "  , " ;
	    	sql = sql + " " + dto.getRoutingEndpointType()	+ " " ;
	    	sql = sql + ",'" + authGroupid + "' " ;
	    	sql = sql + ") ";
	        System.out.println("insert--->"+sql);
	        nResult = statement.executeUpdate(sql);
        }
        
        if(nResult >= 1 ){//(hc-add : 200211 : req.chun)
        	sql = "\n INSERT INTO table_arsnumbergroupsearch ( "; 
        	sql = sql +  "\n e164, groupid ";
        	sql = sql +  "\n , checkgroupid ";
        	sql = sql +  "\n ) VALUES (" ;
        	sql = sql + "'" + ivrTel + "'" ;
        	sql = sql + ",'" + authGroupid + "'" ;
        	sql = sql + ",'" + authGroupid + "' " ;
        	sql = sql + ") ";
            System.out.println("insert--->"+sql);
            nResult = statement.executeUpdate(sql);
        }
        
        if(nResult >= 1 ){//(hc-add : 200211 : req.chun)
        	sql = "\n INSERT INTO table_localprefix ( "; 
        	sql = sql +  "\n startprefix, endprefix, prefixtype, protocol, endpointid, groupid, maxdigit ";
        	sql = sql +  "\n , checkgroupid ";
        	sql = sql +  "\n ) VALUES (" ;
        	sql = sql + "'" + dto.getStartPrefix() + "'" ;
        	sql = sql + ",'" + dto.getEndPrefix() + "'" ;
        	sql = sql + ", 275 " ;
        	sql = sql + ", " + dto.getProtocol() ;
        	sql = sql + ",'" + dto.getRouteId() + "'" ;
        	sql = sql + ",'" + authGroupid + "'" ;
        	sql = sql + ", 24 " ;//hc-modify : req.chun & req.oh,dong-sung : 9 -> 32 -> 24
        	sql = sql + ",'" + authGroupid + "'" ;
        	sql = sql + ") ";
            System.out.println("insert--->"+sql);
            nResult = statement.executeUpdate(sql);
        }
        
        if (nResult >= 1)
            System.out.println("OK");
        else
            System.out.println("Fail");            
        
        statement.endTransaction(true);			// commit
        returnVal = true;
        System.out.println("2. sql commit :"+returnVal);
    } catch (Exception e) {
    	statement.endTransaction(false);		// rollback
        e.printStackTrace();
        returnVal = false;
        System.out.println("3. sql rollback :"+returnVal);
    } finally {
//         if (statement != null ) ConnectionManager.freeStatement(statement);
    }
	
	if(returnVal){
		// ############### LogHistory 처리  ###############
		String		strIp		= request.getRemoteAddr();
		LogHistory	logHistory 	= new LogHistory();
		int int_result = logHistory.LogHistorySave(userID+"|82|음성안내번호 관리 ("+ei64+" 번)|1|"+strIp);
		// ##############################################

		StringBuffer jsArray = new StringBuffer();
		if(jsArray.length()==0)	jsArray.append("[{params:");
   		else					jsArray.append(",{params:");
		
		jsArray.append("[\""+scCompany+"\",\""+ei64+"\",\""+endPointID+"\"]}");
		if(jsArray.length()>0)	jsArray.append("]");
		
		System.out.println("success ------^^");
		out.clear();
		out.print("OK:");
		out.print(jsArray.toString());
	}else{
		System.out.println("fail ------TT");
		out.clear();
		out.print("NO");
	}	
	
}catch(Exception ex){
	System.out.println(ex);
	if(statement!=null) statement.endTransaction(false);		// rollback
}finally{
	 if(rs!=null) rs.close();	
	 if (statement != null ) ConnectionManager.freeStatement(statement);
} 

%>
