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


package oscar.oscarSurveillance;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.oscarehr.util.MiscUtils;

import oscar.OscarProperties;
import oscar.oscarDB.DBHandler;

/**
 *
 * @author  Jay Gallagher
 */
public class ProcessSurveyFile{
   private static Logger log = MiscUtils.getLogger();
   
   
   
   private int maxProcessed(String surveyId){
      int maxprocessed = 0 ;
      try{
         
         String sql = "select max(processed) as maxprocessed from surveyData  where surveyId = '"+surveyId+"'  ";         
         ResultSet rs = DBHandler.GetSQL(sql);
         
         if(rs.next()){
            maxprocessed = rs.getInt("maxprocessed");            
         }            
         rs.close();         
      }catch(Exception e){
         MiscUtils.getLogger().error("Error", e);
      }
      return maxprocessed;
   }
   
   private void setProcessed(String surveyDataId, int processedId){
      try{
         
         String sql = "update surveyData set processed = '"+processedId+"' where surveyDataId = '"+surveyDataId+"'  ";         
         DBHandler.RunSQL(sql);         
      }catch(Exception e){
         MiscUtils.getLogger().error("Error", e);
      }
   }
               
   String replaceAllValues(String guideString,ResultSet rs) throws SQLException{      
      String processString = getFirstVal(guideString);
      while (processString != null){         
         String replaceVal = oscar.Misc.getString(rs,processString);   
         if(replaceVal == null) replaceVal ="";
         guideString = guideString.replaceAll("\\$\\{"+processString+"\\}", replaceVal);         
         processString = getFirstVal(guideString);
      }
      return guideString;
   }
   
   public String getFirstVal(String s){
      String firstString = null;
      int start = s.indexOf("${");
      int end = s.indexOf("}");      
      if (start > 0 ){
         firstString = s.substring(start+2,end);
      }
      return firstString;
   }
   
   public synchronized String processSurveyFile(String surveyId){
      String sStatus = null;
      int numRecordsToProcess = 0;
      try{
         
         String processCount = "select count(surveyDataId) as recordsForProcessing from surveyData  where surveyId = '"+surveyId+"' and processed is null and status = 'A'";
         
         ResultSet rs = DBHandler.GetSQL(processCount);
         
         if (rs.next()){
            numRecordsToProcess = rs.getInt("recordsForProcessing");            
            if (numRecordsToProcess > 0){                 
               int processedId = maxProcessed(surveyId);
               processedId++;
               String fileDir = OscarProperties.getInstance().getProperty("surveillance_directory");
               String filename = surveyId+Integer.toString(processedId)+".txt";
               
               SurveillanceMaster sm = SurveillanceMaster.getInstance();
               Survey survey = sm.getSurveyById(surveyId);
               String sql = survey.getExportQuery() + " '"+surveyId+"' ";
                 log.debug("sql "+sql);
               String exp = survey.getExportString();
                 log.debug("xp "+exp);
               
               rs = DBHandler.GetSQL(sql);  
               
               try{
                  BufferedWriter out = new BufferedWriter(new FileWriter(fileDir+filename));                
                  while(rs.next()){ 
                     String surveyDataId = oscar.Misc.getString(rs, "surveyDataId");
                     String writeString = replaceAllValues(exp, rs);                     
                     out.write(writeString+'\n');                                    
                     setProcessed(surveyDataId,processedId);
                  }        
                  out.close();
               } catch (IOException e) {
                  MiscUtils.getLogger().error("Error", e);
               }             
            }
         }
         rs.close();
         
      }catch(Exception e){
         MiscUtils.getLogger().error("Error", e);
      }
      return sStatus;
   }

   
   /** Creates a new instance of ILISurveyFile */
   public ProcessSurveyFile() {
   }
   
   
   
}
