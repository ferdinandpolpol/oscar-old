/**
 * Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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
 */

package oscar.oscarBilling.ca.on.data;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Vector;

import org.apache.log4j.Logger;
import org.apache.struts.util.LabelValueBean;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.billing.CA.ON.dao.BillingClaimDAO;
import org.oscarehr.billing.CA.ON.dao.BillingOnItemPaymentDao;
import org.oscarehr.billing.CA.ON.model.BillingClaimHeader1;
import org.oscarehr.common.model.Provider;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class JdbcBillingReviewImpl {
	private static final Logger _logger = Logger
			.getLogger(JdbcBillingReviewImpl.class);
	BillingONDataHelp dbObj = new BillingONDataHelp();

	public String getCodeFee(String val, String billReferalDate) {
		String retval = null;
		String sql = "select value, termination_date from billingservice where service_code='"
				+ val
				+ "' and billingservice_date = (select max(billingservice_date) from billingservice where billingservice_date <= '"
				+ billReferalDate + "' and service_code = '" + val + "')";

		// _logger.info("getCodeFee(sql = " + sql + ")");
		ResultSet rs = dbObj.searchDBRecord(sql);

		try {
			if (rs.next()) {
				retval = rs.getString("value");

				DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
				Date serviceDate = df.parse(billReferalDate);
				String tDate = rs.getString("termination_date");
				Date termDate = df.parse(tDate);
				if (termDate.before(serviceDate)) {
					retval = "defunct";
				}
			}
			rs.close();
		} catch (SQLException e) {
			_logger.error("getCodeFee(sql = " + sql + ")");
			MiscUtils.getLogger().error("Error", e);
		} catch (ParseException e) {
			_logger.error("Parse service date error");
			MiscUtils.getLogger().error("Error", e);
		}

		return retval;
	}

	public String getPercFee(String val, String billReferalDate) {
		String retval = null;
		String sql = "select percentage from billingservice where service_code='"
				+ val
				+ "' and billingservice_date = (select max(billingservice_date) from billingservice where billingservice_date <= '"
				+ billReferalDate + "' and service_code = '" + val + "')";

		// _logger.info("getCodeFee(sql = " + sql + ")");
		ResultSet rs = dbObj.searchDBRecord(sql);

		try {
			while (rs.next()) {
				retval = rs.getString("percentage");
			}
			rs.close();
		} catch (SQLException e) {
			_logger.error("getPercFee(sql = " + sql + ")");
		}

		return retval;
	}

	public String[] getPercMinMaxFee(String val, String billReferalDate) {
		String[] retval = { "", "" };
		String sql = "select b.min, b.max from billingperclimit b where b.service_code='"
				+ val
				+ "' and  b.effective_date = (select max(b2.effective_date) from billingperclimit b2 where b2.effective_date <= '"
				+ billReferalDate + "' and b2.service_code = '" + val + "')";

		// _logger.info("getCodeFee(sql = " + sql + ")");
		ResultSet rs = dbObj.searchDBRecord(sql);

		try {
			while (rs.next()) {
				retval[0] = rs.getString("min");
				retval[1] = rs.getString("max");
			}
			rs.close();
		} catch (SQLException e) {
			_logger.error("getPercMinMaxFee(sql = " + sql + ")");
		}

		return retval;
	}

	// invoice report
	public List getBill(String billType, String statusType, String providerNo,
			String startDate, String endDate, String demoNo) {
		List retval = new Vector();
		BillingClaimHeader1Data ch1Obj = null;
		String temp = demoNo + " " + providerNo + " " + statusType + " "
				+ startDate + " " + endDate + " " + billType;
		temp = temp.trim().startsWith("and") ? temp.trim().substring(3) : temp;
		String sql = "select id,pay_program,billing_on_cheader1.demographic_no,demographic_name,billing_date,billing_time,status,"
				+ "provider_no,provider_ohip_no, apptProvider_no,timestamp1,total,paid,clinic"
				+ " from billing_on_cheader1 "
				+ "where "
				+ temp
				+ " order by billing_date, billing_time";

		_logger.info("getBill(sql = " + sql + ")");
		ResultSet rs = dbObj.searchDBRecord(sql);

		try {
			while (rs.next()) {
				ch1Obj = new BillingClaimHeader1Data();
				ch1Obj.setId("" + rs.getInt("id"));
				ch1Obj.setDemographic_no("" + rs.getInt("demographic_no"));
				ch1Obj.setDemographic_name(rs.getString("demographic_name"));
				ch1Obj.setBilling_date(rs.getString("billing_date"));
				ch1Obj.setBilling_time(rs.getString("billing_time"));
				ch1Obj.setStatus(rs.getString("status"));
				ch1Obj.setProviderNo(rs.getString("provider_no"));
				ch1Obj.setProvider_ohip_no(rs.getString("provider_ohip_no"));
				ch1Obj.setApptProvider_no(rs.getString("apptProvider_no"));
				ch1Obj.setUpdate_datetime(rs.getString("timestamp1"));
				ch1Obj.setTotal(rs.getString("total"));
				ch1Obj.setPay_program(rs.getString("pay_program"));
				ch1Obj.setPaid(rs.getString("paid"));

				sql = "select value from billing_on_ext where key_val = 'payDate' and billing_no = "
						+ rs.getInt("id");
				ResultSet rs2 = dbObj.searchDBRecord(sql);
				if (rs2.next()) {
					ch1Obj.setSettle_date(rs2.getString("value"));
				}
				rs2.close();

				ch1Obj.setClinic(rs.getString("clinic"));

				retval.add(ch1Obj);
			}
			rs.close();
		} catch (SQLException e) {
			_logger.error("getBill(sql = " + sql + ")");
		}
		return retval;
	}

	// invoice report
	public List getBill(String billType, String statusType, String providerNo,
			String startDate, String endDate, String demoNo,
			String serviceCodes, String dx, String visitType) {
		List retval = new Vector();
		BillingClaimHeader1Data ch1Obj = null;

		// modify by rohit : for filtering invoice report based on dx code
		String temp = demoNo + " " + providerNo + " " + statusType + " "
				+ startDate + " " + endDate + " " + billType + " " + dx + " "
				+ visitType + " " + serviceCodes;
		temp = temp.trim().startsWith("and") ? temp.trim().substring(3) : temp;
		String sql = "SELECT ch1.id,ch1.pay_program,ch1.demographic_no,ch1.demographic_name,ch1.billing_date,ch1.billing_time,"
				+ "ch1.status,ch1.provider_no,ch1.provider_ohip_no,ch1.apptProvider_no,ch1.timestamp1,ch1.total,ch1.paid,ch1.clinic,"
				+ "bi.fee, bi.service_code, bi.dx, bi.id as billing_on_item_id "
				+ "FROM billing_on_item bi LEFT JOIN billing_on_cheader1 ch1 ON ch1.id=bi.ch1_id "
				+ "WHERE "
				+ temp
				+ " and bi.status!='D' "
				+ " ORDER BY ch1.billing_date, ch1.billing_time";
		
		_logger.info("getBill(sql = " + sql + ")");
		ResultSet rs = dbObj.searchDBRecord(sql);

		if (rs != null) {
			try {
				String prevId = null;
				String prevPaid = null;
				BillingOnItemPaymentDao billOnItemPaymentDao = (BillingOnItemPaymentDao)SpringUtils.getBean(BillingOnItemPaymentDao.class);
				while (rs.next()) {

					boolean bSameBillCh1 = false;
					ch1Obj = new BillingClaimHeader1Data();
					ch1Obj.setId("" + rs.getInt("id"));
					ch1Obj.setDemographic_no("" + rs.getInt("demographic_no"));
					ch1Obj.setDemographic_name(rs.getString("demographic_name"));
					ch1Obj.setBilling_date(rs.getString("billing_date"));
					ch1Obj.setBilling_time(rs.getString("billing_time"));
					ch1Obj.setStatus(rs.getString("status"));
					ch1Obj.setProviderNo(rs.getString("provider_no"));
					ch1Obj.setProvider_ohip_no(rs.getString("provider_ohip_no"));
					ch1Obj.setApptProvider_no(rs.getString("apptProvider_no"));
					ch1Obj.setUpdate_datetime(rs.getString("timestamp1"));

					ch1Obj.setClinic(rs.getString("clinic"));

					// ch1Obj.setTotal(rs.getString("total"));
					ch1Obj.setPay_program(rs.getString("pay_program"));
					/*
					 * if (!bSameBillCh1) ch1Obj.setPaid(rs.getString("paid"));
					 * else ch1Obj.setPaid("0.00");
					 */
					if("PAT".equals(rs.getString("pay_program"))){
						BigDecimal amountPaid = billOnItemPaymentDao.getAmountPaidByItemId(rs.getInt(18));
						ch1Obj.setPaid(amountPaid.toString());
					}else{
						if (!(ch1Obj.getId().equals(prevId) && rs.getString("paid")
								.equals(prevPaid))) {
							ch1Obj.setPaid(rs.getString("paid"));
						} else
							ch1Obj.setPaid("0.00");
					}
					ch1Obj.setTotal(rs.getString("fee"));
					ch1Obj.setRec_id(rs.getString("dx"));
					ch1Obj.setTransc_id(rs.getString("service_code"));

					retval.add(ch1Obj);
					// bSameBillCh1 = true;
					prevId = ch1Obj.getId();
					prevPaid = rs.getString("paid");

				}

				rs.close();
			} catch (SQLException e) {
				_logger.error("getBill(sql = " + sql + ")");
			}
		}
		return retval;
	}
	
	@SuppressWarnings("rawtypes")
	public List getBillingHist(String demoNo, int iPageSize, int iOffset, Date strStart,Date strToday) throws Exception {
		List retval = new Vector();
		BillingClaimHeader1Data ch1Obj = null;
		String sql;
		BillingClaimDAO billingclaimdao = (BillingClaimDAO)SpringUtils.getBean(BillingClaimDAO.class);
		ProviderDao providerdao = (ProviderDao)SpringUtils.getBean(ProviderDao.class);
		Provider provider = null;
		List<BillingClaimHeader1> rs= null;
		
		rs = billingclaimdao.getInvoices(demoNo, iPageSize, iOffset, strStart, strToday);
		for(int i=0;i<rs.size();i++){
			provider = new Provider();
			ch1Obj = new BillingClaimHeader1Data();
			ch1Obj.setId("" + rs.get(i).getId());
			ch1Obj.setBilling_date(rs.get(i).getBilling_date().toString());
			ch1Obj.setBilling_time(rs.get(i).getBilling_time().toString());
			ch1Obj.setStatus(rs.get(i).getStatus());
			ch1Obj.setProviderNo(rs.get(i).getProvider_no());
			ch1Obj.setApptProvider_no(rs.get(i).getApptProvider_no());
			ch1Obj.setUpdate_datetime(rs.get(i).getTimestamp1().toString());

			ch1Obj.setClinic(rs.get(i).getClinic());
			ch1Obj.setAppointment_no(rs.get(i).getAppointment_no());
			ch1Obj.setPay_program(rs.get(i).getPay_program());
			ch1Obj.setVisittype(rs.get(i).getVisittype());
			ch1Obj.setAdmission_date(rs.get(i).getAdmission_date());
			ch1Obj.setFacilty_num(rs.get(i).getFacilty_num());
			ch1Obj.setTotal(rs.get(i).getTotal());
			provider = providerdao.getProvider(rs.get(i).getProvider_no());
			ch1Obj.setLast_name(provider.getLastName());
			ch1Obj.setFirst_name(provider.getFirstName());
			retval.add(ch1Obj);

			sql = "select boi.*,boip.paid,boip.refund,boip.discount from billing_on_item boi left join billing_on_item_payment boip ON boi.id=boip.billing_on_item_id where boi.ch1_id="
					+ ch1Obj.getId() + " and boi.status!='D'";
			// SELECT boi.*,boip.paid,boip.refund,boip.discount FROM billing_on_item boi 
			// LEFT JOIN billing_on_item_payment boip ON boi.id=boip.billing_on_item_id WHERE boi.status!='D'

			// _logger.info("getBillingHist(sql = " + sql + ")");

			ResultSet rs2 = dbObj.searchDBRecord(sql);
			String dx = "";
			Set<String> serviceCodeSet = new HashSet<String>();
			
			String strServiceDate = "";
			BigDecimal paid = new BigDecimal("0.00");
			BigDecimal refund = new BigDecimal("0.00");
			BigDecimal discount = new BigDecimal("0.00");
			while (rs2.next()) {
				String strService = rs2.getString("service_code") + " x "
						+ rs2.getString("ser_num") + "";
				serviceCodeSet.add(strService);
				dx = rs2.getString("dx");
				strServiceDate = rs2.getString("service_date");
				try {
					paid = paid.add(rs2.getBigDecimal("paid"));
				} catch (Exception e) {}
				try {
					refund = refund.add(rs2.getBigDecimal("refund"));
				} catch (Exception e) {}
				try {
					discount = discount.add(rs2.getBigDecimal("discount"));
				} catch (Exception e) {}
			}
			rs2.close();
			BillingItemData itObj = new BillingItemData();
			StringBuffer codeBuf = new StringBuffer();
			for (String codeStr : serviceCodeSet) {
				codeBuf.append(codeStr + ",");
			}
			if (codeBuf.length() > 0) {
				codeBuf.deleteCharAt(codeBuf.length() - 1);
			}
			itObj.setService_code(codeBuf.toString());
			itObj.setDx(dx);
			itObj.setService_date(strServiceDate);
			itObj.setPaid(paid.toString());
			itObj.setRefund(refund.toString());
			itObj.setDiscount(discount.toString());
			retval.add(itObj);
		}
		return retval;
	}
	

	public List<LabelValueBean> listBillingForms() {
		List<LabelValueBean> res = null;
		try {
			String sql = "select distinct servicetype, servicetype_name from ctl_billingservice"
					+ " where status!='D' and servicetype is not null AND LENGTH(TRIM(servicetype))>0";
			_logger.trace("billing forms list: " + sql);
			ResultSet rs = dbObj.searchDBRecord(sql);
			if (rs != null && rs.next()) {
				res = new ArrayList<LabelValueBean>();
				do {
					String servicetype = rs.getString("servicetype");
					String servicetypename = rs.getString("servicetype_name");
					res.add(new LabelValueBean(servicetypename, servicetype));
				} while (rs.next());

			}
		} catch (SQLException ex) {
			_logger.error("Error getting billing forms list", ex);
		}
		return res;
	}

	public List<String> mergeServiceCodes(String serviceCodes,
			String billingForm) {
		List<String> serviceCodeList = null;

		if (serviceCodes != null && serviceCodes.length() > 0) {
			String[] serviceArray = serviceCodes.split(",");
			serviceCodeList = new ArrayList<String>();
			for (int i = 0; i < serviceArray.length; i++) {
				serviceCodeList.add("bi.service_code like '%"
						+ serviceArray[i].trim() + "%'");
			}
		}

		if (billingForm != null && billingForm.length() > 0) {
			String sql = "select distinct service_code from ctl_billingservice "
					+ " where status!='D' and servicetype='"
					+ billingForm
					+ "'";
			_logger.trace("billing forms list: " + sql);
			try {
				ResultSet rs = dbObj.searchDBRecord(sql);
				if (rs != null && rs.next()) {
					if (serviceCodeList == null)
						serviceCodeList = new ArrayList<String>();
					do {
						String serviceCode = rs.getString("service_code");
						serviceCodeList.add("bi.service_code='" + serviceCode
								+ "'");
					} while (rs.next());
				}
			} catch (SQLException ex) {
				_logger.error("Error getting billing forms list", ex);
			}
		}

		return serviceCodeList;
	}
      
	public List getBillingByApptNo(String apptNo) throws Exception {
		List retval = new Vector();
		BillingClaimHeader1Data ch1Obj = null;
		String sql;
		BillingClaimDAO billingclaimdao = (BillingClaimDAO)SpringUtils.getBean(BillingClaimDAO.class);
		List<BillingClaimHeader1> rs= null;
		rs = billingclaimdao.getInvoicesByApptNo(apptNo);
		for(int i =0;i<rs.size();i++){
			ch1Obj = new BillingClaimHeader1Data();
			ch1Obj.setId("" + rs.get(i).getId());
			ch1Obj.setBilling_date(rs.get(i).getBilling_date().toString());
			ch1Obj.setBilling_time(rs.get(i).getBilling_time().toString());
			ch1Obj.setStatus(rs.get(i).getStatus());
			ch1Obj.setProviderNo(rs.get(i).getProvider_no());
			ch1Obj.setAppointment_no(rs.get(i).getAppointment_no());
			ch1Obj.setApptProvider_no(rs.get(i).getApptProvider_no());
			ch1Obj.setAsstProvider_no(rs.get(i).getAsstProvider_no());
			ch1Obj.setMan_review(rs.get(i).getMan_review());

			ch1Obj.setUpdate_datetime(rs.get(i).getTimestamp1().toString());

			ch1Obj.setClinic(rs.get(i).getClinic());

			ch1Obj.setPay_program(rs.get(i).getPay_program());
			ch1Obj.setVisittype(rs.get(i).getVisittype());
			ch1Obj.setAdmission_date(rs.get(i).getAdmission_date());
			ch1Obj.setFacilty_num(rs.get(i).getFacilty_num());
			ch1Obj.setHin(rs.get(i).getHin());
			ch1Obj.setVer(rs.get(i).getVer());
			ch1Obj.setProvince(rs.get(i).getProvince());
			ch1Obj.setDob(rs.get(i).getDob());
			ch1Obj.setDemographic_name(rs.get(i).getDemographic_name());
			ch1Obj.setDemographic_no(rs.get(i).getDemographic_no().toString());

			ch1Obj.setTotal(rs.get(i).getTotal());
			retval.add(ch1Obj);

			sql = "select * from billing_on_item where ch1_id="
					+ ch1Obj.getId() + " and status!='D'";

			// _logger.info("getBillingHist(sql = " + sql + ")");

			ResultSet rs2 = dbObj.searchDBRecord(sql);
			String dx = null;
			String dx1 = null;
			String dx2 = null;
			String strService = null;
			String strServiceDate = null;

			while (rs2.next()) {
				strService += rs2.getString("service_code") + " x "
						+ rs2.getString("ser_num") + ", ";
				dx = rs2.getString("dx");
				strServiceDate = rs2.getString("service_date");
				dx1 = rs2.getString("dx1");
				dx2 = rs2.getString("dx2");
			}
			rs2.close();
			BillingItemData itObj = new BillingItemData();
			itObj.setService_code(strService);
			itObj.setDx(dx);
			itObj.setDx1(dx1);
			itObj.setDx2(dx2);
			itObj.setService_date(strServiceDate);
			retval.add(itObj);

		}
		return null;
	}
	

}
