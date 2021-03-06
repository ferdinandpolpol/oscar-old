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


package oscar.form;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import oscar.OscarProperties;
import oscar.login.DBHelp;
import oscar.oscarDB.DBHandler;
import oscar.util.UtilDateUtilities;

public class FrmONAREnhancedRecord extends FrmRecord {
    public Properties getFormRecord(int demographicNo, int existingID) throws SQLException {
        Properties props = new Properties();

        if (existingID <= 0) {
            DBHelp db = new DBHelp();
            String sql = "SELECT demographic_no, last_name, first_name, sex, "
                    + "address, city, province, postal, phone, phone2, "
                    + "year_of_birth, month_of_birth, date_of_birth, hin, hc_type, chart_no FROM demographic WHERE demographic_no = "
                    + demographicNo;
            ResultSet rs = DBHelp.searchDBRecord(sql);
            if (rs.next()) {
                java.util.Date date = UtilDateUtilities.calcDate(oscar.Misc.getString(rs, "year_of_birth"), rs
                        .getString("month_of_birth"), oscar.Misc.getString(rs, "date_of_birth"));
                props.setProperty("demographic_no", oscar.Misc.getString(rs, "demographic_no"));
                props.setProperty("formCreated", UtilDateUtilities
                        .DateToString(UtilDateUtilities.Today(), "yyyy/MM/dd"));
                // props.setProperty("formEdited",
                // UtilDateUtilities.DateToString(UtilDateUtilities.Today(),"yyyy/MM/dd"));
                props.setProperty("c_lastName", oscar.Misc.getString(rs, "last_name"));
                props.setProperty("c_firstName", oscar.Misc.getString(rs, "first_name"));
                props.setProperty("c_address", oscar.Misc.getString(rs, "address"));
                props.setProperty("c_city", oscar.Misc.getString(rs, "city"));
                props.setProperty("c_province", oscar.Misc.getString(rs, "province"));
                props.setProperty("c_postal", oscar.Misc.getString(rs, "postal"));
                props.setProperty("c_hin", oscar.Misc.getString(rs, "hin"));
                if(oscar.Misc.getString(rs, "hc_type").equals("ON")) {
                	 props.setProperty("c_hinType","OHIP");
                } else if(oscar.Misc.getString(rs, "hc_type").equals("QC")) {
                	 props.setProperty("c_hinType","RAMQ");
                } else {
                	 props.setProperty("c_hinType","OTHER");
                }
                props.setProperty("c_fileNo", oscar.Misc.getString(rs, "chart_no"));
                props.setProperty("pg1_dateOfBirth", UtilDateUtilities.DateToString(date, "yyyy/MM/dd"));
                props.setProperty("pg1_age", String.valueOf(UtilDateUtilities.calcAge(oscar.Misc.getString(rs, "year_of_birth"), rs
                        .getString("month_of_birth"), oscar.Misc.getString(rs, "date_of_birth"))));
                props.setProperty("pg1_homePhone", oscar.Misc.getString(rs, "phone"));
                props.setProperty("pg1_workPhone", oscar.Misc.getString(rs, "phone2"));
                props.setProperty("pg1_formDate", UtilDateUtilities.DateToString(UtilDateUtilities.Today(),
                        "yyyy/MM/dd"));
            }
            rs.close();
        } else {
            String sql = "SELECT * FROM formONAREnhanced WHERE demographic_no = " + demographicNo + " AND ID = " + existingID;
            props = (new FrmRecordHelp()).getFormRecord(sql);
        }

        return props;
    }

    public int saveFormRecord(Properties props) throws SQLException {
        String demographic_no = props.getProperty("demographic_no");
        String sql = "SELECT * FROM formONAREnhanced WHERE demographic_no=" + demographic_no + " AND ID=0";

        return ((new FrmRecordHelp()).saveFormRecord(props, sql));
    }

    public Properties getPrintRecord(int demographicNo, int existingID) throws SQLException {
        String sql = "SELECT * FROM formONAREnhanced WHERE demographic_no = " + demographicNo + " AND ID = " + existingID;
        return ((new FrmRecordHelp()).getPrintRecord(sql));
    }

    public String findActionValue(String submit) throws SQLException {
        return ((new FrmRecordHelp()).findActionValue(submit));
    }

    public String createActionURL(String where, String action, String demoId, String formId) throws SQLException {
        return ((new FrmRecordHelp()).createActionURL(where, action, demoId, formId));
    }

    public boolean isSendToPing(String demoNo) throws SQLException {
        boolean ret = false;
        if ("yes".equalsIgnoreCase(OscarProperties.getInstance().getProperty("PHR", ""))) {

            String demographic_no = demoNo;
            
            String sql = "select email from demographic where demographic_no=" + demographic_no;
            ResultSet rs = DBHandler.GetSQL(sql);
            if (rs.next()) {
                if (oscar.Misc.getString(rs, "email") != null && oscar.Misc.getString(rs, "email").length() > 5
                        && oscar.Misc.getString(rs, "email").matches(".*@.*"))
                    ret = true;
            }

            rs.close();
        }
        return ret;
    }

}
