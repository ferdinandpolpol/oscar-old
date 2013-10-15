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


//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vhudson-jaxb-ri-2.1-558 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2011.06.03 at 01:48:51 AM EDT 
//


package org.oscarehr.hospitalReportManager.xsd;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{cds}Demographics"/>
 *         &lt;element ref="{cds}ReportsReceived" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{cds}TransactionInformation" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "demographics",
    "reportsReceived",
    "transactionInformation"
})
@XmlRootElement(name = "PatientRecord", namespace = "cds")
public class PatientRecord {

    @XmlElement(name = "Demographics", namespace = "cds", required = true)
    protected Demographics demographics;
    @XmlElement(name = "ReportsReceived", namespace = "cds")
    protected List<ReportsReceived> reportsReceived;
    @XmlElement(name = "TransactionInformation", namespace = "cds")
    protected List<TransactionInformation> transactionInformation;

    /**
     * Gets the value of the demographics property.
     * 
     * @return
     *     possible object is
     *     {@link Demographics }
     *     
     */
    public Demographics getDemographics() {
        return demographics;
    }

    /**
     * Sets the value of the demographics property.
     * 
     * @param value
     *     allowed object is
     *     {@link Demographics }
     *     
     */
    public void setDemographics(Demographics value) {
        this.demographics = value;
    }

    /**
     * Gets the value of the reportsReceived property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the reportsReceived property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getReportsReceived().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ReportsReceived }
     * 
     * 
     */
    public List<ReportsReceived> getReportsReceived() {
        if (reportsReceived == null) {
            reportsReceived = new ArrayList<ReportsReceived>();
        }
        return this.reportsReceived;
    }

    /**
     * Gets the value of the transactionInformation property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the transactionInformation property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getTransactionInformation().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link TransactionInformation }
     * 
     * 
     */
    public List<TransactionInformation> getTransactionInformation() {
        if (transactionInformation == null) {
            transactionInformation = new ArrayList<TransactionInformation>();
        }
        return this.transactionInformation;
    }

}
