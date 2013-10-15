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


package oscar.oscarEncounter.oscarMeasurements.pageUtil;

import org.apache.struts.action.ActionForm;

public final class EctAddMeasurementTypeForm extends ActionForm {

    
    String type;
    String typeDesc;
    String typeDisplayName;
    String measuringInstrc;
    String validation;
    
    public String getType(){
        return this.type;
    }
    
    public void setType(String type){
        this.type = type;
    }
    
    
    public String getTypeDesc(){
        return this.typeDesc;
    }
    
    public void setTypeDesc(String typeDesc){
        this.typeDesc = typeDesc;
    }
    
    public String getTypeDisplayName(){
        return this.typeDisplayName;
    }
    
    public void setTypeDisplayName(String typeDisplayName){
        this.typeDisplayName = typeDisplayName;
    }
    
    public String getMeasuringInstrc(){
        return this.measuringInstrc;
    }
    
    public void setMeasuringInstrc(String measuringInstrc){
        this.measuringInstrc = measuringInstrc;
    }
    
    public String getValidation(){
        return this.validation;
    }
    
    public void setValidation(String validation){
        this.validation = validation;
    }
    
}
