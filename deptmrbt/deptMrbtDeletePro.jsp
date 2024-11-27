<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.ResultSet, business.LogHistory, java.util.Vector, java.io.File"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;
//String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

String userWavPath = StringUtil.null2Str(request.getSession(false).getAttribute("login.strUserWavPath"), "");
			
String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    AddServiceDAO dao 	= new AddServiceDAO();
    int count = 0 ;
 	// ############### LogHistory 처리  ###############
	//returnVal = dao.deptNewMRBTDelete(deleteStr);
 	int cnt=0, nResult=0;
    String sql="", fileName = "";
    ResultSet rs=null;
    Vector 	  	vecTmp 	  	= new Vector();
    File tempFile = null;
    try {
            if (stmt != null){
        		// 트랜잭션 시작
				stmt.stxTransaction();

            	for(String strE164 : e164s){
            		strE164 = strE164.trim();
            		
            		int strValue = dao.getHuntConstraint(stmt, strE164);
					if(strValue>4){
						strValue = strValue - strValue % 8 + 0 + strValue % 4 ;
					}else{
						strValue = 0;
					}
                	sql = " Update table_keynumberid Set sound = '', huntconstraint = "+ strValue +" ";  
	    			sql = sql + "\n  Where keynumberid = '" + strE164 + "' ";
	    			System.out.println("SQL :\n"+sql);
	    			stmt.executeUpdate(sql);
                	
                    // addmrbt, 통화 연결음 파일 삭제			                    
	            	sql  = " SELECT sound FROM table_addmrbt WHERE e164 = '" + strE164 +"' ";
	            	System.out.println("SQL :\n"+sql);
                    rs = stmt.executeQuery(sql);
                    vecTmp.clear();
                    while(rs.next()){
    	            	vecTmp.add(WebUtil.CheckNullString(rs.getString(1)));            	
    	            }	                        
                    rs.close();
                    
                    int cnt3	= vecTmp.size();	                    
	                if (cnt3 > 0){
                    	sql = " Delete From table_addmrbt WHERE e164 = '" + strE164 +"' ";
                    	System.out.println("SQL :\n"+sql);
                    	stmt.executeUpdate(sql);
                    	
                        for(int j=0; j < cnt3; j++){
                        	fileName = (String)vecTmp.get(j);
                        	
		                    int nameChk = dao.wavFileChk(stmt, fileName);
		                	if(nameChk==0){
		                		int mrbtChk = dao.wavMRBTFileChk(stmt, fileName);
		                		if(mrbtChk==0){
			                		tempFile = new File(userWavPath.length()>0?userWavPath:StaticString.userWavPath +"/"+ fileName);
			                    	tempFile.delete();
		                		}
		                	}
                        }
                    }
						
						// ############### LogHistory 처리  #############
// 						LogHistory	logHistory 	= new LogHistory();
// 						int int_result = logHistory.LogHistorySave(userID+"|83|대표통화 연결음 ("+strE164+" 번)|2|"+strIp);
						// ##############################################
            	}//for
            	// commit 처리
				stmt.endTransaction(true);
				count = nResult = 1;
            }//if
    } catch (Exception e) {
    	stmt.endTransaction(false);		// rollback 처리
    	e.printStackTrace();
    	count = nResult = 0;
    } finally {
        try {
            if (rs != null) rs.close();                
        } catch (Exception e) {}
    }
        
	if(1!=1) count += dao.deptNewMRBTDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(/* count >= e164s.length */ count > 0){
%>
    <script>
        alert("삭제되었습니다.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
        parent.location.href = parent.location.href;
    </script>
<%
    }else{
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");

 %>
    <script>
    	alert("삭제되었습니다.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href = parent.location.href;
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>