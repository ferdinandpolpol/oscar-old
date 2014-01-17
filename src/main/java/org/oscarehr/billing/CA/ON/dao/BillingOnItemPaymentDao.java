package org.oscarehr.billing.CA.ON.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.billing.CA.ON.model.BillingOnItemPayment;
import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;

@Repository
public class BillingOnItemPaymentDao extends AbstractDao<BillingOnItemPayment>{
	public BillingOnItemPaymentDao() {
		super(BillingOnItemPayment.class);
	}
	
	public BillingOnItemPayment findByPaymentIdAndItemId(int paymentId, int itemId) {
		Query query = entityManager.createQuery("select boip from BillingOnItemPayment boip where boip.billingOnPaymentId = ?1 amd boip.billingOnItemId = ?2");
		query.setParameter(1, paymentId);
		query.setParameter(2, itemId);
		return getSingleResultOrNull(query);
	}
	
	public List<BillingOnItemPayment> getAllByItemId(int itemId) {
		Query query = entityManager.createQuery("select boip from BillingOnItemPayment boip where boip.billingOnItemId =?1");
		query.setParameter(1, itemId);
		return query.getResultList();
	}
}
