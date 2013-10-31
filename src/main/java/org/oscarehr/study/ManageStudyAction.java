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
package org.oscarehr.study;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.oscarehr.common.dao.DemographicStudyDao;
import org.oscarehr.common.dao.StudyDao;
import org.oscarehr.common.dao.StudyDataDao;
import org.oscarehr.common.model.DemographicStudy;
import org.oscarehr.common.model.DemographicStudyPK;
import org.oscarehr.common.model.Study;
import org.oscarehr.common.model.StudyData;
import org.oscarehr.util.SpringUtils;

import oscar.util.ConversionUtils;
public class ManageStudyAction extends DispatchAction {
	
	
	public ActionForward saveUpdateStudy(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		StudyDao studyDao = (StudyDao)SpringUtils.getBean(StudyDao.class);
		String studyId = request.getParameter("studyId");
		
		boolean isNewStudy = studyId == null || studyId.equals("");
		if(isNewStudy) {
			Study study = new Study();
			study.setStudyName(request.getParameter("studyName"));
			study.setStudyLink(request.getParameter("studyLink"));
			study.setDescription(request.getParameter("studyDescription"));
			study.setFormName(request.getParameter("studyForm"));
			study.setCurrent1(0);
			study.setRemoteServerUrl(request.getParameter("studyRemoteURL"));
			study.setProviderNo(String.valueOf(request.getSession().getAttribute("user")));
			study.setTimestamp(new Date());
			studyDao.persist(study);
		}
		else {			
			Study study = studyDao.find(Integer.parseInt(studyId));
			study.setStudyName(request.getParameter("studyName"));
			study.setStudyLink(request.getParameter("studyLink"));
			study.setDescription(request.getParameter("studyDescription"));
			study.setFormName(request.getParameter("studyForm"));
			study.setCurrent1(0);
			study.setRemoteServerUrl(request.getParameter("studyRemoteURL"));
			study.setProviderNo(String.valueOf(request.getSession().getAttribute("user")));
			study.setTimestamp(new Date());
			studyDao.merge(study);
		}
		
		 String resultName = isNewStudy ? "create" : "update";
		 return mapping.findForward(resultName);
	}
	
	public ActionForward setStudyStatus(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		StudyDao studyDao = (StudyDao)SpringUtils.getBean(StudyDao.class);
		String studyId = request.getParameter("studyId");
		String studyStatus = request.getParameter("studyStatus");
		
		if( studyId != null && studyStatus != null ) {
			Study study = studyDao.find(Integer.parseInt(studyId));
			study.setCurrent1(Integer.parseInt(studyStatus));
			study.setProviderNo(String.valueOf(request.getSession().getAttribute("user")));
			study.setTimestamp(new Date());
			studyDao.merge(study);
		}
		
		return null;
	}

	@SuppressWarnings("unchecked")
    public ActionForward AddToStudy(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		String[] selectArray = (String[])request.getAttribute("selectArray");
		if( !selectArray[0].equals("demographic_no") ) {
			request.setAttribute("error", "You must select demographic_no");
		}
		else {
			List<ArrayList<String>> searchList = (List<ArrayList<String>>)request.getAttribute("searchedArray");
		
			String studyId = (String)request.getAttribute("studyId");
			String demoId;
			DemographicStudyDao demographicStudyDao = (DemographicStudyDao)SpringUtils.getBean(DemographicStudyDao.class);
			DemographicStudy demographicStudy;
			DemographicStudyPK demographicStudyPK;
			
			for( ArrayList<String> results : searchList) {
				demoId = results.get(0);
				demographicStudy = demographicStudyDao.findByDemographicNoAndStudyNo(Integer.parseInt(demoId), Integer.parseInt(studyId));
				if( demographicStudy == null ) {
					demographicStudyPK = new DemographicStudyPK();
					demographicStudyPK.setDemographicNo(Integer.parseInt(demoId));
					demographicStudyPK.setStudyNo(Integer.parseInt(studyId));
					
					demographicStudy = new DemographicStudy();
					demographicStudy.setId(demographicStudyPK);
					demographicStudy.setProviderNo(String.valueOf(request.getSession().getAttribute("user")));
					demographicStudy.setTimestamp(new Date());
					
					demographicStudyDao.persist(demographicStudy);
				}
			}
		
		}
		return mapping.findForward("AddedToStudy");
	}
	
	public ActionForward RemoveFromStudy(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		String studyId = request.getParameter("studyId");
		Integer studyIdAsInt = ConversionUtils.fromIntString(studyId);
		String removeType = request.getParameter("submit");
		
		if( removeType.equals("Remove Demographic") ) {
			String[] demoIds = request.getParameterValues("demographicNo");
			DemographicStudyDao demographicStudyDao = (DemographicStudyDao)SpringUtils.getBean(DemographicStudyDao.class);			
            StudyDataDao studyDataDao = SpringUtils.getBean(StudyDataDao.class);
			DemographicStudyPK demographicStudyPK;

			for( int idx = 0; idx < demoIds.length; ++idx ) {
				Integer demoIdAsInt = ConversionUtils.fromIntString(demoIds[idx]);
                if (demoIdAsInt == 0) {
                        continue;
                }
				demographicStudyPK = new DemographicStudyPK();
				demographicStudyPK.setDemographicNo(Integer.parseInt(demoIds[idx]));
				demographicStudyPK.setStudyNo(Integer.parseInt(studyId));
				
				demographicStudyDao.remove(demographicStudyPK);
				studyDataDao.removeByDemoAndStudy(demoIdAsInt, studyIdAsInt);
			}
		}
		else if( removeType.equals("Remove Provider") ) {
//			String[] providerIds = request.getParameterValues("providerNo");
//			ProviderStudyDao providerStudyDao = (ProviderStudyDao)SpringUtils.getBean(ProviderStudyDao.class);			
//			ProviderStudyPK providerStudyPK;
//
//			for( int idx = 0; idx < providerIds.length; ++idx ) {
//				providerStudyPK = new ProviderStudyPK();
//				providerStudyPK.setProviderNo(providerIds[idx].trim());
//				providerStudyPK.setStudyNo(Integer.parseInt(studyId));
//				
//				providerStudyDao.remove(providerStudyPK);
//			}			
		}
		
		
		
		return mapping.findForward("AddedToStudy");
	}
	
//	public ActionForward AddProvider(ActionMapping mapping, ActionForm form,
//            HttpServletRequest request, HttpServletResponse response) {
//		
//		String studyId = request.getParameter("studyId");
//		String[] providerIds = request.getParameterValues("providerNo");
//		ProviderStudyDao providerStudyDao = (ProviderStudyDao)SpringUtils.getBean(ProviderStudyDao.class);			
//		ProviderStudyPK providerStudyPK;
//		ProviderStudy providerStudy;
//		
//		for( int idx = 0; idx < providerIds.length; ++idx ) {
//			providerStudy = providerStudyDao.findByProviderNoAndStudyNo(providerIds[idx], Integer.parseInt(studyId));
//			if( providerStudy == null ) {
//				providerStudyPK = new ProviderStudyPK();
//				providerStudyPK.setProviderNo(providerIds[idx]);
//				providerStudyPK.setStudyNo(Integer.parseInt(studyId));
//				
//				providerStudy = new ProviderStudy();
//				providerStudy.setId(providerStudyPK);
//				providerStudy.setCreator(String.valueOf(request.getSession().getAttribute("user")));
//				providerStudy.setTimestamp(new Date());
//				
//				providerStudyDao.persist(providerStudy);
//			}
//		}
//		
//		return mapping.findForward("AddedToStudy");
//		
//	}
	
//	public ActionForward RunStudy(ActionMapping mapping, ActionForm form,
//            HttpServletRequest request, HttpServletResponse response) {
//		
//		ArrayList<Object> args = new ArrayList<Object>();
//		args.add(request.getParameter("demographicNo"));
//		args.add(request.getParameter("providerNo"));
//		
//		String[] argsArr = request.getParameter("args").split(",");
//		for( int idx = 0; idx < argsArr.length; ++idx ) {
//			if( argsArr[idx].trim().length() > 0 ) {
//				args.add(argsArr[idx].trim());
//			}
//		}
//		MiscUtils.getLogger().debug("dynamicArgs length " + args.size());
//		org.oscarehr.study.Study myMeds = StudyFactory.getFactoryInstance().makeStudy(org.oscarehr.study.Study.MYMEDS, args);
//		HashMap<String,Boolean> hashMap = new HashMap<String,Boolean>();
//		hashMap.put("isEligible", myMeds.run());
//		
//		JSONObject jsonObject = JSONObject.fromObject(hashMap);
//		
//		try {
//	        response.getOutputStream().write(jsonObject.toString().getBytes());
//        } catch (IOException e) {
//	        MiscUtils.getLogger().error("Cannot write response", e);
//	       
//        }
//		
//		return null;
//	}
	
	public ActionForward saveStudyData(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
		
		StudyDataDao studyDataDao = (StudyDataDao)SpringUtils.getBean(StudyDataDao.class);
		
		StudyData studyData = new StudyData();
		studyData.setContent(request.getParameter("content"));
		studyData.setDemographicNo(Integer.parseInt(request.getParameter("demographicNo")));
		studyData.setProviderNo(request.getParameter("providerNo"));
		studyData.setStatus(request.getParameter("status"));
		studyData.setStudyNo(Integer.parseInt(request.getParameter("studyId")));
		studyData.setTimestamp(new Date());
		// studyData.setKey(request.getParameter("key"));
		
		studyDataDao.persist(studyData);
		
		return mapping.findForward("closeWindow");
		
	}
	
}