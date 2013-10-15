/**
 * Copyright (c) 2006-. OSCARservice, OpenSoft System. All Rights Reserved.
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
 */

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package oscar.oscarRx.dao;

import java.util.List;

import oscar.oscarRx.model.Favorites;
import oscar.oscarRx.model.Favoritesprivilege;

/**
 *
 * @author toby
 */
public interface RxCloneFavoritesDAO {
    public List<Favorites> getFavoritesFromProvider(String providerNo);
    public List<Favorites> getFavoritesFromIDs(List<Integer> list);
    public void setFavoritesForProvider(String providerNo, List<Favorites> list);
    public List<String> getProviders(); 
    public void setFavoritesPrivilege(String providerNo,boolean openpublic, boolean writeable);
    public Favoritesprivilege getFavoritesPrivilege(String providerNo);
    public String getProviderName(String providerNo);
}
