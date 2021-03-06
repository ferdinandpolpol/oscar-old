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

<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@page import="oscar.oscarSurveillance.*,java.util.*"%>



<%
SurveillanceMaster sMaster = SurveillanceMaster.getInstance();

%>

<html:html locale="true">



<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<html:base />
<title><bean:message key="oscarSurveillance.Surveillance.title" />
</title>
<link rel="stylesheet" type="text/css"
	href="../share/css/OscarStandardLayout.css">



<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />
</head>

<body class="BodyStyle" vlink="#0000FF">
<!--  -->
<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn"><bean:message
			key="oscarSurveillance.Surveillance.msgSurveillance" /></td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td>Current Surveys: <%=sMaster.numSurveys()%></td>
				<td>&nbsp;</td>
				<td style="text-align: right"><oscar:help keywords="survey" key="app.top1"/> | <a
					href="javascript:popupStart(300,400,'About.jsp')"><bean:message
					key="global.about" /></a> | <a
					href="javascript:popupStart(300,400,'License.jsp')"><bean:message
					key="global.license" /></a></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableLeftColumn" valign="top">&nbsp;</td>
		<td class="MainTableRightColumn">
		<table>
			<tr>
				<td style="text-align: center">Current surveys: <br />
				<% ArrayList list = sMaster.getCurrentSurveys();
                 for (int i = 0; i < list.size() ; i++){ 
                    Survey survey = (Survey) list.get(i);%> <a
					href="ReportSurvey.jsp?surveyId=<%=survey.getSurveyId()%>"> <%=survey.getSurveyTitle()%>
				</a> &nbsp; </br>

				<%}%>
				</td>
			</tr>
			<tr>
				<td style="text-align: center">&nbsp;</td>
			</tr>
			<tr>
				<td style="text-align: center">&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td class="MainTableBottomRowLeftColumn"></td>
		<td class="MainTableBottomRowRightColumn"></td>
	</tr>
</table>
</body>


</html:html>
