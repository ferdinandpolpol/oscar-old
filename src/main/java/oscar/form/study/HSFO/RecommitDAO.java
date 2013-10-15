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


package oscar.form.study.HSFO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.oscarehr.common.model.Demographic;
import org.oscarehr.util.DbConnectionFilter;
import org.oscarehr.util.MiscUtils;

import oscar.oscarDemographic.data.DemographicData;
/**
 *Class used by the HSFO Study
 *
 */
public class RecommitDAO {
	 public RecommitDAO() {
	 }

	 public RecommitSchedule getLastSchedule(boolean statusFlag) {

		 PreparedStatement st = null;
	     String sqlstatement ="select * from hsfo_recommit_schedule ";
	     if (statusFlag) sqlstatement+="where status='D' ";
	     sqlstatement+="order by id desc";
	     ResultSet rs = null;
	     RecommitSchedule reSchedule=null;
	     SimpleDateFormat sf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	     try {
	            Connection connect = DbConnectionFilter.getThreadLocalDbConnection();
	            st = connect.prepareStatement(sqlstatement);
	            st.execute();
	            rs = st.getResultSet();

	            if (rs.next()){
	            	reSchedule=new RecommitSchedule();
	            	reSchedule.setId(new Integer(rs.getInt("id")));
	            	reSchedule.setStatus(oscar.Misc.getString(rs, "status"));
	            	reSchedule.setMemo(oscar.Misc.getString(rs, "memo"));
	            	reSchedule.setSchedule_time(sf.parse(oscar.Misc.getString(rs, "schedule_time")));
	            	reSchedule.setUser_no(oscar.Misc.getString(rs, "user_no"));
	            	reSchedule.setCheck_flag(rs.getBoolean("check_flag"));
	            }


	     }catch (SQLException se) {
	            MiscUtils.getLogger().debug("SQL Error while getting the latest record from the hsfo_xml_recommit table : "+ se.toString());
	        }catch (Exception ne) {
	            MiscUtils.getLogger().debug("Other Error while getting the latest record from the hsfo_xml_recommit table : "+ ne.toString());
	        }finally {
	        	if (rs != null)
	    			try {

	    				rs.close();
	    			} catch (SQLException e) {
                                    MiscUtils.getLogger().error("Error", e);
				}
				if (st != null)
					try {
						st.close();
					} catch (SQLException e) {
                                            MiscUtils.getLogger().error("Error", e);
					}
			}
	        return reSchedule;
	 }

	 public void updateLastSchedule(RecommitSchedule rd) {
		 PreparedStatement st = null;
	     String sqlstatement ="update hsfo_recommit_schedule set id=?, status=?, "+
	     		"memo=?, schedule_time=?,user_no=?,check_flag=? where id=?";
	     SimpleDateFormat sf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");


	     try {

	         Connection connect = DbConnectionFilter.getThreadLocalDbConnection();
	         st = connect.prepareStatement(sqlstatement);
	         st.setString(1,rd.getId().toString());
	         st.setString(2,rd.getStatus());
	         st.setString(3,rd.getMemo());
	         st.setString(4,sf.format(rd.getSchedule_time()));
	         st.setString(5, rd.getUser_no());
	         st.setBoolean(6,rd.isCheck_flag());
	         st.setString(7, rd.getId().toString());
	         st.executeUpdate();
	     }catch (SQLException se) {
	         MiscUtils.getLogger().debug("SQL Error while update the latest record to the hsfo_xml_recommit table : "+ se.toString());
	     }catch (Exception ne) {
	         MiscUtils.getLogger().debug("Other Error while update the latest record to the hsfo_xml_recommit table : "+ ne.toString());
	     }finally {

	    	 if (st != null)
				try {
						st.close();
					} catch (SQLException e) {
                                            MiscUtils.getLogger().error("Error", e);
					}
			}

	 }

	 public void insertchedule(RecommitSchedule rd) {
		 PreparedStatement st = null;
	     String sqlstatement ="insert into hsfo_recommit_schedule set status=?, "+
	     		"memo=?, schedule_time=?,user_no=?,check_flag=?";
	     SimpleDateFormat sf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");


	     try {

	         Connection connect = DbConnectionFilter.getThreadLocalDbConnection();
	         st = connect.prepareStatement(sqlstatement);

	         st.setString(1,rd.getStatus());
	         st.setString(2,rd.getMemo());
	         st.setString(3,sf.format(rd.getSchedule_time()));
	         st.setString(4, rd.getUser_no());
	         st.setBoolean(5,rd.isCheck_flag());

	         st.executeUpdate();
	     }catch (SQLException se) {
	         MiscUtils.getLogger().debug("SQL Error while insert a new record to the hsfo_xml_recommit table : "+ se.toString());
	     }catch (Exception ne) {
	         MiscUtils.getLogger().debug("Other Error while insert a new record to the hsfo_xml_recommit table : "+ ne.toString());
	     }finally {

	    	 if (st != null)
				try {
						st.close();
					} catch (SQLException e) {
                                            MiscUtils.getLogger().error("Error", e);
					}
			}

	 }

	 public boolean isLastActivExpire() {
		 boolean exp=false;
		 RecommitSchedule rd=getLastSchedule(false);
		 if (rd!=null && !"D".equalsIgnoreCase(rd.getStatus())){
			 if (rd.getSchedule_time().before(new Date())) exp=true;
		 }
		 return exp;
	 }

	 public void deActiveLast() {
		 RecommitSchedule rd=getLastSchedule(false);
		 if (rd!=null && !"D".equalsIgnoreCase(rd.getStatus())){
			 rd.setStatus("D");
			 updateLastSchedule(rd);
		 }
	 }

	 public String SynchronizeDemoInfo() {
		 HSFODAO hsfoDao=new HSFODAO();
		 List idList=hsfoDao.getAllPatientId();
		 Iterator itr=idList.iterator();
		 DemographicData demoData = new DemographicData();
		 while (itr.hasNext()){
			 String pid=(String)itr.next();
			 PatientData pd=hsfoDao.retrievePatientRecord(pid);
			 Demographic demo=demoData.getDemographic(pid);
			 String internalId=demo.getProviderNo();
			 if(internalId==null || internalId.length()==0){
				 return demo.getLastName()+","+demo.getFirstName();
			 }
			 pd.setBirthDate(DemographicData.getDOBObj(demo));
			 pd.setSex(demo.getSex().toLowerCase());
			 if (demo.getLastName()!=null
					 && demo.getLastName().trim().length()>0)
				 pd.setLName(demo.getLastName());
			 if (demo.getFirstName()!=null
					 && demo.getFirstName().trim().length()>0)
				 pd.setFName(demo.getFirstName());

			 String pcode=demo.getPostal().trim();
			 if (pcode!=null && pcode.length()>=3)
				 pd.setPostalCode(pcode.substring(0, 3));
			 hsfoDao.updatePatient(pd);
		 }
		 return null;
	 }

	 public String checkProvider() {
		 HSFODAO hsfoDao=new HSFODAO();
		 List idList=hsfoDao.getAllPatientId();
		 Iterator itr=idList.iterator();
		 DemographicData demoData = new DemographicData();
		 while (itr.hasNext()){
			 String pid=(String)itr.next();
			 Demographic demo=demoData.getDemographic(pid);
			 String internalId=demo.getProviderNo();
			 if(internalId==null || internalId.length()==0){
				 return demo.getLastName()+","+demo.getFirstName();
			 }

		 }
		 return null;
	 }


}
