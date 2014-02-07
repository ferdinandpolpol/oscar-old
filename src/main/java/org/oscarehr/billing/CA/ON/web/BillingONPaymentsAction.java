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

package org.oscarehr.billing.CA.ON.web;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.billing.CA.ON.dao.BillingClaimDAO;
import org.oscarehr.billing.CA.ON.dao.BillingONExtDao;
import org.oscarehr.billing.CA.ON.dao.BillingONPaymentDao;
import org.oscarehr.billing.CA.ON.dao.BillingOnItemPaymentDao;
import org.oscarehr.billing.CA.ON.dao.BillingOnTransactionDao;
import org.oscarehr.billing.CA.ON.model.BillingClaimHeader1;
import org.oscarehr.billing.CA.ON.model.BillingONExt;
import org.oscarehr.billing.CA.ON.model.BillingONPayment;
import org.oscarehr.billing.CA.ON.model.BillingOnItemPayment;
import org.oscarehr.billing.CA.ON.model.BillingOnTransaction;
import org.oscarehr.billing.CA.ON.vo.BillingItemPaymentVo;
import org.oscarehr.billing.CA.dao.BillingPaymentTypeDao;
import org.oscarehr.billing.CA.model.BillingPaymentType;
import org.oscarehr.common.dao.BillingONCHeader1Dao;
import org.oscarehr.common.model.BillingONCHeader1;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

import oscar.oscarBilling.ca.on.dao.BillingOnItemDao;
import oscar.oscarBilling.ca.on.data.BillingClaimHeader1Data;
import oscar.oscarBilling.ca.on.data.BillingDataHlp;
import oscar.oscarBilling.ca.on.data.JdbcBilling3rdPartImpl;
import oscar.oscarBilling.ca.on.data.JdbcBillingCorrection;
import oscar.oscarBilling.ca.on.model.BillingOnCHeader1;
import oscar.oscarBilling.ca.on.model.BillingOnItem;
import oscar.oscarBilling.ca.on.model.BillingOnPaymentItem;
import oscar.oscarBilling.ca.on.pageUtil.BillingCorrectionPrep;

/**
 * 
 * @author rjonasz
 */
public class BillingONPaymentsAction extends DispatchAction {
	private static Logger logger = Logger
			.getLogger(BillingONPaymentsAction.class);

	private BillingOnItemDao billingOnItemDao;
	private BillingONPaymentDao billingONPaymentDao;
	private BillingPaymentTypeDao billingPaymentTypeDao;
	private BillingClaimDAO billingClaimDAO;
	private BillingONExtDao billingONExtDao;
	private BillingOnItemPaymentDao billingOnItemPaymentDao;
	private BillingOnTransactionDao billingOnTransactionDao;

	public ActionForward listPayments(ActionMapping actionMapping,
			ActionForm actionForm, HttpServletRequest request,
			HttpServletResponse response) {
		Integer billingNo = Integer.parseInt(request.getParameter("billingNo"));
		
		List<BillingONPayment> paymentLists = billingONPaymentDao.listPaymentsByBillingNo(billingNo);
		if (paymentLists == null) {
			paymentLists = new ArrayList<BillingONPayment>();
		}
		request.setAttribute("paymentsList", paymentLists);
		
		List<BillingOnItem> items = billingOnItemDao.getShowBillingItemByCh1Id(billingNo);
		List<BillingItemPaymentVo> itemPaymentList = new ArrayList<BillingItemPaymentVo>();
		for (BillingOnItem item : items) {
			List<BillingOnItemPayment> paymentList = billingOnItemPaymentDao.getAllByItemId(item.getId());
			BigDecimal payment = BigDecimal.ZERO;
			BigDecimal discount = BigDecimal.ZERO;
			BigDecimal refund = BigDecimal.ZERO;
			for (BillingOnItemPayment payIter : paymentList) {
				payment = payment.add(payIter.getPaid());
				discount = discount.add(payIter.getDiscount());
				refund = refund.add(payIter.getRefund());
			}
			
			BillingItemPaymentVo itemPayment = new BillingItemPaymentVo();
			itemPayment.setItemId(item.getId());
			itemPayment.setServiceCode(item.getService_code());
			itemPayment.setPaid(payment);
			itemPayment.setRefund(refund);
			itemPayment.setTotal(new BigDecimal(item.getFee()));
			itemPayment.setDiscount(discount);
			itemPaymentList.add(itemPayment);
		}
		
		request.setAttribute("itemPaymentList", itemPaymentList);
		List<BillingPaymentType> paymentTypes = billingPaymentTypeDao.list();
		request.setAttribute("paymentTypeList", paymentTypes);
		
		BillingClaimHeader1 cheader1 = billingClaimDAO.find(billingNo);
		Integer demographicNo = cheader1.getDemographic_no();
		BigDecimal payment = BigDecimal.ZERO;
		BigDecimal balance = BigDecimal.ZERO;
		BigDecimal total = BigDecimal.ZERO;
		BigDecimal refund = BigDecimal.ZERO;
		BigDecimal discount = BigDecimal.ZERO;
		
		BillingONExt paymentItem = billingONExtDao.getClaimExtItem(billingNo, demographicNo, BillingONExtDao.KEY_PAYMENT);
		if (paymentItem != null) {
			payment = new BigDecimal(paymentItem.getValue());
		}
		BillingONExt discountItem = billingONExtDao.getClaimExtItem(billingNo, demographicNo, BillingONExtDao.KEY_DISCOUNT);
		if (discountItem != null) {
			discount = new BigDecimal(discountItem.getValue());
		}
		BillingONExt refundItem = billingONExtDao.getClaimExtItem(billingNo, demographicNo, BillingONExtDao.KEY_REFUND);
		if (refundItem != null) {
			refund = new BigDecimal(refundItem.getValue());
		}
		BillingONExt totalItem = billingONExtDao.getClaimExtItem(billingNo, demographicNo, BillingONExtDao.KEY_TOTAL);
		if (totalItem != null) {
			total = new BigDecimal(totalItem.getValue());
		}
		balance = total.subtract(payment).subtract(discount).subtract(refund);
		
		request.setAttribute("totalInvoiced", total);
		request.setAttribute("balance", balance);
	
		return actionMapping.findForward("success");
	}
	
	public ActionForward savePayment(ActionMapping actionMapping,
			ActionForm actionForm, HttpServletRequest request,
			HttpServletResponse response) throws ParseException {

		Date curDate = new Date();
		String paymentdate1=request.getParameter("paymentDate");
		SimpleDateFormat sim=new SimpleDateFormat("yyyy-MM-dd");
	    Date paymentdate=sim.parse(paymentdate1);
		
		int itemSize = Integer.parseInt(request.getParameter("size"));
		int billNo = Integer.parseInt(request.getParameter("billingNo"));
		String curProviderNo = (String) request.getSession().getAttribute("user");
		String paymentTypeId = request.getParameter("paymentType");
		if (paymentTypeId == null || paymentTypeId.isEmpty()) {
			paymentTypeId = "0";
		}

		// get all paid, discount and refund list
		BigDecimal sumPaid = BigDecimal.ZERO;
		BigDecimal sumRefund = BigDecimal.ZERO;
		BigDecimal sumDiscount = BigDecimal.ZERO;
		for (int i = 0; i < itemSize; i++) {
			String payment = request.getParameter("payment" + i);
			String discount = request.getParameter("discount" + i);
			String itemId = request.getParameter("itemId" + i);
			if (billingOnItemDao.getBillingItemById(Integer.parseInt(itemId)).size() > 0) {
				if ("payment".equals(request.getParameter("sel" + i))) {
					BigDecimal pay = BigDecimal.ZERO;
					BigDecimal dicnt = BigDecimal.ZERO;
					try {
						pay = new BigDecimal(payment);
					} catch (Exception e) {}
					if (pay.compareTo(BigDecimal.ZERO) == 1) {
						sumPaid = sumPaid.add(pay);
					}
					try {
						dicnt = new BigDecimal(discount);
					} catch (Exception e) {}
					if (dicnt.compareTo(BigDecimal.ZERO) == 1) {
						sumDiscount = sumDiscount.add(dicnt);
					}
				} else if ("refund".equals(request.getParameter("sel" + i))) {
					BigDecimal refundTmp = BigDecimal.ZERO;
					try {
						refundTmp = new BigDecimal(payment);
					} catch (Exception e) {}
					if (refundTmp.compareTo(BigDecimal.ZERO) == 1) {
						sumRefund = sumRefund.add(refundTmp);
					}
				}
			}
		}
		JSONObject ret = new JSONObject();
		if (sumPaid.compareTo(BigDecimal.ZERO) == 0
				&& sumDiscount.compareTo(BigDecimal.ZERO) == 0
				&& sumRefund.compareTo(BigDecimal.ZERO) == 0) {
			ret.put("ret", 1);
			ret.put("reason", "Payments, discounts and refunds can't be all zeros!!");
			response.setCharacterEncoding("utf-8");
			response.setContentType("html/text");
			try {
				response.getWriter().print(ret.toString());
				response.getWriter().flush();
				response.getWriter().close();
			} catch (Exception e) {
				logger.info(e.toString());
				return actionMapping.findForward("failure");
			}
			return null;
		}
		
		// count sum of paid,refund,discount
		BillingClaimHeader1 cheader1 = billingClaimDAO.find(billNo);
		if (cheader1 == null) {
			return actionMapping.findForward("failure");
		}
		String demographicNo = cheader1.getDemographic_no().toString();
	
		// 1.update billing_on_cheader1 and billing_on_ext table: payment
		JdbcBilling3rdPartImpl tExtObj = new JdbcBilling3rdPartImpl();
		if (sumPaid.compareTo(BigDecimal.ZERO) == 1) {
			BigDecimal sumPaidTmp = sumPaid.add(new BigDecimal(cheader1.getPaid()));
			cheader1.setPaid(sumPaidTmp.toString());
			billingClaimDAO.merge(cheader1);
			if (tExtObj.keyExists(Integer.toString(billNo), BillingONExtDao.KEY_PAYMENT)) {
				tExtObj.updateKeyValue(Integer.toString(billNo), BillingONExtDao.KEY_PAYMENT, sumPaidTmp.toString());
			} else {
				tExtObj.add3rdBillExt(Integer.toString(billNo), demographicNo, BillingONExtDao.KEY_PAYMENT, sumPaidTmp.toString());
			}
		}
		
		// 2.update billing_on_ext table: discount
		if (sumDiscount.compareTo(BigDecimal.ZERO) == 1) {
			BigDecimal extDiscount = BigDecimal.ZERO;
			try {
				extDiscount = new BigDecimal(billingONExtDao.getClaimExtDiscount(billNo));
			} catch (Exception e) {
				MiscUtils.getLogger().info(e.toString());
			}
			BigDecimal sumDiscountTmp = sumDiscount.add(extDiscount);
			if (tExtObj.keyExists(Integer.toString(billNo), BillingONExtDao.KEY_DISCOUNT)) {
				tExtObj.updateKeyValue(Integer.toString(billNo), BillingONExtDao.KEY_DISCOUNT, sumDiscountTmp.toString());
			} else {
				tExtObj.add3rdBillExt(Integer.toString(billNo), demographicNo, BillingONExtDao.KEY_DISCOUNT, sumDiscountTmp.toString());
			}
		}
		
		// 3.update billing_on_ext table: refund
		if (sumRefund.compareTo(BigDecimal.ZERO) == 1) {
			BigDecimal extRefund = BigDecimal.ZERO;
			try {
				extRefund = new BigDecimal(billingONExtDao.getClaimExtRefund(billNo));
			} catch (Exception e) {
				MiscUtils.getLogger().info(e.toString());
			}
			BigDecimal sumRefundTmp = sumRefund.add(extRefund);
			if (tExtObj.keyExists(Integer.toString(billNo), BillingONExtDao.KEY_REFUND)) {
				tExtObj.updateKeyValue(Integer.toString(billNo), BillingONExtDao.KEY_REFUND, sumRefundTmp.toString());
			} else {
				tExtObj.add3rdBillExt(Integer.toString(billNo), demographicNo, BillingONExtDao.KEY_REFUND, sumRefundTmp.toString());
			}
		}

		// 4.update billing_on_payment
		BillingONPayment billPayment = new BillingONPayment();
		billPayment.setBillingOnCheader1(cheader1);
		billPayment.setCreator(curProviderNo);
		billPayment.setPaymentDate(paymentdate);
		billPayment.setPaymentTypeId(Integer.parseInt(paymentTypeId));
		billPayment.setTotal_payment(sumPaid);
		billPayment.setTotal_discount(sumDiscount);
		billPayment.setTotal_refund(sumRefund);
		billingONPaymentDao.persist(billPayment);
		
		// 5.update biling_on_item_payment
		for (int i = 0; i < itemSize; i++) {
			String payment = request.getParameter("payment" + i);
			String discount = request.getParameter("discount" + i);
			String itemId = request.getParameter("itemId" + i);
			BillingOnItem billItem = null;
			try {
				List<BillingOnItem> itemList = billingOnItemDao.getBillingItemById(Integer.parseInt(itemId));
				if (itemList == null || itemList.size() == 0) {
					continue;
				}
				billItem = itemList.get(0);
			} catch (Exception e) {
				logger.info(e.toString());
				continue;
			}
            
			//String str=paymentdate1+" 00:00:00";
     		//SimpleDateFormat sim1=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    	    //Date paymentdatetmp=sim1.parse(str);
			BillingOnItemPayment billItemPayment = new BillingOnItemPayment();
			billItemPayment.setBillingOnItemId(Integer.parseInt(itemId));
			billItemPayment.setBillingOnPaymentId(billPayment.getId());
			billItemPayment.setCh1Id(billNo);
			billItemPayment.setPaymentTimestamp(new Timestamp(curDate.getTime()));
			
			if ("payment".equals(request.getParameter("sel" + i))) {
				BigDecimal itemPayment = BigDecimal.ZERO;
				BigDecimal itemDiscnt = BigDecimal.ZERO;
				try {
					itemPayment = new BigDecimal(payment);
				} catch (Exception e) {}
				try {
					itemDiscnt = new BigDecimal(discount);
				} catch (Exception e) {}
				
				if (itemPayment.compareTo(BigDecimal.ZERO) == 0 && itemDiscnt.compareTo(BigDecimal.ZERO) == 0) {
					continue;
				}
				billItemPayment.setPaid(itemPayment);
				billItemPayment.setDiscount(itemDiscnt);
				billingOnItemPaymentDao.persist(billItemPayment);
				BillingOnTransaction billTrans = billingOnTransactionDao.getTransTemplate(cheader1, billItem, billPayment, curProviderNo,billItemPayment.getId());
				billTrans.setServiceCodePaid(itemPayment);
				billTrans.setServiceCodeDiscount(itemDiscnt);
				billingOnTransactionDao.persist(billTrans);
			} else if ("refund".equals(request.getParameter("sel" + i))) {
				BigDecimal itemRefund = BigDecimal.ZERO;
				try {
					itemRefund = new BigDecimal(payment);
				} catch (Exception e) {}
				if (itemRefund.compareTo(BigDecimal.ZERO) == 0) {
					continue;
				}
				billItemPayment.setRefund(itemRefund);
				billingOnItemPaymentDao.persist(billItemPayment);
				BillingOnTransaction billTrans = billingOnTransactionDao.getTransTemplate(cheader1, billItem, billPayment, curProviderNo,billItemPayment.getId());
				billTrans.setServiceCodeRefund(itemRefund);
				billingOnTransactionDao.persist(billTrans);
			}
			//billingOnItemPaymentDao.persist(billItemPayment);
		}
		ret.put("ret", 0);
		response.setCharacterEncoding("utf-8");
		response.setContentType("html/text");
		try {
			response.getWriter().print(ret.toString());
			response.getWriter().flush();
			response.getWriter().close();
		} catch (Exception e) {
			logger.info(e.toString());
			return actionMapping.findForward("failure");
		}
		return null;

	}

	public ActionForward deletePayment(ActionMapping actionMapping,
			ActionForm actionForm, HttpServletRequest request,
			HttpServletResponse response) {

		Date curDate = new Date();
		try {
			Integer paymentId = Integer.parseInt(request.getParameter("id"));
			BillingONPayment payment = billingONPaymentDao.find(paymentId);
			BillingClaimHeader1 ch1 = payment.getBillingONCheader1();
			Integer billingNo = payment.getBillingONCheader1().getId();

			billingONPaymentDao.remove(paymentId);

			BigDecimal paid = billingONPaymentDao
					.getPaymentsSumByBillingNo(billingNo);
			BigDecimal refund = billingONPaymentDao
					.getPaymentsRefundByBillingNo(billingNo).negate();
			NumberFormat currency = NumberFormat.getCurrencyInstance();
			ch1.setPaid(currency.format(paid.subtract(refund)).replace("$", ""));
			billingClaimDAO.merge(ch1);

			billingONExtDao.setExtItem(billingNo, ch1.getDemographic_no(),
					BillingONExtDao.KEY_PAYMENT,
					currency.format(paid).replace("$", ""), curDate, '1');
			billingONExtDao.setExtItem(billingNo, ch1.getDemographic_no(),
					BillingONExtDao.KEY_REFUND, currency.format(refund)
							.replace("$", ""), curDate, '1');

		} catch (Exception ex) {
			logger.error(
					"Failed to delete payment: " + request.getParameter("id"),
					ex);
			return actionMapping.findForward("failure");
		}

		return listPayments(actionMapping, actionForm, request, response);

	}
	
	public ActionForward viewPayment(ActionMapping actionMapping,
			ActionForm actionForm, HttpServletRequest request,
			HttpServletResponse response) {
		String id = request.getParameter("paymentId");
		int paymentId = 0;
		try {
			paymentId = Integer.parseInt(id);
			if (paymentId == 0) {
				return actionMapping.findForward("failure");
			}
		} catch (Exception e) {
			logger.info(e.toString());
			return actionMapping.findForward("failure");
		}
		BillingONPayment billPayment = billingONPaymentDao.find(paymentId);
		if (billPayment == null) {
			return actionMapping.findForward("failure");
		}
		List<BillingOnItemPayment> itemPaymentList = billingOnItemPaymentDao.getItemsByPaymentId(paymentId);
		if (itemPaymentList == null) {
			return actionMapping.findForward("failure");
		}
		JSONArray payDetail = new JSONArray();

		// payment date object
		JSONObject paymentDateObj = new JSONObject();
		paymentDateObj.put("paymentDate", new SimpleDateFormat("yyyy-MM-dd").format(billPayment.getPaymentDate()));
		payDetail.add(paymentDateObj);
		
		// payment type object
		JSONObject typeObj = new JSONObject();
		typeObj.put("paymentType", billPayment.getPaymentTypeId());
		payDetail.add(typeObj);
		
		for (BillingOnItemPayment itemPayment : itemPaymentList) {
			JSONObject itemObj = new JSONObject();
			itemObj.put("id", itemPayment.getBillingOnItemId());
			if (itemPayment.getRefund().compareTo(BigDecimal.ZERO) == 0) {
				itemObj.put("type", "payment");
				itemObj.put("payment", itemPayment.getPaid());
				itemObj.put("discount", itemPayment.getDiscount());
			} else {
				itemObj.put("type", "refund");
				itemObj.put("refund", itemPayment.getRefund());
			}
			payDetail.add(itemObj);
		}
		response.setCharacterEncoding("utf-8"); 
        response.setContentType("html/text");
		try {
			response.getWriter().print(payDetail.toString());
			response.getWriter().flush();
			response.getWriter().close();
		} catch (Exception e) {
			logger.info(e.toString());
			return actionMapping.findForward("failure");
		}
		
		return null;
	}
	
	public ActionForward viewPayment_ext(ActionMapping actionMapping,
			ActionForm actionForm, HttpServletRequest request,
			HttpServletResponse response) {
		// 1.get payment details according to billing_on_item_payment
		int billPaymentId = 0;
		try {
			billPaymentId = Integer.parseInt(request.getParameter("billPaymentId"));
		} catch (Exception e) {
			MiscUtils.getLogger().info(e.toString());
			return null;
		}
		BillingONPayment billPayment = billingONPaymentDao.find(billPaymentId);
		if (billPayment == null) {
			return null;
		}
		request.setAttribute("billPayment", billPayment);
		List<BillingItemPaymentVo> itemPaymentVoList = new ArrayList<BillingItemPaymentVo>();
		List<BillingOnItemPayment> itemPaymentList = billingOnItemPaymentDao.getItemsByPaymentId(billPaymentId);
		for (BillingOnItemPayment itemPayment : itemPaymentList) {
			List<BillingOnItem> billItemList = billingOnItemDao.getBillingItemById(itemPayment.getBillingOnItemId());
			if (billItemList == null || billItemList.size() == 0) {
				continue;
			}
			BillingItemPaymentVo itemPaymentVo = new BillingItemPaymentVo();
			itemPaymentVo.setItemId(itemPayment.getBillingOnItemId());
			itemPaymentVo.setServiceCode(billItemList.get(0).getService_code());
			itemPaymentVo.setTotal(new BigDecimal(billItemList.get(0).getFee()).setScale(2, BigDecimal.ROUND_HALF_UP));
			itemPaymentVo.setPaid(itemPayment.getPaid());
			itemPaymentVo.setDiscount(itemPayment.getDiscount());
			itemPaymentVo.setRefund(itemPayment.getRefund());
			itemPaymentVoList.add(itemPaymentVo);
		}
		
		request.setAttribute("itemPaymentVoList", itemPaymentVoList);

		return actionMapping.findForward("viewPayment");
	}

	public void setBillingONPaymentDao(BillingONPaymentDao paymentDao) {
		this.billingONPaymentDao = paymentDao;
	}

	public void setBillingPaymentTypeDao(BillingPaymentTypeDao paymentTypeDao) {
		this.billingPaymentTypeDao = paymentTypeDao;
	}

	public void setBillingClaimDAO(BillingClaimDAO billingDao) {
		this.billingClaimDAO = billingDao;
	}

	public void setBillingONExtDao(BillingONExtDao billingExtDao) {
		this.billingONExtDao = billingExtDao;
	}

	public void setBillingOnItemDao(BillingOnItemDao billingOnItemDao) {
		this.billingOnItemDao = billingOnItemDao;
	}
	
	public void setBillingOnItemPaymentDao(BillingOnItemPaymentDao billingOnItemPaymentDao) {
		this.billingOnItemPaymentDao = billingOnItemPaymentDao;
	}

	public void setBillingOnTransactionDao(
			BillingOnTransactionDao billingOnTransactionDao) {
		this.billingOnTransactionDao = billingOnTransactionDao;
	}
}
