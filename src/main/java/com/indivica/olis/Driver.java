/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */

package com.indivica.olis;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.StringReader;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.Security;
import java.security.cert.CertStore;
import java.security.cert.Certificate;
import java.security.cert.CollectionCertStoreParameters;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;

import org.bouncycastle.cms.CMSProcessableByteArray;
import org.bouncycastle.cms.CMSSignedData;
import org.bouncycastle.cms.CMSSignedDataGenerator;
import org.bouncycastle.cms.DefaultSignedAttributeTableGenerator;
import org.bouncycastle.cms.SignerInformation;
import org.bouncycastle.cms.SignerInformationStore;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.util.encoders.Base64;
import org.oscarehr.common.dao.OscarLogDao;
import org.oscarehr.common.model.OscarLog;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.xml.sax.InputSource;

import oscar.OscarProperties;
import oscar.oscarMessenger.data.MsgProviderData;
import ca.ssha._2005.hial.ArrayOfError;
import ca.ssha._2005.hial.ArrayOfString;
import ca.ssha._2005.hial.Response;
import ca.ssha.www._2005.hial.OLISStub;
import ca.ssha.www._2005.hial.OLISStub.HIALRequest;
import ca.ssha.www._2005.hial.OLISStub.HIALRequestSignedRequest;
import ca.ssha.www._2005.hial.OLISStub.OLISRequest;
import ca.ssha.www._2005.hial.OLISStub.OLISRequestResponse;

import com.indivica.olis.queries.Query;

public class Driver {

	private static OscarLogDao logDao = (OscarLogDao) SpringUtils.getBean("oscarLogDao");

	public static String submitOLISQuery(HttpServletRequest request, Query query) {
		try {
			OLISMessage message = new OLISMessage(query);

			System.setProperty("javax.net.ssl.keyStore",
					OscarProperties.getInstance().getProperty("olis_ssl_keystore").trim());
			System.setProperty("javax.net.ssl.keyStorePassword", 
					OscarProperties.getInstance().getProperty("olis_ssl_keystore_password").trim());
			System.setProperty("javax.net.ssl.trustStore",
					OscarProperties.getInstance().getProperty("olis_truststore").trim());
			System.setProperty("javax.net.ssl.trustStorePassword", 
					OscarProperties.getInstance().getProperty("olis_truststore_password").trim());

			OLISRequest olisRequest = new OLISRequest();
			olisRequest.setHIALRequest(new HIALRequest());
			OLISStub olis = new OLISStub();

			olisRequest.getHIALRequest().setClientTransactionID(message.getTransactionId());
			olisRequest.getHIALRequest().setSignedRequest(new HIALRequestSignedRequest());

			String olisHL7String = message.getOlisHL7String().replaceAll("\n", "\r");
			String msgInXML = String
			.format("<Request xmlns=\"http://www.ssha.ca/2005/HIAL\"><Content><![CDATA[%s]]></Content></Request>",
					olisHL7String);

			String signedRequest = Driver.signData(msgInXML);
			olisRequest.getHIALRequest().getSignedRequest().setSignedData(signedRequest);


			try {
				OscarLog logItem = new OscarLog();
				logItem.setAction("OLIS");
				logItem.setContent("query");
				logItem.setData(olisHL7String);

				if (LoggedInInfo.loggedInInfo.get() != null && LoggedInInfo.loggedInInfo.get().loggedInProvider != null)
					logItem.setProviderNo(LoggedInInfo.loggedInInfo.get().loggedInProvider.getProviderNo());
				
				logDao.persist(logItem);

			} catch (Exception e) {
				MiscUtils.getLogger().error("Couldn't write log message for OLIS query", e);
			}

			if(OscarProperties.getInstance().getProperty("olis_simulate","no").equals("yes")) {
				String response = (String) request.getSession().getAttribute("olisResponseContent");
				request.setAttribute("olisResponseContent", response);
				request.getSession().setAttribute("olisResponseContent",null);
				return response;
			} else {
				OLISRequestResponse olisResponse = olis.oLISRequest(olisRequest);
	
				String signedData = olisResponse.getHIALResponse().getSignedResponse().getSignedData();
				String unsignedData = Driver.unsignData(signedData);
				//MiscUtils.getLogger().info(msgInXML);
				//MiscUtils.getLogger().info("---------------------------------");			
				//MiscUtils.getLogger().info(unsignedData);
				
				if (request != null) { 
					request.setAttribute("msgInXML", msgInXML);
					request.setAttribute("signedRequest", signedRequest);
					request.setAttribute("signedData", signedData);
					request.setAttribute("unsignedResponse", unsignedData);
				}
	
				writeToFile(unsignedData);
				readResponseFromXML(request, unsignedData);
	
				return unsignedData;

			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("Can't perform OLIS query due to exception.", e);
			if(request != null) {
				request.setAttribute("searchException", e);
			}
			notifyOlisError(e.getMessage());
			return "";
		}
	}

	public static void readResponseFromXML(HttpServletRequest request,
			String olisResponse) {
		
		olisResponse = olisResponse.replaceAll("<Content", "<Content xmlns=\"\" ");
		olisResponse = olisResponse.replaceAll("<Errors", "<Errors xmlns=\"\" ");

		try {
			DocumentBuilderFactory.newInstance().newDocumentBuilder();
			SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");

			Source schemaFile = new StreamSource(new File(OscarProperties.getInstance().getProperty("olis_response_schema")));
			factory.newSchema(schemaFile);

			JAXBContext jc = JAXBContext.newInstance("ca.ssha._2005.hial");
			Unmarshaller u = jc.createUnmarshaller();
			@SuppressWarnings("unchecked")
			Response root = ((JAXBElement<Response>) u.unmarshal(new InputSource(new StringReader(olisResponse)))).getValue();
			
			if (root.getErrors() != null) {
				List<String> errorStringList = new LinkedList<String>();
				
				// Read all the errors
				ArrayOfError errors = root.getErrors();
				List<ca.ssha._2005.hial.Error> errorList = errors.getError();
				
				for (ca.ssha._2005.hial.Error error : errorList) {
					String errorString = "";
					errorString += "ERROR " + error.getNumber() + " (" + error.getSeverity() + ") : " + error.getMessage();
					
					ArrayOfString details = error.getDetails();
					List<String> detailList = details.getString();
					for (String detail : detailList) {
						errorString += "\n" + detail;
					}
					
					errorStringList.add(errorString);
				}
				if(request!=null)
					request.setAttribute("errors", errorStringList);
			} else if (root.getContent() != null) {
				if(request != null)
					request.setAttribute("olisResponseContent", root.getContent());
			}
		} catch (Exception e) {
			MiscUtils.getLogger().error("Couldn't read XML from OLIS response.", e);
			notifyOlisError("Couldn't read XML from OLIS response." + "\n" + e);
		}
	}

	public static String unsignData(String data) {

		byte[] dataBytes = Base64.decode(data);

		try {

			CMSSignedData s = new CMSSignedData(dataBytes);
			CertStore certs = s.getCertificatesAndCRLs("Collection", "BC");
			SignerInformationStore signers = s.getSignerInfos();
			@SuppressWarnings("unchecked")
			Collection<SignerInformation> c = signers.getSigners();
			Iterator<SignerInformation> it = c.iterator();
			while (it.hasNext())
			{
				X509Certificate cert = null;
				SignerInformation signer = it.next();
				Collection certCollection = certs.getCertificates(signer.getSID());
				@SuppressWarnings("unchecked")
				Iterator<X509Certificate> certIt = certCollection.iterator();
				cert = certIt.next();
				if ( !signer.verify(cert.getPublicKey(), "BC")) throw new Exception("Doesn't verify");
			}

			CMSProcessableByteArray cpb = (CMSProcessableByteArray) s.getSignedContent();
			byte[] signedContent = (byte[]) cpb.getContent();
			String content = new String(signedContent);
			return content;
		} catch (Exception e) {
			MiscUtils.getLogger().error("error",e);
		}
		return null;

	}

	public static String signData(String data) {
		X509Certificate cert = null;
		PrivateKey priv = null;
		KeyStore keystore = null;
		String pwd = "Olis2011";
		String result = null;
		try {
			Security.addProvider(new BouncyCastleProvider());

			keystore = KeyStore.getInstance("PKCS12", "SunJSSE");
			// Load the keystore
			keystore.load(new FileInputStream(OscarProperties.getInstance().getProperty("olis_keystore")), pwd.toCharArray());

			Enumeration e = keystore.aliases();
			String name = "";

			if (e != null) {
				while (e.hasMoreElements()) {
					String n = (String) e.nextElement();
					if (keystore.isKeyEntry(n)) {
						name = n;
					}
				}
			}

			// Get the private key and the certificate
			priv = (PrivateKey) keystore.getKey(name, pwd.toCharArray());
			cert = (X509Certificate) keystore.getCertificate(name);

			// I'm not sure if this is necessary
			
			Certificate[] certChain = keystore.getCertificateChain(name);
			ArrayList<Certificate> certList = new ArrayList<Certificate>();
			certList.add(cert);
			CertStore certs = null;

			
			certs = CertStore.getInstance("Collection", new CollectionCertStoreParameters(certList), "BC");

			// Encrypt data
			CMSSignedDataGenerator sgen = new CMSSignedDataGenerator();
			

			// What digest algorithm i must use? SHA1? MD5? RSA?...
			DefaultSignedAttributeTableGenerator attributeGenerator = new DefaultSignedAttributeTableGenerator();			
			sgen.addSigner(priv, cert, CMSSignedDataGenerator.DIGEST_SHA1,attributeGenerator,null);

			// I'm not sure this is necessary
			sgen.addCertificatesAndCRLs(certs);

			// I think that the 2nd parameter need to be false (detached form)
			CMSSignedData csd = sgen.generate(new CMSProcessableByteArray(data.getBytes()), true, "BC");
			
			byte[] signedData = csd.getEncoded();
			byte[] signedDataB64 = Base64.encode(signedData);

			result = new String(signedDataB64);



		} catch (Exception e) {
			MiscUtils.getLogger().error("Can't sign HL7 message for OLIS", e);
		}
		return result;
	}
	
	
	private static void notifyOlisError(String errorMsg) {
	    HashSet<String> sendToProviderList = new HashSet<String>();

    	String providerNoTemp="999998";
	    sendToProviderList.add(providerNoTemp);
	    
    	LoggedInInfo loggedInInfo=LoggedInInfo.loggedInInfo.get();
	    if (loggedInInfo != null && loggedInInfo.loggedInProvider != null)
	    {
	    	// manual prompts always send to admin
	    	sendToProviderList.add(providerNoTemp);
	    	
	    	providerNoTemp=loggedInInfo.loggedInProvider.getProviderNo();
		    sendToProviderList.add(providerNoTemp);
	    }

	    // no one wants to hear about the problem
	    if (sendToProviderList.size()==0) return;
	    
	    String message = "OSCAR attempted to perform a fetch of OLIS data at " + new Date() + " but there was an error during the task.\n\nSee below for the error message:\n" + errorMsg;

	    oscar.oscarMessenger.data.MsgMessageData messageData = new oscar.oscarMessenger.data.MsgMessageData();

	    ArrayList<MsgProviderData> sendToProviderListData = new ArrayList<MsgProviderData>();
	    for (String providerNo : sendToProviderList) {
	    	MsgProviderData mpd = new MsgProviderData();
	    	mpd.providerNo = providerNo;
	    	mpd.locationId = "145";
	    	sendToProviderListData.add(mpd);
	    }

    	String sentToString = messageData.createSentToString(sendToProviderListData);
    	messageData.sendMessage2(message, "OLIS Retrieval Error", "System", sentToString, "-1", sendToProviderListData, null, null);
    }
	
	static void writeToFile(String data) {
		try {
			File tempFile = new File(System.getProperty("java.io.tmpdir")+(Math.random()*100)+".xml");
			PrintWriter pw = new PrintWriter(new FileWriter(tempFile));
			pw.println(data);
			pw.flush();
			pw.close();
		}catch(Exception e) {
			MiscUtils.getLogger().error("Error",e);
		}
	}
}
