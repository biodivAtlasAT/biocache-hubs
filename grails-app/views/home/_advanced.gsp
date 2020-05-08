<%@ page import="au.org.ala.biocache.hubs.FacetsName; org.apache.commons.lang.StringUtils" contentType="text/html;charset=UTF-8" %>
<g:render template="/layouts/global"/>
<form class="form-horizontal" name="advancedSearchForm" id="advancedSearchForm" action="${request.contextPath}/advancedSearch" method="POST">
    <input type="text" id="solrQuery" name="q" style="position:absolute;left:-9999px;" value="${params.q}"/>
    <input type="hidden" name="nameType" value="${grailsApplication.config.advancedTaxaField?:'matched_name_children'}"/>

    <h4 class="margin-bottom-half-1" style="font-size: 18px;margin-top: 10px;margin-bottom: 10px;font-weight: bold;"><g:message code="advancedsearch.title01"  default="Find records that have"/></h4>
    <div class="form-group">
        <label class="col-md-2 control-label" for="text"><g:message code="advancedsearch.table01col01.title" default="ALL of these words (full text)"/></label>
        <div class="col-md-6">
            <input type="text" name="text" id="text" class="dataset form-control" placeholder="" size="80" value="${params.text}"/>
        </div>
    </div>

    <h4 class="margin-bottom-half-1" style="font-size: 18px;margin-top: 10px;margin-bottom: 10px;font-weight: bold;"><g:message code="advancedsearch.title02" default="Find records for ANY of the following taxa (matched/processed taxon concepts)"/></h4>
    <g:each in="${1..4}" var="i">
        <g:set var="lsidParam" value="lsid_${i}"/>
        <div class="form-group" id="taxon_row_${i}">
            <label class="col-md-2 control-label" for="taxa_${i}"><g:message code="advancedsearch.table02col01.title" default="Species/Taxon"/></label>
            <div class="col-md-6">
                <input type="text" value="" id="taxa_${i}" name="taxonText" class="name_autocomplete form-control" size="60">
                <input type="hidden" name="lsid" class="lsidInput" id="taxa_${i}" value=""/>
            </div>
        </div>
    </g:each>

    <h4 class="margin-bottom-half-1" style="font-size: 18px;margin-top: 10px;margin-bottom: 10px;font-weight: bold;"><g:message code="advancedsearch.allfields.title" default="Find records that specify the following fields"/></h4>
    <div class="form-group">
        <label class="col-md-2 control-label" for="raw_taxon_name"><g:message code="advancedsearch.table03col01.title" default="Raw Scientific Name"/></label>
        <div class="col-md-6">
            <input type="text" name="raw_taxon_name" id="raw_taxon_name" class="dataset form-control" placeholder="" size="60" value=""/>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="species_group"><g:message code="advancedsearch.table04col01.title" default="Species Group"/></label>
        <div class="col-md-6">
            <select class="species_group form-control" name="species_group" id="species_group">
                <option value=""><g:message code="advancedsearch.table04col01.option.label" default="-- select a species group --"/></option>
                <g:each var="group" in="${request.getAttribute("species_group")}">
                    <option value="${group.key}">${group.value}</option>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="institution_collection"><g:message code="advancedsearch.table05col01.title" default="Institution or Collection"/></label>
        <div class="col-md-6">
            <select class="institution_uid collection_uid form-control" name="institution_collection" id="institution_collection">
                <option value=""><g:message code="advancedsearch.table05col01.option01.label" default="-- select an institution or collection --"/></option>
                <g:each var="inst" in="${request.getAttribute("dataPartner")}">
                    <g:set var="partner" value="${inst.value}"/>
                    <g:set var="collections" value="${partner.collections}"/>
                    <g:if test="${collections.size() > 0}">
                        <option value="${inst.key}">${partner.name}</option>
                        <g:each var="coll" in="${collections}">
                            <option value="${coll[0]}">&nbsp;&nbsp;&nbsp;&nbsp;${coll[1]}</option>
                        </g:each>
                    </g:if>
                    <g:else>
                        <option value="${inst.key}">${partner.name}</option>
                    </g:else>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="country"><g:message code="advancedsearch.table06col01.title" default="Country"/></label>
        <div class="col-md-6">
            <select class="country form-control" name="country" id="country">
                <option value=""><g:message code="advancedsearch.table06col01.option.label" default="-- select a country --"/></option>
                <g:each var="country" in="${request.getAttribute("country")}">
                    <option value="${country.key}">${country.value}</option>
                </g:each>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="state"><g:message code="advancedsearch.table06col02.title" default="State/Territory"/></label>
        <div class="col-md-6">
            <select class="state form-control" name="state" id="state">
                <option value=""><g:message code="advancedsearch.table06col02.option.label" default="-- select a state/territory --"/></option>
                <g:each var="state" in="${request.getAttribute("state")}">
                    <option value="${state.key}">${state.value}</option>
                </g:each>
            </select>
        </div>
    </div>

    <g:set var="autoPlaceholder" value="start typing and select from the autocomplete drop-down list"/>
    <g:if test="${request.getAttribute("cl1048") && request.getAttribute("cl1048").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="ibra"><abbr title="Interim Biogeographic Regionalisation of Australia">IBRA</abbr> <g:message code="advancedsearch.table06col03.title" default="region"/></label>
            <div class="col-md-6">
                <select class="biogeographic_region form-control" name="ibra" id="ibra">
                    <option value=""><g:message code="advancedsearch.table06col03.option.label" default="-- select an IBRA region --"/></option>
                    <g:each var="region" in="${request.getAttribute("cl1048").sort()}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>
    <g:if test="${request.getAttribute("cl21") && request.getAttribute("cl21").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="imcra"><abbr title="Integrated Marine and Coastal Regionalisation of Australia">IMCRA</abbr> <g:message code="advancedsearch.table06col04.title" default="region"/></label>
            <div class="col-md-6">
                <select class="biogeographic_region form-control" name="imcra" id="imcra">
                    <option value=""><g:message code="advancedsearch.table06col04.option.label" default="-- select an IMCRA region --"/></option>
                    <g:each var="region" in="${request.getAttribute("cl21").sort()}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>
    <g:if test="${request.getAttribute("${grailsApplication.config.biocache.advancedSearch.lga.layer}") && request.getAttribute("${grailsApplication.config.biocache.advancedSearch.lga.layer}").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="lga"><g:message code="advancedsearch.table06col05.title" default="Local Govt. Area"/></label>
            <div class="col-md-6">
                <select class="lga form-control" name="lga" id="lga">
                    <option value=""><g:message code="advancedsearch.table06col05.option.label" default="-- select local government area--"/></option>
                    <g:each var="region" in="${request.getAttribute("${grailsApplication.config.biocache.advancedSearch.lga.layer}")}">
                        <option value="${region.key}">${region.value}</option>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("type_status") && request.getAttribute("type_status").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="type_status"><g:message code="advancedsearch.table07col01.title" default="Type Status"/></label>
            <div class="col-md-6">
                <select class="type_status form-control" name="type_status" id="type_status">
                    <option value=""><g:message code="advancedsearch.table07col01.option.label" default="-- select a type status --"/></option>
                    <g:each var="type" in="${request.getAttribute("type_status")}">
                        <option value="${type.key}">${type.value}</option>
                    </g:each>
                </select>

            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("collector_text") && request.getAttribute("collector_text").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="collector_text"><g:message code="advancedsearch.collector_text.title" default="Collector"/></label>
            <div class="col-md-6">
                <input type="text" name="collector_text" id="collector_text" class="dataset form-control" placeholder="" value=""/>
            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("data_resource") && request.getAttribute("data_resource").size() > 1}">
        <div class="form-group">
            <label class="col-md-2 control-label" for="data_resource"><g:message code="advancedsearch.dataset.col.label" default="dataset name"/></label>
            <div class="col-md-6">
                <select class="data_resource form-control" name="data_resource" id="data_resource">
                    <option value=""><g:message code="advancedsearch.dataset.select.default" default="-- select a dataset --"/></option>
                    <g:each var="type" in="${request.getAttribute("data_resource").sort({it.value})}">
                        <option value="${type.key}">${type.value}</option>
                    </g:each>
                </select>

            </div>
        </div>
    </g:if>

    <g:if test="${request.getAttribute("data_resource_uid") && request.getAttribute("data_resource_uid").size() > 1}">
        <div class="form-group">
            %{--for="dataset"--}%
            <label class="control-label col-md-2" ><g:message code="advancedsearch.dataset.col.label" default="dataset name"/></label>
            <div class="col-md-6">
                <select class="dataset combobox form-control" name="dataset" id="dataset">
                    <option></option>
                    <g:each var="region" in="${request.getAttribute("data_resource_uid").sort({it.value})}">
                        <g:if test="${region.key?.length() > 1}"><option value="${region.key}">${region.value}</option></g:if>
                    </g:each>
                </select>
            </div>
        </div>
    </g:if>

    <div class="form-group">
        <label class="col-md-2 control-label" for="startDate"><g:message code="advancedsearch.table10col01.title" default="Begin Date"/></label>
        <div class="col-md-2 ">
            <input type="text" name="start_date" id="startDate" class="occurrence_date form-control" placeholder="" value=""/>
        </div>
        <div class="col-md-6">
            <span class="small"><g:message code="advancedsearch.table10col01.des" default="(YYYY-MM-DD) leave blank for earliest record date"/></span>
        </div>
    </div>

    <div class="form-group">
        <label class="col-md-2 control-label" for="endDate"><g:message code="advancedsearch.table10col02.title" default="End Date"/></label>
        <div class="col-md-2 ">
            <input type="text" name="end_date" id="endDate" class="occurrence_date form-control" placeholder="" value=""/>
        </div>
        <div class="col-md-6">
            <span class="small"><g:message code="advancedsearch.table10col02.des" default="(YYYY-MM-DD) leave blank for most recent record date"/> </span>
        </div>
    </div>

    <input type="submit" style="font-weight:bold;text-shadow:none;padding-left:22px; padding-top:6px; padding-bottom:6px" value=<g:message code="advancedsearch.button.submit" default="Search"/> class="btn btn-primary" />
    &nbsp;&nbsp;
    <input type="reset" style="font-weight:bold;text-shadow:none;padding-left:22px; padding-top:6px; padding-bottom:6px" value=<g:message code="advancedsearch.button.reset" default="Clear all"/> id="clearAll" class="btn btn-default" onclick="$('input#solrQuery').val(''); $('input.clear_taxon').click(); return true;"/>
</form>
<asset:script type="text/javascript">
    $(document).ready(function() {
        $('.combobox').combobox({bsVersion: '3'});
    });

</asset:script>