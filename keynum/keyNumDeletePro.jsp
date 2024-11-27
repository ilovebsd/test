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

String keynumberids      = StringUtil.null2Str(request.getParameter("hiKeynumberid"),"");//������ ��ǥ��ȣ
//String deleteStr = StringUtil.null2Str(request.getParameter("deleteStr"),"");	// ������ ��ȭ ���


String[] e164s = StringUtil.getParser(keynumberids, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	if(stmt!=null) stmt.stxTransaction();
    //���� ó���κ�
//     AddServiceDAO dao = new AddServiceDAO();
    int count = 0;//dao.callChangeNumberDelete(keynumberids, request.getRemoteAddr(), userID)?1:0;
    for(String keynumberid : e164s){
    	/***** Table_Localprefix ���� ********/
        sql = "DELETE FROM Table_Localprefix WHERE endpointid='"+keynumberid+"'" ;
        System.out.println("SQL 2:"+sql);
        count += stmt.executeUpdate(sql);
        
        /***** Table_Keynumberid ���� ********/
        sql = "DELETE FROM Table_Keynumberid WHERE keynumberid='" + keynumberid + "'";
        System.out.println("SQL 3:"+sql);
        count += stmt.executeUpdate(sql);
                    
        /***** Table_Dept �μ���ǥ��ȣ �ʱ�ȭ ********/
//         sql = "Update Table_Dept Set keynumber = null WHERE keynumber = '" + keynumberid + "'";
//         System.out.println("SQL 4:"+sql);
//         count += stmt.executeUpdate(sql);

        /***** Table_Keynumber ���� ********/
//         sql = "DELETE FROM Table_Keynumber WHERE keynumberid='" + keynumberid + "'";
//         System.out.println("SQL 5:"+sql);
//         count += stmt.executeUpdate(sql);

        /***** Table_AddMRBT ���� ********/
        /*
        String sql2 = " SELECT sound FROM Table_AddMRBT WHERE e164 = '" + keynumberid + "' ";
        if (stmt != null) {
        	rs = stmt.executeQuery(sql2);
            if (rs.next()) sounfFile = rs.getString(1); 
            rs.close();
        } else            
            System.out.println("�����ͺ��̽��� ������ �� �����ϴ�.");

        sql = "DELETE FROM Table_AddMRBT WHERE e164='" + keynumberid + "'";
        System.out.println("SQL 6:"+sql);
        stmt.executeUpdate(sql);
        */

        /***** table_keynumberforward_days ���� (��ǥ��ȣ ������ȯ)********/
//        sql = "DELETE FROM table_keynumberforward_days WHERE keynumber='" + keynumberid + "'";
//        System.out.println("SQL 7:"+sql);
//        stmt.executeUpdate(sql);
        
        /***** table_keynumberforward_week ���� (��ǥ��ȣ ������ȯ)********/
//        sql = "DELETE FROM table_keynumberforward_week WHERE keynumber='" + keynumberid + "'";
//        System.out.println("SQL 8:"+sql);
//        stmt.executeUpdate(sql);
        
        
        /*
        if(!"".equals(sounfFile)&&(sounfFile!=null)){
			// ����ϴ� ���� ���� ����
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
        alert("�����Ǿ����ϴ�.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
    }else{
    	if(stmt!=null) stmt.endTransaction(false);    	
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
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
    	alert("�����Ǿ����ϴ�.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href="<%=StaticString.ContextRoot+pageDir%>/keynum/keyNumList.jsp";
    </script>
<%
	}
} finally {
    //�Ҵ���� DataStatement ��ü�� �ݳ�
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>