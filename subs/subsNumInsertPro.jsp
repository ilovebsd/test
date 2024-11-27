<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*"%>
<%@ page import="com.acromate.dao.element.ConditionalReplaceDAO"%>
<%@ page import="com.acromate.dto.element.ConditionalReplaceDTO"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

 // startnum --> areanum, localnum
 // table_featureservice 5282 inouflag
 //
 
String grpid        = StringUtil.null2Str(request.getParameter("groupid"),"").trim();

String domainid     = "";//StringUtil.null2Str(request.getParameter("domainid"),"");
String areanum     	= StringUtil.null2Str(request.getParameter("areanum"),"").trim();
String localnum   	= StringUtil.null2Str(request.getParameter("localnum"),"").trim();
String extnum       = StringUtil.null2Str(request.getParameter("extnum"),"").trim();
String authpasswd   = StringUtil.null2Str(request.getParameter("authpasswd"),"").trim();
String createcount  = StringUtil.null2Str(request.getParameter("createcount"),"").trim();

String extensiongroupnum = null;

StringBuffer jsArray = new StringBuffer();
ArrayList               envList = null;
// 서버로부터 DataStatement 객체를 할당
DataStatement   stmt = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
        stmt                    = ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //처리부분
    CommonDAO dao = new CommonDAO();
    envList = dao.select(stmt, "select extensiongroupnum, domain from Table_subscriberGroup where extensiongroupnum like '%*%' AND checkgroupid='"+grpid+"'", new String[]{"extensiongroupnum","domain"} ) ;
    if( envList.size() > 0 ){
        HashMap item = (HashMap)envList.get(0);
        extensiongroupnum = (String)item.get("extensiongroupnum") ;
        domainid = (String)item.get("domain") ;
    }
    
    StringBuffer sql = new StringBuffer();    
    int count = 0 ;
    /** Phone-Number **/
    String number = "1" + extnum ;
    int extnumLength = extnum.length() ;
    int nPlus = Str.CheckNullInt( number ) ;
    int nCount = Str.CheckNullInt( createcount ) + nPlus;
    String tailDomain = domainid.length()>0 ? "@"+domainid+":5060" : "@vpbx.callbox.kt.com:5060" ;
    while(nPlus < nCount){
    	extnum = String.valueOf(nPlus).substring(1) ;
        String phoneNumber = areanum + localnum + extnum ;
    	String endpointID = phoneNumber+tailDomain;//"@vpbx.callbox.kt.com:5060" ;
 
        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164 (e164, VirtualCID, areacode, isgroup, groupid, extensionnumber, prefixtableid, startflag, chargetype, endpointrelationtype, callerservice, answerservice, commonservice, subid,mailbox, checkgroupid) ") ;
        sql.append("VALUES ('"+phoneNumber+"', '"+phoneNumber+"', '"+areanum+"', 2, '"+grpid+"', '"+extnum+"', '', 1, 0, 2, '0000000000000000000000000000000000000000000000000000000000000000', '0000000000000000000000000000000000000000000000000000000000000000', '01010000000000000000000000000000', '"+grpid+"', '', '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+phoneNumber+"', '"+phoneNumber+"', 2, '"+endpointID+"', 1, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+ localnum + extnum +"', '"+phoneNumber+"', 2, '"+endpointID+"', 2, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+ extensiongroupnum + extnum +"', '"+phoneNumber+"', 2, '"+endpointID+"', 5, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        /* Endpoint ID */
        sql.setLength(0) ;
        sql.append("INSERT INTO table_SIPENDPOINT(EndpointID, EndpointClass, DomainID, DynamicFlag, ZoneCode, MultiEndpoint, DtmfType, OPTIONS, checkgroupid) ") ;
        sql.append("VALUES ('"+endpointID+"', 33, '"+domainid+"', 0, '', 0, 0, 0, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_auth (e164, protocol, endpointid, password, authmode, username, ipaddress, ipport, DESCRIPTOR, checkgroupid) ") ; 
        sql.append(" VALUES ('0', 2, '"+endpointID+"', '"+authpasswd+"', 128, '"+phoneNumber+"', '', 0, '', '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_subscriber (id, loginlevel, pwd, phonenum, name, POSITION, department, mobile, homenumber, extension, mailaddress, checkgroupid) ") ; 
        sql.append(" VALUES ('"+endpointID+"', 1, '"+authpasswd+"', '"+phoneNumber+"', '"+phoneNumber+"', '"+grpid+"', 3, '', '', '"+extnum+"', '', '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5282, 5282, '', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5031, 5031, 'default_moh.wav', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;//hc-add : 161103 : Virtual CID
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5431, 5431, '3,"+phoneNumber+",', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;

        nPlus++;
    }
    
    if( count > 0 ){
        jsArray.append("[{params:").append("[\""+grpid+"\",\""+extensiongroupnum+"\"]}");
//         jsArray.append(",{params:").append("[\"extensiongroupnum\",\""+extensiongroupnum+"\"]}");
        jsArray.append("]");
%>
    <script>
        alert("등록되었습니다.");
        parent.goNumInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./subsList.jsp";
    </script>
<%
    } else {
%>
    <script>
        alert("등록 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
        extensiongroupnum = "99999*";
        jsArray.append("[{params:").append("[\""+grpid+"\",\""+extensiongroupnum+"\"]}");
//         jsArray.append(",{params:").append("[\"extensiongroupnum\",\""+extensiongroupnum+"\"]}");
        jsArray.append("]"); 
 %>
    <script>
        alert("등록되었습니다.");
        parent.goNumInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
        }
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}
%>

