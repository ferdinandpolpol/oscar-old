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

package org.oscarehr.billing.CA.ON.dao;

import java.util.Date;
import java.util.List;

import javax.persistence.NoResultException;
import javax.persistence.NonUniqueResultException;
import javax.persistence.Query;

import org.oscarehr.billing.CA.ON.model.BillingONExt;
import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;

/**
*
* @author Eugene Katyukhin
*/

@Repository
public class BillingONExtDao extends AbstractDao<BillingONExt>{
	public final static String KEY_PAYMENT = "payment";
	public final static String KEY_REFUND = "refund";
	public final static String KEY_PAY_DATE = "payDate";
	public final static String KEY_PAY_METHOD = "payMethod";

	public BillingONExtDao() {
        super(BillingONExt.class);
    }

    public List<BillingONExt> getClaimExtItems(int billingNo){
        Query query = entityManager.createQuery("select ext from BillingONExt ext where ext.billingNo = :billingNo");
        query.setParameter("billingNo", billingNo);
        return query.getResultList();
    }

    public BillingONExt getClaimExtItem(Integer billingNo, Integer demographicNo, String keyVal) throws NonUniqueResultException {
    	String filter1 = (billingNo == null ? "" : "ext.billingNo = :billingNo");
    	String filter2 = (demographicNo == null ? "" : "ext.demographicNo = :demographicNo");
    	String filter3 = (keyVal == null ? "" : "ext.keyVal = :keyVal");
    	String sql = "select ext from BillingONExt ext";
    	boolean isWhere = false;
    	if(filter1 != null) {
    		sql += " where ext.billingNo = :billingNo";
    		isWhere = true;
    	}
    	if(filter2 != null) {
    		if(isWhere) sql += " and demographicNo = :demographicNo";
    		else {
    			sql += "where demographicNo = :demographicNo";
    			isWhere = true;
    		}
    	}
    	if(filter3 != null) {
    		if(isWhere) sql += " and keyVal = :keyVal";
    		else {
    			sql += "where keyVal = :keyVal";
    			isWhere = true;
    		}
    	}
    	Query query = entityManager.createQuery(sql);
        if(filter1 != null) query.setParameter("billingNo", billingNo);
        if(filter1 != null) query.setParameter("demographicNo", demographicNo);
        if(filter3 != null) query.setParameter("keyVal", keyVal);
        BillingONExt res = null;
        try {
        	res = (BillingONExt)query.getSingleResult();
        } catch (NoResultException ex) {
        	return null;
        } 
        return res;
    }

    public void setExtItem(int billingNo, int demographicNo, String keyVal, String value, Date dateTime, char status) throws NonUniqueResultException {
    	BillingONExt ext = getClaimExtItem(billingNo, demographicNo, keyVal);
    	if(ext != null) {
    		ext.setValue(value);
    		ext.setDateTime(dateTime);
    		ext.setStatus(Character.toString(status));
    		this.merge(ext);
    	} else {
    		BillingONExt res = new BillingONExt();
    		res.setBillingNo(billingNo);
    		res.setDemographicNo(demographicNo);
    		res.setKeyVal(keyVal);
    		res.setValue(value);
    		res.setDateTime(dateTime);
    		res.setStatus(Character.toString(status));
    		this.persist(res);
    	}
    }

}
