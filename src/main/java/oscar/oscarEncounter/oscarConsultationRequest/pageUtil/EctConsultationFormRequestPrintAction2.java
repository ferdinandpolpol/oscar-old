/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

/*
 * EctConsultationFormRequestPrintAction.java
 *
 * Created on November 19, 2007, 4:05 PM
 */

package oscar.oscarEncounter.oscarConsultationRequest.pageUtil;


import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.oscarehr.util.MiscUtils;

//import oscar.OscarProperties;
import oscar.dms.EDoc;
import oscar.dms.EDocUtil;
import oscar.oscarLab.ca.all.pageUtil.LabPDFCreator;
import oscar.oscarLab.ca.on.CommonLabResultData;
import oscar.oscarLab.ca.on.LabResultData;
import oscar.util.ConcatPDF;
import oscar.util.UtilDateUtilities;

import com.lowagie.text.DocumentException;
import com.sun.xml.messaging.saaj.util.ByteInputStream;
import com.sun.xml.messaging.saaj.util.ByteOutputStream;

/**
 *
 * Convert submitted preventions into pdf and return file
 */
public class EctConsultationFormRequestPrintAction2 extends Action {
    
    private static final Logger logger = MiscUtils.getLogger();
    
    public EctConsultationFormRequestPrintAction2() {
    }
    
    @Override
    public ActionForward execute(ActionMapping mapping,ActionForm form,HttpServletRequest request,HttpServletResponse response){
        
    	String reqId = (String) request.getAttribute("reqId");
		String demoNo = request.getParameter("demographicNo");
		ArrayList<EDoc> docs = EDocUtil.listDocs(demoNo, reqId, EDocUtil.ATTACHED);
//		String path = OscarProperties.getInstance().getProperty("DOCUMENT_DIR");
		ArrayList<Object> alist = new ArrayList<Object>();
		byte[] buffer;
		ByteInputStream bis;
		ByteOutputStream bos;
		CommonLabResultData consultLabs = new CommonLabResultData();
		ArrayList<InputStream> streams = new ArrayList<InputStream>();

		ArrayList<LabResultData> labs = consultLabs.populateLabResultsData(demoNo, reqId, CommonLabResultData.ATTACHED);
		String error = "";
		Exception exception = null;
		try {

			bos = new ByteOutputStream();
			ConsultationPDFCreator cpdfc = new ConsultationPDFCreator(request,bos);
			cpdfc.printPdf();
			
			buffer = bos.getBytes();
			bis = new ByteInputStream(buffer, bos.getCount());
			bos.close();
			streams.add(bis);
			alist.add(bis);

			for (int i = 0; i < docs.size(); i++) {
				EDoc doc = docs.get(i);  
				if (doc.isPrintable()) {
					if (doc.isImage()) {
						bos = new ByteOutputStream();
//						request.setAttribute("imagePath", path + doc.getFileName());
						request.setAttribute("imagePath", EDocUtil.getDocumentPath(doc.getFileName()));
						request.setAttribute("imageTitle", doc.getDescription());
						ImagePDFCreator ipdfc = new ImagePDFCreator(request, bos);
						ipdfc.printPdf();
						
						buffer = bos.getBytes();
						bis = new ByteInputStream(buffer, bos.getCount());
						bos.close();
						streams.add(bis);
						alist.add(bis);
						
					}
					else if (doc.isPDF()) {
//						alist.add(path + doc.getFileName());
						alist.add(EDocUtil.getDocumentPath(doc.getFileName()));
					}
					else {
						logger.error("EctConsultationFormRequestPrintAction: " + doc.getType() + " is marked as printable but no means have been established to print it.");	
					}
				}
			}

			// Iterating over requested labs.
			for (int i = 0; labs != null && i < labs.size(); i++) {
				// Storing the lab in PDF format inside a byte stream.
				bos = new ByteOutputStream();
				request.setAttribute("segmentID", labs.get(i).segmentID);
				LabPDFCreator lpdfc = new LabPDFCreator(request, bos);
				lpdfc.printPdf();

				// Transferring PDF to an input stream to be concatenated with
				// the rest of the documents.
				buffer = bos.getBytes();
				bis = new ByteInputStream(buffer, bos.getCount());
				bos.close();
				streams.add(bis);
				alist.add(bis);

			}
			
			if (alist.size() > 0) {
				
				bos = new ByteOutputStream();
				ConcatPDF.concat(alist, bos);
				response.setContentType("application/pdf"); // octet-stream
				response.setHeader(
						"Content-Disposition",
						"inline; filename=\"combinedPDF-"
								+ UtilDateUtilities.getToday("yyyy-mm-dd.hh.mm.ss")
								+ ".pdf\"");
				response.getOutputStream().write(bos.getBytes(), 0, bos.getCount());
			}

		} catch (DocumentException de) {
			error = "DocumentException";
			exception = de;
		} catch (IOException ioe) {
			error = "IOException";
			exception = ioe;
		} finally { 
			// Cleaning up InputStreams created for concatenation.
			for (InputStream is : streams) {
				try {
					is.close();
				} catch (IOException e) {
					error = "IOException";
				}
			}
		}
		if (!error.equals("")) {
			logger.error(error + " occured insided ConsultationPrintAction", exception);
			request.setAttribute("printError", new Boolean(true));
			return mapping.findForward("error");
		}
		return null;
		
    }
}
