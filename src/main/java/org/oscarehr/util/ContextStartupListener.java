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

package org.oscarehr.util;

import java.util.Date;

import org.apache.log4j.Logger;
import org.oscarehr.PMmodule.caisi_integrator.CaisiIntegratorUpdateTask;
import org.oscarehr.PMmodule.dao.ProgramDao;
import org.oscarehr.PMmodule.dao.ProgramProviderDAO;
import org.oscarehr.PMmodule.model.Program;
import org.oscarehr.PMmodule.model.ProgramProvider;
import org.oscarehr.PMmodule.utility.ProgramAccessCache;
import org.oscarehr.PMmodule.utility.RoleCache;
import org.oscarehr.threads.WaitListEmailThread;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SimpleTrigger;
import org.quartz.impl.StdSchedulerFactory;

import oscar.OscarProperties;
import oscar.util.ICFHTDemoExportJob;

import com.quatro.dao.security.SecroleDao;

public class ContextStartupListener implements javax.servlet.ServletContextListener {
	private static final Logger logger = MiscUtils.getLogger();
	private static String contextPath = null;

	@Override
	public void contextInitialized(javax.servlet.ServletContextEvent sce) {
		try {
			// ensure cxf uses log4j
			System.setProperty("org.apache.cxf.Logger", "org.apache.cxf.common.logging.Log4jLogger");

			// need tc6 for this?
			// String contextPath=sce.getServletContext().getContextPath();

			// hack to get context path until tc6 is our standard.
			// /data/cvs/caisi_utils/apache-tomcat-5.5.27/webapps/oscar
			contextPath = sce.getServletContext().getRealPath("");
			int lastSlash = contextPath.lastIndexOf('/');
			contextPath = contextPath.substring(lastSlash + 1);

			logger.info("Server processes starting. context=" + contextPath);

			MiscUtils.addLoggingOverrideConfiguration(contextPath);

			OscarProperties properties = OscarProperties.getInstance();
			String vmstatLoggingPeriod = properties.getProperty("VMSTAT_LOGGING_PERIOD");
			VMStat.startContinuousLogging(Long.parseLong(vmstatLoggingPeriod));

			MiscUtils.setShutdownSignaled(false);
			MiscUtils.registerShutdownHook();

			createOscarProgramIfNecessary();
			
			CaisiIntegratorUpdateTask.startTask();

			WaitListEmailThread.startTaskIfEnabled();
			
			//Run some optimizations
			loadCaches();
			
			scheduleICFHTDemoExportScheduler();
			
			logger.info("Server processes starting completed. context=" + contextPath);
		} catch (Exception e) {
			logger.error("Unexpected error.", e);
			throw (new RuntimeException(e));
		}
	}
	
	public void loadCaches() {
		ProgramDao programDao = (ProgramDao)SpringUtils.getBean("programDao");
		for(Program program:programDao.getActivePrograms()) {
			ProgramAccessCache.setAccessMap(program.getId().longValue());
		}
		RoleCache.reload();
	}
	

	private void createOscarProgramIfNecessary() {
		ProgramDao programDao = (ProgramDao)SpringUtils.getBean("programDao");
		SecroleDao secRoleDao = (SecroleDao)SpringUtils.getBean("secroleDao");
		ProgramProviderDAO programProviderDao = (ProgramProviderDAO)SpringUtils.getBean("programProviderDAO");
		
		Program p = programDao.getProgramByName("OSCAR");
		if(p !=null) 
			return;
		p = new Program();
		p.setFacilityId(1);
		p.setName("OSCAR");
		p.setMaxAllowed(99999);
		p.setType("Bed");
		p.setProgramStatus("active");
		programDao.saveProgram(p);
		
		ProgramProvider pp = new ProgramProvider();
		pp.setProviderNo("999998");
		pp.setProgramId(p.getId().longValue());
		pp.setRoleId(secRoleDao.getRoleByName("doctor").getId());
		programProviderDao.saveProgramProvider(pp);
		
	}
	@Override
    public void contextDestroyed(javax.servlet.ServletContextEvent sce) {
		// need tc6 for this?
		// logger.info("Server processes stopping. context=" + sce.getServletContext().getContextPath());
		logger.info("Server processes stopping. context=" + contextPath);

		WaitListEmailThread.stopTask();
		CaisiIntegratorUpdateTask.stopTask();
		VMStat.stopContinuousLogging();

		try {
			MiscUtils.checkShutdownSignaled();
			MiscUtils.deregisterShutdownHook();
			MiscUtils.setShutdownSignaled(true);
		} catch (ShutdownException e) {
			// do nothing it's okay.
		}
	}
	
	private void scheduleICFHTDemoExportScheduler()
	{
		logger.info("in scheduleICFHTDemoExportScheduler");
		try
		{
			String schedulerFlg = OscarProperties.getInstance().getProperty("ICFHT_CONVERT_TO_PDF", "false");
			logger.info("ICFHT schedulerFlg = "+schedulerFlg);
			
			if(schedulerFlg.equalsIgnoreCase("true"))
			{
				String jobName = "ICFHTDemoExportJob";
				String triggerName = "ICFHTDemoExportJobTrigger";
				
				Scheduler scheduler = new StdSchedulerFactory().getScheduler();
				scheduler.start();
				
				JobDetail job = new JobDetail();
				job.setName(jobName);
				job.setJobClass(ICFHTDemoExportJob.class);
				job.setGroup(Scheduler.DEFAULT_GROUP);
				
				SimpleTrigger trigger = new SimpleTrigger(triggerName);
				//start after 10 secs
				trigger.setStartTime(new Date(System.currentTimeMillis() + 10000));
				trigger.setRepeatCount(SimpleTrigger.REPEAT_INDEFINITELY);
				
				//default 12 hours.. in proeprty file value is in minutes
				long ICFHT_JOB_REPEAT_INTERVAL = Integer.parseInt(OscarProperties.getInstance().getProperty("ICFHT_JOB_REPEAT_INTERVAL", (12*60)+""));
				trigger.setRepeatInterval(ICFHT_JOB_REPEAT_INTERVAL*60*1000);

				JobDetail existingJob = scheduler.getJobDetail(jobName, Scheduler.DEFAULT_GROUP);
				logger.info("existingJob = "+existingJob);
				if (existingJob != null)
				{
					logger.info("Delete old job.");
					scheduler.deleteJob(jobName, Scheduler.DEFAULT_GROUP);
				}
				
				scheduler.scheduleJob(job, trigger);
				
				logger.info("ICFHT demo export job scheduled");
			}
		}
		catch (Exception e)
		{
			logger.error("Error while scheduling ICFHT demo export job", e);
		}
	}
}
