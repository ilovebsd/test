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

String originalFileName = "";    // �����ϸ�
String s = "";

File    tempFile        = null;  // �ӽ� ���� ��ü

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
//�����κ��� DataStatement ��ü�� �Ҵ�
DataStatement stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);

try {
	boolean isMultipart = FileUpload.isMultipartContent(request);// multipart/form-data �� ���
	
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
        standTime1	= Integer.parseInt(strTime);		// ������ ���ð�
        standTime2	= Integer.parseInt(strTime2);		// ���ȣ ���ð�
        if("".equals(strStand)){
        	stand		= 0;							// �ִ� ���ȣ
        }else{
        	stand		= Integer.parseInt(strStand);	// �ִ� ���ȣ
        }
        if("A".equals(errorType)){
        	huntconstraint += 16*0;		// ȣ����
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        }else if("B".equals(errorType)){
        	huntconstraint += 16*1;	// ������ ��Ʈ ȣ��ȯ
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	String[]	strTemp 	= strEndpointid.split("[,]");
        	endpointid 	= strTemp[0];
        	protocol 	= Integer.parseInt(strTemp[1]);
        	
        }else if("C".equals(errorType)){
        	huntconstraint += 16*3;	// ������ ��ȭ��ȣ ȣ��ȯ
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	endpointid = strEndpointid;
        	
        }else if("D".equals(errorType)){
        	huntconstraint += 16*4;	// ȣ���
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
    		    	
    	// �����κ��� DataStatement ��ü�� �Ҵ�
    	if(stmt!=null) stmt.stxTransaction();
    	
        /***** TABLE_Keynumberid �� ���� ********/
        String soundFile = ipcsDao.getSound(stmt, keynumberid);
        if(!"".equals(soundFile) && soundFile!=null){
        	huntconstraint = huntconstraint + 4;	// MRBT ������ ������ 4�� ����
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
        	if(stmt!=null) stmt.endTransaction(true);		// commit ó��
        	
        	// ############### LogHistory ó��  ###############
//     		String		strIp		= request.getRemoteAddr();
//     		LogHistory	logHistory 	= new LogHistory();
//     		int int_result = logHistory.LogHistorySave(userID+"|82|��ǥ��ȣ ���� ("+keynumberid+" ��)|3|"+strIp);
    		// ##############################################
%>
    <script>
        alert("����Ǿ����ϴ�.");
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
        }else{
%>
    <script>
        alert("������ �����Ͽ����ϴ�.");
    </script>
<%
        }
    }else{
%>
    <script>
        alert("������ �ùٸ��� �ʽ��ϴ�.");
    </script>
<%
    }
} catch(Exception e) {
	e.printStackTrace();
    if(tempFile!=null) tempFile.delete(); // Web���� ���� ����
} finally {
	if(stmt!=null && !returnVal) stmt.endTransaction(false);		// rollback ó��
  	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
