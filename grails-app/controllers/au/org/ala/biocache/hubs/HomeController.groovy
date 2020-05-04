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

import org.springframework.context.MessageSource
import org.springframework.context.i18n.LocaleContextHolder;


class HomeController {
    MessageSource messageSource

    def facetsCacheService

    def index() throws Exception {
        log.debug "Home controller index page"
        addCommonModel()
    }

    def advancedSearch(AdvancedSearchParams requestParams) {
        log.debug "Home controller advancedSearch page"
        //flash.message = "Advanced search for: ${requestParams.toString()}"
        redirect(controller: "occurrences", action:"search", params: requestParams.toParamMap())
    }

    /**
     * Loads some model attributes into the page for advanced search tab.
     * Fields appearing should be specified in config var facets.cached and
     * also need to be set as fields on AdvancedSearchParams.class
     *
     * @see au.org.ala.biocache.hubs.AdvancedSearchParams
     *
     * @return
     */
    private Map addCommonModel() {
        def model = [:]

        facetsCacheService.facetsList.each { fn ->
            log.debug "Getting facet: ${fn}"

            if(fn == "species_group") {
                def res = facetsCacheService.getFacetNamesFor(fn)
                Map translRes = [:]
                res.each { it ->
                    def i18nCode = it.value
                    def translation = messageSource.getMessage("advancedsearch.${i18nCode}",null, i18nCode, LocaleContextHolder.getLocale())
                    translRes.put(it.key, translation)
                }
                def sorted = translRes.sort({m1, m2 -> m1.value <=> m2.value})
                model.put(fn, sorted)
            } else
                if (fn == "institution_name" || fn == "country"  || fn == "state" || fn == grailsApplication.config?.biocache.advancedSearch.lga.layer) {
                    def res = facetsCacheService.getFacetNamesFor(fn)
                    if(res?.containsKey('*')) { // for sorting and translational reasons for "Not supplied"!
                        res.put('*', messageSource.getMessage("advancedsearch.notSupplied",null, 'not supplied', LocaleContextHolder.getLocale()))
                        log.debug "${res['*']}"
                        def notDefined = "~ ${res['*']}"
                        res.put('*', notDefined)
                    }
                    // Replace Ö when sorting wit O, otherwise it will be at the end of the list
                    def sorted = res?.sort({m1, m2 -> m1.value.replaceFirst("Ö", "O").toLowerCase() <=> m2.value.replaceFirst("Ö", "O").toLowerCase()})
                    model.put(fn, sorted)
                }
                else {
                    model.put(fn, facetsCacheService.getFacetNamesFor(fn))
                }

        }

        model
    }
}
