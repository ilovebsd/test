<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="dao.addition.ArrivalSwitchDAO"%>

<%@ page import="business.LogHistory"%>

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

String 	e164 			= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");			//
String 	forwardNumber 	= new String(Str.CheckNullString(request.getParameter("forwardNumber")).getBytes("8859_1"), "euc-kr");	//
String 	startTime 		= new String(Str.CheckNullString(request.getParameter("startTime")).getBytes("8859_1"), "euc-kr");		// 시작시간
String 	endTime 		= new String(Str.CheckNullString(request.getParameter("endTime")).getBytes("8859_1"), "euc-kr");		// 종료시간

String 	userID			= new String(request.getParameter("userID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

//System.out.println("e164 : "+e164);
//System.out.println("forwardNumber : "+forwardNumber);
//System.out.println("startTime : "+startTime);
//System.out.println("endTime : "+endTime);

try{
		//ResultSet	rs 				= null;
		//String		sql				= "";		
		boolean 	returnVal 		= false;
		//int 		totalCnt		= 0;
		try{
			ArrivalSwitchDAO dao 	= new ArrivalSwitchDAO();
			returnVal = dao.forwardDeleteNew(e164, forwardNumber, startTime, endTime);

			if (returnVal){
				// ############### LogHistory 처리  #############
				String		strIp		= request.getRemoteAddr();
				LogHistory	logHistory 	= new LogHistory();
				int int_result = logHistory.LogHistorySave(userID+"|83|착신전환("+e164+"번의 "+forwardNumber+"번)|2|"+strIp);
				// ##############################################
				
				out.clear();
				out.print("OK");
			}else{
				out.clear();
				out.print("NO");					
			}

		}catch(Exception se){
			System.out.println("error-->" +se );
			out.clear();
			out.print("NO");
		}finally{

		}	
	}catch(Exception ex){
		System.out.println(ex);
	}finally{
	} 
%>
