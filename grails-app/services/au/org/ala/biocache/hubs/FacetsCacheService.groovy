/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.biocache.hubs

import org.apache.commons.lang.StringUtils
import org.grails.web.json.JSONObject
import org.springframework.web.client.RestClientException

import javax.annotation.PostConstruct

/**
 * Service to cache the facet values available from a given data hub.
 * Used to populate the values in select drop-down lists in advanced search page.
 */
class FacetsCacheService {
    def webServicesService, grailsApplication
    Map facetsMap = [:]  // generated via SOLR lookup
    List facetsList = [] // set via config (facets.cached) in init()

    /**
     * Init method - load facetsList from config file
     *
     * @return
     */
    @PostConstruct
    void init() {
        // Note config.getProperties will coerce a comma-separated String into a List automagically
        facetsList = grailsApplication.config.getProperty("facets.cached", List, [])
    }

    /**
     * Get the facets values (and labels if available) for the requested facet field.
     *
     * @param facet
     * @return
     */
    Map getFacetNamesFor(String facet) {
        if (!facetsMap) {
            loadSearchResults()
        }

        return facetsMap?.get(facet)
    }

    /**
     * Can be triggered from the admin page. Note: the longTermCache needs to be
     * cleared as well (admin function does this).
     */
    void clearCache() {
        facetsMap = [:]
        init() //  reload config values
    }

    private void loadSearchResultsForCollectory () {
        try {
            SpatialSearchRequestParams requestParams = new SpatialSearchRequestParams()
            JSONObject inJson = webServicesService.cachedCollectoryInstitution(requestParams)
            def fields = [:]
                inJson.result.each { inst ->
                    log.debug "Institute: = ${inst}"
                    def entry = [:]
                    def key = inst.institutionUid
                    entry.put("name",inst.institutionName )
                    entry.put("collections", inst.collections)
                    fields.put(key, entry)
                }
            JSONObject dpJson = webServicesService.cachedCollectoryDataProvider(requestParams)
            dpJson.result.each { prov ->
                log.debug "Provider: = ${prov}"
                def entry = [:]
                def key = prov.uid
                entry.put("name",prov.name )
                entry.put("collections", [])
                fields.put(key, entry)
            }
            def sorted = fields?.sort({m1, m2 -> m1.value.name.toLowerCase() <=> m2.value.name.toLowerCase()})
            facetsMap.put("dataPartner", sorted)

        } catch (RestClientException rce) {
            log.warn "Cached facets for collectory call failed - ${rce.message}", rce
        }


    }
    /**
     * Do a search for all records and store facet values for the requested facet fields
     */
    private void loadSearchResults() {
        if (!facetsList) {
            init()
        }

        SpatialSearchRequestParams requestParams = new SpatialSearchRequestParams()
        requestParams.setQ("*:*")
        requestParams.setPageSize(0)
        requestParams.setFlimit(999)
        requestParams.setFacets(facetsList as String[])

        loadSearchResultsForCollectory()

        try {
            JSONObject sr = webServicesService.cachedFullTextSearch(requestParams)

            if (sr.has("facetResults") && sr.facetResults.size() > 0) {
                sr.facetResults.each { fq ->
                    log.debug "facetResults = ${fq}"
                    def fieldName = fq.fieldName
                    def fields = [:]
                    fq.fieldResult.each {
                        if (it.fq) {
                            def values = it.fq.tokenize(":")
                            if(fieldName == "data_resource") {
                                // may contain ":" in the string and thus leads to a spltting problem with tokenizing
                                def myVal = it.fq
                                values = myVal.split(":", 2)
                            }
                            def value = StringUtils.remove(values[1], '"') // some values have surrounding quotes
                            if (fieldName == "species_group")
                                fields.put(value, it.i18nCode)
                            else
                                fields.put(value, it.label) // it.label is the display label that can be different from the Solr field value
                        } else {
                            fields.put(it.label, it.label)
                        }
                    }

                    if (fields.size() > 0) {
                        facetsMap.put(fieldName, fields)
                    } else {
                        log.warn "No facet values found for ${fieldName}"
                    }
                }
            }
        } catch (RestClientException rce) {
            log.warn "Cached facets call failed - ${rce.message}", rce
        }
    }

}
