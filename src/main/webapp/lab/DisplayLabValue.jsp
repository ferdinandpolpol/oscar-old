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
<%@page import="java.util.Date"%>
<%@ page
	import="java.math.*, java.util.*, java.sql.*, oscar.*, java.net.*, oscar.oscarLab.ca.on.*,oscar.util.*,oscar.oscarLab.*"%>
<%
    

    String ran = ""+Math.random();
    
    String demoNo = request.getParameter("demographicNo");
    String labType = request.getParameter("labType");
    String testName = request.getParameter("testName");
    String identCode = request.getParameter("identCode");
   
    ArrayList list   = CommonLabTestValues.findValuesForTest(labType, demoNo, testName, identCode);
                      Collections.sort(list,new Comparator(){
                    	  public int compare(Object object, Object object0) {
                    	        int ret  = 0;
                    	        
                    	        Date date1 = (Date) ((Map) object).get("collDateDate");
                    	        Date date2 = (Date) ((Map) object0).get("collDateDate");;
                    	        if (date1.after(date2)){
                    	            ret = -1;
                    	        }else if(date1.before(date2)){
                    	            ret = 1;    
                    	        }
                    	        return ret;
                    	    }
                      });
             
    %>
<div class="preventionSection" id="preventionSection<%=ran%>">
<div class="headPrevention" id="headPrevention<%=ran%>">
<p><a id="ahead<%=ran%>"
	title="fade=[on] header=[<%=testName%>] body=[]"
	href="javascript: function myFunction() {return false; }"> <span
	title="<%=""%>" style="font-weight: bold;"> <%=StringUtils.maxLenString(testName, 10, 8, "...")%>
<%=""/*testName*/%> </span> </a> <!--&nbsp;
               <a href="">#</a--> <br />
</p>
</div>
<%     
            for (int k = 0; k < list.size(); k++){
            	Map hdata = (Map) list.get(k);
                String labDisplayLink = "";
                if ( labType.equals(LabResultData.MDS) ){
                    labDisplayLink = "../oscarMDS/SegmentDisplay.jsp?segmentID="+hdata.get("lab_no")+"&providerNo="+session.getValue("user");
                }else if (labType.equals(LabResultData.CML)){ 
                    labDisplayLink = "../lab/CA/ON/CMLDisplay.jsp?segmentID="+hdata.get("lab_no")+"&providerNo="+session.getValue("user");
                }else if (labType.equals(LabResultData.HL7TEXT)){
                    labDisplayLink = "../lab/CA/ALL/labDisplay.jsp?segmentID="+hdata.get("lab_no")+"&providerNo="+session.getValue("user");
                }else if (labType.equals(LabResultData.EXCELLERIS)) {
                    labDisplayLink = "../lab/CA/BC/labDisplay.jsp?segmentID="+hdata.get("lab_no")+"&providerNo="+session.getValue("user");
                }
            %>
<div style="text-align: justify;"
	title="fade=[on] header=[<%=hdata.get("result")%>] body=[<%=hdata.get("units")%> <%=hdata.get("range")%>]"
	class="preventionProcedure" id="preventionProcedure<%=""+k+""+ran%>"
	onclick="javascript:popup(660,960,'<%= labDisplayLink %>','labReport')">
<p <%=r(hdata.get("abn"))%>><%=hdata.get("result")%>
&nbsp;&nbsp;&nbsp; <%=hdata.get("collDate")%></p>
</div>
<%}%>
</div>




<script type="text/javascript">
          ///alert("HI");
          //var ele = document.getElementById("preventionSection<%=ran%>");
          //alert(ele);
          <%for (int k =0; k < list.size(); k++){ %>
          Rounded("div#preventionProcedure<%=""+k+""+ran%>","all","#CCF","#efeadc","small border blue");
          scanDOM(document.getElementById("preventionProcedure<%=""+k+""+ran%>"));
          <%}%>
          Rounded("div#headPrevention<%=ran%>","all","transparent","#F0F0E7","small border #999");
          
          scanDOM(document.getElementById("ahead<%=ran%>"));
      </script>


<%!
String r(Object re){ 
        String ret = "";
        if (re instanceof java.lang.String){                
           if (re != null && re.equals("A")){
              ret = "style=\"background: #FFDDDD;\"";
           }else if(re !=null && re.equals("2")){
              ret = "style=\"background: #FFCC24;\""; 
           }
        }
        return ret;
    }
/*
//first field is testName, 
//second field is abn : abnormal or normal, A or N
//third field is result
//fourth field is units
//fifth field is range
//sixth field is date : collection Date 
 *
 *h.put("testName", testNam);
               h.put("abn",abn);
               h.put("result",result);
               h.put("range",range);
               h.put("units",units);
               h.put("collDate",collDate); 
 */
%>
