<%@page import="java.sql.ResultSet"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.ipcs.IpcsDeptDTO" %>
<%@ page import="dao.ipcs.IpcsDeptDAO" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.List" %>
<%@ page import="business.CommonData"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="java.io.*,java.util.*,java.security.*,sun.misc.*,java.io.File"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>

<%@ page import="business.LogHistory"%>

<% 

String pageDir = "";//"/ems";

String originalFileName = "";    // 원파일명
String s = "";

File    tempFile        = null;  // 임시 파일 객체

boolean returnVal 		= false;
String 	keynumberid		= "";
String 	huntType		= "";
String 	errorType		= "";
String 	strTime			= "";
String 	strTime2		= "";
String 	strEndpointid	= "";
String 	endpointid		= "";
String 	startFile		= "";
String 	endFile			= "";
String 	strStand		= "";
String	standType		= "";
String	strDesc			= "";
String	beforeFile_1	= "";
String	beforeFile_2	= "";
int 	huntconstraint	= 0;
int 	protocol		= 0;
int		hunt			= 0;
int 	standTime1		= 0;
int 	standTime2		= 0;
int 	stand			= 0;
int		queueoption		= 0;
// String	userID			= "";

/* SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}
response.setCharacterEncoding("euc-kr");
 */
 
 response.setHeader("Pragma", "No-cache"); 
 response.setDateHeader("Expires", 0); 
 response.setHeader("Cache-Control", "no-Cache"); 
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);

try {
	boolean isMultipart = FileUpload.isMultipartContent(request);// multipart/form-data 일 경우
	
    if(!isMultipart){    
	  	keynumberid 	= Str.CheckNullString(request.getParameter("hiKeyNumberID_02"));
   		huntType 		= Str.CheckNullString(request.getParameter("hiHunt_02"));
   		errorType 		= Str.CheckNullString(request.getParameter("hiErrorType_02"));                
   		strEndpointid 	= Str.CheckNullString(request.getParameter("hiEndpointid_02"));
       	strTime 		= Str.CheckNullString(request.getParameter("hiStandTime_02"));
       	strTime2 		= Str.CheckNullString(request.getParameter("hiStandTime2_02"));
       	strStand 		= Str.CheckNullString(request.getParameter("hiStand_02"));
       	standType 		= Str.CheckNullString(request.getParameter("hiStandType_02"));
       	strDesc 		= Str.CheckNullString(request.getParameter("hiDesc_02"));
//        	strDesc 		= new String(request.getParameter("hiDesc_02").getBytes("8859_1"),"euc-kr");
//        	userID 			= Str.CheckNullString(request.getParameter("hiUserID"));

//        if("".equals(originalFileName)){
//            originalFileName = dbfile;
//        }

		hunt		= Integer.parseInt(huntType);
        standTime1	= Integer.parseInt(strTime);		// 무응답 대기시간
        standTime2	= Integer.parseInt(strTime2);		// 대기호 대기시간
        if("".equals(strStand)){
        	stand		= 0;							// 최대 대기호
        }else{
        	stand		= Integer.parseInt(strStand);	// 최대 대기호
        }
        if("A".equals(errorType)){
        	huntconstraint += 16*0;		// 호종료
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        }else if("B".equals(errorType)){
        	huntconstraint += 16*1;	// 정해진 루트 호전환
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	String[]	strTemp 	= strEndpointid.split("[,]");
        	endpointid 	= strTemp[0];
        	protocol 	= Integer.parseInt(strTemp[1]);
        	
        }else if("C".equals(errorType)){
        	huntconstraint += 16*3;	// 정해진 전화번호 호전환
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	endpointid = strEndpointid;
        	
        }else if("D".equals(errorType)){
        	huntconstraint += 16*4;	// 호대기
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	endpointid 	= "MS";
        	protocol	= 2;
        	
        	queueoption += standTime2*16*16*16*16;
        	queueoption += stand;
        }else{
        	endpointid 	= "";
        }
        
        
        IpcsDeptDAO ipcsDao 	= new IpcsDeptDAO();
        String strDesc1 		= new String(strDesc.getBytes("8859_1"),"euc-kr");
//         returnVal = ipcsDao.ipcsDeptNewEdit(keynumberid, hunt, strDesc1, endpointid, huntconstraint, protocol, errorType, queueoption, startFile, endFile, beforeFile_1, beforeFile_2);
        //returnVal = true;
        String		sql 		= "";
    	ResultSet 	rs 			= null;
    		    	
    	// 서버로부터 DataStatement 객체를 할당
    	if(stmt!=null) stmt.stxTransaction();
    	
        /***** TABLE_Keynumberid 에 저장 ********/
        String soundFile = ipcsDao.getSound(stmt, keynumberid);
        if(!"".equals(soundFile) && soundFile!=null){
        	huntconstraint = huntconstraint + 4;	// MRBT 파일이 있으면 4를 더함
        }

        sql = "Update TABLE_Keynumberid  Set " ;
    	sql += "\n  Hunt 			= "+ hunt + " " ;
    	sql += "\n ,Keynumberdesc 	= '"+ strDesc1 + "' ";
    	sql += "\n ,huntconstraint 	= "+ huntconstraint + " ";
    	sql += "\n ,endpointid 		= '"+ endpointid + "' ";
    	sql += "\n ,protocol 		= "+ protocol + " ";
    	if("D".equals(errorType)){
    		sql += "\n ,queueoption 	= "+ queueoption + " ";
    		if(!"".equals(startFile))	sql += "\n ,queuestartann 	= '"+ startFile + "' ";
    		if(!"".equals(endFile))		sql += "\n ,queueendann 	= '"+ endFile + "' ";
    	}else{
    		sql += "\n ,queueoption 	= 0 ";
    		sql += "\n ,queuestartann 	= '' ";
    		sql += "\n ,queueendann 	= '' ";
    	}
    	sql += "\n  Where Keynumberid = '"+ keynumberid + "' ";

    	System.out.println("sql :"+sql);
    	returnVal = stmt.executeUpdate(sql)==1? true:false;
		
        if(returnVal){
        	if(stmt!=null) stmt.endTransaction(true);		// commit 처리
        	
        	// ############### LogHistory 처리  ###############
//     		String		strIp		= request.getRemoteAddr();
//     		LogHistory	logHistory 	= new LogHistory();
//     		int int_result = logHistory.LogHistorySave(userID+"|82|대표번호 관리 ("+keynumberid+" 번)|3|"+strIp);
    		// ##############################################
%>
    <script>
        alert("저장되었습니다.");
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
        }else{
%>
    <script>
        alert("저장이 실패하였습니다.");
    </script>
<%
        }
    }else{
%>
    <script>
        alert("형식이 올바르지 않습니다.");
    </script>
<%
    }
} catch(Exception e) {
	e.printStackTrace();
    if(tempFile!=null) tempFile.delete(); // Web템프 파일 삭제
} finally {
	if(stmt!=null && !returnVal) stmt.endTransaction(false);		// rollback 처리
  	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
