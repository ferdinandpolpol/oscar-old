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


package org.oscarehr.hospitalReportManager;

import java.util.Calendar;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.ArrayList;

import javax.xml.datatype.XMLGregorianCalendar;

import org.oscarehr.hospitalReportManager.xsd.Demographics;
import org.oscarehr.hospitalReportManager.xsd.OmdCds;
import org.oscarehr.hospitalReportManager.xsd.PersonNameStandard;
import org.oscarehr.hospitalReportManager.xsd.PersonNameStandard.LegalName.OtherName;
import org.oscarehr.hospitalReportManager.xsd.ReportsReceived.OBRContent;
import org.oscarehr.hospitalReportManager.xsd.DateFullOrPartial;
import org.oscarehr.util.MiscUtils;

public class HRMReport {

	private OmdCds hrmReport;
	private Demographics demographics;
	private String fileLocation;
	private String fileData;
	
	private Integer hrmDocumentId;
	private Integer hrmParentDocumentId;

	public HRMReport(OmdCds hrmReport) {
		this.hrmReport = hrmReport;
		this.demographics = hrmReport.getPatientRecord().getDemographics();
	}

	public HRMReport(OmdCds root, String hrmReportFileLocation, String fileData) {
		this.fileData = fileData;
		this.fileLocation = hrmReportFileLocation;
		this.hrmReport = root;
		this.demographics = hrmReport.getPatientRecord().getDemographics();
	}
	
	public OmdCds getDocumentRoot() {
		return hrmReport;
	}
	
	public String getFileData() {
    	return fileData;
    }

	public String getFileLocation() {
    	return fileLocation;
    }

	public void setFileLocation(String fileLocation) {
    	this.fileLocation = fileLocation;
    }

	public String getLegalName() {
		PersonNameStandard name = demographics.getNames();
		return name.getLegalName().getLastName().getPart() + ", " + name.getLegalName().getFirstName().getPart();
	}

	public String getLegalLastName() {
		PersonNameStandard name = demographics.getNames();
		return name.getLegalName().getLastName().getPart();
	}

	public String getLegalFirstName() {
		PersonNameStandard name = demographics.getNames();
		return name.getLegalName().getFirstName().getPart();
	}

	public List<String> getLegalOtherNames() {
		LinkedList<String> otherNames = new LinkedList<String>();
		PersonNameStandard name = demographics.getNames();
		for (OtherName otherName : name.getLegalName().getOtherName()) {
			otherNames.add(otherName.getPart());
		}

		return otherNames;
	}

	public List<Integer> getDateOfBirth() {
		List<Integer> dateOfBirthList = new ArrayList<Integer>();
		XMLGregorianCalendar fullDate = dateFP(demographics.getDateOfBirth());
		dateOfBirthList.add(fullDate.getYear());
		dateOfBirthList.add(fullDate.getMonth());
		dateOfBirthList.add(fullDate.getDay());

		return dateOfBirthList;
	}
	
	public String getDateOfBirthAsString() {
		List<Integer> dob = getDateOfBirth();
		return dob.get(0) + "-" + dob.get(1) + "-" + dob.get(2);
	}

	public String getHCN(){
		return demographics.getHealthCard().getNumber();
	}

	public String getHCNVersion(){
		return demographics.getHealthCard().getVersion();
	}

	public Calendar getHCNExpiryDate() {
		return demographics.getHealthCard().getExpirydate().toGregorianCalendar();
	}

	public String getHCNProvinceCode() {
		return demographics.getHealthCard().getProvinceCode();
	}

	public String getGender() {
		return demographics.getGender().value();
	}

	public String getUniqueVendorIdSequence() {
		return demographics.getUniqueVendorIdSequence();
	}

	public String getAddressLine1() {
		return demographics.getAddress().get(0).getStructured().getLine1();
	}

	public String getAddressLine2() {
		return demographics.getAddress().get(0).getStructured().getLine2();
	}

	public String getAddressCity() {
		return demographics.getAddress().get(0).getStructured().getCity();
	}

	public String getCountrySubDivisionCode() {
		return demographics.getAddress().get(0).getStructured().getCountrySubdivisionCode();
	}

	public String getPostalCode() {
		return demographics.getAddress().get(0).getStructured().getPostalZipCode().getPostalCode();
	}

	public String getZipCode() {
		return demographics.getAddress().get(0).getStructured().getPostalZipCode().getZipCode();
	}

	public String getPhoneNumber() {
		return demographics.getPhoneNumber().get(0).getContent().get(0).getValue();
	}

	public String getEnrollmentStatus() {
		return demographics.getEnrollmentStatus();
	}

	public String getPersonStatus() {
		return demographics.getPersonStatusCode().value();
	}

	public String getFirstReportTextContent() {
		String result = null;
		try {
			result = hrmReport.getPatientRecord().getReportsReceived().get(0).getContent().getTextContent();
		}catch(Exception e) {
			MiscUtils.getLogger().error("error",e);
		}
		return result;
	}
	
	public String getFirstReportClass() {
		return hrmReport.getPatientRecord().getReportsReceived().get(0).getClazz().value();
	}

	public String getFirstReportSubClass() {
		return hrmReport.getPatientRecord().getReportsReceived().get(0).getSubClass();
	}

	public Calendar getFirstReportEventTime() {
		if (hrmReport.getPatientRecord().getReportsReceived().get(0).getEventDateTime() != null)
                        return dateFP(hrmReport.getPatientRecord().getReportsReceived().get(0).getEventDateTime()).toGregorianCalendar();
		
		return null;
	}

	public List<String> getFirstReportAuthorPhysician() {
		List<String> physicianName = new ArrayList<String>();
		String physicianHL7String = hrmReport.getPatientRecord().getReportsReceived().get(0).getAuthorPhysician().getLastName();
		String[] physicianNameArray = physicianHL7String.split("^");
		physicianName.add(physicianNameArray[0]);
		physicianName.add(physicianNameArray[1]);
		physicianName.add(physicianNameArray[2]);
		physicianName.add(physicianNameArray[3]);
		physicianName.add(physicianNameArray[6]);

		return physicianName;
	}

	public String getSendingFacilityId() {
		return hrmReport.getPatientRecord().getReportsReceived().get(0).getSendingFacility();
	}
	
	public String getSendingFacilityReportNo() {
		return hrmReport.getPatientRecord().getReportsReceived().get(0).getSendingFacilityReportNumber();
	}
	
	public String getResultStatus() {
		return hrmReport.getPatientRecord().getReportsReceived().get(0).getResultStatus();
	}
	
	public List<List<Object>> getAccompanyingSubclassList() {
		LinkedList<List<Object>> subclassList = new LinkedList<List<Object>>();
		
		for (OBRContent o : hrmReport.getPatientRecord().getReportsReceived().get(0).getOBRContent()) {
			LinkedList<Object> obrContentList = new LinkedList<Object>();
			
			obrContentList.add(o.getAccompanyingSubClass());
			obrContentList.add(o.getAccompanyingMnemonic());
			obrContentList.add(o.getAccompanyingDescription());

                        if (o.getObservationDateTime()!=null) {
                            Date date = dateFP(o.getObservationDateTime()).toGregorianCalendar().getTime();
                            obrContentList.add(date);
                        }
			
			subclassList.add(obrContentList);
		}
		
		return subclassList;
	}
	
	public Calendar getFirstAccompanyingSubClassDateTime() {
		if (hrmReport.getPatientRecord().getReportsReceived().get(0).getOBRContent() != null && 
				hrmReport.getPatientRecord().getReportsReceived().get(0).getOBRContent().get(0) != null &&
				hrmReport.getPatientRecord().getReportsReceived().get(0).getOBRContent().get(0).getObservationDateTime() != null) {
			return dateFP(hrmReport.getPatientRecord().getReportsReceived().get(0).getOBRContent().get(0).getObservationDateTime()).toGregorianCalendar();
		}
		
		return null;
	}
	
	public String getMessageUniqueId() {
		return hrmReport.getPatientRecord().getTransactionInformation().get(0).getMessageUniqueID();
	}
	
	public String getDeliverToUserId() {
		return hrmReport.getPatientRecord().getTransactionInformation().get(0).getDeliverToUserID();
	}
	
	public String getDeliverToUserIdFirstName() {
		return hrmReport.getPatientRecord().getTransactionInformation().get(0).getPhysician().getFirstName();
	}
	
	public String getDeliverToUserIdLastName() {
		return hrmReport.getPatientRecord().getTransactionInformation().get(0).getPhysician().getLastName();
	}

	public Integer getHrmDocumentId() {
    	return hrmDocumentId;
    }

	public void setHrmDocumentId(Integer hrmDocumentId) {
    	this.hrmDocumentId = hrmDocumentId;
    }

	public Integer getHrmParentDocumentId() {
    	return hrmParentDocumentId;
    }

	public void setHrmParentDocumentId(Integer hrmParentDocumentId) {
    	this.hrmParentDocumentId = hrmParentDocumentId;
    }


        XMLGregorianCalendar dateFP(DateFullOrPartial dfp) {
            if (dfp==null) return null;

            if (dfp.getDateTime()!=null) return dfp.getDateTime();
            else if (dfp.getFullDate()!=null) return dfp.getFullDate();
            else if (dfp.getYearMonth()!=null) return dfp.getYearMonth();
            else if (dfp.getYearOnly()!=null) return dfp.getYearOnly();
            return null;
    }


}
