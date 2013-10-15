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


package org.oscarehr.hospitalReportManager.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.hospitalReportManager.model.HRMSubClass;
import org.springframework.stereotype.Repository;

@Repository
public class HRMSubClassDao extends AbstractDao<HRMSubClass> {

	public HRMSubClassDao() {
		super(HRMSubClass.class);
	}

	public List<HRMSubClass> findById(int id) {
		String sql = "select x from " + this.modelClass.getName() + " x where x.id=?";
		Query query = entityManager.createQuery(sql);
		query.setParameter(1, id);
		@SuppressWarnings("unchecked")
		List<HRMSubClass> documents = query.getResultList();
		return documents;
	}

	public List<HRMSubClass> listAll() {
		String sql = "select x from " + this.modelClass.getName() + " x ";
		Query query = entityManager.createQuery(sql);

		@SuppressWarnings("unchecked")
		List<HRMSubClass> subclasses = query.getResultList();
		return subclasses;
	}

	public boolean subClassMappingExists(String className, String subClassName) {
		return subClassMappingExists(className, subClassName, "*");
	}

	public boolean subClassMappingExists(String className, String subClassName, String sendingFacilityId) {
		return subClassMappingExists(className, subClassName, null, sendingFacilityId);
	}

	public boolean subClassMappingExists(String className, String subClassName, String subClassMnemonic, String sendingFacilityId) {
		String sql = "select x from " + this.modelClass.getName() + " x where x.className=? and x.subClassName=?  and x.subClassMnemonic=? and x.sendingFacilityId=?";
		Query query = entityManager.createQuery(sql);
		query.setParameter(1, className);
		query.setParameter(2, subClassName);
		query.setParameter(3, subClassMnemonic);
		query.setParameter(4, sendingFacilityId);

		try {
			return (query.getSingleResult() != null);
		} catch (Exception e) {
			return false;
		}
	}

	private HRMSubClass findSubClassMapping(String className, String subClassName, String subClassMnemonic, String sendingFacilityId) {
		String sql = null;

		if (subClassMnemonic != null){
			sql = "select x from " + this.modelClass.getName() + " x where x.className=? and x.subClassName=? and x.sendingFacilityId=? and x.subClassMnemonic=?";
		}else{
			sql = "select x from " + this.modelClass.getName() + " x where x.className=? and x.subClassName=? and x.sendingFacilityId=?";
		}
		Query query = entityManager.createQuery(sql);
		query.setParameter(1, className);
		query.setParameter(2, subClassName);
		query.setParameter(3, sendingFacilityId);

		if (subClassMnemonic != null){
			query.setParameter(4, subClassMnemonic);
		}

		return (HRMSubClass) query.getSingleResult();
	}

	public HRMSubClass findApplicableSubClassMapping(String className, String subClassName, String subClassMnemonic, String sendingFacilityId) {
		HRMSubClass mapping = null;
		try {
			mapping = findSubClassMapping(className, subClassName, subClassMnemonic, sendingFacilityId);
		} catch (Exception e) {
			// Didn't find one... try a wildcard search
			try {
				mapping = findSubClassMapping(className, subClassName, subClassMnemonic, "*");
			} catch (Exception e2) {
				// Didn't find one that way either
				mapping = null;
			}
		}
		return mapping;
	}
}
