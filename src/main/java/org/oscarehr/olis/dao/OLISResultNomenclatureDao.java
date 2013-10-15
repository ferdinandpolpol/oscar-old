/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OLISResultNomenclature;
import org.springframework.stereotype.Repository;

@Repository
public class OLISResultNomenclatureDao extends AbstractDao<OLISResultNomenclature>{

	
	public OLISResultNomenclatureDao() {
	    super(OLISResultNomenclature.class);
    }

	public OLISResultNomenclature findByNameId(String id) {
		String sql = "select x from "+ this.modelClass.getName() + " x where x.nameId=?";
		Query query = entityManager.createQuery(sql);
		query.setParameter(1, id);		
		return (OLISResultNomenclature)query.getSingleResult();
	}
	
	@SuppressWarnings("unchecked")
    public List<OLISResultNomenclature> findAll() {
		String sql = "select x from " + this.modelClass.getName() + " x";
		Query query = entityManager.createQuery(sql);
		return query.getResultList();
	}
}
