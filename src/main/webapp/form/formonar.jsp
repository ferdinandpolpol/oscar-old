<%@ page import="oscar.form.*"%>
<%
    int demoNo = Integer.parseInt(request.getParameter("demographic_no"));
    int formId = Integer.parseInt(request.getParameter("formId"));
    String pg = request.getParameter("pg");
    
	// for oscarcitizens
    String historyet = request.getParameter("historyet") == null ? "" : ("&historyet=" + request.getParameter("historyet"));

	if(true) {
        out.clear();
		if (formId == 0) {
			pageContext.forward("formonarpg1.jsp?demographic_no=" + demoNo + "&formId=" + formId) ; 
 		} else {
			FrmRecord rec = (new FrmRecordFactory()).factory("ONAR");
			java.util.Properties props = rec.getFormRecord(demoNo, formId);

			String suffix =  props.getProperty("c_lastVisited", "pg1");
			if(pg != null && pg.length()>0) {
				suffix = "pg"+pg;
			}
			
			pageContext.forward("formonar" + suffix
				+ ".jsp?demographic_no=" + demoNo + "&formId=" + formId + historyet)  ;
		}
		return;
    }
%>
