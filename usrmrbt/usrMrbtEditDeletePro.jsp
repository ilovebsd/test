<%@page import="java.io.File"%>
<%@page import="java.util.Vector"%>
<%@page import="java.sql.ResultSet"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;
//String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

String 	e164 		= new String(Str.CheckNullString(request.getParameter("d_Ei64")).getBytes("8859_1"), "euc-kr");		// 
String 	dayValue 	= new String(Str.CheckNullString(request.getParameter("d_DayValue")).getBytes("8859_1"), "euc-kr");		//
String 	startTime 	= new String(Str.CheckNullString(request.getParameter("d_StartTime")).getBytes("8859_1"), "euc-kr");		//
String 	endTime 	= new String(Str.CheckNullString(request.getParameter("d_EndTime")).getBytes("8859_1"), "euc-kr");		//
String 	fileName 	= new String(Str.CheckNullString(request.getParameter("d_filename")).getBytes("8859_1"), "euc-kr");		//
			
//String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
//String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
String userWavPath = StringUtil.null2Str(request.getSession(false).getAttribute("login.strUserWavPath"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    AddServiceDAO dao 	= new AddServiceDAO();
    int count = 0 ;
 	// ############### LogHistory 처리  ###############
	//returnVal = dao.e164NewMRBTDelete(deleteStr);
	//count += dao.e164NewMRBTDelete(e164, request.getRemoteAddr(), userID, sesSysGroupID)? 1:0;
	//count += dao.e164UserMRBTDelete(stmt, e164, dayValue, startTime, endTime, fileName)? 1:0;
	
boolean 		returnVal 	= false;
    	try {
//    		int 		count 		= 0;
    		String		sql 		= "";
	    	ResultSet 	rs 			= null;
	    	ResultSet 	rs2 		= null;
	    	ResultSet 	rs3 		= null;
	    	int       	nResult     = 0;
//	        String    	fileName 	= "";
	        File      	tempFile    = null;  //       
	    	Vector 	  	vecTmp 	  	= new Vector();
	        Vector 	  	vecTmp2 	= new Vector();

	        
	    	//DataStatement
	    	//stmt 	= ConnectionManager.allocStatement("SSW");
	    	stmt.stxTransaction();
	    	
            int cnt = 0;		            
        	sql  = "\n SELECT count(*) FROM table_addmrbt " ;
    		sql += "\n  WHERE e164 = '" + e164 +"' And dayvalue = '" + dayValue +"' And starttime = '" + startTime +"' ";
    		sql += "\n    And endtime = '" + endTime +"' And sound = '" + fileName +"' ";
    		
            rs = stmt.executeQuery(sql);
			if (rs.next()){ 
				cnt = Integer.parseInt(rs.getString(1));
			}
			rs.close();
            
            if (rs != null) 
            	rs.close();
        	
            if (cnt > 0){
            	sql = " Delete From table_addmrbt ";
        		sql += "\n  WHERE e164 = '" + e164 +"' And dayvalue = '" + dayValue +"' And starttime = '" + startTime +"' ";
        		sql += "\n    And endtime = '" + endTime +"' And sound = '" + fileName +"' ";                    	
            	stmt.executeUpdate(sql);                    	
            	
            	int cnt2 = 0;
            	sql  = " SELECT count(*) FROM table_addmrbt WHERE e164 = '" + e164 +"' ";                    	
                rs2 = stmt.executeQuery(sql);
				if (rs2.next()){ 
					cnt2 = Integer.parseInt(rs2.getString(1));
				}
				rs2.close();    	                
                if (rs2 != null)	rs2.close();
                
                if (cnt2 == 0){
                	// ????? ???? ?????? table_featureservice ????? ????
                	sql = " Delete From table_featureservice Where e164  = '" + e164 + "' And serviceno = '5011' ";
                	stmt.executeUpdate(sql);

                	sql  = "\n SELECT serviceno FROM table_featureservice ";
            		sql += "\n  WHERE e164 = '" + e164 + "' ";
            		sql += "\n  ORDER BY priority ";	                    	

                    rs2 = stmt.executeQuery(sql);
                    vecTmp2.clear();
                    while(rs2.next()){
    	            	vecTmp2.add(WebUtil.CheckNullString(rs2.getString(1)));            	
    	            }	                        
                    rs2.close();
                    
                    int 		nTmp2	= vecTmp2.size();
                    int 		cnt3 	= 1;
                    String		strTmp2	= "";
                    
                    if(nTmp2>0){
	                    for(int j=0; j < nTmp2; j++){
	                    	strTmp2 = (String)vecTmp2.get(j);
	                    	sql  = "\n UPDATE table_featureservice  " ;
		                    sql += "\n    Set priority  = " + cnt3;
		            		sql += "\n  WHERE e164      = '" + e164 + "' ";
		            		sql += "\n    AND serviceno = " + strTmp2 + " ";
		            		nResult = stmt.executeUpdate(sql);
		                    cnt3++;
	                    }
                    }

                    // table_callermrbt
                    sql  = "\n DELETE FROM table_callermrbt WHERE e164 = '" + e164 + "' ";
                    nResult = stmt.executeUpdate(sql);
                    
                }
            	
                // 
                int nameChk = dao.wavFileChk(stmt, fileName);
            	if(nameChk==0){
            		int mrbtChk = dao.wavMRBTFileChk(stmt, fileName);
            		if(mrbtChk==0){
                		tempFile = new File(userWavPath.length()>0?userWavPath:StaticString.userWavPath+"/"+fileName);
                    	tempFile.delete();
            		}
            	}
                
    			System.out.println("????  ????");
            }
	    	
            stmt.endTransaction(true);			// commit
	        returnVal = true;
	        count = 1;
	        
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback
            e.printStackTrace();
            returnVal = false;
        } finally {
            //if (stmt != null ) ConnectionManager.freeStatement(stmt);
        }
	// ##############################################
   	/*  for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    	if(jsArray.length()>0)	jsArray.append("]");
     */
    if(/* count >= e164s.length */ count > 0){
%>
    <script>
        alert("삭제되었습니다.");
        parent.location.href="usrMrbtList.jsp?viewType=<%=e164%>";
    </script>
<%
    }else{
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        //parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	/* 
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
         */
 %>
    <script>
    	alert("삭제되었습니다.");
    	parent.location.href="usrMrbtList.jsp?viewType=<%=e164%>";
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>