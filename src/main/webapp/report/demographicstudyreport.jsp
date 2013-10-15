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
<%
	if(session.getAttribute("user") == null) response.sendRedirect("../logout.jsp");
	String curUser_no = (String) session.getAttribute("user");
	String deepcolor = "#CCCCFF", weakcolor = "#EEEEFF";
  
	String strLimit1="0";
	String strLimit2="20";  
	if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");  
	if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");
%>

<%@ page import="java.sql.*" errorPage="../errorpage.jsp"%>
<jsp:useBean id="reportMainBean" class="oscar.AppointmentMainBean"
	scope="page" />
<jsp:useBean id="providerBean" class="java.util.Properties"
	scope="session" />
<jsp:useBean id="studyBean" class="java.util.Properties" scope="page" />

<% 
	String [][] dbQueries=new String[][] { 
		{"search_study", "select study_no, study_name, description from study where current1 = ?"}, 
		{"search_demostudy", "select s.demographic_no, s.study_no, d.last_name , d.first_name, d.provider_no, d.email from demographicstudy s left join demographic d on s.demographic_no=d.demographic_no order by d.last_name"}, 
	};
	reportMainBean.doConfigure(dbQueries);
%>

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message key="report.demographicstudyreport.title" />
</title>
<!--link rel="stylesheet" href="../receptionist/receptionistapptstyle.css" -->
<script language="JavaScript">
<!--

//-->
</SCRIPT>
</head>

<body onLoad="setfocus()" topmargin="0" leftmargin="0" rightmargin="0">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="<%=deepcolor%>">
		<th><font face="Helvetica"><bean:message
			key="report.demographicstudyreport.msgTitle" /></font></th>
	</tr>
	<tr>
		<td align="right"><input type="button" name="Button"
			value="<bean:message key="global.btnPrint" />"
			onClick="window.print()"> <input type="button" name="Button"
			value="<bean:message key="global.btnCancel" />"
			onClick="window.close()"></td>
	</tr>
</table>

<table width="100%" border="0" bgcolor="white" cellspacing="2"
	cellpadding="2">
	<tr bgcolor='<%=deepcolor%>'>
		<TH width="20%" nowrap><bean:message
			key="report.reportpatientchartlist.msgLastName" /></TH>
		<TH width="20%"><bean:message
			key="report.reportpatientchartlist.msgFirstName" /></TH>
		<TH width="20%"><bean:message
			key="report.demographicstudyreport.msgStudy" /></TH>
		<TH width="20%">Email</TH>
		<TH><bean:message key="report.demographicstudyreport.msgProvider" /></TH>
	</tr>
	<%
	ResultSet rs=null ;
	rs = reportMainBean.queryResults("1", "search_study");
	while (rs.next()) { 
		studyBean.setProperty(reportMainBean.getString(rs,"study_no"), reportMainBean.getString(rs,"study_name") );
		studyBean.setProperty(reportMainBean.getString(rs,"study_no") + reportMainBean.getString(rs,"study_name"), reportMainBean.getString(rs,"description") );
	}
    
	//int[] itemp1 = new int[2];  //itemp1[0] = Integer.parseInt(strLimit1);

	int nItems=0;
	rs = reportMainBean.queryResults("search_demostudy");
	while (rs.next()) {
		nItems++; 
%>
	<tr bgcolor="<%=(nItems%2 == 0)?weakcolor:"white"%>">
		<td nowrap><a
			href="../demographic/demographiccontrol.jsp?demographic_no=<%=reportMainBean.getString(rs,"s.demographic_no")%>&displaymode=edit&dboperation=search_detail"><%=reportMainBean.getString(rs,"last_name")%></a></td>
		<td><%=reportMainBean.getString(rs,"d.first_name")%></td>
		<td
			title='<%=studyBean.getProperty(reportMainBean.getString(rs,"s.study_no")+studyBean.getProperty(reportMainBean.getString(rs,"s.study_no")), "")%>'><%=studyBean.getProperty(reportMainBean.getString(rs,"s.study_no"), "")%></td>
		<td><%=reportMainBean.getString(rs,"d.email")%></td>
		<td><%=providerBean.getProperty(reportMainBean.getString(rs,"d.provider_no"), "")%></td>
	</tr>
	<%
	}
%>
</table>
<br>
<%
	int nLastPage=0,nNextPage=0;
	nNextPage=Integer.parseInt(strLimit2)+Integer.parseInt(strLimit1);
	nLastPage=Integer.parseInt(strLimit1)-Integer.parseInt(strLimit2);
	if(nLastPage>=0) {
%>
<a
	href="demographicstudyreport.jsp?limit1=<%=nLastPage%>&limit2=<%=strLimit2%>"><bean:message
	key="report.reportactivepatientlist.msgLastPage" /></a>
|
<%
	}
	if(nItems==Integer.parseInt(strLimit2)) {
%>
<a
	href="demographicstudyreport.jsp?limit1=<%=nNextPage%>&limit2=<%=strLimit2%>">
<bean:message key="report.reportactivepatientlist.msgNextPage" /></a>
<%
	}
%>
</body>
</html:html>
