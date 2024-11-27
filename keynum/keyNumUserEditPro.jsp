<%@page import="business.CommonData"%>
<%@page import="java.sql.ResultSet"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.ipcs.IpcsDeptDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<%@ page import="business.LogHistory"%>

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

String userID		= Str.CheckNullString(scDTO.getSubsID()).trim();
 */
 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String groupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;
 
String pageDir = "";//"/ems";

String keynumberid	= StringUtil.null2Str(request.getParameter("hiKeynumberid"),"");
String e164List 	= StringUtil.null2Str(request.getParameter("hiE164List"),"");	// 추가할 목록
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
ResultSet rs = null;
try{
    //처리부분
    IpcsDeptDAO ipcsDeptDAO = new IpcsDeptDAO();
    int count = 0, totalcount=0;//ipcsDeptDAO.deptNumberE164Update(stmt, keynumberid, e164List);
    String sql = "", sipEndpointId ="";
    int 	newMaxHuntIndex = 0;
    
    
    CommonData		commonData	= new CommonData();
	String 			domainid 	= commonData.getDomain(stmt);			// 도메인ID 조회

	String[]		tempDomain;
	if(!"".equals(domainid)){
		tempDomain 		= domainid.split("[.]");
		domainid		= tempDomain[0];
		sipEndpointId 	= "@" + domainid + ".callbox.kt.com:5060";
	} 
	
	
 	// Transaction 시작
	if(stmt!=null) stmt.stxTransaction(); 

	if(!"".equals(e164List)){
		// table_keynumber 데이타 삭제 후 새롭게 선택한 E164를 table_keynumber 에 저장
		sql = "Delete From table_keynumber Where keynumberid = '" + keynumberid + "'";
		count += stmt.executeUpdate(sql);
		System.out.println("1-1:"+sql);
		//if (nResult < 0){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+keynumberid+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		
		sql = "Delete From table_PresenceReport Where OfferID = '" + keynumberid + "'";
		count += stmt.executeUpdate(sql);
		System.out.println("sql :"+sql);
		
		/////////////////////
		int 	nTmp3 		= 0;
		long registerTime = 0;
		String strArray[]	= e164List.split("[|]");
		for(int i=0;i<strArray.length;i++){
			String e164Temp00	= strArray[i];
			String e164Temp[]	= e164Temp00.split(";");
			String e164Temp_01	= e164Temp[0];
			
			nTmp3 = nTmp3 +1;
        	sql = "\n  Insert into table_keynumber(keynumberid, e164, indexno, callrate, fromtime, totime) ";
        	sql = sql + "\n  values('" + keynumberid + "', '" + e164Temp_01 + "', " + nTmp3 + ", 0, '0000', '2400')";
            System.out.println("1-2-"+i+"번째:"+sql);
            stmt.executeUpdate(sql);

            sql   = "INSERT INTO table_PresenceReport(UserE164, OfferID, Protocol, OfferType, ReportType, checkgroupid) ";
            sql += " VALUES ('" + e164Temp_01  + "', '"+keynumberid+"', 0, 0, 0, '"+groupid+"')";
            System.out.println("  sql :"+sql);
            stmt.executeUpdate(sql);
            
            totalcount = 0;
            
            /***** 프레즌스(Presence) 테이블 업데이트 *******/
            sql = "SELECT COUNT(*) FROM table_Presence WHERE Usere164 = '" + e164Temp_01 +"'";
            System.out.println("  sql :"+sql);
            rs = stmt.executeQuery(sql);
            if(rs!=null){
	            if(rs.next()==true)	totalcount = rs.getInt(1);
	            rs.close();
            }
            if(totalcount == 0){
            	registerTime = 0;
            	
	            sql = "select registeredtime from table_sipcontact where endpointid = '" + (e164Temp_01 + sipEndpointId) +"'";
	            System.out.println("  sql :"+sql);
	            rs = stmt.executeQuery(sql);
	            if(rs!=null){
	            	totalcount = 0;
		            if(rs.next()==true)	registerTime = Str.CheckNullLong(rs.getString(1));
		            rs.close();
	            }
	            
	            sql   = "INSERT INTO table_presence(UserE164, EndpointID, Protocol, UserType, RegisterTime, PresenceStatus, checkgroupid) ";            
                sql += " VALUES ('" + e164Temp_01  + "', '" + (e164Temp_01 + sipEndpointId)  + "', 2, 1, " + registerTime + ",0, '"+groupid+"')";
                System.out.println("  sql :"+sql);
                stmt.executeUpdate(sql);
            }
            
		}//for
		/////////////////////
        
		sql = "SELECT count(*) FROM table_keynumber WHERE keynumberid = '" + keynumberid + "'";
		System.out.println("sql :"+sql);
        rs = stmt.executeQuery(sql);
        if(rs!=null) {
        	if (rs.next()) newMaxHuntIndex = rs.getInt(1);	
        	rs.close();
        }

        sql   = "Update table_keynumberid set maxhuntindex = " + newMaxHuntIndex + " Where keynumberid = '" + keynumberid + "'";
        System.out.println("1-3:"+sql);
        count += stmt.executeUpdate(sql);
        //if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+keynumberid+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}                        

	}else{
		
		// 부서대표번호에 할당할 E164를 선택하지 안아  table_keynumber 데이타 삭제
		sql = "Delete From table_keynumber Where keynumberid = '" + keynumberid + "'";
		System.out.println("2-1:"+sql);
		count += stmt.executeUpdate(sql);
		//if (nResult < 0){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+keynumberid+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		
		sql   = "Update table_keynumberid set maxhuntindex = 0 Where keynumberid = '" + keynumberid + "'";
		System.out.println("2-2:"+sql);
		count += stmt.executeUpdate(sql);
		//if (nResult < 1){	throw new Exception(l.x("[부서대표번호 오류] '","[Auth Properties Error] '")+keynumberid+l.x("'는 부서대표번호 수정이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}	                
	}
	
    if(count > 0){
		// ############### LogHistory 처리  ###############
// 		String		strIp		= request.getRemoteAddr();
// 		LogHistory	logHistory 	= new LogHistory();
// 		int int_result = logHistory.LogHistorySave(userID+"|82|대표번호 관리 ("+keynumberid+" 번)|3|"+strIp);
		// ##############################################
		// Transaction 종료
    	stmt.endTransaction(true);			// commit 처리
%>
    <script>
        alert("수정되었습니다.");
        parent.hiddenAdCodeDiv();
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
    }else{
    	// Transaction  Rollback 처리
    	stmt.endTransaction(false);		// rollback 처리
%>
    <script>
        alert("수정 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
 	// Transaction  Rollback 처리
	stmt.endTransaction(false);		// rollback 처리
	
	e.printStackTrace();	
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>