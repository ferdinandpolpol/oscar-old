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

  String strLimit1="0";
  String strLimit2="1500";
  if(request.getParameter("limit1")!=null) strLimit1 = request.getParameter("limit1");
  if(request.getParameter("limit2")!=null) strLimit2 = request.getParameter("limit2");

  String startDate =null, endDate=null;
  if(request.getParameter("startDate")!=null) startDate = request.getParameter("startDate");
  if(request.getParameter("endDate")!=null) endDate = request.getParameter("endDate");
%>
<%@ page import="java.util.*, java.sql.*, oscar.*"
	errorPage="../errorpage.jsp"%>
<jsp:useBean id="reportMainBean" class="oscar.AppointmentMainBean"
	scope="page" />
<jsp:useBean id="providerNameBean" class="oscar.Dict" scope="page" />
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.ReportTemp" %>
<%@ page import="org.oscarehr.common.dao.ReportTempDao" %>
<%
	ReportTempDao reportTempDao = SpringUtils.getBean(ReportTempDao.class);
%>
<%  if(!reportMainBean.getBDoConfigure()) { %>
<%@ include file="reportMainBeanConn.jspf"%>
<% } %>

<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title>REPORT EDB</title>
<link rel="stylesheet" href="../receptionist/receptionistapptstyle.css">
<script language="JavaScript">
<!--
function setfocus() {
//  document.titlesearch.keyword.focus();
//  document.titlesearch.keyword.select();
}
//-->
</SCRIPT>
<!--base target="pt_srch_main"-->
</head>
<body background="../images/gray_bg.jpg" bgproperties="fixed"
	onLoad="setfocus()" topmargin="0" leftmargin="0" rightmargin="0">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="#486ebd">
		<th align=CENTER><font face="Helvetica" color="#FFFFFF">EDB
		LIST</font></th>
		<th align="right" width="10%" NOWRAP><input type="button"
			name="Button" value="Print" onClick="window.print()"> <input
			type="button" name="Button" value="Cancel" onClick="window.close()">
		</th>
	</tr>
</table>

<CENTER>
<table width="100%" border="1" bgcolor="#ffffff" cellspacing="0"
	cellpadding="1">
	<tr bgcolor="silver">
		<TH>&nbsp;</TH>
		<TH align="center"><b>#</b></TH>
		<TH align="center" width="10%" nowrap><b>EDB</b></TH>
		<TH align="center" width="30%"><b>Patient's Name </b></TH>
		<!--TH align="center" width="20%"><b>Demog' No </b></TH-->
		<TH align="center" width="5%"><b>Age</b></TH>
		<TH align="center" width="5%"><b>Gravida</b></TH>
		<TH align="center" width="10%"><b>Term</b></TH>
		<TH align="center" width="30%"><b>Phone</b></TH>
		<TH align="center"><b>Provider</b></TH>
	</tr>
	<%
   GregorianCalendar now=new GregorianCalendar();
   int curYear = now.get(Calendar.YEAR);
   int curMonth = (now.get(Calendar.MONTH)+1);
   int curDay = now.get(Calendar.DAY_OF_MONTH);
   int age=0;
   ResultSet rs=null ;
   rs = reportMainBean.queryResults("search_provider");
   while (rs.next()) {
      providerNameBean.setDef(reportMainBean.getString(rs,"provider_no"), new String( reportMainBean.getString(rs,"last_name")+","+reportMainBean.getString(rs,"first_name") ));
   }

   List<ReportTemp> temps = reportTempDao.findAll();
   for(ReportTemp temp:temps) {
		reportTempDao.remove(temp.getId());
   }
	rs = reportMainBean.queryResults("search_form_demo");

   while (rs.next()) {
	   String[] param1 =new String[2];
	     param1[0]=reportMainBean.getString(rs,"demographic_no");
	     param1[1]="ar%";
	   ResultSet rsdemo = reportMainBean.queryResults(param1, "search_form_aredb");
      while (rsdemo.next()) {
	      int []itemp = new int[] {Integer.parseInt(rsdemo.getString("demographic_no"))};
	      String[] param2 =new String[5];
  	        param2[0]=rsdemo.getString("content")!=null?(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_fedb")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_fedb"):"0001-01-01"):"0001-01-01";
	        param2[1]=rsdemo.getString("content")!=null?(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_name")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_name"):""):"";
	        param2[2]=rsdemo.getString("provider_no");
	        param2[3]="<age>"+(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_age")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_age"):"") + "</age>" +  "<gravida>"+(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_gra")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_gra"):"") + "</gravida>" +   "<term>"+(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_term")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_term"):"") + "</term>" +   "<phone>"+(SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_hp")!=null?SxmlMisc.getXmlContent(rsdemo.getString("content"),"xml_hp"):"") + "</phone>";
	        param2[4]=curUser_no;

	 	    ReportTemp temp = new ReportTemp();
	 	    temp.setId(new org.oscarehr.common.model.ReportTempPK());
	 	    temp.getId().setDemographicNo(Integer.parseInt(rsdemo.getString("demographic_no")));
	 	    temp.getId().setEdb(MyDateFormat.getSysDate(param2[0]));
	 	    temp.setDemoName(param2[1]);
	 	    temp.setProviderNo(param2[2]);
	 	    temp.setAddress(param2[3]);
	 	    reportTempDao.persist(temp);

	   }
   }

	String[] param =new String[4];
	  param[1]=startDate; //"0001-01-01";
	  param[0]=endDate; //"0001-01-01";
	  param[2]=curUser_no;
	  //param[3]="edb";
   int[] itemp1 = new int[2];
     itemp1[0] = Integer.parseInt(strLimit1);
     itemp1[1] = Integer.parseInt(strLimit2);
	rs = reportMainBean.queryResults(param, itemp1, "search_reporttemp"); //unlock the table
   boolean bodd=false;
   int nItems=0;

   while (rs.next()) {
      bodd=bodd?false:true; //for the color of rows
      nItems++;
%>
	<tr bgcolor="<%=bodd?"ivory":"white"%>">
		<td align="center"><%=nItems%></td>
		<td align="center" nowrap><%=reportMainBean.getString(rs,"edb").replace('-','/')%></td>
		<td><%=reportMainBean.getString(rs,"demo_name")%></td>
		<!--td align="center" ><%=reportMainBean.getString(rs,"demographic_no")%> </td-->
		<td><%=SxmlMisc.getXmlContent(reportMainBean.getString(rs,"address"),"age")%></td>
		<td><%=SxmlMisc.getXmlContent(reportMainBean.getString(rs,"address"),"gravida")%></td>
		<td><%=SxmlMisc.getXmlContent(reportMainBean.getString(rs,"address"),"term")%></td>
		<td nowrap><%=SxmlMisc.getXmlContent(reportMainBean.getString(rs,"address"),"phone")%></td>
		<td><%=providerNameBean.getShortDef(reportMainBean.getString(rs,"provider_no"), "", 11)%></td>
	</tr>
	<%
  }

  if(reportMainBean.getBDoConfigure()) reportMainBean.setBDoConfigure();
%>

</table>
<CENTER><br>
<%
    int nLastPage=0,nNextPage=0;
    nNextPage=Integer.parseInt(strLimit2)+Integer.parseInt(strLimit1);
    nLastPage=Integer.parseInt(strLimit1)-Integer.parseInt(strLimit2);
    if(nLastPage>=0) {
%> <a
	href="reportedblist.jsp?startDate=<%=request.getParameter("startDate")%>&endDate=<%=request.getParameter("endDate")%>&limit1=<%=nLastPage%>&limit2=<%=strLimit2%>">Last
Page</a> | <%
  }
  if(nItems==Integer.parseInt(strLimit2)) {
%> <a
	href="reportedblist.jsp?startDate=<%=request.getParameter("startDate")%>&endDate=<%=request.getParameter("endDate")%>&limit1=<%=nNextPage%>&limit2=<%=strLimit2%>">
Next Page</a> <%}%>

</body>
</html>
