<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.addition.AlarmServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="business.LogHistory"%>
<%@ page import="acromate.l"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession 		ses 		= request.getSession();
String checkgroupid = (String)ses.getAttribute("login.name");
String userID = Str.CheckNullString((String)ses.getAttribute("login.user")).trim();
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );

//String grpid     = StringUtil.null2Str(request.getParameter("grpid"),"");////////////////
String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String deleteStr = StringUtil.null2Str(request.getParameter("deleteStr"),"");	// ������ ��ȭ ���

String logElement = e164 ;
System.out.println("del.fmv.e164:"+e164);
String[] e164s = e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

boolean 		returnVal 	= false;
DataStatement 	statement 	= null;
ResultSet 	rs 		= null;

try{
    String      sql 		= "" ;
    int       	nResult         = 0;
    String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	statement = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	statement.stxTransaction();

    int count = 0 ;
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
            int cnt = 0;
            
        	sql  = "\n SELECT count(*) FROM table_featureservice  WHERE serviceno = 5501 AND e164 = '" + strE164 +"' AND checkgroupid='"+checkgroupid+"'";
    		
            rs = statement.executeQuery(sql);
			if (rs.next()){ 
				cnt = Integer.parseInt(rs.getString(1));
			}
			rs.close();
            
            if (rs != null) {
            	rs.close();
                rs = null ;
            }
        	
            if (cnt > 0){
            	sql = " DELETE FROM table_featureservice WHERE e164  = '" + strE164 + "' AND serviceno = 5501 AND checkgroupid='"+checkgroupid+"'";
                System.out.println(sql);
            	statement.executeUpdate(sql);
            	System.out.println("���� ����");
            }
            count++ ;
            jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
       	if (statement != null ) statement.endTransaction(true);	
	    returnVal = true;
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(count >= e164s.length /* count > 0 */){
%>
    <script>
        alert("�����Ǿ����ϴ�.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
	if (statement != null ) statement.endTransaction(false);		// rollback ó��
	e.printStackTrace();
    returnVal = false;

 %>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
} finally {
    if (rs != null) rs.close();
    if (statement != null ) ConnectionManager.freeStatement(statement);
}	
%>