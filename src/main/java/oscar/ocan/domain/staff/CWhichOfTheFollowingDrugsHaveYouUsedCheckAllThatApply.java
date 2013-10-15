/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */

//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vhudson-jaxb-ri-2.1-793 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2009.05.24 at 10:52:14 PM EDT 
//


package oscar.ocan.domain.staff;

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
 *         &lt;element ref="{}CMarijuana"/>
 *         &lt;element ref="{}CCocaine__crack"/>
 *         &lt;element ref="{}CHallucinogens__e_g__LSD__PCP_"/>
 *         &lt;element ref="{}CStimulants__e_g__amphetamines_"/>
 *         &lt;element ref="{}COpiates__e_g__heroin_"/>
 *         &lt;element ref="{}CSedatives__not_prescribed_or_not_taken_as_prescribed_e_g__Valium_"/>
 *         &lt;element ref="{}COver_the_counter"/>
 *         &lt;element ref="{}CSolvents"/>
 *         &lt;element ref="{}COther"/>
 *         &lt;element ref="{}CHas_the_substance_been_injected_"/>
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
    "cMarijuana",
    "cCocaineCrack",
    "cHallucinogensEGLSDPCP",
    "cStimulantsEGAmphetamines",
    "cOpiatesEGHeroin",
    "cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium",
    "cOverTheCounter",
    "cSolvents",
    "cOther",
    "cHasTheSubstanceBeenInjected"
})
@XmlRootElement(name = "CWhich_of_the_following_drugs_have_you_used___check_all_that_apply_")
public class CWhichOfTheFollowingDrugsHaveYouUsedCheckAllThatApply {

    @XmlElement(name = "CMarijuana", required = true)
    protected CMarijuana cMarijuana;
    @XmlElement(name = "CCocaine__crack", required = true)
    protected CCocaineCrack cCocaineCrack;
    @XmlElement(name = "CHallucinogens__e_g__LSD__PCP_", required = true)
    protected CHallucinogensEGLSDPCP cHallucinogensEGLSDPCP;
    @XmlElement(name = "CStimulants__e_g__amphetamines_", required = true)
    protected CStimulantsEGAmphetamines cStimulantsEGAmphetamines;
    @XmlElement(name = "COpiates__e_g__heroin_", required = true)
    protected COpiatesEGHeroin cOpiatesEGHeroin;
    @XmlElement(name = "CSedatives__not_prescribed_or_not_taken_as_prescribed_e_g__Valium_", required = true)
    protected CSedativesNotPrescribedOrNotTakenAsPrescribedEGValium cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium;
    @XmlElement(name = "COver_the_counter", required = true)
    protected COverTheCounter cOverTheCounter;
    @XmlElement(name = "CSolvents", required = true)
    protected CSolvents cSolvents;
    @XmlElement(name = "COther", required = true)
    protected COther cOther;
    @XmlElement(name = "CHas_the_substance_been_injected_", required = true)
    protected CHasTheSubstanceBeenInjected cHasTheSubstanceBeenInjected;

    /**
     * Gets the value of the cMarijuana property.
     * 
     * @return
     *     possible object is
     *     {@link CMarijuana }
     *     
     */
    public CMarijuana getCMarijuana() {
        return cMarijuana;
    }

    /**
     * Sets the value of the cMarijuana property.
     * 
     * @param value
     *     allowed object is
     *     {@link CMarijuana }
     *     
     */
    public void setCMarijuana(CMarijuana value) {
        this.cMarijuana = value;
    }

    /**
     * Gets the value of the cCocaineCrack property.
     * 
     * @return
     *     possible object is
     *     {@link CCocaineCrack }
     *     
     */
    public CCocaineCrack getCCocaineCrack() {
        return cCocaineCrack;
    }

    /**
     * Sets the value of the cCocaineCrack property.
     * 
     * @param value
     *     allowed object is
     *     {@link CCocaineCrack }
     *     
     */
    public void setCCocaineCrack(CCocaineCrack value) {
        this.cCocaineCrack = value;
    }

    /**
     * Gets the value of the cHallucinogensEGLSDPCP property.
     * 
     * @return
     *     possible object is
     *     {@link CHallucinogensEGLSDPCP }
     *     
     */
    public CHallucinogensEGLSDPCP getCHallucinogensEGLSDPCP() {
        return cHallucinogensEGLSDPCP;
    }

    /**
     * Sets the value of the cHallucinogensEGLSDPCP property.
     * 
     * @param value
     *     allowed object is
     *     {@link CHallucinogensEGLSDPCP }
     *     
     */
    public void setCHallucinogensEGLSDPCP(CHallucinogensEGLSDPCP value) {
        this.cHallucinogensEGLSDPCP = value;
    }

    /**
     * Gets the value of the cStimulantsEGAmphetamines property.
     * 
     * @return
     *     possible object is
     *     {@link CStimulantsEGAmphetamines }
     *     
     */
    public CStimulantsEGAmphetamines getCStimulantsEGAmphetamines() {
        return cStimulantsEGAmphetamines;
    }

    /**
     * Sets the value of the cStimulantsEGAmphetamines property.
     * 
     * @param value
     *     allowed object is
     *     {@link CStimulantsEGAmphetamines }
     *     
     */
    public void setCStimulantsEGAmphetamines(CStimulantsEGAmphetamines value) {
        this.cStimulantsEGAmphetamines = value;
    }

    /**
     * Gets the value of the cOpiatesEGHeroin property.
     * 
     * @return
     *     possible object is
     *     {@link COpiatesEGHeroin }
     *     
     */
    public COpiatesEGHeroin getCOpiatesEGHeroin() {
        return cOpiatesEGHeroin;
    }

    /**
     * Sets the value of the cOpiatesEGHeroin property.
     * 
     * @param value
     *     allowed object is
     *     {@link COpiatesEGHeroin }
     *     
     */
    public void setCOpiatesEGHeroin(COpiatesEGHeroin value) {
        this.cOpiatesEGHeroin = value;
    }

    /**
     * Gets the value of the cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium property.
     * 
     * @return
     *     possible object is
     *     {@link CSedativesNotPrescribedOrNotTakenAsPrescribedEGValium }
     *     
     */
    public CSedativesNotPrescribedOrNotTakenAsPrescribedEGValium getCSedativesNotPrescribedOrNotTakenAsPrescribedEGValium() {
        return cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium;
    }

    /**
     * Sets the value of the cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium property.
     * 
     * @param value
     *     allowed object is
     *     {@link CSedativesNotPrescribedOrNotTakenAsPrescribedEGValium }
     *     
     */
    public void setCSedativesNotPrescribedOrNotTakenAsPrescribedEGValium(CSedativesNotPrescribedOrNotTakenAsPrescribedEGValium value) {
        this.cSedativesNotPrescribedOrNotTakenAsPrescribedEGValium = value;
    }

    /**
     * Gets the value of the cOverTheCounter property.
     * 
     * @return
     *     possible object is
     *     {@link COverTheCounter }
     *     
     */
    public COverTheCounter getCOverTheCounter() {
        return cOverTheCounter;
    }

    /**
     * Sets the value of the cOverTheCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link COverTheCounter }
     *     
     */
    public void setCOverTheCounter(COverTheCounter value) {
        this.cOverTheCounter = value;
    }

    /**
     * Gets the value of the cSolvents property.
     * 
     * @return
     *     possible object is
     *     {@link CSolvents }
     *     
     */
    public CSolvents getCSolvents() {
        return cSolvents;
    }

    /**
     * Sets the value of the cSolvents property.
     * 
     * @param value
     *     allowed object is
     *     {@link CSolvents }
     *     
     */
    public void setCSolvents(CSolvents value) {
        this.cSolvents = value;
    }

    /**
     * Gets the value of the cOther property.
     * 
     * @return
     *     possible object is
     *     {@link COther }
     *     
     */
    public COther getCOther() {
        return cOther;
    }

    /**
     * Sets the value of the cOther property.
     * 
     * @param value
     *     allowed object is
     *     {@link COther }
     *     
     */
    public void setCOther(COther value) {
        this.cOther = value;
    }

    /**
     * Gets the value of the cHasTheSubstanceBeenInjected property.
     * 
     * @return
     *     possible object is
     *     {@link CHasTheSubstanceBeenInjected }
     *     
     */
    public CHasTheSubstanceBeenInjected getCHasTheSubstanceBeenInjected() {
        return cHasTheSubstanceBeenInjected;
    }

    /**
     * Sets the value of the cHasTheSubstanceBeenInjected property.
     * 
     * @param value
     *     allowed object is
     *     {@link CHasTheSubstanceBeenInjected }
     *     
     */
    public void setCHasTheSubstanceBeenInjected(CHasTheSubstanceBeenInjected value) {
        this.cHasTheSubstanceBeenInjected = value;
    }

}
