<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.lang.l"%>
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
 
String pageDir = "";//"/ems";

String originalFileName = "";    // �����ϸ�
String s = "";

boolean returnVal 		= false;
String 	keynumberid		= "";
String 	huntType		= "";
String 	errorType		= "";
String 	strTime			= "";
String 	strTime2		= "";
String 	strEndpointid	= "";
String 	k_endpointid	= "";
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
        	k_endpointid 	= strTemp[0];
        	protocol 	= Integer.parseInt(strTemp[1]);
        	
        }else if("C".equals(errorType)){
        	huntconstraint += 16*3;	// ������ ��ȭ��ȣ ȣ��ȯ
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	k_endpointid = strEndpointid;
        	
        }else if("D".equals(errorType)){
        	huntconstraint += 16*4;	// ȣ���
        	if("1".equals(standType)){
	        	huntconstraint += standTime1*16*16;
        	}
        	k_endpointid 	= "MS";
        	protocol	= 2;
        	
        	queueoption += standTime2*16*16*16*16;
        	queueoption += stand;
        }else{
        	k_endpointid 	= "";
        }
        
        
//         IpcsDeptDAO ipcsDao 	= new IpcsDeptDAO();
        String strDesc1 		= new String(strDesc.getBytes("8859_1"),"euc-kr");
        
        IpcsDeptDTO dto = new IpcsDeptDTO();
        
     	// LocalPrefix ���̺�	
    	dto.setStartprefix(WebUtil.CheckNullString(keynumberid.trim()));
    	dto.setEndprefix(keynumberid);
    	dto.setPrefixtype(4);
    	dto.setEndpointid(keynumberid);
    	
    	// KeyNumberID ���̺�
    	dto.setKeynumberid(keynumberid);
    	dto.setKeynumberdesc(strDesc1);
    	dto.setHunt(hunt);
    	dto.setMaxhuntindex(0);
    	dto.setHuntconstraint(huntconstraint);
    	dto.setGroupid(authGroupid);		// ������ȣ ������ ��ȭ��ȣ
    	
    	dto.setQueueOption(queueoption);
        dto.setQueueStartAnn(startFile);
        dto.setQueueEndAnn(endFile);
        
    	dto.setK_endpointid(k_endpointid);
    	dto.setK_protocol(protocol);
        
    	int 	count 				= 0;
    	int 	nResult 			= 0;
    	// TABLE_Localprefix ���̺�
    	String 	startprefix			= dto.getStartprefix().trim();		//  
    	String 	endprefix			= dto.getEndprefix().trim();		// 
    	int 	prefixtype			= dto.getPrefixtype();				// 
//     	int 	protocol			= dto.getProtocol();				// 
    	String 	endpointid			= dto.getEndpointid().trim();		//  
    	String 	groupid				= authGroupid;//dto.getGroupid().trim();			// 	    	
    	// TABLE_Keynumberid ���̺�
//     	String 	keynumberid			= dto.getKeynumberid().trim();		// 
    	String 	keynumberdesc		= dto.getKeynumberdesc().trim();	// 
//     	int 	hunt				= dto.getHunt();					// 
    	int 	huntindex			= dto.getHuntindex();				// 
    	int 	maxhuntindex		= dto.getMaxhuntindex();			// 
//     	int 	huntconstraint		= dto.getHuntconstraint();			// 

//     	String 	k_endpointid		= dto.getK_endpointid();			// 
    	int 	k_protocol			= dto.getK_protocol();				// 

//     	int		queueoption			= dto.getQueueOption();
//     	String	startFile			= dto.getQueueStartAnn();
//     	String	endFile				= dto.getQueueEndAnn();
	    	
    	String			sql 		= "";
//     	ResultSet 		rs 			= null;
	    	
        /***** TABLE_Localprefix �� ���� ********/
        sql = "INSERT INTO TABLE_Localprefix " +
           "(Startprefix, Endprefix, Prefixtype, Endpointid, groupid, checkgroupid) "
           + "\n VALUES ('"
           + startprefix + "','"
           + endprefix + "',"
           + prefixtype + ",'"
           + endpointid + "','"
           + groupid + "','"
           + groupid + "')";
		System.out.println("sql : "+sql);
		nResult = stmt.executeUpdate(sql);
		if (nResult < 1){	throw new Exception(l.x("[��ǥ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+keynumberid+ l.x(" ��ǥ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}
			
        /***** TABLE_Keynumberid �� ���� ********/
        if(k_protocol==0){
        	sql = "INSERT INTO TABLE_Keynumberid " +
            "(Keynumberid, Keynumberdesc, Hunt, Maxhuntindex, Huntconstraint, Groupid, checkGroupid, Endpointid) "
            + "\n VALUES ('"
            + keynumberid + "','"
            + keynumberdesc + "',"
            + hunt + ","
            + maxhuntindex + ","
            + huntconstraint + ",'"
            + groupid +"','"+ groupid +"','"
			+ k_endpointid +"')";
        }else{
			sql = "INSERT INTO TABLE_Keynumberid " +
            "(Keynumberid, Keynumberdesc, Hunt, Maxhuntindex, Huntconstraint, Groupid, checkGroupid, Endpointid, Protocol, queueoption, queuestartann, queueendann) "
            + "\n VALUES ('"
            + keynumberid + "','"
            + keynumberdesc + "',"
            + hunt + ","
            + maxhuntindex + ","
            + huntconstraint + ",'"
            + groupid +"','"+ groupid +"','"
			+ k_endpointid +"',"
			+ k_protocol +","
			+ queueoption +",'"
			+ startFile +"','"
			+ endFile +"')";
        }
	        
		System.out.println("sql : "+sql);
		nResult = stmt.executeUpdate(sql);
		if (nResult < 1){	throw new Exception(l.x("[��ǥ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+keynumberid+ l.x(" ��ǥ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}
		
        if (nResult >= 1) returnVal = true;
        //returnVal = true;
        
        if(returnVal){
        	System.out.println("��ǥ��ȣ ���� ���� : "+keynumberid);
        	// ############### LogHistory ó��  ###############
//     		String		strIp		= request.getRemoteAddr();
//     		LogHistory	logHistory 	= new LogHistory();
//     		int int_result = logHistory.LogHistorySave(userID+"|82|��ǥ��ȣ ("+keynumberid+" ��)|3|"+strIp);
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
%>
    <script>
        alert("������ �����Ͽ����ϴ�.");
    </script>
<%
} finally {
  	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
