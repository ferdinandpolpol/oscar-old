package oscar.util;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.oscarehr.common.dao.DemographicSiteDao;
import org.oscarehr.common.dao.SiteDao;
import org.oscarehr.common.model.DemographicSite;
import org.oscarehr.common.model.Site;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.springframework.jdbc.core.RowMapper;

import oscar.dao.OscarSuperDao;

import com.quatro.dao.security.SecroleDao;
import com.quatro.model.security.Secrole;

/***
 * 
 * @author Rohit Prajapati (rohitprajapati54@gmail.com)
 * 
 * Utility to check whether user has rights to access site or not.
 * If user has access to site, then he can access the patients of that site.
 * 
 * This users below 2 columns of the site table.
 * # roleIdsOnlyAccessThisSite - comma separated roles id - 
 *  User can access all the sites for which user's role is there in this column.
 *  
 *  But once the user's role is configured in this column even for the single site,
 *  then user will not have access to any other site.
 *  
 *  If user's role is not configured in this column for any site, then user can 
 *  access all the sites.
 *    
 * # roleIdsCouldAmitDischarge - comma separated roles id -
 *  user whose role is configured in this column, can only enroll/discharge the 
 *  patient to/from this site. no other patients will have access to do this.
 *  
 *  if no role is configured in this column, then all user have rights to 
 *  enroll/discharge patients to/from this site.
 */
public class SuperSiteUtil extends OscarSuperDao
{

	private static Logger logger = MiscUtils.getLogger();
	
	private String currentProviderNo;
	private List<Site> userAccessSites;
	private List<Long> userRoles;
	
	/*public SuperSiteUtil(String currentProviderNo)
	{
		this.currentProviderNo = currentProviderNo;
		userAccessSites = getSitesWhichUserCanOnlyAccess();
	}
	*/
	//this will be used.. from where checkSuperSiteAccess needs to be called
	//in this case provider no. will not be passed.. instead it will be fetched from the
	//request itself in checkSuperSiteAccess method.. and userAccessSites will be initialized there
	private SuperSiteUtil()
	{
	}
	
	/***
	 * @param userId
	 * @return
	 * @throws Exception
	 * 
	 * -- return list of sites which are accessible by the user. 
	 *  
	 * Once user's role is configured in site.roleIdsOnlyAccessThisSite column for atleast one site, 
	 * then he will not have access to any other site. 
	 * So first check whether the user's role is configured in site.roleIdsOnlyAccessThisSite for any site? 
	 * If yes then return only those sites. 
	 * If no then return those site for which site.roleIdsOnlyAccessThisSite=null
	 */
	public List<Site> getUserAccessibleSites(String userId)
	{
		List<Site> sites = null;
		
		//List<Site> userAccessSites = getSitesWhichUserCanOnlyAccess(userId);
		if(userAccessSites==null || userAccessSites.size()==0)
		{
			//if user doesn't have access to any specific site (user's role is not configured in site_role_mpg, 
			//then return all sites accessible to all users)
			sites = getAllSitesAccessibleToAllUsers();
		}
		else
		{
			sites = userAccessSites;
		}
		
		return sites;
	}
	
	/***
	 * check whether supplied user has access to open patient's detail (e.g from encounter, master, rx etc..)
	 * -- means if user has access to only specific site (user's role is in site_role_mpg.access_role_id),
	 * and if patient is enrolled in that site, then user has access rights..
	 *
	 * -- if user doesn't have access to any specific site (user's role is not in site_role_mpg.access_role_id),
	 * then user can access any patient
	 * 
	 * -- if user has access to specific site (user's role is in site_role_mpg.access_role_id),
	 * and if patient is not enrolled in that site, then user is not allowed to view that patient
	 * 
	 *  parameter:
	 *  userId - userid who is accessing the patient.. may be logged in userid
	 *  demographicId - patient id which is being accessed.
	 * @return
	 */
	public boolean isUserAllowedToOpenPatientDtl(String demographicId) 
	{
		boolean flg = false;
		
		if(!org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
		{
			flg = true;
			return flg;
		}
		
		//List<Site> userAccessSites = getSitesWhichUserCanOnlyAccess(userId);
		if(userAccessSites==null || userAccessSites.size()==0)
		{
			//means user doesn't have any specific site access. so it can access any site..
			flg = true;
		}
		else
		{
			//user is configured to access certain sites.. check if patient is enrolled in that site or not
			List<Integer> userSiteIdList = getSiteIdList(userAccessSites);
			
			//get patient's site
			DemographicSiteDao demographicSiteDao = (DemographicSiteDao)SpringUtils.getBean("demographicSiteDao");
			List<DemographicSite> demoSiteList = demographicSiteDao.findSitesByDemographicId(Integer.parseInt(demographicId));
			
			if(demoSiteList!=null)
			{
				for (DemographicSite demographicSite : demoSiteList)
				{
					if(demographicSite!=null && demographicSite.getSiteId()!=null)
					{
						if(userSiteIdList.contains(demographicSite.getSiteId()))
						{
							flg = true;
							break;
						}
					}
				}
			}
		}
		
		return flg;
	}
	
	private boolean isUserAllowedToOpenPatientDtl(HttpServletRequest request, String demographicIdReqParamName)
	{
		logger.info("in SuperSiteUtil : isUserAllowedToOpenPatientDtl");
		
		boolean flg = true;
		if(org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
		{
			String userId = "", demographicId = "";
			if(request.getSession().getAttribute("user")!=null)
				  userId = request.getSession().getAttribute("user").toString();
			
			if(request.getParameter(demographicIdReqParamName)!=null)
				demographicId = request.getParameter(demographicIdReqParamName).trim();
			
			//here we need to initialize userAccessSites.
			//userAccessSites = getSitesWhichUserCanOnlyAccess();
			setCurrentProviderNo(userId);
			
			logger.info("userId = "+userId);
			logger.info("demographicId = "+demographicId);
			
			if(demographicId!=null && demographicId.trim().length()>0)
			{
				flg = isUserAllowedToOpenPatientDtl(demographicId);
			}
		}
		
		logger.info("out SuperSiteUtil : isUserAllowedToOpenPatientDtl ... flg = "+flg);
		return flg;
	}
	
	public boolean isUserAllowedToAdmitDischargeForSite(int siteId)
	{
		boolean flg = false;
		
		if(org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
		{
			//get roles associated with siteid .. site_role_mpg.admit_discharge_role_id
			List<Secrole> siteAdmitDischargeRoleList = getAdmitDischargeRolesAssociatedWithSite(siteId);
			
			//if atleast one role is configured.. and user's role is there then only user have access to
			//admin/discharge.. otherwise not
			if(siteAdmitDischargeRoleList!=null && siteAdmitDischargeRoleList.size()>0)
			{
				//admit/discharge roles are configured for site.. check if user's role is there
				if(userRoles!=null)
				{
					for (Secrole secrole : siteAdmitDischargeRoleList)
					{
						if(secrole!=null && userRoles.contains(secrole.getId()))
						{
							flg = true;
							break;
						}
					}
				}
			}
			else
			{
				//no admit/discharge role configured for site 
				flg = false;
			}
		}
		else
		{
			flg = true;
		}
		
		return flg;
	}
	
	public static SuperSiteUtil getInstance()
	{
		SuperSiteUtil superSiteUtil = (SuperSiteUtil) SpringUtils.getBean("superSiteUtil");
		return superSiteUtil;
	}
	
	public static SuperSiteUtil getInstance(String currentProviderNo)
	{
		SuperSiteUtil superSiteUtil = (SuperSiteUtil) SpringUtils.getBean("superSiteUtil");
		superSiteUtil.setCurrentProviderNo(currentProviderNo);
		return superSiteUtil;
	}
	
	//check access and if user is not allowed to access demographic then forward to error page
	public void checkSuperSiteAccess(HttpServletRequest request, HttpServletResponse response, String demographicIdReqParamName) throws IOException, ServletException
	{
		if(org.oscarehr.common.IsPropertiesOn.isMultisitesEnable())
		{
			if(!isUserAllowedToOpenPatientDtl(request, demographicIdReqParamName))
			{
				request.getRequestDispatcher("/common/superSiteAccessError.jsp").forward(request, response);
			}			
		}
	}
	
	private List<Integer> getSiteIdList(List<Site> siteList)
	{
		List<Integer> list = null;
		
		if(siteList!=null)
		{
			list = new ArrayList<Integer>();
			
			for (Site site : siteList)
			{
				list.add(site.getSiteId());
			}
		}
		
		return list;
	}
	
	public void deleteAccessRoleFromSite(int siteId, int roleId)
	{
		String qr = "delete from site_role_mpg where site_id = ? and access_role_id = ?";
		Object[] params = new Integer[]{siteId, roleId};
		getJdbcTemplate().update(qr, params);
	}
	
	public void deleteAdmitDischargeRoleToSite(int siteId, int roleId)
	{
		String qr = "delete from site_role_mpg where site_id = ? and admit_discharge_role_id = ?";
		Object[] params = new Integer[]{siteId, roleId};
		getJdbcTemplate().update(qr, params);
	}
	
	public void addAccessRoleToSite(int siteId, int roleId)
	{
		String qr = "insert into site_role_mpg (site_id, access_role_id) " +
				"values (?, ?)";
		Object[] params = new Integer[]{siteId, roleId};
		getJdbcTemplate().update(qr, params);
	}
	
	public void addAdmitDischargeRoleToSite(int siteId, int roleId)
	{
		String qr = "insert into site_role_mpg (site_id, admit_discharge_role_id) " +
				"values (?, ?)";
		Object[] params = new Integer[]{siteId, roleId};
		getJdbcTemplate().update(qr, params);
	}
	
	public String getAccessRolesAssociatedWithSiteStr(int siteId)
	{
		String str = "";
		
		List<Secrole> list = getAccessRolesAssociatedWithSite(siteId);
		if(list!=null && list.size()>0)
		{
			for(int i=0;i<list.size();i++)
			{
				Secrole secrole = list.get(i);
				if(i==0)
					str = secrole.getRoleName();
				else
					str = str+", "+secrole.getRoleName();
			}
		}
		
		return str;
	}
	
	public List<Secrole> getAccessRolesAssociatedWithSite(int siteId)
	{
		List<Secrole> roleList = null;
		
		String qr = "select * from secRole where role_no in ( "
					+" select access_role_id from site_role_mpg "
					+" where site_id = '"+siteId+"')";
		
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		roleList = getRoles(resultList);
		
		return roleList;
	}
	
	public List<Secrole> getAdmitDischargeRolesAssociatedWithSite(int siteId)
	{
		List<Secrole> roleList = null;
		
		String qr = "select * from secRole where role_no in ( "
					+" select admit_discharge_role_id from site_role_mpg "
					+" where site_id = '"+siteId+"')";
		
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		roleList = getRoles(resultList);
		
		return roleList;
	}
	
	private List<Long> getUserRoles(String userId)
	{
		List<Long> roleList = null;
		
		String qr = "select sr.role_no from secRole sr, secUserRole sur "
					+" where sur.provider_no='"+userId+"' and sr.role_name = sur.role_name";
		
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		if(resultList!=null && resultList.size()>0)
		{
			roleList = new ArrayList<Long>();
			
			for (Map<String, Object> map : resultList)
			{
				if(map.get("ROLE_NO")!=null && map.get("ROLE_NO").toString().length()>0)
				{
					roleList.add(Long.parseLong(map.get("ROLE_NO").toString()));
				}
			}
		}
		return roleList;
	}
	
	private List<Secrole> getRoles(List<Map<String, Object>> resultList)
	{
		List<Secrole> roleList = null;
		
		if(resultList!=null && resultList.size()>0)
		{
			roleList = new ArrayList<Secrole>();
			
			SecroleDao secroleDao = (SecroleDao) SpringUtils.getBean("secroleDao");
			for (Map<String, Object> map : resultList)
			{
				if(map!=null && map.get("ROLE_NO")!=null)
				{
					Secrole secrole = secroleDao.getRole(Integer.parseInt(map.get("ROLE_NO").toString()));
					roleList.add(secrole);
				}
			}
		}
		
		return roleList;
	}
	//get sites which user only can access. 
	//means sites for which user's role is configured in site_role_mpg.access_role_id
	public List<Site> getSitesWhichUserCanOnlyAccess()
	{
		List<Site> sites = null;
		
		String qr = "select * from site where site_id in ( "
					+" select site_id from site_role_mpg where access_role_id in ( "
					+" select t2.role_no from secUserRole t1, secRole t2 "
					+" where t1.provider_no = '"+currentProviderNo+"' and t1.role_name = t2.role_name))";
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		sites = getSiteList(resultList);
		
		return sites;
	}
	
	//get sites for which user's role is configured in site_role_mpg.admit_discharge_role_id
	public List<Site> getSitesWhichUserCanOnlyAdmitDischargeTo()
	{
		List<Site> sites = null;
		
		String qr = "select * from site where site_id in ( "
					+" select site_id from site_role_mpg where admit_discharge_role_id in ( "
					+" select t2.role_no from secUserRole t1, secRole t2 "
					+" where t1.provider_no = '"+currentProviderNo+"' and t1.role_name = t2.role_name))";
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		sites = getSiteList(resultList);
		
		return sites;
	}
	
	//get sites that all users can access
	//means sites for which there is no entry in site_role_mpg where access_role_id is not null
	private List<Site> getAllSitesAccessibleToAllUsers()
	{
		List<Site> sites = null;
		
		String qr = "select * from site where site_id not in (select distinct site_id from site_role_mpg where access_role_id is not null)";
		List<Map<String, Object>> resultList = getJdbcTemplate().queryForList(qr);
		sites = getSiteList(resultList);
		
		return sites;
	}
	
	private List<Site> getSiteList(List<Map<String, Object>> list)
	{
		List<Site> siteList = null;
		
		if(list!=null && list.size()>0)
		{
			siteList = new ArrayList<Site>();
			
			SiteDao siteDao = (SiteDao) SpringUtils.getBean("siteDao");
			for (Map<String, Object> map : list)
			{
				if(map!=null && map.get("SITE_ID")!=null)
				{
					Site site = siteDao.getById(Integer.parseInt(map.get("SITE_ID").toString()));
					siteList.add(site);
				}
			}
		}
		
		return siteList;
	}

	@Override
	protected String[][] getDbQueries()
	{
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	protected Map<String, RowMapper> getRowMappers()
	{
		// TODO Auto-generated method stub
		return null;
	}

	public String getCurrentProviderNo()
	{
		return currentProviderNo;
	}

	public void setCurrentProviderNo(String currentProviderNo)
	{
		this.currentProviderNo = currentProviderNo;
		userAccessSites = getSitesWhichUserCanOnlyAccess();
		userRoles = getUserRoles(currentProviderNo);
	}
}
