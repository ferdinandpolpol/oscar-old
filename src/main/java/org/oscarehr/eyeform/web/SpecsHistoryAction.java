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

package org.oscarehr.eyeform.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;
import net.sf.json.JsonConfig;
import net.sf.json.processors.JsDateJsonBeanProcessor;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.apache.struts.validator.DynaValidatorForm;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.eyeform.dao.SpecsHistoryDao;
import org.oscarehr.eyeform.model.EyeformSpecsHistory;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class SpecsHistoryAction extends DispatchAction {

	@Override
	public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return form(mapping, form, request, response);
    }

    public ActionForward cancel(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return form(mapping, form, request, response);
    }

    public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String demographicNo = request.getParameter("demographicNo");
    	SpecsHistoryDao dao = (SpecsHistoryDao)SpringUtils.getBean("SpecsHistoryDAO");

    	List<EyeformSpecsHistory> specs = dao.getByDemographicNo(Integer.parseInt(demographicNo));
    	request.setAttribute("specs", specs);

        return mapping.findForward("list");
    }

    public ActionForward form(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	ProviderDao providerDao = (ProviderDao)SpringUtils.getBean("providerDao");
    	SpecsHistoryDao dao = (SpecsHistoryDao)SpringUtils.getBean("SpecsHistoryDAO");

    	request.setAttribute("providers",providerDao.getActiveProviders());

    	if(request.getParameter("specs.id") != null) {
    		int shId = Integer.parseInt(request.getParameter("specs.id"));
    		EyeformSpecsHistory specs = dao.find(shId);
    		DynaValidatorForm f = (DynaValidatorForm)form;
    		f.set("specs", specs);

    		if (request.getParameter("json") != null && request.getParameter("json").equalsIgnoreCase("true")) {
    			try {
    				HashMap<String, EyeformSpecsHistory> hashMap = new HashMap<String, EyeformSpecsHistory>();

    				hashMap.put("specs", specs);

    				JsonConfig config = new JsonConfig();
    		    	config.registerJsonBeanProcessor(java.sql.Date.class, new JsDateJsonBeanProcessor());

    				JSONObject json = JSONObject.fromObject(hashMap, config);
    				response.getOutputStream().write(json.toString().getBytes());
    			} catch (Exception e) {
    				MiscUtils.getLogger().error("Can't write json encoded message", e);
    			}

    			return null;
    		}
    	}

        return mapping.findForward("form");
    }

    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		DynaValidatorForm f = (DynaValidatorForm) form;
		String type = request.getParameter("specs.type");
		String date = request.getParameter("specs.dateStr");
		String odSph = request.getParameter("specs.odSph");
		String odCyl = request.getParameter("specs.odCyl");
		String odAxis = request.getParameter("specs.odAxis");
		String odAdd = request.getParameter("specs.odAdd");
		String odPrism = request.getParameter("specs.odPrism");
		String osSph = request.getParameter("specs.osSph");
		String osCyl = request.getParameter("specs.osCyl");
		String osAxis = request.getParameter("specs.osAxis");
		String osAdd = request.getParameter("specs.osAdd");
		String osPrism = request.getParameter("specs.osPrism");
		int demographicNo = Integer.parseInt(request
				.getParameter("specs.demographicNo"));
		int appointmentNo = Integer.parseInt(request
				.getParameter("specs.appointmentNo"));

		String type2 = request.getParameter("specs.type2");
		String date2 = request.getParameter("specs.dateStr2");
		String odSph2 = request.getParameter("specs.odSph2");
		String odCyl2 = request.getParameter("specs.odCyl2");
		String odAxis2 = request.getParameter("specs.odAxis2");
		String odAdd2 = request.getParameter("specs.odAdd2");
		String odPrism2 = request.getParameter("specs.odPrism2");
		String osSph2 = request.getParameter("specs.osSph2");
		String osCyl2 = request.getParameter("specs.osCyl2");
		String osAxis2 = request.getParameter("specs.osAxis2");
		String osAdd2 = request.getParameter("specs.osAdd2");
		String osPrism2 = request.getParameter("specs.osPrism2");

		String type3 = request.getParameter("specs.type3");
		String date3 = request.getParameter("specs.dateStr3");
		String odSph3 = request.getParameter("specs.odSph3");
		String odCyl3 = request.getParameter("specs.odCyl3");
		String odAxis3 = request.getParameter("specs.odAxis3");
		String odAdd3 = request.getParameter("specs.odAdd3");
		String odPrism3 = request.getParameter("specs.odPrism3");
		String osSph3 = request.getParameter("specs.osSph3");
		String osCyl3 = request.getParameter("specs.osCyl3");
		String osAxis3 = request.getParameter("specs.osAxis3");
		String osAdd3 = request.getParameter("specs.osAdd3");
		String osPrism3 = request.getParameter("specs.osPrism3");

		String type4 = request.getParameter("specs.type4");
		String date4 = request.getParameter("specs.dateStr4");
		String odSph4 = request.getParameter("specs.odSph4");
		String odCyl4 = request.getParameter("specs.odCyl4");
		String odAxis4 = request.getParameter("specs.odAxis4");
		String odAdd4 = request.getParameter("specs.odAdd4");
		String odPrism4 = request.getParameter("specs.odPrism4");
		String osSph4 = request.getParameter("specs.osSph4");
		String osCyl4 = request.getParameter("specs.osCyl4");
		String osAxis4 = request.getParameter("specs.osAxis4");
		String osAdd4 = request.getParameter("specs.osAdd4");
		String osPrism4 = request.getParameter("specs.osPrism4");
		
		

		EyeformSpecsHistory specs = (EyeformSpecsHistory) f.get("specs");
		if (specs.getId() != null && specs.getId() == 0) {
			specs.setId(null);
		}
    	SpecsHistoryDao dao = (SpecsHistoryDao)SpringUtils.getBean("SpecsHistoryDAO");
    	specs.setProvider(LoggedInInfo.loggedInInfo.get().loggedInProvider.getProviderNo());

    	if(request.getParameter("specs.id") != null && request.getParameter("specs.id").length()>0) {
    		specs.setId(Integer.parseInt(request.getParameter("specs.id")));
    	}

		if (specs.getId() != null && specs.getId() == 0) {
			specs.setId(null);
		}

		if (date != null) {
			specs.setDateStr(date);
			Date updateTime=new Date();
			specs.setUpdateTime(updateTime);

			specs.setOdAdd(odAdd);
			specs.setOdAxis(odAxis);
			specs.setOdCyl(odCyl);
			specs.setOdPrism(odPrism);
			specs.setOdSph(odSph);

			specs.setOsAdd(osAdd);
			specs.setOsAxis(osAxis);
			specs.setOsCyl(osCyl);
			specs.setOsPrism(osPrism);
			specs.setOsSph(osSph);

			specs.setType(type);
			specs.setId(dao.getById(demographicNo, appointmentNo, type));
			specs.setNote(dao.getByNote(demographicNo, appointmentNo, type));

			if (specs.getId() == null||specs.getId().equals(0)) {
				specs.setId(null);
				dao.persist(specs);
			} else {

				dao.merge(specs);

			}
			;

		}

		EyeformSpecsHistory specs2 = (EyeformSpecsHistory) f.get("specs");
		if (specs2.getId() != null) {
			specs2.setId(null);
		}
		SpecsHistoryDao dao2 = (SpecsHistoryDao) SpringUtils
				.getBean("SpecsHistoryDAO");
		specs2.setProvider(LoggedInInfo.loggedInInfo.get().loggedInProvider
				.getProviderNo());

		if (request.getParameter("specs.id2") != null
				&& request.getParameter("specs.id2").length() > 0) {
			specs2.setId(Integer.parseInt(request.getParameter("specs.id2")));
		}

		if (date2 != null) {

			specs2.setDateStr(date2);
			Date updateTime2=new Date();
			specs2.setUpdateTime(updateTime2);

			specs2.setOdAdd(odAdd2);
			specs2.setOdAxis(odAxis2);
			specs2.setOdCyl(odCyl2);
			specs2.setOdPrism(odPrism2);
			specs2.setOdSph(odSph2);

			specs2.setOsAdd(osAdd2);
			specs2.setOsAxis(osAxis2);
			specs2.setOsCyl(osCyl2);
			specs2.setOsPrism(osPrism2);
			specs2.setOsSph(osSph2);

			specs2.setType(type2);
			specs2.setId(dao2.getById(demographicNo, appointmentNo, type2));
			specs2.setNote(dao2.getByNote(demographicNo, appointmentNo, type2));
			if (specs2.getId() == null||specs2.getId().equals(0)) {
				specs2.setId(null);
				dao2.persist(specs2);
			} else {

				dao2.merge(specs2);
			}

		}

		EyeformSpecsHistory specs3 = (EyeformSpecsHistory) f.get("specs");
		if (specs3.getId() != null) {
			specs3.setId(null);
		}
		SpecsHistoryDao dao3 = (SpecsHistoryDao) SpringUtils
				.getBean("SpecsHistoryDAO");
		specs3.setProvider(LoggedInInfo.loggedInInfo.get().loggedInProvider
				.getProviderNo());

		if (request.getParameter("specs.id3") != null
				&& request.getParameter("specs.id3").length() > 0) {
			specs3.setId(Integer.parseInt(request.getParameter("specs.id3")));
		}

		if (date3 != null) {
			specs3.setDateStr(date3);
			Date updateTime3=new Date();
			specs3.setUpdateTime(updateTime3);

			specs3.setOdAdd(odAdd3);
			specs3.setOdAxis(odAxis3);
			specs3.setOdCyl(odCyl3);
			specs3.setOdPrism(odPrism3);
			specs3.setOdSph(odSph3);

			specs3.setOsAdd(osAdd3);
			specs3.setOsAxis(osAxis3);
			specs3.setOsCyl(osCyl3);
			specs3.setOsPrism(osPrism3);
			specs3.setOsSph(osSph3);

			specs3.setType(type3);
			specs3.setId(dao3.getById(demographicNo, appointmentNo, type3));
			specs3.setNote(dao3.getByNote(demographicNo, appointmentNo, type3));
			if (specs3.getId() == null||specs3.getId().equals(0)) {
				specs3.setId(null);
				dao3.persist(specs3);
			} else {

				dao3.merge(specs3);
			}
		}

		EyeformSpecsHistory specs4 = (EyeformSpecsHistory) f.get("specs");
		if (specs4.getId() != null) {
			specs4.setId(null);
		}
		SpecsHistoryDao dao4 = (SpecsHistoryDao) SpringUtils
				.getBean("SpecsHistoryDAO");
		specs4.setProvider(LoggedInInfo.loggedInInfo.get().loggedInProvider
				.getProviderNo());

		if (request.getParameter("specs.id4") != null
				&& request.getParameter("specs.id4").length() > 0) {
			specs4.setId(Integer.parseInt(request.getParameter("specs.id4")));
		}

		if (date4 != null) {
			specs4.setDateStr(date4);
			Date updateTime4=new Date();
			specs4.setUpdateTime(updateTime4);

			specs4.setOdAdd(odAdd4);
			specs4.setOdAxis(odAxis4);
			specs4.setOdCyl(odCyl4);
			specs4.setOdPrism(odPrism4);
			specs4.setOdSph(odSph4);

			specs4.setOsAdd(osAdd4);
			specs4.setOsAxis(osAxis4);
			specs4.setOsCyl(osCyl4);
			specs4.setOsPrism(osPrism4);
			specs4.setOsSph(osSph4);

			specs4.setType(type4);
			specs4.setId(dao4.getById(demographicNo, appointmentNo, type4));
			specs4.setNote(dao4.getByNote(demographicNo, appointmentNo, type4));
			if (specs4.getId() == null||specs4.getId().equals(0)) {
				specs4.setId(null);
				dao4.persist(specs4);
			} else {

				dao4.merge(specs4);
			}
		}
		
		if (request.getParameter("json") != null
				&& request.getParameter("json").equalsIgnoreCase("true")) {
			HashMap<String, Integer> hashMap = new HashMap<String, Integer>();
			hashMap.put("saved", specs.getId());

			JSONObject json = JSONObject.fromObject(hashMap);
			response.getOutputStream().write(json.toString().getBytes());

			return null;
		}

		request.setAttribute("parentAjaxId", "specshistory");
		return mapping.findForward("success");
	}


    public ActionForward copySpecs(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
    	String demographicNo = request.getParameter("demographicNo");
    	SpecsHistoryDao dao = (SpecsHistoryDao)SpringUtils.getBean("SpecsHistoryDAO");
    	List<EyeformSpecsHistory> specs = dao.getByDemographicNo(Integer.parseInt(demographicNo));
    	if(specs.size()>0) {
    		EyeformSpecsHistory latestSpecs = specs.get(0);
    		PrintWriter out = response.getWriter();
    		out.println("setfieldvalue(\"od_manifest_refraction_sph\",\""+latestSpecs.getOdSph()+"\");");
    		out.println("setfieldvalue(\"os_manifest_refraction_sph\",\""+latestSpecs.getOsSph()+"\");");
    		out.println("setfieldvalue(\"od_manifest_refraction_cyl\",\""+latestSpecs.getOdCyl()+"\");");
    		out.println("setfieldvalue(\"os_manifest_refraction_cyl\",\""+latestSpecs.getOsCyl()+"\");");
    		out.println("setfieldvalue(\"od_manifest_refraction_axis\",\""+latestSpecs.getOdAxis()+"\");");
    		out.println("setfieldvalue(\"os_manifest_refraction_axis\",\""+latestSpecs.getOsAxis()+"\");");
    	} else {
    		PrintWriter out = response.getWriter();
    		out.println("alert('No Specs Found.');");
    	}
    	return null;
    }
}
