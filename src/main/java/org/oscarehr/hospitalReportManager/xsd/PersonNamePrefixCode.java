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

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for personNamePrefixCode.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="personNamePrefixCode">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
 *     &lt;maxLength value="6"/>
 *     &lt;enumeration value="Miss"/>
 *     &lt;enumeration value="Mr"/>
 *     &lt;enumeration value="Mssr"/>
 *     &lt;enumeration value="Mrs"/>
 *     &lt;enumeration value="Ms"/>
 *     &lt;enumeration value="Prof"/>
 *     &lt;enumeration value="Reeve"/>
 *     &lt;enumeration value="Rev"/>
 *     &lt;enumeration value="RtHon"/>
 *     &lt;enumeration value="Sen"/>
 *     &lt;enumeration value="Sgt"/>
 *     &lt;enumeration value="Sr"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "personNamePrefixCode")
@XmlEnum
public enum PersonNamePrefixCode {

    @XmlEnumValue("Miss")
    MISS("Miss"),
    @XmlEnumValue("Mr")
    MR("Mr"),
    @XmlEnumValue("Mssr")
    MSSR("Mssr"),
    @XmlEnumValue("Mrs")
    MRS("Mrs"),
    @XmlEnumValue("Ms")
    MS("Ms"),
    @XmlEnumValue("Prof")
    PROF("Prof"),
    @XmlEnumValue("Reeve")
    REEVE("Reeve"),
    @XmlEnumValue("Rev")
    REV("Rev"),
    @XmlEnumValue("RtHon")
    RT_HON("RtHon"),
    @XmlEnumValue("Sen")
    SEN("Sen"),
    @XmlEnumValue("Sgt")
    SGT("Sgt"),
    @XmlEnumValue("Sr")
    SR("Sr");
    private final String value;

    PersonNamePrefixCode(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static PersonNamePrefixCode fromValue(String v) {
        for (PersonNamePrefixCode c: PersonNamePrefixCode.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
