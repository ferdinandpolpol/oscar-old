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
package org.oscarehr.billing.CA.ON.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.billing.CA.ON.model.BillingItem;
import org.oscarehr.common.dao.AbstractDao;
import org.springframework.stereotype.Repository;
@Repository
public class BillingItemDao extends AbstractDao<BillingItem>{

	public BillingItemDao() {
        super(BillingItem.class);
    }
	
	public List<BillingItem> getBillingItemByIdDesc(Integer ch1_id){
        
        Query query = entityManager.createQuery("select b from BillingItem b where b.ch1_id = :ch1_id AND b.status!='D' ORDER BY b.id desc");
        query.setParameter("ch1_id",ch1_id);
        
        List<BillingItem> list= query.getResultList();
        return list;
    }

}
