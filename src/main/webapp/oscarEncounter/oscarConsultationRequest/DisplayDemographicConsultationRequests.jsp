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
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@page
	import="oscar.oscarEncounter.pageUtil.*,oscar.oscarEncounter.data.*"%>

<%
if(session.getAttribute("user") == null) response.sendRedirect("../../logout.jsp");
String demo = request.getParameter("de");
String appNo = request.getParameter("appNo");
String proNo = (String) session.getAttribute("user");
oscar.oscarDemographic.data.DemographicData demoData=null;
org.oscarehr.common.model.Demographic demographic=null;

oscar.oscarProvider.data.ProviderData pdata = new oscar.oscarProvider.data.ProviderData(proNo);
String team = pdata.getTeam();

if (demo != null ){ 
    demoData = new oscar.oscarDemographic.data.DemographicData();
    demographic = demoData.getDemographic(demo);    
}
else
    response.sendRedirect("../error.jsp");

oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctConsultationFormRequestUtil consultUtil;
consultUtil = new  oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctConsultationFormRequestUtil();
consultUtil.estPatient(demo);

oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctViewConsultationRequestsUtil theRequests;
theRequests = new  oscar.oscarEncounter.oscarConsultationRequest.pageUtil.EctViewConsultationRequestsUtil();
theRequests.estConsultationVecByDemographic(demo);
%>

<html:html locale="true">
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<title><bean:message
	key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.title" />
</title>
<html:base />

<!--META HTTP-EQUIV="Refresh" CONTENT="20;"-->

<link rel="stylesheet" type="text/css" media="all" href="../share/css/extractedFromPages.css"  />





</head>
<script language="javascript">
function BackToOscar()
{
       window.close();
}
function popupOscarRx(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgConsReq"/>", windowprops);
  //if (popup != null) {
  //  if (popup.opener == null) {
  //    popup.opener = self;
  //  }
  //}
}
function popupOscarConS(vheight,vwidth,varpage) { //open a new popup window
  var page = varpage;
  windowprops = "height="+vheight+",width="+vwidth+",location=no,scrollbars=yes,menubars=no,toolbars=no,resizable=yes,screenX=0,screenY=0,top=0,left=0";
  var popup=window.open(varpage, "<bean:message key="oscarEncounter.oscarConsultationRequest.ConsultChoice.oscarConS"/>", windowprops);
  window.close();
}
</script>

<link rel="stylesheet" type="text/css" href="../encounterStyles.css">
<body class="BodyStyle" vlink="#0000FF" onload="window.focus()">
<!--  -->
<table class="MainTable" id="scrollNumber1" name="encounterTable">
	<tr class="MainTableTopRow">
		<td class="MainTableTopRowLeftColumn">Consultation</td>
		<td class="MainTableTopRowRightColumn">
		<table class="TopStatusBar">
			<tr>
				<td class="Header" NOWRAP><bean:message
					key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgConsReqFor" />
				<%=demographic.getLastName() %>, <%=demographic.getFirstName()%> <%=demographic.getSex()%>
				<%=demographic.getAge()%></td>
				<td></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr style="vertical-align: top">
		<td class="MainTableLeftColumn">
		<table>
			<tr>
				<td NOWRAP><a
					href="javascript:popupOscarRx(700,960,'ConsultationFormRequest.jsp?de=<%=demo%>&teamVar=<%=team%>&appNo=<%=appNo%>')">
				<bean:message
					key="oscarEncounter.oscarConsultationRequest.ConsultChoice.btnNewCon" /></a>
				</td>
			</tr>
		</table>
		</td>
		<td class="MainTableRightColumn">
		<table width="100%">
			<tr>
				<td><bean:message
					key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgClickLink" />
				</td>
			</tr>
			<tr>
				<td>

				<table border="0" width="80%" cellspacing="1">
					<tr>
						<th align="left" class="VCRheads" width="75"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgStatus" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgPat" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgProvider" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgService" />
						</th>
						<th align="left" class="VCRheads"><bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgRefDate" />
						</th>
						<th align="left" class="VCRheads"><bean:message
                                                        key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgConsultant" />
                                                </th>
						<th align="left" class="VCRheads"><bean:message
                                                        key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgReason" />
                                                </th>
						<th align="left" class="VCRheads"><bean:message
                                                        key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgDocument" />
                                                </th>
					</tr>
					<%  
                                    for (int i = 0; i < theRequests.ids.size(); i++){
                                    String id      = (String) theRequests.ids.elementAt(i);
                                    String status  = (String) theRequests.status.elementAt(i);
                                    String patient = (String) theRequests.patient.elementAt(i);
                                    String provide = (String) theRequests.provider.elementAt(i);
                                    String service = (String) theRequests.service.elementAt(i);
                                    String date    = (String) theRequests.date.elementAt(i);
				    String consultant = (String) theRequests.consultant.elementAt(i);
				    String reason = (String) theRequests.reason.elementAt(i);
				    String document =(String) theRequests.documentNo.elementAt(i);
                                %>
					<tr>
						<td class="stat<%=status%>" width="75">
						<% if (status.equals("1")){ %> <bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgNothingDone" />
						<% }else if(status.equals("2")) { %> <bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgSpecialistCall" />
						<% }else if(status.equals("3")) { %> <bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgPatCall" />
						<% }else if(status.equals("4")) { %> <bean:message
							key="oscarEncounter.oscarConsultationRequest.DisplayDemographicConsultationRequests.msgAppMade" />
						<% } %>
						</td>
						<td class="stat<%=status%>"><a
							href="javascript:popupOscarRx(700,960,'../../oscarEncounter/ViewRequest.do?de=<%=demo%>&requestId=<%=id%>')">
						<%=patient%> </a></td>
						<td class="stat<%=status%>"><%=provide%></td>
						<td class="stat<%=status%>"><a
							href="javascript:popupOscarRx(700,960,'../../oscarEncounter/ViewRequest.do?de=<%=demo%>&requestId=<%=id%>')">
						<%=service%> </a></td>
						<td class="stat<%=status%>"><%=date%></td>
						<td class="stat<%=status%>"><%=consultant%></td>
						<td class="stat<%=status%>"><%=(reason!=null?reason:"")%></td>
						
						<%--modified by rohit to display doc descr in consultation list.. and opening the doc on click of it --%>
						<%
						if(document!=null && document.length()>0)
						{
							String[] docs = document.split("~");
							if(docs!=null && docs.length>0)
							{
								%><td><%
								for(int k=0;k<docs.length;k++)
								{
									String[] docDtlArr = docs[k].split("#");
									%>
									<a href="#" onclick="window.open('../../dms/ManageDocument.do?method=display&doc_no=<%=docDtlArr[0] %>&providerNo=<%=proNo%>'); return false;">
									<%=docDtlArr[1] %></a>&nbsp;
									<%
								}
								%></td><%
							}
						}
						else
						{
							%>&nbsp;<%
						}
						%>
						<%-- <td class="stat<%=status%>"><%=document%></td> --%>
					</tr>
					<%}%>
				</table>
				</td>
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
