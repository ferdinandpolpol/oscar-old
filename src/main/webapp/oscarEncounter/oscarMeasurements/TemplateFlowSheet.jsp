<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada

--%>
<%long startTime = System.currentTimeMillis();%>
<%@page import="oscar.oscarRx.data.RxPatientData"%>
<%@page  import="oscar.oscarDemographic.data.*,java.util.*,oscar.oscarPrevention.*,oscar.oscarEncounter.oscarMeasurements.*,oscar.oscarEncounter.oscarMeasurements.bean.*,java.net.*"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils,oscar.log.*"%>
<%@page import="org.springframework.web.context.WebApplicationContext,oscar.oscarResearch.oscarDxResearch.bean.*"%>
<%@page import="org.oscarehr.common.dao.FlowSheetCustomizationDao,org.oscarehr.common.model.FlowSheetCustomization"%>
<%@page import="org.oscarehr.common.dao.FlowSheetDrugDao,org.oscarehr.common.dao.FlowSheetDxDao,org.oscarehr.common.model.FlowSheetDrug,org.oscarehr.util.MiscUtils"%>
<%@page import="org.oscarehr.caisi_integrator.ws.CachedMeasurement,org.oscarehr.PMmodule.caisi_integrator.CaisiIntegratorManager,org.oscarehr.util.LoggedInInfo" %>
<%@page import="oscar.util.UtilDateUtilities" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/oscar-tag.tld" prefix="oscar" %>
<%@ taglib uri="/WEB-INF/rewrite-tag.tld" prefix="rewrite" %>
<%@ taglib uri="/WEB-INF/security.tld" prefix="security"%>
<%@page import="oscar.OscarProperties"%>

<%
	if(session.getValue("user") == null) response.sendRedirect("../../logout.jsp");
    //int demographic_no = Integer.parseInt(request.getParameter("demographic_no"));
    if(session.getAttribute("userrole") == null )  response.sendRedirect("../logout.jsp");
    String roleName$ = (String)session.getAttribute("userrole") + "," + (String) session.getAttribute("user");
    String demographic_no = request.getParameter("demographic_no");
    String providerNo = (String) session.getAttribute("user");
    String temp = request.getParameter("template");
%>
<oscar:oscarPropertiesCheck property="SPEC3" value="yes">
    <security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="r" reverse="<%=true%>">
        "You have no right to access this page!"
        <%
    	LogAction.addLog((String) session.getAttribute("user"), LogConst.NORIGHT+LogConst.READ, LogConst.CON_FLOWSHEET,  temp , request.getRemoteAddr(),demographic_no);
            response.sendRedirect("../../noRights.html");
    %>
    </security:oscarSec>
</oscar:oscarPropertiesCheck>

<%
	if (OscarProperties.getInstance().getBooleanProperty("new_flowsheet_enabled", "true")) {
%>
	<%
		if (temp.equals("diab3")) {
	%>
		<jsp:forward page="DiabFlowSheet.jsp" />
	<%
		} else if (request.getAttribute("temp") != null && request.getAttribute("temp").equals("diab3")) {
	%>
		<jsp:forward page="DiabFlowSheet.jsp" />
	<%
		}
	%>
<%
	}
%>

<%
	LogAction.addLog((String) session.getAttribute("user"), LogConst.READ, LogConst.CON_FLOWSHEET,  temp , request.getRemoteAddr(),demographic_no);


    int numElementsToShow = 4;
    Date sdate = null;
    Date edate = null;
    if ( request.getParameter("numEle") != null ){
        try{
            numElementsToShow = Integer.parseInt(request.getParameter("numEle"));
        }catch(Exception e){}
    }

    if (request.getParameter("sdate") != null){
        try{
           sdate = oscar.util.UtilDateUtilities.StringToDate(request.getParameter("sdate"));
        }catch(Exception e){sdate =null;}
    }

    if(request.getParameter("edate") != null){
        try{
           edate = oscar.util.UtilDateUtilities.StringToDate(request.getParameter("edate"));
        }catch(Exception e){edate = null;}
    }


    long startTimeToGetP = System.currentTimeMillis();

    boolean dsProblems = false;


    WebApplicationContext ctx = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());

    FlowSheetCustomizationDao flowSheetCustomizationDao = (FlowSheetCustomizationDao) ctx.getBean("flowSheetCustomizationDao");
    FlowSheetDrugDao flowSheetDrugDao = (FlowSheetDrugDao) ctx.getBean("flowSheetDrugDao");
	FlowSheetDxDao flowSheetDxDao = (FlowSheetDxDao) ctx.getBean("flowSheetDxDao");
    List<FlowSheetCustomization> custList = flowSheetCustomizationDao.getFlowSheetCustomizations( temp,(String) session.getAttribute("user"),demographic_no);

    ////Start
    MeasurementTemplateFlowSheetConfig templateConfig = MeasurementTemplateFlowSheetConfig.getInstance();


    MeasurementFlowSheet mFlowsheet = templateConfig.getFlowSheet(temp,custList);

    MeasurementInfo mi = new MeasurementInfo(demographic_no);
    List<String> measurementLs = mFlowsheet.getMeasurementList();
    ArrayList<String> measurements = new ArrayList(measurementLs);
    long startTimeToGetM = System.currentTimeMillis();

    mi.getMeasurements(measurements);

    try{
    	mFlowsheet.getMessages(mi);
    }catch(Exception e){
    	MiscUtils.getLogger().error("Error getting messages for flowsheet ",e);
    }


    ArrayList recList = mi.getList();



    mFlowsheet.sortToCurrentOrder(recList);
    StringBuffer recListBuffer = new StringBuffer();
    for(int i = 0; i < recList.size(); i++){
        recListBuffer.append("&amp;measurement="+response.encodeURL( (String) recList.get(i)));
    }


    String flowSheet = mFlowsheet.getDisplayName();
    ArrayList<String> warnings = mi.getWarnings();
    ArrayList<String> recomendations = mi.getRecommendations();
    ArrayList comments = new ArrayList();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html:html locale="true">

<head>
<title><%=flowSheet%> - <oscar:nameage demographicNo="<%=demographic_no%>"/></title><!--I18n-->
<link rel="stylesheet" type="text/css" href="../../share/css/OscarStandardLayout.css" />
<script type="text/javascript" src="../../share/javascript/Oscar.js"></script>
<script type="text/javascript" src="../../share/javascript/prototype.js"></script>

<style type="text/css">
    div.ImmSet { background-color: #ffffff;clear:left;margin-top:10px;}
    div.ImmSet h2 {  }
    div.ImmSet h2 span { font-size:smaller; }
    div.ImmSet ul {  }
    div.ImmSet li {  }
    div.ImmSet li a { text-decoration:none; color:blue;}
    div.ImmSet li a:hover { text-decoration:none; color:red; }
    div.ImmSet li a:visited { text-decoration:none; color:blue;}

    /*h3{font-size: 100%;margin:0 0 10px;padding: 2px 0;color: #497B7B;text-align: center}*/

</style>

<style type="text/css" media="print">
.DoNotPrint {
	display: none;
}

.noborder{
    border: 0px solid #FFF;
}



div.headPrevention {
    position:relative;
    margin-left:1px;
    width:22em;
    /*height:2.9em;*/
}

div.headPrevention a:active { color:black; }
div.headPrevention a:hover { color:black; }
div.headPrevention a:link { color:black; }
div.headPrevention a:visited { color:black; }
</style>
<style type="text/css" media="screen">
    .DoNotScreen{ display:none;}

    div.headPrevention {
    position:relative;
    float:left;
    width:12em;
    /*height:2.9em;*/
}


div.headPrevention a:active { color:black; }
div.headPrevention a:hover { color:black; }
div.headPrevention a:link { color:black; }
div.headPrevention a:visited { color:black; }

div.headPrevention p {
    background: #ddddff;
    font-family: verdana,tahoma,sans-serif;
    margin:0;

    padding: 4px 4px;
    line-height: 1.2;
/*text-align: justify;*/
    height:2em;
    font-family: sans-serif;
}


</style>

<link rel="stylesheet" type="text/css" href="../../share/css/niftyCorners.css" />
<link rel="stylesheet" type="text/css" href="../../share/css/niftyPrint.css" media="print" />
<script type="text/javascript" src="../../share/javascript/nifty.js"></script>

<script type="text/javascript">
    window.onload=function(){
        if(!NiftyCheck())
            return;

//Rounded("div.news","all","transparent","#FFF","small border #999");
        Rounded("div.headPrevention","all","#CCF","#efeadc","small border blue");
        Rounded("div.preventionProcedure","all","transparent","#F0F0E7","small border #999");

//Rounded("span.footnote","all","transparent","#F0F0E7","small border #999");

        Rounded("div.leftBox","top","transparent","#CCCCFF","small border #ccccff");
        Rounded("div.leftBox","bottom","transparent","#EEEEFF","small border #ccccff");

    }


   function loadDifferentElements(){
       //console.log("hapy");
        var numEle = $('numEle').value;
        var sdate = $('flowsheetStartDate').value;
        var edate = $('flowsheetEndDate').value;
        if( !numEle.blank()){
            window.location = 'TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>&numEle='+numEle;
            //console.log("one");
        }else if (!sdate.blank() && !edate.blank()){
            window.location = 'TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>&sdate='+sdate+'&edate='+edate;
            //console.log("two");
        }else{
            window.location = 'TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>';
        }

    }


    function fsPopup(width,height,url,window) {
    	<%
    		com.quatro.service.security.SecurityManager securityMgr = new com.quatro.service.security.SecurityManager();
    		if(securityMgr.hasWriteAccess("_flowsheet."+mFlowsheet.getName(),roleName$)) {
    	%>

    	return popup(width,height,url,window);
    	<%}%>
    }
</script>


<style type="text/css">
body {font-size:100%}


div.leftBox{
    width:90%;
    margin-top: 2px;
    margin-left:3px;
    margin-right:3px;
    float: left;
}

span.footnote {
    background-color: #ccccee;
    border: 1px solid #000;
    width: 4px;
}

div.leftBox h3 {
    background-color: #ccccff;
/*font-size: 1.25em;*/
    font-size: 8pt;
    font-variant:small-caps;
    font-weight:bold;
    margin-top:0px;
    padding-top:0px;
    margin-bottom:0px;
    padding-bottom:0px;
}

div.leftBox ul{
/*border-top: 1px solid #F11;*/
/*border-bottom: 1px solid #F11;*/
    font-size: 1.0em;
    list-style:none;
    list-style-type:none;
    list-style-position:outside;
    padding-left:1px;
    margin-left:1px;
    margin-top:0px;
    padding-top:1px;
    margin-bottom:0px;
    padding-bottom:0px;
}

div.leftBox li {
    padding-right: 15px;
    white-space: nowrap;
}

<%--
div.headPrevention {
    position:relative;
    float:left;
    width:12em;
    height:2.9em;
}

div.headPrevention p {
    background: #ddddff;
    font-family: verdana,tahoma,sans-serif;
    margin:0;

    padding: 4px 4px;
    line-height: 1.2;
/*text-align: justify;*/
    height:2em;
    font-family: sans-serif;
}
--%>
div.headPrevention a {
    text-decoration:none;
}
<%--
div.headPrevention a:active { color:blue; }
div.headPrevention a:hover { color:blue; }
div.headPrevention a:link { color:blue; }
div.headPrevention a:visited { color:blue; }
--%>

div.preventionProcedure{
    width:9em;
    float:left;
    margin-left:3px;
    margin-bottom:3px;
}

div.preventionProcedure p {
    font-size: 0.8em;
    font-family: verdana,tahoma,sans-serif;
    background: #F0F0E7;
    margin:0;
    padding: 1px 2px;
/*line-height: 1.3;*/
/*text-align: justify*/
}

div.preventionSection {
    width: 100%;
    position:relative;
    margin-top:5px;
    float:left;
    clear:left;
}

div.preventionSet {
    border: thin solid grey;
    clear:left;
}

div.recommendations{
    font-family: verdana,tahoma,sans-serif;
    font-size: 1.2em;
}

div.recommendations ul{
    padding-left:15px;
    margin-left:1px;
    margin-top:0px;
    padding-top:1px;
    margin-bottom:0px;
    padding-bottom:0px;
}

div.recommendations li{

}



</style>

</head>

<body class="BodyStyle" >
<!--  -->
<table  class="MainTable" id="scrollNumber1" >
<tr class="MainTableTopRow">
    <td class="MainTableTopRowLeftColumn"  >
        <%=flowSheet%>
    </td>
    <td class="MainTableTopRowRightColumn">
        <table class="TopStatusBar" cellpadding="2">
            <tr>
                <td colspan="3">
                    <oscar:nameage demographicNo="<%=demographic_no%>"/>
                    <oscar:oscarPropertiesCheck property="SPEC3" value="yes">
                    <span class="DoNotPrint">
                    <security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="x">
                    <a href="adminFlowsheet/EditFlowsheet.jsp?flowsheet=<%=temp%>&demographic=<%=demographic_no%>" target="_new">Edit</a>
                    &nbsp;
                    </security:oscarSec>
                    <a href="TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>&show=lastOnly">Last Only</a>
                    &nbsp;
                    <a href="TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>&show=outOfRange">Only out of Range</a>
                    &nbsp;
                    <a href="TemplateFlowSheet.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>">All</a>
                    &nbsp;
                    <a href="TemplateFlowSheetPrint.jsp?demographic_no=<%=demographic_no%>&template=<%=temp%>">Custom Print</a>
                  </span>
                </td>
             </tr>
             <tr>
             	<td>
               		<span class="DoNotPrint">
                    #Of Elements <input type="text" size="3" id="numEle"/>

                    Start Date <input type="text" size="10" id="flowsheetStartDate" />
                    End Date <input type="text" size="10"id="flowsheetEndDate"/>
                    <input type="button" value="go" onclick="javascript: loadDifferentElements()"/>
                    </span>
                    </oscar:oscarPropertiesCheck>
                </td>
                <td>
                &nbsp;
                </td>
                <td style="text-align:right" valign="bottom">
                    <oscar:help keywords="measurement" key="app.top1"/> | <a href="javascript:popupStart(300,400,'About.jsp')" ><bean:message key="global.about" /></a> | <a href="javascript:popupStart(300,400,'License.jsp')" ><bean:message key="global.license" /></a>
                </td>
            </tr>
        </table>
    </td>
</tr>
<tr>
<td class="MainTableLeftColumn" valign="top">
	<security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
    <% if (recList.size() > 0){ %>
    <p><a class="DoNotPrint" href="javascript: function myFunction() {return false; }"  onclick="javascript:createAddAll(<%=demographic_no%>, '<%= URLEncoder.encode(temp,"UTF-8") %>', <%=Math.abs( "ADDTHEMALL".hashCode() ) %>)" TITLE="Add all measurements.">
	    Add All
	</a> </p>
    <p><a class="DoNotPrint" href="javascript: function myFunction() {return false; }"  onclick="javascript:fsPopup(760,670,'AddMeasurementData.jsp?demographic_no=<%=demographic_no%><%=recListBuffer.toString()%>&amp;template=<%=temp%>','addMeasurementData<%=Math.abs( "ADDTHEMALL".hashCode() ) %>')" TITLE="Add all overdue measurements.">
        Add Overdue
    </a></p>
    <%}%>
    </security:oscarSec>
    <!-- only show disease registry and prescriptions for flowsheets which aren't medical in nature -->
    <% if (mFlowsheet.isMedical()) {%>
    <div class="leftBox">
        <h3>&nbsp;Current Patients Dx List  <a class="DoNotPrint"  href="#" onclick="Element.toggle('dxFullListing'); return false;" style="font-size:x-small;" >show/hide</a></h3>
        <div class="wrapper" id="dxFullListing"  >
            <ul>
            <%

                dxResearchBeanHandler dxResearchBeanHand = new dxResearchBeanHandler(demographic_no);
                Vector patientDx = dxResearchBeanHand.getDxResearchBeanVector();

                int lim =15;
                for ( int i = 0; i < patientDx.size(); i++){
                    dxResearchBean code = (dxResearchBean)patientDx.get(i);  // code.getEnd_date() code.getStart_date()
                    String desc = code.getDescription();
                    desc = org.apache.commons.lang.StringUtils.abbreviate(desc,lim) ;
                    HashMap<String,String> dxMap = flowSheetDxDao.getFlowSheetDxMap( temp, demographic_no);

                    String pDx = dxMap.get(code.getType()+""+code.getDxSearchCode());

            %>
            <li>
                <oscar:oscarPropertiesCheck property="SPEC3" value="yes">
                    <% if (pDx == null){ %>
                     <a href="FlowSheetDrugAction.do?method=dxSave&flowsheet=<%=temp%>&demographic=<%=demographic_no%>&dxCode=<%=code.getDxSearchCode()%>&dxCodeType=<%=code.getType()%>">
                    <%}else{%>
                     <span title="<%=code.getDescription()%>"  style="background-color: yellow;">
                    <%}%>
                </oscar:oscarPropertiesCheck>
                - <%=desc%>
                <oscar:oscarPropertiesCheck property="SPEC3" value="yes">
                    <% if (pDx == null){ %>
                     </a>
                    <%}else{%>
                     </span>
                    <%}%>
                </oscar:oscarPropertiesCheck>
            </li>
            <%  }%>
            </ul>
        </div>
    </div>

    <security:oscarSec roleName="<%=roleName$%>" objectName="_rx" rights="r"  >
        <div class="leftBox">
            <h3>&nbsp;Current Patient Rx List  <a class="DoNotPrint" href="#" onclick="Element.toggle('rxFullListing'); return false;" style="font-size:x-small;" >show/hide</a></h3>
            <div class="wrapper" id="rxFullListing"  >

                <%
                    oscar.oscarRx.data.RxPrescriptionData prescriptData = new oscar.oscarRx.data.RxPrescriptionData();
                    oscar.oscarRx.data.RxPrescriptionData.Prescription [] arr = {};
                    arr = prescriptData.getUniquePrescriptionsByPatient(Integer.parseInt(demographic_no));
                    if (arr.length > 0){%>
                <ul>
                    <%for (int i = 0; i < arr.length; i++){
                        String rxD = arr[i].getRxDate().toString();
                        //String rxP = arr[i].getRxDisplay();
                        String rxP = arr[i].getFullOutLine().replaceAll(";"," ");
                        rxP = rxP + "   " + arr[i].getEndDate();
                        String styleColor = "";
                        if(arr[i].isCurrent()){
                    %>
                    <li title="<%=rxD%> - <%=rxP%>">
                        <oscar:oscarPropertiesCheck property="SPEC3" value="yes">
                            <a href="FlowSheetDrugAction.do?method=save&flowsheet=<%=temp%>&demographic=<%=demographic_no%>&atcCode=<%=arr[i].getAtcCode()%>">
                            </oscar:oscarPropertiesCheck>
                            - <%= org.apache.commons.lang.StringUtils.abbreviate(rxP, 12)%>
                            <oscar:oscarPropertiesCheck property="SPEC3" value="yes">
                            </a>
                        </oscar:oscarPropertiesCheck>
                    </li>
                    <%  }
                    }%>
                </ul>
                <%}%>



            </div>
        </div>



         <div class="leftBox">
            <h3>&nbsp;Current Patient Allergy List  <a class="DoNotPrint" href="#" onclick="Element.toggle('allergFullListing'); return false;" style="font-size:x-small;" >show/hide</a></h3>
            <div class="wrapper" id="allergFullListing"  >

                <%
			org.oscarehr.common.model.Allergy[] allergies;
                    allergies = RxPatientData.getPatient(Integer.parseInt(demographic_no)).getActiveAllergies();

// oscar.oscarRx.data.RxPatientData.Patient.Allergy[] allergies;
//                    allergies = oscar.oscarRx.data.RxPatientData().getPatient(Integer.parseInt(demographic_no)).getAllergies();

                    if (allergies.length > 0){%>
                <ul>
                    <%for (int i = 0; i < allergies.length; i++){
                        String rxD = ""+allergies[i].getEntryDate();
                        String rxP = allergies[i].getDescription();
                    %>
                    <li title="<%=rxD%> - <%=rxP%>">
                            - <%= org.apache.commons.lang.StringUtils.abbreviate(rxP, 12)%>
                    </li>
                    <%}%>
                </ul>
                <%}%>
            </div>
        </div>


    </security:oscarSec>
    <% } %>
<div>
   <input type="button" class="DoNotPrint" value="Print" onclick="javascript:window.print()">
</div>
</td>

<td valign="top" class="MainTableRightColumn">
<% if (warnings.size() > 0 || recomendations.size() > 0  || dsProblems) { %>
<div class="recommendations">
    <span style="font-size:larger;"><%=flowSheet%> Recommendations</span>
    <a href="#" onclick="Element.toggle('recomList'); return false;" style="font-size:x-small;" >show/hide</a>
    <ul id="recomList" style="display:none;">
        <% for (String warn : warnings){ %>
        <li style="color: red;"><%=warn%></li>
        <%}%>
        <% for (String warn : recomendations ){%>
        <li style="color: black;"><%=warn%></li>
        <%}%>
        <!--li style="color: red;">6 month TD overdue</li>
  <li>12 month MMR due in 2 months</li-->
        <% if (dsProblems){ %>
        <li style="color: red;">Decision Support Had Errors Running.</li>
        <% } %>
    </ul>
</div>
<% } %>
<%=mFlowsheet.getTopHTMLStream() %>
<%--
<img src="../../oscarEncounter/GraphMeasurements.do?demographic_no=<%=demographic_no%>&type=INR&type2=COUM"/>
<br/>
--%>
<div >
<%
	//set add link array
	String[] addAllLink = new String[measurements.size()];
	int mCount=0;

    EctMeasurementTypeBeanHandler mType = new EctMeasurementTypeBeanHandler();
    long startTimeToLoopAndPrint = System.currentTimeMillis();
    for (String measure:measurements){
        Map h2 = mFlowsheet.getMeasurementFlowSheetInfo(measure);
        FlowSheetItem item =  mFlowsheet.getFlowSheetItem(measure);

        String hidden= "";
        if (item.isHide()){
            hidden= "display:none;";
        }

        if (h2.get("measurement_type") != null ){
            Hashtable h = new Hashtable();
            EctMeasurementTypesBean mtypeBean = mType.getMeasurementType(measure);//mFlowsheet.getMeasurementInfo(measure);

            if(mtypeBean!=null) {
                h.put("name",mtypeBean.getTypeDisplayName());
                h.put("desc",mtypeBean.getTypeDesc());



            }
            String prevName = (String) h.get("name");
            ArrayList<EctMeasurementsDataBean> alist = mi.getMeasurementData(measure);
            if (LoggedInInfo.loggedInInfo.get().currentFacility.isIntegratorEnabled()) {
               EctMeasurementsDataBeanHandler.addRemoteMeasurements(alist,measure,Integer.parseInt(demographic_no));
            }
            String extraColour = "";
            if(mi.hasRecommendation(measure)){
                extraColour = "style=\"background-color: "+mFlowsheet.getRecommendationColour()+"\" ";
            }else if(mi.hasWarning(measure)){
                extraColour = "style=\"background-color: "+mFlowsheet.getWarningColour()+"\" ";
            }
            //measurement_type="EDGI"
            //display_name="Autonomic Neuropathy"
            //guideline="Erectile Dysfunction, hastrointestinal disturbance"
            //graphable="no"
            //value_name="Answer"
%>
<div class="preventionSection"  style="overflow: auto;<%=hidden%>" nowrap>
    <div class="headPrevention">

        <p class="noborder" <%=extraColour%> title="fade=[on] header=[<%=h2.get("display_name")%>] body=[<%=wrapWithSpanIfNotNull(mi.getWarning(measure),"red")%><%=wrapWithSpanIfNotNull(mi.getRecommendation(measure),"red")%><%=h2.get("guideline")%>]"   >
            <%if(h2.get("graphable") != null && ((String) h2.get("graphable")).equals("yes")){%>
            <%if (alist != null && alist.size() > 1) { %>
               <img class="DoNotPrint" src="img/chart.gif" alt="Plot"  onclick="window.open('../../oscarEncounter/GraphMeasurements.do?demographic_no=<%=demographic_no%>&type=<%=measure%>');"/>
            <%}else{%>
               <img class="DoNotPrint" src="img/chart.gif" alt="Plot"/>
            <%}%>
           <%}%>

		   <security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
            <a class="noborder" href="javascript: function myFunction() {return false; }"  onclick="javascript:fsPopup(760,670,'AddMeasurementData.jsp?measurement=<%= response.encodeURL( measure) %>&amp;demographic_no=<%=demographic_no%>&amp;template=<%= URLEncoder.encode(temp,"UTF-8") %>','addMeasurementData<%=Math.abs( ((String) h.get("name")).hashCode() ) %>')">
           </security:oscarSec>
                <span  class="noborder" style="font-weight:bold;"><%=h2.get("display_name")%></span>

           <security:oscarSec roleName="<%=roleName$%>" objectName="_flowsheet" rights="w">
            </a>
			</security:oscarSec>

        </p>
    </div>
    <%  int k = 0;
        for (EctMeasurementsDataBean mdb:alist){
            k++;
            mFlowsheet.runRulesForMeasurement(mdb);
            Hashtable hdata = new Hashtable();//(Hashtable) alist.get(k);
            hdata.put("age",mdb.getDataField());
            hdata.put("prevention_date",UtilDateUtilities.DateToString(mdb.getDateObservedAsDate()));
            hdata.put("id",""+mdb.getId());
            String com = mdb.getComments();
            boolean comb = false;
            if (com != null && !com.trim().equals("")){
                comments.add(com);
                comb = true;
            }else{
                com ="";
            }
            String hider = "";

            int num =numElementsToShow;
            if (request.getParameter("show") !=null && request.getParameter("show").equals("lastOnly")){
                num =1;
            }
            if(sdate != null && edate != null){
                Date itDate = mdb.getDateObservedAsDate();
                if (itDate.before(sdate) || itDate.after(edate)){
                        hider = "style=\"display:none\"";
                }
            }else if ( k > num){
                hider = "style=\"display:none;\"";
            }

            String indColour = "";
            if ( mdb.getIndicationColour() != null ){
                indColour = "style=\"background-color:"+mFlowsheet.getIndicatorColour(mdb.getIndicationColour())+"\"";
            }

            if (request.getParameter("show") !=null && request.getParameter("show").equals("outOfRange") && indColour.equals("")){
                hider = "style=\"display:none;\"";
            }

    %>
    <div class="preventionProcedure" <%=hider%>  
    <%if(mdb.getRemoteFacility() == null){ %>
    onclick="javascript:fsPopup(760,670,'AddMeasurementData.jsp?measurement=<%= response.encodeURL( measure) %>&amp;id=<%=hdata.get("id")%>&amp;demographic_no=<%=demographic_no%>&amp;template=<%= URLEncoder.encode(temp,"UTF-8") %>','addMeasurementData')" 
    <%}%>
    >
        <p <%=indColour%> title="fade=[on] header=[<%=hdata.get("age")%> -- Date:<%=hdata.get("prevention_date")%>] body=[<%=com%>&lt;br/&gt;Entered By:<%=mdb.getProviderFirstName()%> <%=mdb.getProviderLastName()%>]"><%=h2.get("value_name")%>: <%=hdata.get("age")%> <br/>
            <%=hdata.get("prevention_date")%>&nbsp;<%=mdb.getNumMonthSinceObserved()%>M
            <%if (comb) {%>
            <span class="footnote"><%=comments.size()%></span>
            <%}%>
           <%=getFromFacilityMsg(mdb) %> 
        </p>
    </div>
    <%}%>
</div>
<%
	//creating add all link array
	addAllLink[mCount]=measure;
	mCount++;

    }else{
    String prevType = (String) h2.get("prevention_type");
    long startPrevType = System.currentTimeMillis();
    ArrayList<Map<String,Object>> alist = PreventionData.getPreventionData(prevType, demographic_no);
%>


<div class="preventionSection" style="<%=hidden%>" >
    <div class="headPrevention">
        <p title="fade=[on] header=[<%=h2.get("display_name")%>] body=[<%=wrapWithSpanIfNotNull(mi.getWarning(measure),"red")%><%=wrapWithSpanIfNotNull(mi.getRecommendation(measure),"red")%><%=h2.get("guideline")%>]">
            <a href="javascript: function myFunction() {return false; }"  onclick="javascript:fsPopup(465,635,'../../oscarPrevention/AddPreventionData.jsp?prevention=<%= response.encodeURL( prevType) %>&amp;demographic_no=<%=demographic_no%>','addPreventionData<%=Math.abs( prevType.hashCode() ) %>')">
                <span title="<%=h2.get("guideline")%>" style="font-weight:bold;"><%=h2.get("display_name")%></span>
            </a>
            &nbsp;

            <br/>
        </p>
    </div>
    <%
        out.flush();
        for (int k = 0; k < alist.size(); k++){
      	  	Map<String,Object> hdata = alist.get(k);
            String com = PreventionData.getPreventionComment(""+hdata.get("id"));
            boolean comb = false;
            if (com != null ){
                comments.add(com);
                comb = true;
            }else{
                com ="";
            }
    %>
    <div class="preventionProcedure"  onclick="javascript:fsPopup(465,635,'../../oscarPrevention/AddPreventionData.jsp?id=<%=hdata.get("id")%>&amp;demographic_no=<%=demographic_no%>','addPreventionData')" >
        <p <%=r(hdata.get("refused"))%> title="fade=[on] header=[<%=hdata.get("age")%> -- Date:<%=hdata.get("prevention_date")%>] body=[<%=com%>]" >Age: <%=hdata.get("age")%> <br/>
            <!--<%=refused(hdata.get("refused"))%>-->Date: <%=hdata.get("prevention_date")%>
            <%if (comb) {%>
            <span class="footnote"><%=comments.size()%></span>
            <%}%>
        </p>
    </div>
    <%}%>
</div>

<%
	}

}
%>

<script language="javascript">
function createAddAll(d,t,h){

	//most likely will remove this and create qs above to account for prevention
	var newMtype;
	newMtype='<%for(int i=0;i<mCount;i++){
   				out.print("&measurement="+ addAllLink[i]);
   				}%>';

	return fsPopup(760,670,'AddMeasurementData.jsp?demographic_no='+d+'&template='+t+newMtype,'addMeasurementData'+h);
}
</script>

<%
    oscar.oscarRx.data.RxPrescriptionData prescriptData = new oscar.oscarRx.data.RxPrescriptionData();
    oscar.oscarRx.data.RxPrescriptionData.Prescription [] arr = {};

    List<FlowSheetDrug> atcCodes = flowSheetDrugDao.getFlowSheetDrugs(temp,demographic_no);
    for(FlowSheetDrug fsd : atcCodes){
            arr = prescriptData.getPrescriptionScriptsByPatientATC(Integer.parseInt(demographic_no),fsd.getAtcCode());

%>

<div class="preventionSection"  >
    <div class="headPrevention">
        <p title="fade=[on] header=[ddddd] body=[ddddddddsdfsdf]">
            <!-- a href="javascript: function myFunction() {return false; }"  -->
                <span title="dd" style="font-weight:bold;"><%=arr[0].getGenericName()%></span>
            <!-- /a -->
            &nbsp;
            <br/>
        </p>
    </div>
    <%
        out.flush();
        for (oscar.oscarRx.data.RxPrescriptionData.Prescription pres : arr){
    %>
    <div class="preventionProcedure"  onclick="javascript:fsPopup(465,635,'','addPreventionData')" >
        <p <%=""/*r(hdata.get("refused"))*/%> title="fade=[on] header=[<%=""/*hdata.get("age")*/%> -- Date:<%=""/*hdata.get("prevention_date")*/%>] body=[<%=""/*com*/%>]" ><%=pres.getBrandName()%> <br/>
            Date: <%=pres.getRxDate()%>
            <%-- if (comb) {%>
            <span class="footnote"><%=comments.size()%></span>
            <%} --%>
        </p>
    </div>
    <%}%>
</div>

<%}%>

</div>
<br style="clear:left;"/>
<div style="margin-top: 20px;">
    <h3>Comments</h3>
    <ol>
        <% for (int i = 0; i < comments.size(); i++){
            String str = (String) comments.get(i);
        %>
        <li><%=str%></li>
        <% }%>
    </ol>
</div>
</td>
</tr>
<tr>
    <td class="MainTableBottomRowLeftColumn">
        &nbsp;
    </td>
    <td class="MainTableBottomRowRightColumn" valign="top">
        &nbsp;
    </td>
</tr>
</table>
<script type="text/javascript" src="../../share/javascript/boxover.js"></script>
</body>
</html:html>

<%!String refused(Object re){
        String ret = "Given";
        if (re instanceof java.lang.String){

            if (re != null && re.equals("1")){
                ret = "Refused";
            }
        }
        return ret;
    }
    String r(Object re){
        String ret = "";
        if (re instanceof java.lang.String){
            if (re != null && re.equals("1")){
                ret = "style=\"background: #FFDDDD;\"";
            }else if(re !=null && re.equals("2")){
                ret = "style=\"background: #FFCC24;\"";
            }
        }
        return ret;
    }
    String wrapWithSpanIfNotNull(String s,String colour){
        String ret = "";
        String q = "\"";
        if (s != null){
            ret = "<span style='color:"+colour+"'>"+s+"</span> </br>";
        }
        return ret;
    }

    public void printOutStringLists(List<String> measurements){
       for (String measurement : measurements){

       }
    }
    
    
    public String getFromFacilityMsg(EctMeasurementsDataBean emdb){
		if (emdb.getRemoteFacility()!=null)	return("<br /><span style=\"color:#990000\">(At facility : "+emdb.getRemoteFacility()+")<span>");
		else return("");
	}
    
    
    
    
    %>
