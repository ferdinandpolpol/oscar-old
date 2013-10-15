/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */


package oscar.oscarBilling.ca.on.pageUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringWriter;
import java.net.URLEncoder;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.io.FileUtils;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.upload.FormFile;
import org.oscarehr.common.dao.BatchEligibilityDao;
import org.oscarehr.common.dao.DemographicCustDao;
import org.oscarehr.common.dao.DemographicDao;
import org.oscarehr.common.model.BatchEligibility;
import org.oscarehr.common.model.Demographic;
import org.oscarehr.common.model.DemographicCust;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.OscarProperties;
import oscar.oscarBilling.ca.on.bean.BillingClaimBatchAcknowledgementReportBeanHandler;
import oscar.oscarBilling.ca.on.bean.BillingClaimsErrorReportBeanHandler;
import oscar.oscarBilling.ca.on.bean.BillingEDTOBECOutputSpecificationBean;
import oscar.oscarBilling.ca.on.bean.BillingEDTOBECOutputSpecificationBeanHandler;
import oscar.oscarBilling.ca.on.data.BillingClaimsErrorReportBeanHandlerSave;
import oscar.oscarDB.DBHandler;

public class BillingDocumentErrorReportUploadAction extends Action {

	private BatchEligibilityDao batchEligibilityDao = (BatchEligibilityDao)SpringUtils.getBean("batchEligibilityDao");
	private DemographicCustDao demographicCustDao = (DemographicCustDao)SpringUtils.getBean("demographicCustDao");
	private DemographicDao demographicDao = (DemographicDao) SpringUtils.getBean("demographicDao");

	public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		BillingDocumentErrorReportUploadForm frm = (BillingDocumentErrorReportUploadForm) form;
		request.getSession().setAttribute("BillingDocumentErrorReportUploadForm", frm);
		FormFile file1 = frm.getFile1();
		ActionMessages errors = new ActionMessages();

		String filename = request.getParameter("filename") == null ? "null" : request.getParameter("filename");
		
		if (filename == "null") {
			if (!saveFile(file1)) {
				errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("errors.fileNotAdded"));
				saveErrors(request, errors);
				return (new ActionForward(mapping.getInput()));
			} else {
				if (getData(file1.getFileName(), "DOCUMENT_DIR", request))
					if(file1.getFileName().startsWith("L"))
					{
						/*OscarProperties props = OscarProperties.getInstance();
						request.getSession().setAttribute("backupfilepath", props.getProperty("DOCUMENT_DIR"));*/
						transform(request, file1.getFileName());
						return mapping.findForward("outside");
					}
					else
					{
						return mapping.findForward("success");
					}
					//return file1.getFileName().startsWith("L") ? mapping.findForward("outside") : mapping.findForward("success");
				else {
					errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("errors.incorrectFileFormat"));
					saveErrors(request, errors);
					return (new ActionForward(mapping.getInput()));
				}
			}
		} else {
			if (getData(filename, "ONEDT_INBOX", request)) {
				return filename.startsWith("L") ? mapping.findForward("outside") : mapping.findForward("success");
			} else if (getData(filename, "ONEDT_ARCHIVE", request)) {
				return filename.startsWith("L") ? mapping.findForward("outside") : mapping.findForward("success");
			} else {
				errors.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("errors.incorrectFileFormat"));
				saveErrors(request, errors);
				return (new ActionForward(mapping.getInput()));
			}
		}
	}

	
	private void transform(HttpServletRequest request, String fname) throws ServletException
	{
		String sname="ES.xsl";
		if (fname.substring(2,4).equals("OU")) {
		   sname="OU.xsl";
		}

		try {
			
			String xslPath = request.getSession().getServletContext().getRealPath(request.getServletPath());
			xslPath = xslPath.replaceAll("\\\\", "/");
			
			xslPath = xslPath.substring(0, xslPath.lastIndexOf("/"));
			xslPath = xslPath.substring(0, xslPath.lastIndexOf("/"))+"/billing/CA/ON/";
			
			StringWriter writer = new StringWriter();
			
			int idx = xslPath.lastIndexOf("/");			
			xslPath = xslPath.substring(0, idx);
			
			OscarProperties props = OscarProperties.getInstance();
			String filepath = props.getProperty("DOCUMENT_DIR");
			boolean bNewBilling = props.getProperty("isNewONbilling", "").equals("true") ? true : false;
			if (!filepath.endsWith("/"))
				filepath = new StringBuilder(filepath).insert(filepath.length(), "/").toString();
			filepath = filepath + fname;
			
			transformToString(filepath, xslPath +"/"+sname, writer);
			
			String content = writer.toString();
			if(content == null || content.equals("")) {
				request.setAttribute("xsltError", "Action failed: XSLT transformation failed.");
			}
			content = content.replaceAll("\r", "").replaceAll("\n", "");
			
			request.setAttribute("xsltResult", content);
		}
		catch(Exception e)
		{
			throw new ServletException(e);
		}
	}
	
	public static void transformToString(String sourcePath, String xsltPath,  
            StringWriter writer) throws Exception {  
		TransformerFactory tFactory = TransformerFactory.newInstance();  
		Transformer transformer =  
			tFactory.newTransformer(new StreamSource(new File(xsltPath)));  

		transformer.transform(new StreamSource(new File(sourcePath)),  
			new StreamResult(writer));  
	}
	
	/**
	 *
	 * Save a Jakarta FormFile to a preconfigured place.
	 *
	 * @param file
	 * @return
	 */
	public static boolean saveFile(FormFile file) {
		String retVal = null;
		boolean isAdded = true;

		try {
			// retrieve the file data
			InputStream stream = file.getInputStream();
			OscarProperties props = OscarProperties.getInstance();

			// properties must exist
			String place = props.getProperty("DOCUMENT_DIR");

			if (!place.endsWith("/"))
				place = new StringBuilder(place).insert(place.length(), "/").toString();
			retVal = place + file.getFileName();
			MiscUtils.getLogger().debug(retVal);
			// write the file to the file specified
			OutputStream bos = new FileOutputStream(retVal);
			int bytesRead = 0;
			byte[] buffer = file.getFileData();
			while ((bytesRead = stream.read(buffer)) != -1) {
				bos.write(buffer, 0, bytesRead);
			}
			bos.close();

			// close the stream
			stream.close();
			FileUtils.copyFileToDirectory(new File(retVal), new File(OscarProperties.getInstance().getProperty("ONEDT_INBOX")));
			
		} catch (FileNotFoundException e) {
			MiscUtils.getLogger().error("File not found", e);
			return isAdded = false;

		} catch (IOException ioe) {
			MiscUtils.getLogger().error("Error", ioe);
			return isAdded = false;
		}

		return isAdded;
	}



	/**
	 *
	 * Get Data from the file.
	 *
	 * @param file
	 * @return
	 */
	private boolean getData(String fileName, String pathDir, HttpServletRequest request) {
		boolean isGot = false;

		try {
			OscarProperties props = OscarProperties.getInstance();
			// properties must exist
			String filepath = props.getProperty(pathDir);
			boolean bNewBilling = props.getProperty("isNewONbilling", "").equals("true") ? true : false;
			if (!filepath.endsWith("/"))
				filepath = new StringBuilder(filepath).insert(filepath.length(), "/").toString();
			FileInputStream file = new FileInputStream(filepath + fileName);
			MiscUtils.getLogger().debug("file path: " + filepath + fileName);
			// Assign associated report Name
			ArrayList<String> messages = new ArrayList<String>();
			String ReportName = "";
			String ReportFlag = "";

			if (fileName.substring(0, 1).compareTo("E") == 0 || fileName.substring(0, 1).compareTo("F") == 0) {
				ReportName = "Claims Error Report";
				BillingClaimsErrorReportBeanHandler hd = generateReportE(file, bNewBilling, fileName);
				request.setAttribute("claimsErrors", hd);
				isGot = hd.verdict;
			}
			else if (fileName.substring(0, 1).compareTo("B") == 0) {
				ReportName = "Claim Batch Acknowledgement Report";
				BillingClaimBatchAcknowledgementReportBeanHandler hd = generateReportB(file);
				request.setAttribute("batchAcks", hd);
				isGot = hd.verdict;
			}
			else if (fileName.substring(0, 1).compareTo("X") == 0) {
				ReportName = "Claim File Rejection Report";
				messages = generateReportX(file);
				request.setAttribute("messages", messages);
				isGot = reportXIsGenerated;
			}
			else if (fileName.substring(0, 1).compareTo("R") == 0) {
				ReportName = "EDT OBEC Output Specification";
				BillingEDTOBECOutputSpecificationBeanHandler hd = generateReportR(file);
				request.setAttribute("outputSpecs", hd);
				isGot = hd.verdict;
			}
			else if (fileName.substring(0,1).compareTo("L") == 0) {
				ReportName = "OUTSIDE USE REPORT";
				request.setAttribute("backupfilepath", filepath);
				request.setAttribute("filename", fileName);
				isGot = true;
			}
			request.setAttribute("ReportName", ReportName);
		} catch (FileNotFoundException fnfe) {

			MiscUtils.getLogger().debug("File not found");
			MiscUtils.getLogger().error("Error", fnfe);
			return isGot = false;

		}
		return isGot;
	}

	/**
	 *
	 * Generate Claims Error Report (E).
	 *
	 * @param file
	 * @return BillingClaimsErrorReportBeanHandler
	 */
	private BillingClaimsErrorReportBeanHandler generateReportE(FileInputStream file, boolean bB, String filename) {
		BillingClaimsErrorReportBeanHandler hd = null;
		if (bB) {
			hd = (new BillingClaimsErrorReportBeanHandlerSave(file, filename)).getErrorReportBeanObj(file);
		} else {
			hd = new BillingClaimsErrorReportBeanHandler(file);
		}

		return hd;
	}

	/**
	 *
	 * Generate Claim Batch Acknowledgement Report (B).
	 *
	 * @param file
	 * @return BillingClaimBatchAcknowlegementReportBeanHandler
	 */
	private BillingClaimBatchAcknowledgementReportBeanHandler generateReportB(FileInputStream file) {
		BillingClaimBatchAcknowledgementReportBeanHandler hd = new BillingClaimBatchAcknowledgementReportBeanHandler(
				file);

		return hd;
	}

	/**
	 *
	 * Generate Claim File Rejection Report (X).
	 *
	 * @param file
	 * @return
	 */
	private boolean reportXIsGenerated = true;

	private ArrayList<String> generateReportX(FileInputStream file) {
		ArrayList<String> messages = new ArrayList<String>();
		messages.add("M01 | Message Reason         Length     Msg Type   Filler  Record Image");
		messages.add("M02 | File:    File Name    Date:   Mail Date   Time: Mail Time     Process Date");
		InputStreamReader reader = new InputStreamReader(file);
		BufferedReader input = new BufferedReader(reader);
		String nextline;
		try {
			while ((nextline = input.readLine()) != null) {
				String headerCount = nextline.substring(2, 3);

				if (headerCount.compareTo("1") == 0) {
					String recordLength = nextline.substring(23, 28);
					String msgType = nextline.substring(28, 31);
					String filler = nextline.substring(32, 39);
					String error = nextline.substring(39, 76);
					String explain = nextline.substring(3, 23);
					String msg = "M01 | " + explain + "   " + recordLength + "   " + msgType + "   " + filler + "   "
							+ URLEncoder.encode(error, "UTF-8");
					messages.add(msg);

				}
				if (headerCount.compareTo("2") == 0) {
					String mailFile = nextline.substring(8, 20);
					String mailDate = nextline.substring(25, 33);
					String mailTime = nextline.substring(38, 44);
					String batchProcessDate = nextline.substring(50, 58);
					String msg = "M02 | File:   " + mailFile + "    " + "Date:   " + mailDate + "   " + "Time: "
							+ mailTime + "     PDate: " + batchProcessDate;
					messages.add(msg);
				}
			}

		} catch (IOException ioe) {
			MiscUtils.getLogger().error("Error", ioe);
		} catch (StringIndexOutOfBoundsException ioe) {
			reportXIsGenerated = false;
		}
		return messages;
	}

	/**
	 *
	 * Generate EDT OBEC Output Specification (R).
	 *
	 * @param file
	 * @return BillingEDTOBECOutputSpecificationBeanHandler
	 */
	private BillingEDTOBECOutputSpecificationBeanHandler generateReportR(FileInputStream file) {
		BillingEDTOBECOutputSpecificationBeanHandler hd = new BillingEDTOBECOutputSpecificationBeanHandler(file);
		Vector<BillingEDTOBECOutputSpecificationBean> outputSpecVector = hd.getEDTOBECOutputSecifiationBeanVector();
		try {


			for (int i = 0; i < outputSpecVector.size(); i++) {
				BillingEDTOBECOutputSpecificationBean bean = outputSpecVector.elementAt(i);
				String hin = bean.getHealthNo();
				String responseCode = bean.getResponseCode();
				int responseCodeNum = -1;
				try {
					responseCodeNum = Integer.parseInt(responseCode);
				} catch (Exception e) {
					MiscUtils.getLogger().error("Error",e);
				}

				if (responseCodeNum < 50 || responseCodeNum > 59) {

					BatchEligibility batchEligibility = batchEligibilityDao.find(Integer.parseInt(responseCode));

					String sqlDemo = "SELECT * FROM demographic WHERE hin='" + hin + "'";
					ResultSet rsDemo = DBHandler.GetSQL(sqlDemo);

					if (rsDemo.next()) {
						if (rsDemo.getString("ver").compareTo(bean.getVersion()) == 0) {
							List<Demographic> demographics = demographicDao.searchByHealthCard(hin);
							for(Demographic demographic:demographics) {
								demographic.setVer("##");
								demographicDao.save(demographic);
							}
							DemographicCust demographicCust = demographicCustDao.find(Integer.parseInt(rsDemo.getString("demographic_no")));
							if(demographicCust != null && batchEligibility != null) {
								String newAlert =  demographicCust.getAlert() + "\n" + "Invalid old version code: "
										+ bean.getVersion() + "\nReason: " + batchEligibility.getMOHResponse() + "- "
										+ batchEligibility.getReason() + "\nResponse Code: " + responseCode;
								demographicCust.setAlert(newAlert);
								demographicCustDao.merge(demographicCust);
							}
						}
						rsDemo.close();
					}
				}
			}
		} catch (SQLException e) {
			MiscUtils.getLogger().error("Error", e);
		}

		return hd;
	}

}
