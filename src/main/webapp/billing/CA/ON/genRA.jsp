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
    if(session.getAttribute("user") == null) response.sendRedirect("../../../logout.jsp");

OscarProperties props = OscarProperties.getInstance();
if(props.getProperty("isNewONbilling", "").equals("true")) {
%>
<jsp:forward page="onGenRA.jsp" />
<% } %>


<%@ page
	import="java.io.*, java.sql.*,oscar.*, oscar.util.*, java.util.*"
	errorPage="errorpage.jsp"%>
<%@ page import="oscar.oscarBilling.ca.on.pageUtil.*"%>
<%@ page import="oscar.oscarBilling.ca.on.data.*"%>
<%@ include file="../../../admin/dbconnection.jsp"%>
<jsp:useBean id="apptMainBean" class="oscar.AppointmentMainBean" scope="session" />
<jsp:useBean id="documentBean" class="oscar.DocumentBean" scope="request" />
<%@ include file="dbBilling.jspf"%>
<%@ page import="org.oscarehr.util.SpringUtils" %>
<%@ page import="org.oscarehr.common.model.RaHeader" %>
<%@ page import="org.oscarehr.common.dao.RaHeaderDao" %>
<%
RaHeaderDao raHeaderDao = SpringUtils.getBean(RaHeaderDao.class);
JdbcBillingRAImpl dbObj = new JdbcBillingRAImpl();
Properties propRt = new Properties();

String nowDate = UtilDateUtilities.DateToString(UtilDateUtilities.now(), "yyyy/MM/dd");

String filepath="", filename = "", header="", headerCount="", total="", paymentdate="", payable="", totalStatus="", deposit=""; //request.getParameter("filename");
String transactiontype="", providerno="", specialty="", account="", patient_last="", patient_first="", provincecode="", newhin="", hin="", ver="", billtype="", location="";
String servicedate="", serviceno="", servicecode="", amountsubmit="", amountpay="", amountpaysign="", explain="", error="";
String proFirst="", proLast="", demoFirst="", demoLast="", apptDate="", apptTime="", checkAccount="", strcount="", strtCount="";
String balancefwd="",abf_ca="", abf_ad="",abf_re="",abf_de="";
String transaction="",trans_code="",cheque_indicator="", trans_date="",trans_amount="", trans_message="";
String message="", message_txt="";
String xml_ra="";

int accountno=0, totalsum=0, txFlag=0, recFlag=0, flag=0, payFlag=0, count=0, tCount=0, amountPaySum=0, amountSubmitSum=0;
String raNo = "";

ResultSet rslocal;
filename = documentBean.getFilename();

if(!filename.equals("")) {

	filepath = oscarVariables.getProperty("DOCUMENT_DIR").trim();
	FileInputStream file = new FileInputStream(filepath + filename);
	InputStreamReader reader = new InputStreamReader(file);
	BufferedReader input = new BufferedReader(reader);
	String nextline;

	while ((nextline=input.readLine())!=null){
		header = nextline.substring(0,1);

		if (header.compareTo("H") == 0) {
			headerCount = nextline.substring(2,3);

			if (headerCount.compareTo("1") == 0){
				paymentdate = nextline.substring(21,29);
				payable = nextline.substring(29,59);
				total = nextline.substring(59,68);
				totalStatus = nextline.substring(68,69);
				deposit = nextline.substring(69,77);

				totalsum = Integer.parseInt(total);
				total = String.valueOf(totalsum);
				if (total.compareTo("0") == 0){
					total = "000";
				}

				total = total.substring(0, total.length()-2) + "." + total.substring(total.length()-2) + totalStatus;

				String[] param2 = new String[2];
				param2[0] = filename;
				param2[1] = paymentdate;

				ResultSet rsdemo = apptMainBean.queryResults(param2, "search_rahd");
				while (rsdemo.next()) {
					raNo = rsdemo.getString("raheader_no");
				}

				//judge if it is empty in table radt
				int radtNum = 0;
				if (raNo!=null && raNo.length()>0) {
					// can't make sure the record has only one result here
					rsdemo = apptMainBean.queryResults(new String[]{raNo}, "search_radt");
					while (rsdemo.next()) {
						radtNum = rsdemo.getInt("count(raheader_no)");
					}

					// if there is no radt record for the rahd, update the rahd status to "D"
					// if (radtNum == 0) update rahd
					propRt = dbObj.getPropBillNoRAHeaderNo(raNo);
				}

				if (raNo.compareTo("") == 0 || raNo == null || radtNum == 0){
					recFlag = 1;

					RaHeader raHeader = new RaHeader();
					raHeader.setFilename(filename);
					raHeader.setPaymentDate(paymentdate);
					raHeader.setPayable(payable);
					raHeader.setTotalAmount(total);
					raHeader.setRecords("0");
					raHeader.setClaims("0");
					raHeader.setStatus("N");
					raHeader.setReadDate(nowDate);
					raHeader.setContent("<xml_cheque>"+total+"</xml_cheque>");
					raHeaderDao.persist(raHeader);

					rsdemo = null;
					rsdemo = apptMainBean.queryResults(param2, "search_rahd");
					// can't make sure the record has only one result here
					while (rsdemo.next()) {
						raNo = rsdemo.getString("raheader_no");
					}
					propRt = dbObj.getPropBillNoRAHeaderNo(raNo);
				}
			} // ends with "1"

			if (headerCount.compareTo("4") == 0){
				transactiontype = nextline.substring(14,15);
				providerno = nextline.substring(15,21);
				specialty = nextline.substring(21,23);
				account = nextline.substring(23,31);
				patient_last = nextline.substring(31,45);
				patient_first = nextline.substring(45,50);
				hin = nextline.substring(52,64);
				ver = nextline.substring(64,66);
				billtype = nextline.substring(66,69);
				location = nextline.substring(69,73);


				count = count + 1;

				String validnum = "0123456789- ";
				boolean valid = true;
				for (int i = 0; i < account.length(); i++) {
					char c = account.charAt(i);
					if (validnum.indexOf(c) == -1) {
						valid = false;
						break;
					}
				}

				if (account.trim().length() == 0) account = "0";

				if (valid){
					accountno= Integer.parseInt(account.trim());
					account = String.valueOf(accountno);
				}
			}

			if (headerCount.compareTo("5") == 0){
				transactiontype = nextline.substring(14,15);
				servicedate = nextline.substring(15,23);
				serviceno= nextline.substring(23,25);
				servicecode = nextline.substring(25,30);
				amountsubmit = nextline.substring(31,37);
				amountpay = nextline.substring(37,43);
				amountpaysign = nextline.substring(43,44);
				explain = nextline.substring(44,46);

				payFlag = 0;
				error = "";
				tCount = tCount +1;
				amountPaySum = Integer.parseInt(amountpay );
				amountpay  = String.valueOf(amountPaySum );
				if (amountpay.compareTo("0") == 0)	amountpay = "000";

				if(amountpay.length()>2) {
					amountpay = amountpay.substring(0, amountpay.length()-2) + "." + amountpay.substring(amountpay.length()-2);
				} else {
					if(amountpay.length()==2) {
						amountpay = "0." + amountpay;
					} else {
						amountpay = "0.0" + amountpay;
					}
				}
				amountSubmitSum = Integer.parseInt(amountsubmit);
				amountsubmit  = String.valueOf(amountSubmitSum );
				if (amountsubmit.compareTo("0") == 0) amountsubmit = "000";

				amountsubmit =amountsubmit.substring(0, amountsubmit.length()-2) + "." + amountsubmit.substring(amountsubmit.length()-2);
				newhin = hin + ver;

				// if it needs to write a radt record for the rahd record
				if (recFlag > 0 || !propRt.contains(account)) {
					String[] param4 =new String[11];
					param4[0]=raNo;
					param4[1]=providerno;
					param4[2]=account;
					param4[3]=servicecode;
					param4[4]=serviceno;
					param4[5]=newhin;
					param4[6]=amountsubmit;
					param4[7]=amountpaysign+amountpay;
					param4[8]=servicedate;
					param4[9]=explain;
					param4[10]=billtype;

					BillingRAData dObj = new BillingRAData();
					dObj.setRaheader_no(raNo);
					dObj.setProviderohip_no(providerno);
					dObj.setBilling_no(account);
					dObj.setService_code(servicecode);
					dObj.setService_count(serviceno);
					dObj.setHin(newhin);
					dObj.setAmountclaim(amountsubmit);
					dObj.setAmountpay(amountpaysign+amountpay);
					dObj.setService_date(servicedate);
					dObj.setError_code(explain);
					dObj.setBilltype(billtype);
					int rowsAffected3 = dbObj.addOneRADtRecord(dObj);
				}
			}

			if (headerCount.compareTo("6") == 0){
				// balancefwd = "<table width='100%' border='0' cellspacing='0' cellpadding='0'><tr><td colspan='4'>Balance Forward Record - Amount Brought Forward (ABF)</td></tr><tr><td>Claims Adjustment</td><td>Advances</td><td>Reductions</td><td>Deductions</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></table>";
				abf_ca = nextline.substring(3,10)+"."+nextline.substring(10,13);
				abf_ad = nextline.substring(13,20)+"."+nextline.substring(20,23);
				abf_re = nextline.substring(23,30)+"."+nextline.substring(30,33);
				abf_de = nextline.substring(33,40)+"."+nextline.substring(40,43);
			}

			if (headerCount.compareTo("7") == 0){
				trans_code = nextline.substring(3,5);
				if (trans_code.compareTo("10")==0) trans_code="Advance";
				if (trans_code.compareTo("20")==0) trans_code="Reduction";
				if (trans_code.compareTo("30")==0) trans_code="Unused";
				if (trans_code.compareTo("40")==0) trans_code="Advance repayment";
				if (trans_code.compareTo("50")==0) trans_code="Accounting adjustment";
				if (trans_code.compareTo("70")==0) trans_code="Attachments";
				cheque_indicator = nextline.substring(5,6);
				if (cheque_indicator.compareTo("M")==0) cheque_indicator="Manual Cheque issued";
				if (cheque_indicator.compareTo("C")==0) cheque_indicator="Computer Cheque issued";
				if (cheque_indicator.compareTo("I")==0) cheque_indicator="Interim payment Cheque/Direct Bank Deposit issued";

				trans_date = nextline.substring(6,14);
				trans_amount= nextline.substring(14,20)+"."+nextline.substring(20,23);
				trans_message = nextline.substring(23,73);

				transaction = transaction + "<tr><td width='14%'>"+trans_code+"</td><td width='12%'>"+trans_date+"</td><td width='17%'>"+cheque_indicator+"</td><td width='13%'>"+trans_amount+"</td><td width='44%'>"+trans_message+"</td></tr>";
			}

			if (headerCount.compareTo("8") == 0){
				message_txt = message_txt + nextline.substring(3,73)+"<br>";
			}

		} // ends with header "H"
	}
	file.close();
	reader.close();
	input.close();

}

if (transaction.compareTo("") != 0){
	transaction = "<xml_transaction><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr><td colspan='5'>Accounting Transaction Record</td></tr><tr><td width='14%'>Transaction</td><td width='12%'>Transaction Date</td><td width='17%'>Cheque Issued</td><td width='13%'>Amount</td><td width='44%'>Message</td></tr>"+ transaction + "</table></xml_transaction>";
}

balancefwd = "<xml_balancefwd><table width='100%' border='0' cellspacing='0' cellpadding='0'><tr><td colspan='4'>Balance Forward Record - Amount Brought Forward (ABF)</td></tr><tr><td>Claims Adjustment</td><td>Advances</td><td>Reductions</td><td>Deductions</td></tr><tr><td>"+abf_ca+"</td><td>"+abf_ad+"</td><td>"+abf_re+"</td><td>"+abf_de+"</td></tr></table></xml_balancefwd>";
message = "<xml_message><tr><td>Message Facility Record</td></tr><tr><td>" + message_txt+"</td></tr></table></xml_message>";

xml_ra = transaction + balancefwd + "<xml_cheque>"+total+"</xml_cheque>";

String[] param3 =new String[6];
param3[0]=total;
param3[1]=String.valueOf(count);
param3[2]=String.valueOf(tCount);
param3[3]=xml_ra;
param3[4]=paymentdate;
param3[5]=filename;
// only one? for paymentdate, filename
int rowsAffected1 = apptMainBean.queryExecuteUpdate(param3,"update_rahd");

%>


<html>
<head>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/global.js"></script>
<link rel="stylesheet" href="billing.css">
<title>Billing Reconcilliation</title>

<script language="JavaScript">
<!--
var remote=null;


function rs(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0,top=60,left=30";
  remote=window.open(u,n,args);
  if (remote != null) {
    if (remote.opener == null)
      remote.opener = self;
  }
  if (x == 1) { return remote; }
}

var awnd=null;
function popPage(url) {
  awnd=rs('',url ,400,200,1);
  awnd.focus();
}

function checkReconcile(url){
  if(confirm("You are about to reconcile the file, are you sure?")) {
    location.href=url;
  } else{
    alert("You have cancel the action!");
  }
}
//-->
</SCRIPT>
</head>

<body bgcolor="#EBF4F5" text="#000000" leftmargin="0" topmargin="0"
	marginwidth="0" marginheight="0">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr bgcolor="#486ebd">
		<th align='LEFT'><input type='button' name='print' value='Print'
			onClick='window.print(); return false;'></th>
		<th align='CENTER'><font face="Arial, Helvetica, sans-serif"
			color="#FFFFFF">Billing Reconcilliation </font></th>
		<th align='RIGHT'><input type='button' name='close' value='Close'
			onClick='window.close()'></th>
	</tr>
</table>

<table width="100%" border="0" cellspacing="1" cellpadding="0">
	<form>
	<tr bgcolor="#CCCCFF">
		<th width="10%">Read Date</th>
		<th width="10%">Payment Date</th>
		<th width="25%">Payable</th>
		<th width="10%">Records/Claims</th>
		<th width="8%">Total</th>
		<th width="22%">Action</th>
		<th>Status</th>
	</tr>

	<%
int n = 0;
ResultSet rsdemo = null;
String[] param5 =new String[1];
param5[0] = "D";
rsdemo = apptMainBean.queryResults(param5, "search_all_rahd");
while (rsdemo.next()) {
	n++;
	raNo = rsdemo.getString("raheader_no");
	nowDate = rsdemo.getString("readdate");
	paymentdate = rsdemo.getString("paymentdate");
	payable = rsdemo.getString("payable");
	strcount= rsdemo.getString("claims");
	strtCount = rsdemo.getString("records");
	total = rsdemo.getString("totalamount");
%>

	<tr bgcolor="<%=n%2==0?"#EFEFEF":"white"%>">
		<td><%=nowDate%></td>
		<td align="center"><%=paymentdate%></td>
		<td><%=payable%></td>
		<td align="center"><%=strcount%>/<%=strtCount%></td>
		<td align="right"><%=total%></td>
		<td align="center"><a
			href="../billing/CA/ON/genRAError.jsp?rano=<%=raNo%>&proNo="
			target="_blank">Error</a> | <a
			href="../billing/CA/ON/genRASummary.jsp?rano=<%=raNo%>&proNo="
			target="_blank">Summary</a>| <a
			href="../billing/CA/ON/genRADesc.jsp?rano=<%=raNo%>" target="_blank">Report
		</a></td>
		<td><%=rsdemo.getString("status").compareTo("N")==0?"<a href=# onClick=\"checkReconcile('../billing/CA/ON/genRAsettle.jsp?rano=" + raNo +"')\">Settle</a> <a href=# onClick=\"checkReconcile('../billing/CA/ON/genRAsettle35.jsp?rano=" + raNo +"')\">S35</a>" : rsdemo.getString("status").compareTo("S")==0?" <a href=# onClick=\"checkReconcile('../billing/CA/ON/genRAsettle35.jsp?rano=" + raNo +"')\">S35</a>":"Processed"%></td>
	</tr>
	<%
}

%>
</table>

</body>
</html>
