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

String pageDir = "";//"/ems";

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;

String keynumberids      = StringUtil.null2Str(request.getParameter("hiKeynumberid"),"");//삭제할 대표번호
//String deleteStr = StringUtil.null2Str(request.getParameter("deleteStr"),"");	// 삭제할 통화 목록


String[] e164s = StringUtil.getParser(keynumberids, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	if(stmt!=null) stmt.stxTransaction();
    //삭제 처리부분
//     AddServiceDAO dao = new AddServiceDAO();
    int count = 0;//dao.callChangeNumberDelete(keynumberids, request.getRemoteAddr(), userID)?1:0;
    for(String keynumberid : e164s){
    	/***** Table_Localprefix 삭제 ********/
        sql = "DELETE FROM Table_Localprefix WHERE endpointid='"+keynumberid+"'" ;
        System.out.println("SQL 2:"+sql);
        count += stmt.executeUpdate(sql);
        
        /***** Table_Keynumberid 삭제 ********/
        sql = "DELETE FROM Table_Keynumberid WHERE keynumberid='" + keynumberid + "'";
        System.out.println("SQL 3:"+sql);
        count += stmt.executeUpdate(sql);
                    
        /***** Table_Dept 부서대표번호 초기화 ********/
//         sql = "Update Table_Dept Set keynumber = null WHERE keynumber = '" + keynumberid + "'";
//         System.out.println("SQL 4:"+sql);
//         count += stmt.executeUpdate(sql);

        /***** Table_Keynumber 삭제 ********/
//         sql = "DELETE FROM Table_Keynumber WHERE keynumberid='" + keynumberid + "'";
//         System.out.println("SQL 5:"+sql);
//         count += stmt.executeUpdate(sql);

        /***** Table_AddMRBT 삭제 ********/
        /*
        String sql2 = " SELECT sound FROM Table_AddMRBT WHERE e164 = '" + keynumberid + "' ";
        if (stmt != null) {
        	rs = stmt.executeQuery(sql2);
            if (rs.next()) sounfFile = rs.getString(1); 
            rs.close();
        } else            
            System.out.println("데이터베이스에 연결할 수 없습니다.");

        sql = "DELETE FROM Table_AddMRBT WHERE e164='" + keynumberid + "'";
        System.out.println("SQL 6:"+sql);
        stmt.executeUpdate(sql);
        */

        /***** table_keynumberforward_days 삭제 (대표번호 착신전환)********/
//        sql = "DELETE FROM table_keynumberforward_days WHERE keynumber='" + keynumberid + "'";
//        System.out.println("SQL 7:"+sql);
//        stmt.executeUpdate(sql);
        
        /***** table_keynumberforward_week 삭제 (대표번호 착신전환)********/
//        sql = "DELETE FROM table_keynumberforward_week WHERE keynumber='" + keynumberid + "'";
//        System.out.println("SQL 8:"+sql);
//        stmt.executeUpdate(sql);
        
        
        /*
        if(!"".equals(sounfFile)&&(sounfFile!=null)){
			// 사용하던 음원 파일 삭제
            int nameChk1 = wavFileChk(stmt, sounfFile);
        	if(nameChk1==0){
        		int mrbtChk1 = wavMRBTFileChk(stmt, sounfFile);
        		if(mrbtChk1==0){
        			int queueChk1 = wavQueueFileChk(stmt, sounfFile);
        			if(queueChk1==0){
                		tempFile = new File(StaticString.userWavPath+"/"+sounfFile);
                    	tempFile.delete();
        			}
        		}
        	}
        }
        */
    }//
    
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		//count += dao.deleteAll(stmt, strE164);
    		
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){
    	
    	if(stmt!=null) stmt.endTransaction(true);
    	
%>
    <script>
        alert("삭제되었습니다.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
    }else{
    	if(stmt!=null) stmt.endTransaction(false);    	
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        //parent.hiddenAdCodeDiv();
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(stmt!=null) stmt.endTransaction(false);
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
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>