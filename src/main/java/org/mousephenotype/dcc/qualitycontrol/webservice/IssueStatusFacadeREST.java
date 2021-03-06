/*
 * Copyright 2012 Medical Research Council Harwell.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.mousephenotype.dcc.qualitycontrol.webservice;

import java.util.ArrayList;
import javax.ejb.Stateless;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import org.mousephenotype.dcc.entities.qc.IssueStatus;
import org.mousephenotype.dcc.qualitycontrol.webservice.pack.IssueStatusPack;

/**
 *
 * @author Gagarine Yaikhom <g.yaikhom@har.mrc.ac.uk>
 */
@Stateless
@Path("issuestatuses")
public class IssueStatusFacadeREST extends AbstractFacade<IssueStatus> {

    public IssueStatusFacadeREST() {
        super(IssueStatus.class);
    }

    @GET
    @Path("extjs/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public IssueStatusPack extjsFind(
            @PathParam("id") Short id,
            @QueryParam("s") String sessionId,
            @QueryParam("u") Integer userId) {
        IssueStatusPack p = new IssueStatusPack();
        if (isValidSession(sessionId, userId)) {
            ArrayList<IssueStatus> t = new ArrayList<IssueStatus>();
            t.add(super.find(id));
            p.setDataSet(t);
        } else {
            p.sessionHasExpired();
        }
        return p;
    }

    @GET
    @Path("extjs")
    @Produces(MediaType.APPLICATION_JSON)
    public IssueStatusPack extjsFindAll(
            @QueryParam("s") String sessionId,
            @QueryParam("u") Integer userId) {
        IssueStatusPack p = new IssueStatusPack();
        if (isValidSession(sessionId, userId)) {
            p.setDataSet(super.findAll());
        } else {
            p.sessionHasExpired();
        }
        return p;
    }
}
