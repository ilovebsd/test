<%@page import="acromate.common.util.Str"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.*"%>
<%@ page import="com.acromate.dao.element.ConditionalReplaceDAO"%>
<%@ page import="com.acromate.dto.element.ConditionalReplaceDTO"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = (String)ses.getAttribute("login.name") ;
String userID = (String)ses.getAttribute("login.user") ;

String areanum     	= StringUtil.null2Str(request.getParameter("areanum"),"").trim();
String localnum   	= StringUtil.null2Str(request.getParameter("localnum"),"").trim();
String extnum           = StringUtil.null2Str(request.getParameter("extnum"),"").trim();
String startextnum  = StringUtil.null2Str(request.getParameter("startextnum"),"").trim();
int createcount  	= Str.CheckNullInt((String)request.getParameter("createcount"));

String extensiongroupnum = null ;
String domain = null ;

HashMap<String, String> listNewExt = new HashMap<String, String>(); 
StringBuffer jsArray = new StringBuffer();
ArrayList               envList = null;
// 서버로부터 DataStatement 객체를 할당
DataStatement   stmt = null;
HashMap item = null , checkItem = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
    stmt                    = ConnectionManager.allocStatement("SSW", sesSysGroupID) ;
    //처리부분
    CommonDAO dao = new CommonDAO() ;
    envList = dao.select(stmt, "select extensiongroupnum, domain from Table_subscriberGroup where checkgroupid='"+authGroupid+"' ", new String[]{"extensiongroupnum","domain"} ) ;
    if( envList.size() > 0 ) {
        item = (HashMap)envList.get(0) ;
        extensiongroupnum = (String)item.get("extensiongroupnum") ;
        domain = (String)item.get("domain") ;
    }
    
    int count = 0 ;
    StringBuffer sql = new StringBuffer() ; 
    int nPlus = Str.CheckNullInt( "1" + startextnum ) ;
    
    String number="", extnumber="", endpointID = "", checkgroupid = "" ;
    String startNumber = areanum + localnum + extnum ;
    envList = dao.select(stmt, "select e164, extensionnumber, checkgroupid from Table_e164 where checkgroupid = '"+authGroupid+"' order by e164 ", new String[]{"e164", "extensionnumber", "checkgroupid"} ) ;
    StringBuffer buff = new StringBuffer() ;
    int size = envList.size() ;
    int nCreatCount = 0 ;


    for( int i=0 ; i<size ; i++ ) {
    	if(nCreatCount >= createcount) 		
    		break;
    	
        item = (HashMap)envList.get(i);
        number = (String)item.get("e164") ;
        System.out.println("number:"+number+", startNumber:"+startNumber);
        if ( number.compareTo(startNumber) < 0 ) continue ;
        extnumber = String.valueOf(nPlus).substring(1) ;
        
        //--- 기존 내선 번호 삭제 ----
        for( int j=0; j<size ; j++ ) {
        	checkItem = (HashMap)envList.get(j);
            String checkExtensionNumber = (String)checkItem.get("extensionnumber") ;
            if ( checkExtensionNumber.equals(extnumber) == false ) continue ;
            
            String checkNumber = (String)checkItem.get("e164") ;
            String checkEndpointID = checkNumber+"@"+ domain +":5060" ;
            
            sql.setLength(0) ;
            sql.append("UPDATE table_subscriber SET extension='' WHERE id ='"+checkEndpointID+"' ") ;
            System.out.println(sql.toString());
            count += dao.update(stmt, sql.toString()) ;

            sql.setLength(0) ;
            sql.append("DELETE FROM table_e164route WHERE e164='"+checkNumber+"' AND routingnumbertype = 5 ") ;
            System.out.println(sql.toString());
            count += dao.delete(stmt, sql.toString()) ;
            
            sql.setLength(0) ;
            sql.append("UPDATE table_e164 SET extensionnumber='' WHERE e164 ='"+checkNumber+"' ") ;
            System.out.println(sql.toString());
            count += dao.update(stmt, sql.toString()) ;
            listNewExt.put(checkNumber, "") ;

            break ;
        }

        nCreatCount++;
        nPlus++;      
        //count=1;
    }//for

    count = 0 ;
    nPlus = Str.CheckNullInt( "1" + startextnum ) ;
    nCreatCount = 0 ;

    for( int i=0 ; i<size ; i++ ) {
    	if(nCreatCount >= createcount) 		
    		break;
    	
        item = (HashMap)envList.get(i);
        number = (String)item.get("e164") ;
        System.out.println("number:"+number+", startNumber:"+startNumber);
        if ( number.compareTo(startNumber) < 0 ) continue ;
        
        checkgroupid = (String)item.get("checkgroupid") ;
        endpointID = number+"@"+ domain +":5060" ;
        
        extnumber = String.valueOf(nPlus).substring(1) ;
        
        sql.setLength(0) ;
        sql.append("UPDATE table_e164 SET extensionnumber='"+extnumber+"' WHERE e164 ='"+number+"' ") ;
        count += dao.update(stmt, sql.toString()) ;
        System.out.println(sql.toString());
        
        sql.setLength(0) ;
        sql.append("DELETE FROM table_e164route WHERE e164='"+number+"' AND routingnumbertype = 5 AND checkgroupid='"+checkgroupid+"' ") ;
        count += dao.delete(stmt, sql.toString()) ;
        System.out.println(sql.toString());
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+ extensiongroupnum + extnumber +"', '"+number+"', 2, '"+endpointID+"', 5, 1, '"+checkgroupid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;
        System.out.println(sql.toString());
        
        sql.setLength(0) ;
        sql.append("UPDATE table_subscriber SET extension='"+extnumber+"' WHERE id ='"+endpointID+"' AND checkgroupid='"+checkgroupid+"' ") ;
        count += dao.update(stmt, sql.toString()) ;
        System.out.println(sql.toString());
        
        listNewExt.put(number, extnumber) ;
        nCreatCount++;
        nPlus++;      
        //count=1;
    }//for

    if( count > 0 ){
    	String strE164;
    	Iterator iter = listNewExt.keySet().iterator() ;
    	while(iter.hasNext()){
    		strE164 = (String)iter.next() ;
    		if( (strE164 = strE164.trim()).length()>0 ){
        		if(jsArray.length()==0)	jsArray.append("[{params:");
           		else					jsArray.append(",{params:");
        		
        		jsArray.append("[\""+strE164+"\",\""+listNewExt.get(strE164)+"\"]}");
           	}
    	}
    	if(jsArray.length()>0)	jsArray.append("]");
    	
%>
    <script>
        alert("변경되었습니다.");
        parent.goExtNumUpdateDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
    } else {
%>
    <script>
        alert("변경 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
        String strE164;
    	Iterator iter = listNewExt.keySet().iterator() ;
    	while(iter.hasNext()){
    		strE164 = (String)iter.next() ;
    		if( (strE164 = strE164.trim()).length()>0 ){
        		if(jsArray.length()==0)	jsArray.append("[{params:");
           		else					jsArray.append(",{params:");
        		
        		jsArray.append("[\""+strE164+"\",\""+listNewExt.get(strE164)+"\"]}");
           	}
    	}
    	if(jsArray.length()>0)	jsArray.append("]");
 %>
    <script>
        alert("변경되었습니다.");
        parent.goExtNumUpdateDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
        }
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}
%>
