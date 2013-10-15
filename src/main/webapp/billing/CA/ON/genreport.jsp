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
%>

<%@ page
	import="java.math.*, java.util.*, java.sql.*, oscar.*, oscar.oscarBilling.ca.on.OHIP.*, java.net.*"
	errorPage="errorpage.jsp"%>
<%@ include file="../../../admin/dbconnection.jsp"%>
<jsp:useBean id="apptMainBean" class="oscar.AppointmentMainBean" scope="session" />
<jsp:useBean id="SxmlMisc" class="oscar.SxmlMisc" scope="session" />
<%@ include file="dbBilling.jspf"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.billing.CA.model.BillActivity" %>
<%@ page import="org.oscarehr.billing.CA.dao.BillActivityDao" %>
<%
	BillActivityDao billActivityDao = SpringUtils.getBean(BillActivityDao.class);
%>
<%
boolean bHybridBilling = false;
Vector vecGrpBillingPro = new Vector();
if(oscarVariables.getProperty("hybrid_billing", "").equalsIgnoreCase("on")) {
    bHybridBilling = true;
	String proList = oscarVariables.getProperty("group_billing_providerNo", "");
	String[] temp = proList.split("\\,");
	for(int i = 0; i<temp.length; i++) {
	    vecGrpBillingPro.add(temp[i].trim());
	}
}

GregorianCalendar now=new GregorianCalendar();
int curYear = now.get(Calendar.YEAR);
int bCount = 1;
String batchCount = "0";
//String oscar_home= oscarVariables.getProperty("project_home")+".properties";
String provider = request.getParameter("provider");
String proOHIP="";
String specialty_code;
String billinggroup_no;
String eFlag = "1";

if (provider.compareTo("all") == 0 ){
	ResultSet rslocal = apptMainBean.queryResults("%", "search_provider_ohip_dt");
	while(rslocal.next()){
	    if(bHybridBilling && vecGrpBillingPro.contains(rslocal.getString("provider_no"))) continue;

		proOHIP = rslocal.getString("ohip_no");
		billinggroup_no= SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_billinggroup_no>","</xml_p_billinggroup_no>");
		specialty_code = SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_specialty_code>","</xml_p_specialty_code>");

		batchCount = "0";
		int fileCount = 0;
		String[] param2 =new String[3];
		param2[0]=request.getParameter("monthCode");
		param2[1]=proOHIP;
		param2[2]=curYear+"/01/01";
		ResultSet rslocal2 = apptMainBean.queryResults(param2, "search_billactivity_monthCodeshort");
		while(rslocal2.next()){
			batchCount = rslocal2.getString("batchcount");
		}

		fileCount = Integer.parseInt(batchCount) + 1;
		batchCount = String.valueOf(fileCount);

		if (specialty_code == null || specialty_code.compareTo("") == 0 || specialty_code.compareTo("null")==0){
			specialty_code = "00";
		}
		if ( billinggroup_no == null ||  billinggroup_no.compareTo("") == 0 ||  billinggroup_no.compareTo("null")==0){
			billinggroup_no = "0000";
		}

		oscar.oscarBilling.ca.on.OHIP.ExtractBean extract = new oscar.oscarBilling.ca.on.OHIP.ExtractBean();
		//extract.setOscarHome(oscar_home);
		extract.seteFlag(eFlag);
		// extract.setDateRange("");
		extract.setOhipVer(request.getParameter("verCode"));
		extract.setProviderNo(proOHIP);
		extract.setOhipCenter(request.getParameter("billcenter"));
		extract.setGroupNo(billinggroup_no);
		extract.setSpecialty(specialty_code);
		extract.setBatchCount(String.valueOf(bCount));
		extract.dbQuery();

		int fLength = 3 - batchCount.length();
		String zero ="";
		if (fLength == 1) zero = "0";
		if (fLength == 2) zero = "00";
		String htmlFilename = "H" + request.getParameter("monthCode") + proOHIP + "_" + zero +  batchCount + ".htm";
		String ohipFilename = "H" + request.getParameter("monthCode") + proOHIP + "." + zero + batchCount;

		BillActivity ba = new BillActivity();
		ba.setMonthCode(request.getParameter("monthCode"));
		ba.setBatchCount(Integer.parseInt(batchCount));
		ba.setHtmlFilename(htmlFilename);
		ba.setOhipFilename(ohipFilename);
		ba.setProviderOhipNo(proOHIP);
		ba.setGroupNo(billinggroup_no);
		ba.setCreator(request.getParameter("curUser"));
		ba.setHtmlContext(extract.getHtmlCode());
		ba.setOhipContext(extract.getValue());
		ba.setClaimRecord(extract.getOhipClaim()+"/"+extract.getOhipRecord());
		ba.setUpdateDateTime(new java.util.Date());
		ba.setStatus("A");
		ba.setTotal(extract.getTotalAmount());
		billActivityDao.persist(ba);

		int rowsAffected = 1;

		extract.setHtmlFilename(htmlFilename);
		extract.setOhipFilename(ohipFilename);
		String filecontext = extract.getValue();
		String htmlcontext = extract.getHtmlCode();
		extract.writeFile(filecontext);
		extract.writeHtml(htmlcontext);
	}

}else {
	ResultSet rslocal = apptMainBean.queryResults(request.getParameter("provider").substring(0,6), "search_provider_ohip_dt");
	while(rslocal.next()){
	    if(bHybridBilling && vecGrpBillingPro.contains(rslocal.getString("provider_no"))) continue;

	    proOHIP = rslocal.getString("ohip_no");
		billinggroup_no= SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_billinggroup_no>","</xml_p_billinggroup_no>");
		specialty_code = SxmlMisc.getXmlContent(rslocal.getString("comments"),"<xml_p_specialty_code>","</xml_p_specialty_code>");

		batchCount = "0";
		int fileCount = 0;

		String[] param2 =new String[3];
		param2[0]=request.getParameter("monthCode");
		param2[1]=proOHIP;
		param2[2]=curYear+"/01/01";
		ResultSet rslocal2 = apptMainBean.queryResults(param2, "search_billactivity_monthCodeshort");
		while(rslocal2.next()){
			batchCount = rslocal2.getString("batchcount");
		}

		fileCount = Integer.parseInt(batchCount) + 1;
		batchCount = String.valueOf(fileCount);

		if (specialty_code == null || specialty_code.compareTo("") == 0 || specialty_code.compareTo("null")==0){
			specialty_code = "00";
		}
		if ( billinggroup_no == null ||  billinggroup_no.compareTo("") == 0 ||  billinggroup_no.compareTo("null")==0){
			billinggroup_no = "0000";
		}
		oscar.oscarBilling.ca.on.OHIP.ExtractBean extract = new oscar.oscarBilling.ca.on.OHIP.ExtractBean();
		//extract.setOscarHome(oscar_home);
		extract.seteFlag(eFlag);
		//   extract.setDateRange("");
		extract.setOhipVer(request.getParameter("verCode"));
		extract.setProviderNo(proOHIP);
		extract.setOhipCenter(request.getParameter("billcenter"));
		extract.setGroupNo(billinggroup_no);
		extract.setSpecialty(specialty_code);
		extract.setBatchCount(String.valueOf(bCount));
		extract.dbQuery();

		int fLength = 3 - batchCount.length();
		String zero ="";
		if (fLength == 1) zero = "0";
		if (fLength == 2) zero = "00";

		String htmlFilename = "H" + request.getParameter("monthCode") + proOHIP + "_" + zero +  batchCount + ".htm";
		String ohipFilename = "H" + request.getParameter("monthCode") + proOHIP + "." + zero + batchCount;


		BillActivity ba = new BillActivity();
		ba.setMonthCode(request.getParameter("monthCode"));
		ba.setBatchCount(Integer.parseInt(batchCount));
		ba.setHtmlFilename(htmlFilename);
		ba.setOhipFilename(ohipFilename);
		ba.setProviderOhipNo(proOHIP);
		ba.setGroupNo(billinggroup_no);
		ba.setCreator(request.getParameter("curUser"));
		ba.setHtmlContext(extract.getHtmlCode());
		ba.setOhipContext(extract.getValue());
		ba.setClaimRecord(extract.getOhipClaim()+"/"+extract.getOhipRecord());
		ba.setUpdateDateTime(new java.util.Date());
		ba.setStatus("A");
		ba.setTotal(extract.getTotalAmount());
		billActivityDao.persist(ba);

		int rowsAffected = 1;

		extract.setHtmlFilename(htmlFilename);
		extract.setOhipFilename(ohipFilename);
		String filecontext = extract.getValue();
		String htmlcontext = extract.getHtmlCode();
		extract.writeFile(filecontext);
		extract.writeHtml(htmlcontext);
	}
}

%>

<% if(bHybridBilling) { %>
<jsp:forward page='genGroupReport.jsp'>
	<jsp:param name="year" value='' />
</jsp:forward>
<% } else { %>
<jsp:forward page='billingOHIPreport.jsp'>
	<jsp:param name="year" value='' />
</jsp:forward>
<% } %>
