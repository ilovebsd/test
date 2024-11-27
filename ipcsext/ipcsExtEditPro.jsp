<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="acromate.common.util.WebUtil"%>
<%@ page import="acromate.*"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="business.LogHistory, business.ipcs.IpcsList, java.util.*"%>

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

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");
 */
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String checkgroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;

 	String 	endpointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr").trim();	// 연결된 단말기 ID
	String 	ei64			= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr").trim();			// E164
	String 	name			= new String(request.getParameter("hiName").getBytes("8859_1"), "euc-kr").trim();			// 이름
	String 	position		= new String(request.getParameter("hiPosition").getBytes("8859_1"), "euc-kr").trim();		// 직급
	String 	dept			= new String(request.getParameter("hiDept").getBytes("8859_1"), "euc-kr").trim();			// 부서
	String 	mobile		= new String(request.getParameter("hiMobile").getBytes("8859_1"), "euc-kr").trim();		// 핸드폰
	String 	homeNumber	= new String(request.getParameter("hiHomeNumber").getBytes("8859_1"), "euc-kr").trim();	// 집전화
	String 	mail			= new String(request.getParameter("hiMail").getBytes("8859_1"), "euc-kr").trim();			// 메일주소
	String 	pwd				= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr").trim();			// 상용자 비밀번호
	String 	extensionNum	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr").trim();		// 내선번호
	
	String 	zoneCode		= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr").trim();		// 망관리
	String 	hiAuthE164		= new String(request.getParameter("hiAuthE164").getBytes("8859_1"), "euc-kr").trim();		// 전화번호 인증 여부
	String 	hiAuthIPChk		= new String(request.getParameter("hiAuthIPChk").getBytes("8859_1"), "euc-kr").trim();		// IP인증 여부
	String 	authIP		= new String(request.getParameter("hiAuthIP").getBytes("8859_1"), "euc-kr").trim().trim();		// IP인증
	String 	hiAuthPortChk	= new String(request.getParameter("hiAuthPortChk").getBytes("8859_1"), "euc-kr").trim();	// Port인증 여부
	String 	authPort		= new String(request.getParameter("hiAuthPort").getBytes("8859_1"), "euc-kr").trim();		// Port인증
	String 	hiAuthMd5		= new String(request.getParameter("hiAuthMd5").getBytes("8859_1"), "euc-kr").trim();		// MD5 인증 여부
	String 	hiAuthRegister	= new String(request.getParameter("hiAuthRegister").getBytes("8859_1"), "euc-kr").trim();	// Register 유형
	String 	hiAuthStale		= new String(request.getParameter("hiAuthStale").getBytes("8859_1"), "euc-kr").trim();		// Stale 여부
	String 	hiAuthInvite	= new String(request.getParameter("hiAuthInvite").getBytes("8859_1"), "euc-kr").trim();	// Invite 여부
	String 	authID		= new String(request.getParameter("hiAuthID").getBytes("8859_1"), "euc-kr").trim();		// 인증ID
	String 	authPass		= new String(request.getParameter("hiAuthPass").getBytes("8859_1"), "euc-kr").trim();		// 인증 비밀번호
	
	String 	PAGE_NUM		= new String(request.getParameter("Edit_PAGE").getBytes("8859_1"), "euc-kr").trim();		// 페이지번호
	String 	hiOldExtension	= new String(request.getParameter("hiOldExtension").getBytes("8859_1"), "euc-kr").trim();	// 수정전 내선번호
	//String 	userID			= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr").trim();		// 로그인 ID
	
	String 	goodsName_Type	= new String(request.getParameter("hiGoodsName").getBytes("8859_1"), "euc-kr").trim();		// 제품명(모델명)
	System.out.println("인증PORT 값1 : "+authPort);

	// Auth 테이블 	(Auth 인증값 설정)
    int authMode = 0;
    if (hiAuthE164.equals("1"))		authMode += WebUtil.conCheckAuth_Phone_Num_Use;				//전화번호인증(E164) : 2048
    if (hiAuthIPChk.equals("1"))		authMode += WebUtil.conCheckAuth_IP_Use;				//IP인증 : 2
    if (hiAuthPortChk.equals("1"))	authMode += WebUtil.conCheckAuth_IP_Port_Use;				//Port 인증 :1
    if (hiAuthMd5.equals("1")){
    	authMode += WebUtil.conCheckAuth_Passwd_Use;											//비밀번호 인증 :128
    	if (hiAuthRegister.equals("1")){
    		authMode += WebUtil.conCheckAuth_Passwd_Register_IPchange;							//Register관련 : IP변경 시 : 64
    	}else if (hiAuthRegister.equals("2")){
    		authMode += WebUtil.conCheckAuth_Passwd_Register_AnyTime;							//Register관련 : 항상인증 : 0
    	}
    	if (hiAuthStale.equals("1"))	authMode += WebUtil.conCheckAuth_Passwd_Register_Stale;	//Register관련 : Stele 모드 : 8
    	if (hiAuthInvite.equals("1")){
    		authMode += WebUtil.conCheckAuth_Passwd_Invite_Uncheck;								//Inviter관련 : 인증안함 :0
    	}else if (hiAuthInvite.equals("2")){
    		authMode += WebUtil.conCheckAuth_Passwd_Invite_IPReject;							//Inviter관련 : IP변경시 Reject :32
    	}else if (hiAuthInvite.equals("3")){
    		authMode += WebUtil.conCheckAuth_Passwd_Invite_IPchange;							//Inviter관련 : IP변경시 인증 :48
    	}else if (hiAuthInvite.equals("4")){
    		authMode += WebUtil.conCheckAuth_Passwd_Invite_AnyTime;								//Inviter관련 : 항상 인증 :16
    	}
    }
    
  //hiEndPointID, hiEi64, hiName, hiPosition, hiDept, hiMobile, hiHomeNumber, hiMail, hiPwd, hiZoneCode, hiAuthIP, hiAuthPort, hiAuthID, hiAuthPass, nRetAuthMode, hiExtension, hiOldExtension, goodsName_Type
    //hiEndPointID, hiEi64, hiName, hiPosition, hiDept, hiMobile, hiHomeNumber, hiMail, hiPwd, hiZoneCode, hiAuthIP, hiAuthPort, hiAuthID, hiAuthPass, int hiAuthMode, hiExtension, hiOldExtension, goodsName_Type
	//IpcsUserDAO dao = new IpcsUserDAO();
	
String[] e164s = StringUtil.getParser(ei64, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

DataStatement 	stmt 	= null;
ResultSet	rs 				= null;
String		sql				= "";		
boolean 	returnVal 		= false;
int 		totalCnt		= 0;
		try{
			//AddServiceDAO dao 	= new AddServiceDAO();
			//returnVal = dao.callBlockEdit(e164, callBlockType, prefixType, blockType, blockE164, note, authGroupid);

			try {
		    	int       	nResult     	= 0, count = 0;
	
		    	String[]	tempStr 	= dept.split("[|]");
		    	String 		deptId		= tempStr[0];		
		    	String		parentID	= tempStr[1];
		    	
		    	Vector 			vecTmpKeyNum 	= new Vector();
		    	
		    	// MD5 Hash (IMS용) 관련 추가 (2012.11.09) ==============
	            IpcsList 	ipcsList 		= new IpcsList();
	            String		beforeAuthPass	= "";
	            // ==================================================
	            String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
		    	// 서버로부터 DataStatement 객체를 할당
		    	stmt 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
		    	stmt.stxTransaction();
		    	
		    	String groupExtCode = "";
		    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+checkgroupid+"' ";
		    	rs = stmt.executeQuery(sql);
		        if (rs.next()) groupExtCode = rs.getString(1); 
		        rs.close();
		        
		    	for(String e164 : e164s){
		    		e164 = e164.trim();
		    		
		    		/***** SIP테이블 (table_sipendpoint) ZoneCode 수정 ********/
			    	if(!"".equals(zoneCode)){
				    	sql   = "Update table_sipendpoint set zonecode = '" + zoneCode + "' Where endpointid = '" + endpointID + "' ";
			            System.out.println("0:"+sql);
			            nResult = stmt.executeUpdate(sql);
			            if (nResult < 1){	throw new Exception(l.x("[SIP테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 SIP테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            
		            }else{
				    	sql   = "Update table_sipendpoint set zonecode = '' Where endpointid = '" + endpointID + "' ";
			            System.out.println("0:"+sql);
			            nResult = stmt.executeUpdate(sql);
			            if (nResult < 1){	throw new Exception(l.x("[SIP테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 SIP테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            	
		            }
		            
			    	/***** TABLE_SUBSCRIBER 추가/수정 ********/
			    	sql = "SELECT COUNT(*) FROM TABLE_SUBSCRIBER WHERE ID = '"+endpointID+"'";
			    	System.out.println("00:"+sql);
			    	rs = stmt.executeQuery(sql);
		            rs.next();
		            count = rs.getInt(1);
		            rs.close();
		            if(count == 0){
		            	// 추가 저장
		                /***** 사용자테이블(table_subscriber) 등록********/
		                sql = "INSERT INTO table_subscriber(id, loginlevel , pwd, phonenum, name, position, department, mobile, homenumber, extension, mailaddress, checkgroupid) ";
		                sql = sql + " VALUES ('" + endpointID  + "', 1, '" + pwd  + "', '" + e164  + "', '" + name  + "', '" + position  + "', " + deptId  + ", ";
		                sql = sql + " '" + mobile  + "', '" + homeNumber  + "', '" + extensionNum  + "', '" + mail  + "', '"+checkgroupid+"')";
		                System.out.println("1:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 1){	throw new Exception(l.x("[사용자 등록 오류] '","[Auth Properties Error] '")+endpointID+l.x("'는 사용자 정보등록이 실패하였습니다. 사용자 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            

		            	/***** 프레즌스(Presence) 테이블 업데이트 *******/
		                sql = "SELECT COUNT(*) FROM table_Presence WHERE Usere164 = '" + e164 +"'";
		                rs = stmt.executeQuery(sql);
		                if(rs.next()==true)	count = rs.getInt(1);
		                rs.close();
		                if (count > 0){	throw new Exception(l.x("[Presence정보 오류] '","[Auth Properties Error] '")+e164+l.x("'는 Presence정보가 있습니다. 등록이 실패하였습니다.","' have Auth Properties. Insertion failed."));	}
		                
		                //등록시각을 불러온다
		                int registerTime = 0;
		                sql = "SELECT registeredTime FROM table_sipcontact WHERE endpointid='" + endpointID + "'";
		                rs = stmt.executeQuery(sql);
		                if (rs.next()) registerTime = rs.getInt(1);
		                rs.close();
		                
		                sql   = "INSERT INTO table_presence(UserE164, EndpointID, Protocol, UserType, Options, RegisterTime, PresenceStatus, checkgroupid) ";            
		                sql += " VALUES ('" + e164  + "', '" + endpointID  + "', 2, 101, 0, " + registerTime + ",0, '"+checkgroupid+"')";
		                System.out.println("1-2:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 1){	throw new Exception(l.x("[Presence정보 오류] '","[Auth Properties Error] '")+e164+l.x("'는 Presence 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		                
		                sql = "SELECT COUNT(*) FROM table_PresenceReport WHERE Usere164 = '" + e164 +"'";
		                rs = stmt.executeQuery(sql);
		                if(rs.next()==true)	count = rs.getInt(1);
		                rs.close();
		                if (count > 0){	throw new Exception(l.x("[PresenceReport정보 오류] '","[Auth Properties Error] '")+e164+l.x("'는 PresenceReport 정보가 있습니다. 등록이 실패하였습니다.","' have Auth Properties. Insertion failed."));	}
		                
		                sql   = "INSERT INTO table_PresenceReport(UserE164, OfferID, Protocol, OfferType, ReportType, checkgroupid) ";
		                sql += " VALUES ('" + e164  + "', '', 0, 0, 101, '"+checkgroupid+"')";
		                System.out.println("1-3:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 1){	throw new Exception(l.x("[PresenceReport정보 오류] '","[PresenceReport Error] '")+e164+l.x("'는 PresenceReport 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	
		                
		                sql = "SELECT COUNT(*) FROM table_presenceReport Where usere164 <> '" + e164 +"' ";
		                rs = stmt.executeQuery(sql);
		                if(rs.next()==true)	count = rs.getInt(1);
		                rs.close();
		                if (count > 0){            
		    	            sql   = "Insert into table_presenceReport(usere164, offerid, reporttype, offertype, protocol, checkgroupid) ";
		    	            sql += " Select DISTINCT(usere164), '" + e164 +"', 101, 0, 0, checkgroupid From table_presenceReport ";
		    	            sql += " Where usere164 <> '" + e164 +"' AND checkgroupid='"+checkgroupid+"' ";
		    	            System.out.println("1-4:"+sql);
		    	            nResult = stmt.executeUpdate(sql);
		    	            System.out.println("1-4-1:"+nResult);
		    	            if (nResult < 1){	throw new Exception(l.x("[PresenceReport정보 오류] '","[PresenceReport Error] '")+e164+l.x("'는 PresenceReport 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	
		                }
		                
		                sql = "SELECT COUNT(*) FROM table_presenceReport Where usere164 <> '" + e164 +"' and offerid <> '' AND checkgroupid='"+checkgroupid+"' ";
		                rs = stmt.executeQuery(sql);
		                if(rs.next()==true)	count = rs.getInt(1);
		                rs.close();
		                if (count > 0){                        
		    	            sql   = "Insert into table_presenceReport(offerid, usere164, reporttype, offertype, protocol, checkgroupid) ";
		    	            sql += " Select DISTINCT(usere164), '" + e164 +"', 101, 0, 0, checkgroupid from table_presenceReport ";
		    	            sql += " Where usere164 <> '" + e164 +"' and offerid <> '' AND checkgroupid='"+checkgroupid+"'";           
		    	            System.out.println("1-5:"+sql);
		    	            nResult = stmt.executeUpdate(sql);
		    	            if (nResult < 1){	throw new Exception(l.x("[PresenceReport정보 오류] '","[PresenceReport Error] '")+e164+l.x("'는 PresenceReport 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	            
		                }
		                
		                /***** 부서대표번호(table_dept) 등록여부 확인 후 table_keynumber 등록********/
		                sql = "SELECT keynumber FROM table_dept WHERE  deptid = " + deptId + "";
		                rs = stmt.executeQuery(sql);
		                String tempKeynumber = "";
		                if(rs.next()==true){
		                	tempKeynumber = rs.getString("keynumber");
		                }
		                rs.close();
		                if (!"".equals(tempKeynumber) && tempKeynumber != null){	
		                    int nextIndex = 0;
		                    sql = "SELECT coalesce(max(indexno),0) FROM table_keynumber WHERE keynumberid = '" + tempKeynumber + "'";
		                    rs = stmt.executeQuery(sql);
		                    if (rs.next()) nextIndex = 1 + rs.getInt(1);
		                    rs.close();
		                	
		                    sql   = "INSERT INTO table_keynumber(keynumberid, e164, indexno, callrate, fromtime, totime, checkgroupid) ";
		                    sql += " VALUES ('"+tempKeynumber+"', '" + e164  + "', " + nextIndex  + ", 0, '0000', '2400', '"+checkgroupid+"')";            
		                    System.out.println("1-6:"+sql);
		                    nResult = stmt.executeUpdate(sql);
		                    if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+e164+l.x("'는 부서대표번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	
		                
		                    int maxHuntIndex = 0;
		                    sql = "SELECT count(*) FROM table_keynumber WHERE keynumberid = '" + tempKeynumber + "'";
		                    rs = stmt.executeQuery(sql);
		                    if (rs.next()) maxHuntIndex = rs.getInt(1);
		                    rs.close();
		                
		                    sql   = "Update table_keynumberid set maxhuntindex = " + maxHuntIndex + " Where keynumberid = '" + tempKeynumber + "'";
		                    System.out.println("1-7:"+sql);
		                    nResult = stmt.executeUpdate(sql);
		                    if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+e164+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
		                }                                
		            }else{
		            	// 수정 (부서대표번호(table_dept) 등록여부 확인 후 table_keynumber 등록)

		            	/***** 기존 부서대표번호 조회********/
		            	sql = "SELECT keynumber, deptid FROM table_dept WHERE  deptid = (Select department From Table_Subscriber Where id = '" + endpointID + "')";
		                rs = stmt.executeQuery(sql);
		                String 	oldKeynumber = "";
		                int		oldID		= 0;
		                if(rs.next()==true){
		                	//oldKeynumber 	= rs.getString("keynumber");
		                	oldKeynumber 	= Str.CheckNullString(rs.getString("keynumber"));
		                	oldID			= rs.getInt("deptid");
		                }
		                rs.close();
		                
		            	/***** 새롭게 변경된 부서대표번호 조회********/
		            	sql = "SELECT keynumber FROM table_dept WHERE  deptid = " + deptId + "";
		                rs = stmt.executeQuery(sql);
		                String newKeynumber = "";
		                if(rs.next()==true){
		                	//newKeynumber = rs.getString("keynumber");
		                	newKeynumber = Str.CheckNullString(rs.getString("keynumber"));
		                }
		                rs.close();
		                
		                // 기존의 부서 대표번호와 새로운 부서 대표번호가 같은지 비교
		                if((oldKeynumber.equals(newKeynumber)) && (oldID == Integer.parseInt(deptId))){
			                // 부서 변경을 안한 경우
		                	sql = "Update TABLE_SUBSCRIBER Set ";
			                sql = sql + "  name = '" + name + "' ";
			                sql = sql + " , position = '" + position + "' ";
			                sql = sql + " , department = " + deptId + " ";
			                sql = sql + " , mobile = '" + mobile + "' ";
			                sql = sql + " , homenumber = '" + homeNumber + "' ";
			                sql = sql + " , mailaddress = '" + mail + "' ";
			                sql = sql + " , extension = '" + extensionNum + "' ";
			                sql = sql + " WHERE ID = '"+endpointID+"'" ;            
			                System.out.println("2-1:"+sql);
			                stmt.executeUpdate(sql);	                
		                }else{
		                	// 부서가 변경된 경우
			                if (!"".equals(newKeynumber) && newKeynumber != null){	
			                    // 새로운 부서에 부서 대표번호가 있는 경우
			                    sql = "SELECT COUNT(*) FROM table_keynumber WHERE keynumberid = '" + newKeynumber + "' And e164 = '" + e164 + "' ";
			                    rs = stmt.executeQuery(sql);
			                    if(rs.next()==true)	count = rs.getInt(1);
			                    rs.close();
			                    if (count == 0){
				                	int nextIndex = 0;
				                    sql = "SELECT coalesce(max(indexno),0) FROM table_keynumber WHERE keynumberid = '" + newKeynumber + "'";
				                    rs = stmt.executeQuery(sql);
				                    if (rs.next()) nextIndex = 1 + rs.getInt(1);
				                    rs.close();
				                	
				                    sql   = "INSERT INTO table_keynumber(keynumberid, e164, indexno, callrate, fromtime, totime, checkgroupid) ";
				                    sql += " VALUES ('"+newKeynumber+"', '" + e164  + "', " + nextIndex  + ", 0, '0000', '2400', '"+checkgroupid+"')";            
				                    System.out.println("1-6:"+sql);
				                    nResult = stmt.executeUpdate(sql);
				                    if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+e164+l.x("'는 부서대표번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	
				                
				                    int maxHuntIndex = 0;
				                    sql = "SELECT count(*) FROM table_keynumber WHERE keynumberid = '" + newKeynumber + "'";
				                    rs = stmt.executeQuery(sql);
				                    if (rs.next()) maxHuntIndex = rs.getInt(1);
				                    rs.close();
				                
				                    sql   = "Update table_keynumberid set maxhuntindex = " + maxHuntIndex + " Where keynumberid = '" + newKeynumber + "'";
				                    System.out.println("1-7:"+sql);
				                    nResult = stmt.executeUpdate(sql);
				                    if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+e164+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
			                    }
			                }

			                if (!"".equals(oldKeynumber) && oldKeynumber != null){	
			                    // 기존 부서에 부서 대표번호가 있는 경우
			                    sql = "SELECT COUNT(*) FROM table_keynumber WHERE keynumberid = '" + oldKeynumber + "' And e164 = '" + e164 + "' ";
			                    System.out.println("1-5:"+sql);
			                    rs = stmt.executeQuery(sql);
			                    if(rs.next()==true)	count = rs.getInt(1);
			                    rs.close();
			                    if (count > 0){
				                	sql   = "DELETE FROM table_keynumber WHERE e164 = '" + e164  + "' And keynumberid = '" + oldKeynumber + "' ";            
				                    System.out.println("1-6:"+sql);
				                    nResult = stmt.executeUpdate(sql);
				                    if (nResult < 0){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+e164+l.x("'는 부서대표번호 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	
				                    //////////////////////
				    	            sql = "SELECT e164 FROM table_keynumber WHERE keynumberid = '" + oldKeynumber + "' Order by indexno";
				    	            rs = stmt.executeQuery(sql);
				    	            while(rs.next()){
				    	            	vecTmpKeyNum.add(WebUtil.CheckNullString(rs.getString(1))) ;            	
				    	            }
				    	            rs.close();
				    	            
				    	            int 	nTmp2 		= vecTmpKeyNum.size();
				    	            int 	nTmp3 		= 0;
				    	            String	strE164 	= ""; 
				    	            for(int i=0; i < nTmp2; i++){
				    	            	strE164 = (String)vecTmpKeyNum.get(i);
				    	            	nTmp3 = nTmp3 + 1;
				    	            	sql = "Update table_keynumber Set indexno = " + nTmp3 + " WHERE e164 = '" + strE164 + "' And keynumberid = '" + oldKeynumber + "' ";
				    	                System.out.println("9-"+i+"번째:"+sql);
				    	                stmt.executeUpdate(sql);                
				    	            }
				    	            sql = "Update table_keynumberid Set maxhuntindex = " + nTmp2 + " WHERE keynumberid = '" + oldKeynumber + "' ";
				    	            System.out.println("10번째:"+sql);
				    	            stmt.executeUpdate(sql);
			                    }
			                }
			                
			                sql = "Update TABLE_SUBSCRIBER Set ";
			                sql = sql + "  name = '" + name + "' ";
			                sql = sql + " , position = '" + position + "' ";
			                sql = sql + " , department = " + deptId + " ";
			                sql = sql + " , mobile = '" + mobile + "' ";
			                sql = sql + " , homenumber = '" + homeNumber + "' ";
			                sql = sql + " , mailaddress = '" + mail + "' ";
			                sql = sql + " , extension = '" + extensionNum + "' ";
			                sql = sql + " WHERE ID = '"+endpointID+"'" ;            
			                System.out.println("2-1:"+sql);
			                stmt.executeUpdate(sql);	                
		                }
		            }
		            
		            
		            /** MD5 **/
		            /***** 인증테이블 (table_auth / Table_SipContact) 인증값 수정 ********/
		            if("".equals(authPass)){
		            	/***** IMS 관련 추가 20121101 ********/
		            	if("ACRO-CBS-IMS".equals(goodsName_Type)||"ACRO-HCBS-IMS".equals(goodsName_Type)){
		                	beforeAuthPass 	= authPass;
		                	authPass 		= ipcsList.makeMD5(authPass);
		                	// MD5 Hash 관련 수정 (2012.11.09)
		            		sql   = "Update table_auth set authmode = " + authMode + ", password = '" + authPass + "', descriptor = '" + beforeAuthPass + "', ";
		            	}else{
		            		sql   = "Update table_auth set authmode = " + authMode + ", username = ' ', password = '" + authPass + "', descriptor = '', ";
		            	}
		            	
		                sql += " ipaddress = '" + authIP + "', ipport = " + authPort + "  Where endpointid = '" + endpointID + "' ";
		                System.out.println("3-1:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 1){	throw new Exception(l.x("[인증테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 인증테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}                
		                
		                sql   = "Update Table_SipContact set username = ' ' Where endpointid = '" + endpointID + "' ";
		                System.out.println("3-2:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 0){	throw new Exception(l.x("[인증테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 인증테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		            }else{
		            	/***** IMS 관련 추가 20121101 ********/
		            	if("ACRO-CBS-IMS".equals(goodsName_Type)||"ACRO-HCBS-IMS".equals(goodsName_Type)){
		            		beforeAuthPass 	= authPass;
		                	authPass 		= ipcsList.makeMD5(authPass);
		                	// MD5 Hash 관련 수정 (2012.11.09)
		            		sql   = "Update table_auth set authmode = " + authMode + ", password = '" + authPass + "', descriptor = '" + beforeAuthPass + "', ";
		            	}else{
		            		sql   = "Update table_auth set authmode = " + authMode + ", username = '" + authID + "', password = '" + authPass + "', descriptor = '', ";
		            	}
		            	
		                sql += " ipaddress = '" + authIP + "', ipport = " + authPort + "  Where endpointid = '" + endpointID + "' ";
		                System.out.println("3-1:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 1){	throw new Exception(l.x("[인증테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 인증테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		                
		                sql   = "Update Table_SipContact set username = '" + authID + "' Where endpointid = '" + endpointID + "' ";
		                System.out.println("3-2:"+sql);
		                nResult = stmt.executeUpdate(sql);
		                if (nResult < 0){	throw new Exception(l.x("[인증테이블 오류] '","[Auth Properties Error] '")+e164+l.x("'는 인증테이블 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		            }
		            
		            
		            /***** TABLE_E164 에서 extensionnumber수정 ********/
		            sql = "Update TABLE_E164 Set extensionnumber = '" + extensionNum + "' ";
		            sql = sql + " WHERE e164 = '"+e164+"'" ;            
		            System.out.println("4:"+sql);
		            stmt.executeUpdate(sql);            	


		            /***** table_e164route 에서 routingnumber 수정 ********/
		            String strExtension = /* "99"+ */groupExtCode + extensionNum;
		            sql = "Update table_e164route Set routingnumber = '" + strExtension + "' ";
		            sql = sql + " WHERE routingnumber = '"+groupExtCode + hiOldExtension+"'" ;            
		            System.out.println("5:"+sql);
		            stmt.executeUpdate(sql);            	

		            
		            System.out.println("############ 수정 : 6666666");
		            stmt.endTransaction(true);			// commit 처리
		            System.out.println("############ 수정 : 77777777");
			        returnVal = true;
			        System.out.println("############ 수정 : 88888888");
			        
		            /***** SSW 처리(090615) ********/
		            //int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2,endpointID, stmt.getString());
		            //int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)0,endpointID, "");
		            int nPacketResult = ConnectionManager.updateEndpoint((short)33,(short)2,endpointID," ",  "(SSW).active" );
		            
			        //stmt.endTransaction(true);			// commit 처리
			        //returnVal = true;
		    	}//for(key)
		        
	        } catch (Exception e) {
	        	stmt.endTransaction(false);		// rollback 처리
	            e.printStackTrace();
	            returnVal = false;
	        } finally {
	            //할당받은 DataStatement 객체는 반납
	            if (stmt != null ) ConnectionManager.freeStatement(stmt);
	        }
        
			if (returnVal){
				// ############### LogHistory 처리  #############
				/* String		strIp		= request.getRemoteAddr();
				LogHistory	logHistory 	= new LogHistory();
				logHistory.LogHistorySave(userID+"|82|개인내선번호/단말관리  ("+ei64+" 번)|3|"+strIp); */
				if(1!=1)
    		    try{
    		    	// 서버로부터 DataStatement 객체를 할당
    		    	stmt 	= ConnectionManager.allocStatement("EMS");
    		    	stmt.stxTransaction();
    		    	//LogHistory	logHistory 	= new LogHistory();
    		    	String strTmp = userID+"|82|개인내선번호/단말관리|3|"+request.getRemoteAddr() ;
    		    	String[] 	blockStr 	= StringUtil.getParser(strTmp, "|");
    				String		userId 		= blockStr[0];
    				int			categori	= Integer.parseInt(blockStr[1]);
    				String		subject 	= blockStr[2];
    				int			action		= Integer.parseInt(blockStr[3]);
    				String		clientIp	= blockStr[4];
    				//String sql;
    				for(String num : e164s){
    			    	sql = " INSERT INTO table_operationhistory(checktime, managerid, sysgroupid, categori, subject, actiondml, ipaddress) ";
    			        sql = sql + " VALUES(now(), '"+userId+"', 'callbox', "+categori+", '"+subject+" ("+num+" 번)"+"', "+action+", '"+clientIp+"') ";
    			        stmt.executeUpdate(sql);
    				}
    				System.out.println("Log Save Success!!(web)");
    		     	stmt.endTransaction(true);			// commit 처리
    	    	}catch(Exception e){
    	    		stmt.endTransaction(false);		// rollback 처리
    	            e.printStackTrace();
    	    	}finally {
    	            //할당받은 DataStatement 객체는 반납
    	            if (stmt != null ){
    	            	ConnectionManager.freeStatement(stmt);
    	            }
    	        }
    		 	// ##############################################

				out.clear(); out.print("OK");
			}else{
				out.clear(); out.print("NO");					
			}

		}catch(Exception se){
			System.out.println("error-->" +se );
			if(rs!=null) rs.close() ;
			if (stmt != null ) ConnectionManager.freeStatement(stmt);
			
			if(nModeDebug==1){
		    	for(String strE164 : e164s)
			       	if( (strE164 = strE164.trim()).length()>0 ){
			       		if(jsArray.length()==0)	jsArray.append("[{params:");
			       		else					jsArray.append(",{params:");
			       		
			       		//jsArray.append("[\""+strE164+"\",\"\"]}");
			       		jsArray.append("[\""+strE164+"\",\""+endpointID+"\",\""+extensionNum+"\",\""+authIP+"\"]}");
			       	}
		        if(jsArray.length()>0)	jsArray.append("]");
		        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
		     	
		        out.clear();
		        if(e164s.length>1) out.print(jsArray.toString());
		        else out.print("OK");
		        return;
			}
			out.clear();
			out.print("NO");
		}finally{

			if(returnVal){		
				for(String strE164 : e164s)
			       	if( (strE164 = strE164.trim()).length()>0 ){
			       		if(jsArray.length()==0)	jsArray.append("[{params:");
			       		else					jsArray.append(",{params:");
			       		
			       		jsArray.append("[\""+strE164+"\",\""+endpointID+"\",\""+extensionNum+"\",\""+authIP+"\"]}");
			       	}
		        if(jsArray.length()>0)	jsArray.append("]");
%>
				<script>
			        alert("수정되었습니다.");
			        parent.goEditDone(<%=jsArray.toString()%>);
			        parent.hiddenAdCodeDiv();
			        //parent.location.href="./alarmTimeList.jsp";
			    </script>
<%		
			}else{
%>
			    <script>
			        alert("수정 중 오류가 발생하였습니다.");
			        //parent.hiddenAdCodeDiv();
			    </script>
<%
			}
		}
%>
