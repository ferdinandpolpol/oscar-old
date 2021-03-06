<%--

    Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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

--%>
<% 
if(session.getValue("user") == null) response.sendRedirect("../../../logout.jsp");
String user_no = (String) session.getAttribute("user");

OscarProperties props = OscarProperties.getInstance();
if(props.getProperty("isNewONbilling", "").equals("true")) {
%>
<jsp:forward page="billingONOhipSimulation.jsp" />
<% } 
%>

<%@ page
	import="java.util.*, java.sql.*, oscar.*, oscar.util.*, java.net.*"
	errorPage="errorpage.jsp"%>
<%@ include file="../../../admin/dbconnection.jsp"%>
<jsp:useBean id="apptMainBean" class="oscar.AppointmentMainBean"
	scope="session" />
<jsp:useBean id="SxmlMisc" class="oscar.SxmlMisc" scope="session" />
<%@ include file="dbBilling.jspf"%>

<%
GregorianCalendar now=new GregorianCalendar();
int curYear = now.get(Calendar.YEAR);
int curMonth = (now.get(Calendar.MONTH)+1);
int curDay = now.get(Calendar.DAY_OF_MONTH);

String nowDate = UtilDateUtilities.DateToString(UtilDateUtilities.now(), "yyyy-MM-dd"); //"yyyy/MM/dd HH:mm"
String monthCode = "";
if (curMonth == 1) monthCode = "A";
else if (curMonth == 2) monthCode = "B";
else if (curMonth == 3) monthCode = "C";
else if (curMonth == 4) monthCode = "D";
else if (curMonth == 5) monthCode = "E";
else if (curMonth == 6) monthCode = "F";
else if (curMonth == 7) monthCode = "G";
else if (curMonth == 8) monthCode = "H";
else if (curMonth == 9) monthCode = "I";
else if (curMonth == 10) monthCode = "J";
else if (curMonth == 11) monthCode = "K";
else if (curMonth == 12) monthCode = "L";

String billCenter = oscarVariables.getProperty("billcenter", "").trim();
String healthOffice = null;
switch (billCenter.charAt(0)) {
  case 'G': 
    healthOffice = "Hamilton";
    break;
  case 'J': 
    healthOffice = "Kingston";
    break;
  case 'P': 
    healthOffice = "London";
    break;
  case 'E': 
    healthOffice = "Mississauga";
    break;
  case 'F': 
    healthOffice = "Oshawa";
    break;
  case 'D': 
    healthOffice = "Ottawa";
    break;
  case 'R': 
    healthOffice = "Sudbury";
    break;
  case 'U': 
    healthOffice = "Thunder Bay";
    break;
  case 'N': 
    healthOffice = "Toronto";
    break;
  default: 
    healthOffice = "Hamilton";
}

%>

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>Billing Report</title>
<script language="JavaScript">
<!--
function openBrWindow(theURL,winName,features) {
	window.open(theURL,winName,features);
}


function checkData() {
	var b = true;
	if(document.forms[0].provider.value=="000000"){
		alert("Please select a provider!");
		b = false;
	}else if(document.forms[0].xml_vdate.value==""){
		alert("Please give a date!");
		b = false;
	}

	return b;
}
//-->
</script>

<style type='text/css'>
<!--
.bodytext {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-style: normal;
	line-height: normal;
	font-weight: normal;
	font-variant: normal;
	text-transform: none;
	color: #003366;
	text-decoration: none;
}
-->
</style>
</head>

<body bgcolor="#FFFFFF" text="#000000" leftmargin="0" rightmargin="0"
	topmargin="0" onLoad="setfocus()">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="#486ebd">
		<th align='LEFT'><input type='button' name='print' value='Print'
			onClick='window.print()'></th>
		<th><font face="Arial, Helvetica, sans-serif" color="#FFFFFF">
		OHIP Report Simulation</font></th>
		<th align='RIGHT'><input type='button' name='close' value='Close'
			onClick='window.close()'></th>
	</tr>
</table>

<%
String providerview=request.getParameter("provider")==null?"":request.getParameter("provider");
String xml_vdate=request.getParameter("xml_vdate") == null?"":request.getParameter("xml_vdate");
String xml_appointment_date = request.getParameter("xml_appointment_date")==null? nowDate : request.getParameter("xml_appointment_date");
%>

<table width="100%" border="0" bgcolor="#E6F0F7">
	<form name="serviceform" method="post" action="genSimulation.jsp"
		onSubmit="return checkData();">
	<tr>
		<td width="220"><b><font face="Arial, Helvetica, sans-serif"
			size="2" color="#003366"> Select Provider </font></b></td>
		<td width="254"><select name="provider">
			<option value="000000"
				<%=providerview.equals("000000")?"selected":""%>><b>Select
			Provider</b></option>

			<% 
String proFirst="";
String proLast="";
String proOHIP="";
Vector vecOHIP = new Vector();
Vector vecProviderName = new Vector();
String specialty_code; String billinggroup_no;
int Count = 0;
ResultSet rslocal = apptMainBean.queryResults("%", "search_provider_dt");
while(rslocal.next()){
	proFirst = rslocal.getString("first_name");
	proLast = rslocal.getString("last_name");
	proOHIP = rslocal.getString("ohip_no"); 
	//billinggroup_no= SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_billinggroup_no>","</xml_p_billinggroup_no>");
	//specialty_code = SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_specialty_code>","</xml_p_specialty_code>");
	vecOHIP.add(proOHIP);
	vecProviderName.add(proLast + ", " + proFirst);
}
rslocal.close();
for(int i=0; i<vecOHIP.size(); i++) {
	proOHIP = (String)vecOHIP.get(i);
%>
			<option value="<%=proOHIP%>"
				<%=providerview.equals(proOHIP)?"selected":(vecOHIP.size()==1?"selected":"")%>><%=(String)vecProviderName.get(i)%></option>
			<% 
}
%>

		</select></td>
		<td width="254"><b><font face="Arial, Helvetica, sans-serif"
			size="2"> Bill Center: </font></b> <input type="hidden" name="billcenter"
			value="<%=billCenter%>"> <font
			face="Arial, Helvetica, sans-serif" size="2"><%=healthOffice%>
		</font></td>
		<td width="277"><font color="#003366"> <input
			type="hidden" name="monthCode" value="<%=monthCode%>"> <input
			type="hidden" name="verCode" value="V03"> <input
			type="hidden" name="curUser" value="<%=user_no%>"> <input
			type="hidden" name="curDate" value="<%=nowDate%>"> </font></td>
	</tr>
	<tr>
		<td><font face="Arial, Helvetica, sans-serif" size="2"><b>
		Service Date: </b></font></td>
		<td><font size="1" face="Arial, Helvetica, sans-serif"> <a
			href="#"
			onClick="openBrWindow('../../../share/CalendarPopup.jsp?urlfrom=../billing/CA/ON/billingOHIPsimulation.jsp&year=<%=curYear%>&month=<%=curMonth%>&param=<%=URLEncoder.encode("&formdatebox=document.forms[0].xml_vdate.value")%>','','top=0,left=0,width=430,height=310')">
		From:</a></font> <input type="text" name="xml_vdate" maxlength="10"
			value="<%=xml_vdate%>" readonly></td>
		<td><font size="1" face="Arial, Helvetica, sans-serif"> <a
			href="#"
			onClick="openBrWindow('../../../share/CalendarPopup.jsp?urlfrom=../billing/CA/ON/billingOHIPsimulation.jsp&year=<%=curYear%>&month=<%=curMonth%>&param=<%=URLEncoder.encode("&formdatebox=document.forms[0].xml_appointment_date.value")%>','','top=0,left=0,width=430,height=310')">
		To:</a></font> <input type="text" name="xml_appointment_date" maxlength="10"
			value="<%=xml_appointment_date%>" readonly></td>
		<td><input type="submit" name="Submit" value="Create Report">
		</td>
	</tr>
	</form>
</table>

<%=request.getAttribute("html") == null?"":request.getAttribute("html")%>

</body>
</html>
