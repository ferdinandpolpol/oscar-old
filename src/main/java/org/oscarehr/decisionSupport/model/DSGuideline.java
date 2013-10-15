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


/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.oscarehr.decisionSupport.model;

import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;

/**
 *
 * @author apavel
 */
public abstract class DSGuideline {
    /*
    enum Status {
        ACTIVE('A'),
        INACTIVE('I'),
        FAILED('F');

        private char statusChar;
        private Status(char statusChar) { this.statusChar = statusChar; }
        private char getStatusChar() { return this.statusChar; }
    }*/

    private static Logger _log = MiscUtils.getLogger();
    protected int id;
    protected String uuid;
    protected Integer version;
    protected String author;
    protected String xml;
    protected String source;
    protected String engine;
    protected Date dateStart;
    protected Date dateDecomissioned;
    protected char status;


    //following are populated by parsing
    private String title;
    private List<DSParameter> parameters;
    private List<DSCondition> conditions;
    private List<DSConsequence> consequences;

    private boolean parsed = false;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<DSCondition> getConditions() {
        if (!parsed) this.tryParseFromXml();
        return conditions;
    }

    public void setConditions(List<DSCondition> conditions) {
        this.conditions = conditions;
    }

    public List<DSConsequence> getConsequences() {
        if (!parsed) this.tryParseFromXml();
        return consequences;
    }

    public void setConsequences(List<DSConsequence> consequences) {
        this.consequences = consequences;
    }

    public abstract List<DSConsequence> evaluate(String demographicNo) throws DecisionSupportException;

    public abstract List<DSConsequence> evaluate(String demographicNo, String providerNo) throws DecisionSupportException;

    public boolean evaluateBoolean(String demographicNo) throws DecisionSupportException {
        if (evaluate(demographicNo) == null) return false;
        return true;
    }

    private void tryParseFromXml() {
        try {
            this.parseFromXml();
        } catch (Exception e) {
            _log.error("Could not parse xml for guideline", e);
        }
    }

    //generally done automatically
    public void parseFromXml() throws DecisionSupportParseException {
        DSGuidelineFactory factory = new DSGuidelineFactory();
        DSGuideline newGuideline = factory.createGuidelineFromXml(getXml());
        setParsed(true);
        //copy over
        this.title = newGuideline.getTitle();
        this.conditions = newGuideline.getConditions();
        this.consequences = newGuideline.getConsequences();
        this.parameters = newGuideline.getParameters();
    }

    public boolean isParsed() {
        return parsed;
    }

    public void setParsed(boolean parsed) {
        this.parsed = parsed;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @return the uuid
     */
    public String getUuid() {
        return uuid;
    }

    /**
     * @param uuid the uuid to set
     */
    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    /**
     * @return the version
     */
    public Integer getVersion() {
        return version;
    }

    /**
     * @param version the version to set
     */
    public void setVersion(Integer version) {
        this.version = version;
    }

    /**
     * @return the author
     */
    public String getAuthor() {
        return author;
    }

    /**
     * @param author the author to set
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * @return the xml
     */
    public String getXml() {
        return xml;
    }

    /**
     * @param xml the xml to set
     */
    public void setXml(String xml) {
        this.xml = xml;
    }

    /**
     * @return the source
     */
    public String getSource() {
        return source;
    }

    /**
     * @param source the source to set
     */
    public void setSource(String source) {
        this.source = source;
    }

    /**
     * @return the engine
     */
    public String getEngine() {
        return engine;
    }

    /**
     * @param engine the engine to set
     */
    public void setEngine(String engine) {
        this.engine = engine;
    }

    /**
     * @return the dateStart
     */
    public Date getDateStart() {
        return dateStart;
    }

    /**
     * @param dateStart the dateStart to set
     */
    public void setDateStart(Date dateStart) {
        this.dateStart = dateStart;
    }

    /**
     * @return the dateDecomissioned
     */
    public Date getDateDecomissioned() {
        return dateDecomissioned;
    }

    /**
     * @param dateDecomissioned the dateDecomissioned to set
     */
    public void setDateDecomissioned(Date dateDecomissioned) {
        this.dateDecomissioned = dateDecomissioned;
    }

    /**
     * @return the status
     */
    public char getStatus() {
        return status;
    }

    /**
     * @param status the status to set
     */
    public void setStatus(char status) {
        this.status = status;
    }

    /**
     * @return the parameters
     */
    public List<DSParameter> getParameters() {
        return parameters;
    }

    /**
     * @param parameters the parameters to set
     */
    public void setParameters(List<DSParameter> parameters) {
        this.parameters = parameters;
    }


}
