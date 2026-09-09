Class Terminology.Production.API Extends (%CSP.REST, Ens.BusinessService)
{

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

Parameter LoincTargetConfigName = "LoincRepositoryOperation";

Parameter SnomedTargetConfigName = "SnomedRepositoryOperation";

Parameter SnomedGatewayConfigName = "SnomedGatewayService";

Parameter LoincGatewayConfigName = "LoincGatewayService";

Parameter ICDTargetConfigName = "ICDRepositoryOperation";

Parameter ICDGatewayConfigName = "ICDGatewayService";

Parameter VectorTargetConfigName = "VectorSearchOperation";

Parameter VectorGatewayConfigName = "VectorGatewayService";

XData UrlMap
{
<Routes>
    <Route Url="/auth/login" Method="GET" Call="AppLogin"/>
    <Route Url="/snomed/search" Method="GET" Call="SnomedSearch"/>
    <Route Url="/snomed/concepts/:conceptId" Method="GET" Call="SnomedGetConcept"/>
    <Route Url="/snomed/concepts/:conceptId/children" Method="GET" Call="SnomedGetChildren"/>
    <Route Url="/snomed/concepts/:conceptId/descendants" Method="GET" Call="SnomedGetDescendants"/>
    <Route Url="/snomed/concepts/:conceptId/ancestors" Method="GET" Call="SnomedGetAncestors"/>
    <Route Url="/snomed/concepts/:conceptId/descriptions" Method="GET" Call="SnomedGetDescriptions"/>
    <Route Url="/snomed/subsumes/:codeA/:codeB" Method="GET" Call="SnomedGetSubsumes"/>
    <Route Url="/snomed/refsets" Method="GET" Call="SnomedGetRefsets"/>
    <Route Url="/snomed/refsets/:refsetId/members" Method="GET" Call="SnomedGetRefsetMembers"/>
    <Route Url="/snomed/validate-code" Method="GET" Call="SnomedValidateCode"/>
    <Route Url="/snomed/concepts/:conceptId/icd10-mappings" Method="GET" Call="SnomedGetIcd10Mappings"/>
    <Route Url="/loinc/search" Method="GET" Call="LoincSearch"/>
    <Route Url="/loinc/codes/:loincNum" Method="GET" Call="LoincGetCode"/>
    <Route Url="/loinc/codes/:loincNum/displays" Method="GET" Call="LoincGetDisplays"/>
    <Route Url="/loinc/codes/:loincNum/parts" Method="GET" Call="LoincGetParts"/>
    <Route Url="/loinc/codes/:loincNum/ancestors" Method="GET" Call="LoincGetAncestors"/>
    <Route Url="/loinc/codes/:loincNum/descendants" Method="GET" Call="LoincGetDescendants"/>
    <Route Url="/loinc/groups" Method="GET" Call="LoincGetGroups"/>
    <Route Url="/loinc/groups/:groupId/members" Method="GET" Call="LoincGetGroupMembers"/>
    <Route Url="/loinc/validate-code" Method="GET" Call="LoincValidateCode"/>
    <Route Url="/icd/search" Method="GET" Call="ICDSearch"/>
    <Route Url="/icd/codes/:code" Method="GET" Call="ICDGetCode"/>
    <Route Url="/icd/codes/:code/children" Method="GET" Call="ICDGetChildren"/>
    <Route Url="/icd/codes/:code/descendants" Method="GET" Call="ICDGetDescendants"/>
    <Route Url="/icd/codes/:code/ancestors" Method="GET" Call="ICDGetAncestors"/>
    <Route Url="/icd/families" Method="GET" Call="ICDGetFamilies"/>
    <Route Url="/icd/validate-code" Method="GET" Call="ICDValidateCode"/>
    <Route Url="/drug/search" Method="GET" Call="DrugSearch"/>
    <Route Url="/drug/lookup" Method="GET" Call="DrugLookup"/>
    <Route Url="/drug/validate-code" Method="GET" Call="DrugValidate"/>
    <Route Url="/drug/codesystems" Method="GET" Call="DrugCodeSystems"/>
    <Route Url="/rxnorm/search" Method="GET" Call="RxnormSearch"/>
    <Route Url="/rxnorm/lookup" Method="GET" Call="RxnormLookup"/>
    <Route Url="/rxnorm/validate-code" Method="GET" Call="RxnormValidate"/>
    <Route Url="/rxnorm/chinese-map" Method="GET" Call="RxnormZhMap"/>
    <Route Url="/icd10/search" Method="GET" Call="Icd10Search"/>
    <Route Url="/icd10/lookup" Method="GET" Call="Icd10Lookup"/>
    <Route Url="/icd10/validate-code" Method="GET" Call="Icd10Validate"/>
    <Route Url="/uscore-condition/search" Method="GET" Call="UsCoreConditionSearch"/>
    <Route Url="/uscore-condition/lookup" Method="GET" Call="UsCoreConditionLookup"/>
    <Route Url="/uscore-condition/validate-code" Method="GET" Call="UsCoreConditionValidate"/>
    <Route Url="/systems" Method="GET" Call="TermSystemsJson"/>
    <Route Url="/" Method="GET" Call="TermSystemsPage"/>
    <Route Url="/vector/search" Method="GET" Call="VectorSearch"/>
    <Route Url="/vector/crosswalk" Method="GET" Call="VectorCrosswalk"/>
</Routes>
}

ClassMethod AppLogin() As %Status
{
    Set %response.ContentType = "application/json"

    Set obj = {}
    Set obj.ok = 1
    Set obj.message = "OK"

    Write obj.%ToJSON()
    Return $$$OK
}

ClassMethod SnomedSearch() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedSearchRequest).%New()
        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetConcept(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetConceptRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetChildren(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetChildrenRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetDescendants(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetDescendantsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetAncestors(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetAncestorsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetDescriptions(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetDescriptionsRequest).%New()
        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.ActiveOnly = +$Get(%request.Data("activeOnly",1))
        Set req.TypeId = $Get(%request.Data("typeId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=200
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetSubsumes(codeA As %String, codeB As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetSubsumesRequest).%New()
        Set req.CodeA = codeA
        Set req.CodeB = codeB
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.View = $Get(%request.Data("view",1))
        If req.View="" Set req.View="inferred"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetRefsets() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetRefsetsRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetRefsetMembers(refsetId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetRefsetMembersRequest).%New()
        Set req.RefsetId = refsetId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Dialect = $Get(%request.Data("dialect",1))
        If req.Dialect="" Set req.Dialect="es-ES"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedValidateCodeRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Code = $Get(%request.Data("code",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod SnomedGetIcd10Mappings(conceptId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.SnomedGetIcd10MappingsRequest).%New()

        Set req.ConceptId = conceptId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=50

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#SnomedGatewayConfigName, ..#SnomedTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincSearch() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincSearchRequest).%New()
        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetCode(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetCodeRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetDisplays(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetDisplaysRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetParts(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetPartsRequest).%New()
        Set req.LoincNum = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=200
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetAncestors(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetAncestorsRequest).%New()
        Set req.Code = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.HierarchyType = $Get(%request.Data("hierarchyType",1))
        If req.HierarchyType="" Set req.HierarchyType="COMPONENTBYSYSTEM"
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetDescendants(loincNum As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetDescendantsRequest).%New()
        Set req.Code = loincNum
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.HierarchyType = $Get(%request.Data("hierarchyType",1))
        If req.HierarchyType="" Set req.HierarchyType="COMPONENTBYSYSTEM"
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetGroups() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetGroupsRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincGetGroupMembers(groupId As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincGetGroupMembersRequest).%New()
        Set req.GroupId = groupId
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Lang = $Get(%request.Data("lang",1))
        If req.Lang="" Set req.Lang="es"
        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100
        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod LoincValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.LoincValidateCodeRequest).%New()
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Code = $Get(%request.Data("code",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#LoincGatewayConfigName, ..#LoincTargetConfigName)
        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDSearch() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDSearchRequest).%New()

        Set req.Query = $Get(%request.Data("q",1))
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=20

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }
    Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    }Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDGetCode(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDGetCodeRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDGetChildren(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDGetChildrenRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDGetDescendants(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDGetDescendantsRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDGetAncestors(code As %String) As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDGetAncestorsRequest).%New()

        Set req.Code = code
        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.IncludeSelf = +$Get(%request.Data("includeSelf",1))
        Set req.MaxDepth = +$Get(%request.Data("maxDepth",1))

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDGetFamilies() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDGetFamiliesRequest).%New()

        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set req.Limit = +$Get(%request.Data("limit",1))
        If req.Limit=0 Set req.Limit=100

        Set req.Offset = +$Get(%request.Data("offset",1))

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod ICDValidateCode() As %Status
{
    Set tSC = $$$OK

    Try {
        Set req = ##class(Terminology.Production.Msg.ICDValidateCodeRequest).%New()

        Set req.ReleaseId = $Get(%request.Data("releaseId",1))
        Set req.Version = +$Get(%request.Data("version",1))
        Set req.CodeType = $Get(%request.Data("codeType",1))
        Set req.Code = $Get(%request.Data("code",1))

        If req.CodeType="" Set req.CodeType="DIAGNOSIS"

        Set rsp = ""
        Set tSC = ..SendGatewayRequest(req, .rsp, ..#ICDGatewayConfigName, ..#ICDTargetConfigName)

        If $$$ISERR(tSC) {
            Do ..WriteError($System.Status.GetOneErrorText(tSC), 500)
            Return $$$OK
        }

        Do ..WriteDynamicResponse(rsp.Payload)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod VectorSearch() As %Status
{
    Try {
        Set q = $Get(%request.Data("q",1))
        If $ZSTRIP(q,"<>W")="" {
            Do ..WriteError("参数 q（查询文本）必填", 400)
            Return $$$OK
        }

        Set lang = $Get(%request.Data("lang",1))
        Set limit = +$Get(%request.Data("limit",1))
        If limit=0 Set limit=10
        Set model = $Get(%request.Data("model",1))
        If model="" Set model="Qwen3-Embedding-0.6B"

        Set sysUris = []
        Set i=""
        For  {
            Set i=$Order(%request.Data("systemUri",i))
            Quit:i=""
            Do sysUris.%Push($Get(%request.Data("systemUri",i)))
        }

        Set relIds = []
        Set i=""
        For  {
            Set i=$Order(%request.Data("releaseId",i))
            Quit:i=""
            Do relIds.%Push($Get(%request.Data("releaseId",i)))
        }

        Set res = ##class(Terminology.Vector.Utils).SearchSimilarMulti(q, sysUris, relIds, lang, limit, model)

        // 编码自愈：Embedded HTTP 偶发中文编码异常会导致全库低分（<0.6）；重试一次通常即恢复。
        // 正常弱匹配（罕见词 top<0.6）仅多一次检索，不影响正确性。
        If (res.Count > 0) && (res.Items.Count() > 0) {
            Set topScore = res.Items.GetAt(1).Score
            If topScore < 0.6 {
                Set res = ##class(Terminology.Vector.Utils).SearchSimilarMulti(q, sysUris, relIds, lang, limit, model)
            }
        }

        // 空结果时探活 embedding 服务：编码失败抛异常 -> catch 显式 500（不静默返回空）
        If res.Count=0 {
            Do ##class(Terminology.Vector.Utils).EncodeText(q, model)
        }

        If $Get(%request.Data("debug",1)) = "1" {
            // 自检：本请求 EncodeText 编码的 q 与库内已知行点积（诊断 REST 上下文编码是否正常）
            Set qv = ##class(Terminology.Vector.Utils).EncodeText(q, model)
            Set chk = ##class(%SQL.Statement).%New()
            Set csc = chk.%Prepare("SELECT VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), Embedding) AS S FROM Terminology_Vector.TermEmbedding WHERE Code=? AND SystemUri=?")
            Set crs = chk.%Execute(qv, "NRDL-FDDBF2D502", "urn:cn-nhsa:drug-nrdl")
            Do crs.%Next()
            Set qvd = crs.%Get("S")
        } Else {
            Set qvd = ""
        }

        Set out = {}
        Set out.selfcheck = qvd
        Set out.count = res.Count
        Set out.items = []
        For i=1:1:res.Items.Count() {
            Set it = res.Items.GetAt(i)
            Set o = {}
            Set o.systemUri = it.SystemUri
            Set o.releaseId = it.ReleaseId
            Set o.code = it.Code
            Set o.lang = it.Lang
            Set o.text = it.Text
            Set o.model = it.Model
            Set o.score = it.Score
            Do out.items.%Push(o)
        }
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod VectorCrosswalk() As %Status
{
    Do ..WriteError("跨术语集语义匹配(crosswalk)由平台 AI 数据转换 Skill 负责，本术语服务器不提供（裁剪版）", 501)
    Return $$$OK
}
ClassMethod RxnormSearch() As %Status
{
    // RxNorm 名称检索：q 必填；可选 tty（逗号分隔）与 limit；名称包含匹配（英文，大小写不敏感）
    Try {
        Set q = $Get(%request.Data("q",1))
        If $ZSTRIP(q,"<>W")="" {
            Do ..WriteError("参数 q（药名检索）必填", 400)
            Return $$$OK
        }
        Set limit = +$Get(%request.Data("limit",1))
        If limit=0 Set limit=20
        Set tty = $Get(%request.Data("tty",1))

        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "SELECT TOP ? Rxcui, Tty, Str FROM Terminology_Rxnorm.Concept WHERE Str LIKE ?"
        Set tArgs($I(tArgs)) = limit
        Set tArgs($I(tArgs)) = "%"_q_"%"
        If tty '= "" {
            Set ttys = $Length(tty,",")
            Set sql = sql _ " AND Tty IN ("
            For i = 1:1:ttys {
                If i>1 Set sql = sql _ ","
                Set sql = sql _ "?"
                Set tArgs($I(tArgs)) = $Piece(tty,",",i)
            }
            Set sql = sql _ ")"
        }
        Set sql = sql _ " ORDER BY $LENGTH(Str)"
        Do stmt.%Prepare(sql)
        Set rs = stmt.%Execute(tArgs...)

        Set out = {}
        Set out.query = q
        Set out.items = []
        While rs.%Next() {
            Set o = {}
            Set o.rxcui = rs.%Get("Rxcui")
            Set o.tty = rs.%Get("Tty")
            Set o.str = rs.%Get("Str")
            Do out.items.%Push(o)
        }
        Set out.count = out.items.%Size()
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod RxnormLookup() As %Status
{
    // RxNorm 概念查询：rxcui 必填，返回该概念全部名称/TTY
    Try {
        Set rxcui = $Get(%request.Data("rxcui",1))
        If rxcui = "" {
            Do ..WriteError("参数 rxcui 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT RxaUI, Tty, Str FROM Terminology_Rxnorm.Concept WHERE Rxcui = ? ORDER BY Tty, Str")
        Set rs = stmt.%Execute(rxcui)

        Set out = {}
        Set out.rxcui = rxcui
        Set out.items = []
        While rs.%Next() {
            Set o = {}
            Set o.tty = rs.%Get("Tty")
            Set o.str = rs.%Get("Str")
            Set o.rxaUI = rs.%Get("RxaUI")
            Do out.items.%Push(o)
        }
        If out.items.%Size() = 0 {
            Do ..WriteError("RXCUI 不存在: "_rxcui, 404)
            Return $$$OK
        }
        Set out.count = out.items.%Size()
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod RxnormValidate() As %Status
{
    // RxNorm 码校验：返回该 RXCUI 是否存在
    Try {
        Set rxcui = $Get(%request.Data("rxcui",1))
        If rxcui = "" {
            Do ..WriteError("参数 rxcui 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT TOP 1 Rxcui FROM Terminology_Rxnorm.Concept WHERE Rxcui = ?")
        Set rs = stmt.%Execute(rxcui)
        Set out = {}
        If rs.%Next() {
            Set out.valid = 1
        } Else {
            Set out.valid = 0
        }
        Set out.rxcui = rxcui
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod RxnormZhMap() As %Status
{
    // 中文药名 ↔ RxNorm 别名映射查询：?q=中文名（LIKE）或 ?code=RXCUI（反查）
    Try {
        Set q = $Get(%request.Data("q",1))
        Set code = $Get(%request.Data("code",1))
        If (q = "") && (code = "") {
            Do ..WriteError("参数 q（中文名）或 code（RXCUI）必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        If q '= "" {
            // 双向包含：ZhName 含 q（词表名较长，如"阿基仑赛注射液"）或 q 含 ZhName
            //（查询带剂型后缀如"阿基仑赛注射液"vs词表"阿基仑赛"）都命中
            Set esc = $Replace(q, "'", "''")
            Set sql = "SELECT TOP 20 ZhName, Rxcui, EnName, Tty, Source FROM Terminology_Rxnorm.ChineseAlias "
            Set sql = sql _ "WHERE (ZhName LIKE '%" _ esc _ "%') OR ('" _ esc _ "' LIKE '%' || ZhName || '%') ORDER BY ZhName"
            Do stmt.%Prepare(sql)
            Set rs = stmt.%Execute()
        } Else {
            Do stmt.%Prepare("SELECT TOP 20 ZhName, Rxcui, EnName, Tty, Source FROM Terminology_Rxnorm.ChineseAlias WHERE Rxcui = ? ORDER BY ZhName")
            Set rs = stmt.%Execute(code)
        }
        Set out = {}
        Set out.items = []
        While rs.%Next() {
            Set o = {}
            Set o.zhName = rs.%Get("ZhName")
            Set o.rxcui = rs.%Get("Rxcui")
            Set o.enName = rs.%Get("EnName")
            Set o.tty = rs.%Get("Tty")
            Set o.source = rs.%Get("Source")
            Do out.items.%Push(o)
        }
        Set out.count = out.items.%Size()
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod Icd10Search() As %Status
{
    // 国标 ICD-10 诊断检索：q 必填（编码前缀或疾病名包含），可选 limit
    Try {
        Set q = $Get(%request.Data("q",1))
        If $ZSTRIP(q,"<>W")="" {
            Do ..WriteError("参数 q（疾病名/编码）必填", 400)
            Return $$$OK
        }
        Set limit = +$Get(%request.Data("limit",1))
        If limit=0 Set limit=20
        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "SELECT TOP ? Code, Name, Dagger FROM Terminology_Icd10.Concept "
        Set sql = sql _ "WHERE (Name LIKE ? OR Code LIKE ?) ORDER BY $LENGTH(Code), Code"
        Do stmt.%Prepare(sql)
        Set rs = stmt.%Execute(limit, "%"_q_"%", q_"%")
        Set out = {}
        Set out.query = q
        Set out.items = []
        While rs.%Next() {
            Set o = {}
            Set o.code = rs.%Get("Code")
            Set o.name = rs.%Get("Name")
            Set o.dagger = rs.%Get("Dagger")
            Do out.items.%Push(o)
        }
        Set out.count = out.items.%Size()
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod Icd10Lookup() As %Status
{
    // 国标 ICD-10 编码查询：code 必填
    Try {
        Set code = $Get(%request.Data("code",1))
        If code = "" {
            Do ..WriteError("参数 code 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT Code, Name, Dagger FROM Terminology_Icd10.Concept WHERE Code = ?")
        Set rs = stmt.%Execute(code)
        If rs.%Next() {
            Set out = {}
            Set out.code = rs.%Get("Code")
            Set out.name = rs.%Get("Name")
            Set out.dagger = rs.%Get("Dagger")
            Set %response.ContentType = "application/json"
            Do out.%ToJSON()
            Return $$$OK
        }
        Do ..WriteError("编码不存在: "_code, 404)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod Icd10Validate() As %Status
{
    // 国标 ICD-10 编码校验
    Try {
        Set code = $Get(%request.Data("code",1))
        If code = "" {
            Do ..WriteError("参数 code 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT TOP 1 Code FROM Terminology_Icd10.Concept WHERE Code = ?")
        Set rs = stmt.%Execute(code)
        Set out = {}
        If rs.%Next() {
            Set out.valid = 1
        } Else {
            Set out.valid = 0
        }
        Set out.code = code
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod UsCoreConditionSearch() As %Status
{
    // US Core Condition SNOMED 样本检索：q 必填（显示名包含或码前缀），可选 limit
    Try {
        Set q = $Get(%request.Data("q",1))
        If $ZSTRIP(q,"<>W")="" {
            Do ..WriteError("参数 q（病名/码）必填", 400)
            Return $$$OK
        }
        Set limit = +$Get(%request.Data("limit",1))
        If limit=0 Set limit=20
        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "SELECT TOP ? Code, Display FROM Terminology_SnomedUs.Concept "
        Set sql = sql _ "WHERE (Display LIKE ? OR Code LIKE ?) ORDER BY $LENGTH(Display), Code"
        Do stmt.%Prepare(sql)
        Set rs = stmt.%Execute(limit, "%"_q_"%", q_"%")
        Set out = {}
        Set out.query = q
        Set out.items = []
        While rs.%Next() {
            Set o = {}
            Set o.code = rs.%Get("Code")
            Set o.display = rs.%Get("Display")
            Do out.items.%Push(o)
        }
        Set out.count = out.items.%Size()
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod UsCoreConditionLookup() As %Status
{
    // US Core Condition SNOMED 码查询
    Try {
        Set code = $Get(%request.Data("code",1))
        If code = "" {
            Do ..WriteError("参数 code 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT Code, Display FROM Terminology_SnomedUs.Concept WHERE Code = ?")
        Set rs = stmt.%Execute(code)
        If rs.%Next() {
            Set out = {}
            Set out.code = rs.%Get("Code")
            Set out.display = rs.%Get("Display")
            Set %response.ContentType = "application/json"
            Do out.%ToJSON()
            Return $$$OK
        }
        Do ..WriteError("编码不存在: "_code, 404)
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod UsCoreConditionValidate() As %Status
{
    // US Core Condition SNOMED 码校验
    Try {
        Set code = $Get(%request.Data("code",1))
        If code = "" {
            Do ..WriteError("参数 code 必填", 400)
            Return $$$OK
        }
        Set stmt = ##class(%SQL.Statement).%New()
        Do stmt.%Prepare("SELECT TOP 1 Code FROM Terminology_SnomedUs.Concept WHERE Code = ?")
        Set rs = stmt.%Execute(code)
        Set out = {}
        If rs.%Next() {
            Set out.valid = 1
        } Else {
            Set out.valid = 0
        }
        Set out.code = code
        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod TableCount(pSql As %String) As %Integer [ Private ]
{
    // 轻量 COUNT 辅助：表不存在/出错返回 -1
    Set n = -1
    Try {
        Set st = ##class(%SQL.Statement).%New()
        Do st.%Prepare(pSql)
        Set rs = st.%Execute()
        If rs.%Next() Set n = +rs.%GetData(1)
    } Catch ex {
        Set n = -1
    }
    Quit n
}

ClassMethod TermSystemsJson() As %Status
{
    // 术语集清单 JSON：GET /terminology/systems（浏览器/前端可用）
    Try {
        Set out = {}
        Set out.items = []

        // ① 中文药品（医保目录 + 商保补充）
        Set nrdl = ..TableCount("SELECT COUNT(*) FROM Terminology_Drug.Code WHERE CodeSystemId='nrdl'")
        Set cbih = ..TableCount("SELECT COUNT(*) FROM Terminology_Drug.Code WHERE CodeSystemId='cbih'")
        If nrdl < 0 Set nrdl = ..TableCount("SELECT COUNT(*) FROM Terminology_Drug.Code")
        If cbih < 0 Set cbih = 0
        Set o = {}
        Set o.id = "chinese-drugs"
        Set o.name = "中文药品（医保目录 NRDL + 商保补充 CBIH）"
        Set o.language = "zh"
        Set o.kind = "drug"
        Set o.count = nrdl + cbih
        Set o.vectorCount = (..TableCount("SELECT COUNT(*) FROM Terminology_Vector.TermEmbedding WHERE SystemUri='urn:cn-nhsa:drug-nrdl'")
                            + ..TableCount("SELECT COUNT(*) FROM Terminology_Vector.TermEmbedding WHERE SystemUri='urn:cn-nhsa:drug-cbih'"))
        Set o.systemUri = "urn:cn-nhsa:drug-nrdl / urn:cn-nhsa:drug-cbih"
        Set o.endpoints = "/terminology/drug/search|lookup|validate-code|codesystems"
        Do out.items.%Push(o)

        // ② RxNorm 药品（英文）
        Set o = {}
        Set o.id = "rxnorm"
        Set o.name = "RxNorm 药品（IN/SCD/BN 全层级 + 中文别名映射）"
        Set o.language = "en"
        Set o.kind = "drug"
        Set o.count = ..TableCount("SELECT COUNT(*) FROM Terminology_Rxnorm.Concept")
        Set o.vectorCount = ..TableCount("SELECT COUNT(*) FROM Terminology_Vector.TermEmbedding WHERE SystemUri='http://www.nlm.nih.gov/research/umls/rxnorm'")
        Set o.systemUri = "http://www.nlm.nih.gov/research/umls/rxnorm"
        Set o.endpoints = "/terminology/rxnorm/search|lookup|validate-code|chinese-map"
        Do out.items.%Push(o)

        // ③ 中文诊断（国标 ICD-10）
        Set o = {}
        Set o.id = "chinese-icd10"
        Set o.name = "中文诊断（国标 ICD-10 GB/T 14396-2016）"
        Set o.language = "zh"
        Set o.kind = "diagnosis"
        Set o.count = ..TableCount("SELECT COUNT(*) FROM Terminology_Icd10.Concept")
        Set o.vectorCount = 0
        Set o.systemUri = "urn:cn-nhsa:icd10-gbt2016"
        Set o.endpoints = "/terminology/icd10/search|lookup|validate-code"
        Do out.items.%Push(o)

        // ④ SNOMED CT 诊断（US Core Condition 值集样本）
        Set o = {}
        Set o.id = "snomed-uscore"
        Set o.name = "SNOMED CT 诊断（US Core Condition Codes 公开样本）"
        Set o.language = "en"
        Set o.kind = "diagnosis"
        Set o.count = ..TableCount("SELECT COUNT(*) FROM Terminology_SnomedUs.Concept")
        Set o.vectorCount = 0
        Set o.systemUri = "http://snomed.info/sct (US Core context)"
        Set o.endpoints = "/terminology/uscore-condition/search|lookup|validate-code"
        Do out.items.%Push(o)

        Set %response.ContentType = "application/json"
        Do out.%ToJSON()
        Return $$$OK
    } Catch ex {
        Do ..WriteError(ex.DisplayString(), 500)
        Return $$$OK
    }
}

ClassMethod TermSystemsPage() As %Status
{
    // 术语集状态页：GET /terminology/（浏览器直接看；同源 fetch /systems）
    Set %response.ContentType = "text/html; charset=utf-8"
    Write "<!doctype html><html lang='zh-CN'><head><meta charset='utf-8'>"
    Write "<title>术语服务器 · 术语集</title>"
    Write "<style>body{font-family:system-ui,-apple-system,'PingFang SC','Microsoft YaHei',sans-serif;margin:2rem auto;max-width:1080px;padding:0 1rem;color:#222}"
    Write "h1{font-size:1.4rem}table{border-collapse:collapse;width:100%;margin-top:1rem;font-size:.92rem}"
    Write "th,td{border:1px solid #d9dee6;padding:.55rem .7rem;text-align:left;vertical-align:top}"
    Write "th{background:#f3f6fa}.badge{display:inline-block;padding:.05rem .5rem;border-radius:10px;font-size:.75rem;font-weight:600}"
    Write ".ok{background:#e4f5e9;color:#1a7f37}.no{background:#fdecea;color:#c62828}.kind{font-weight:600}"
    Write ".vec{color:#1a7f37}.mono{font-family:ui-monospace,Menlo,monospace;font-size:.8rem}.note{color:#777;font-size:.85rem;margin-top:1.5rem}"
    Write ".err{color:#c62828;padding:1rem}</style></head><body>"
    Write "<h1>🩺 术语服务器 · 术语集清单</h1><p id='st'>加载中…</p>"
    Write "<table id='tb' style='display:none'><thead><tr><th>术语集</th><th>语言</th><th>类别</th><th>结构化规模</th><th>向量</th><th>Code System (URI)</th><th>检索端点</th></tr></thead><tbody id='rows'></tbody></table>"
    Write "<p class='note'>致谢：本术语服务器基于 InterSystems 开源项目《Terminology Server on InterSystems IRIS for Health》构建——感谢原作者与贡献者（InterSystems Developer Community，MIT License © 2026）。原项目定位为 IRIS 上的多术语参考实现（SNOMED CT / LOINC / ICD + FHIR API）：https://github.com/intersystems-ib/iris-terminology-server 。本项目使用的 fork: https://github.com/zlnick/iris-terminology-server（demo-community 分支：community 镜像、关闭依赖 license 的 vector 运行组件），并扩展了中文药品 / RxNorm / 国标 ICD-10 / US Core SNOMED 术语集。JSON 清单接口: GET /terminology/systems。术语数据来源：国家医保及商保药品目录、NLM RxNorm（美国国立医学图书馆）、GB/T 14396-2016《疾病分类与代码》、SNOMED CT（IHTSDO 版权；此处仅用 US Core 值集公开展开样本）。</p>"
    Write "<script>"
    Write "fetch('systems').then(r=>r.json()).then(d=>{document.getElementById('st').textContent='共 '+d.items.length+' 个术语集';"
    Write "const tb=document.getElementById('tb'),tr=document.getElementById('rows');tb.style.display='table';"
    Write "d.items.forEach(it=>{const row=document.createElement('tr');row.innerHTML=`<td class='kind'>${it.name}</td><td>${it.language==='zh'?'中文':'English'}</td><td>${it.kind==='drug'?'💊药品':'📋诊断'}</td><td>${it.count}</td><td>${it.vectorCount>0?'向量 '+it.vectorCount:'未向量'}</td><td class='mono'>${it.systemUri}</td><td class='mono'>${it.endpoints}</td>`;tr.appendChild(row);});"
    Write "}).catch(e=>{document.getElementById('st').className='err';document.getElementById('st').textContent='加载失败: '+e;});"
    Write "</script></body></html>"
    Return $$$OK
}

ClassMethod SendGatewayRequest(pRequest As Ens.Request, Output pResponse As Ens.Response, tGatewayName As %String, tTargetName As %String) As %Status
{
  Do ##class(Terminology.Core.Trace).StartRequest("native", tTargetName, "gateway="_tGatewayName_" requestClass="_$Select($IsObject(pRequest):pRequest.%ClassName(1),1:""))
  Set pRequest.TraceId = $Get(^||TSTraceRequestId)
  Set pRequest.TraceStart = $Get(^||TSTraceRequestStart)

  Set status = ##class(Ens.Director).CreateBusinessService(tGatewayName, .instance)
  If $$$ISERR(status) {
      Do ##class(Terminology.Core.Trace).LogError("native", "CreateBusinessService failed", $System.Status.GetOneErrorText(status))
      Do ##class(Terminology.Core.Trace).EndRequest("native", "request-error", "stage=CreateBusinessService")
      Return status
  }

  Do ##class(Terminology.Core.Trace).Log("native", "SendRequestSync", "target="_tTargetName_" requestClass="_$Select($IsObject(pRequest):pRequest.%ClassName(1),1:""))
  Set status = instance.SendRequestSync(tTargetName, pRequest, .pResponse)
  If $$$ISERR(status) {
      Do ##class(Terminology.Core.Trace).LogError("native", "SendRequestSync failed", $System.Status.GetOneErrorText(status))
      Do ##class(Terminology.Core.Trace).EndRequest("native", "request-error", "stage=SendRequestSync")
      Return status
  }

  Return status
}

ClassMethod WriteDynamicResponse(pPayload As %JSON.Adaptor) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("native", "WriteDynamicResponse", "payloadClass="_$Select($IsObject(pPayload):pPayload.%ClassName(1),1:""))
    Do ##class(Terminology.Core.Trace).EndRequest("native")
    Set %response.ContentType = "application/json"
    do pPayload.%JSONExport()
    Return $$$OK
}

ClassMethod WriteError(pMessage As %String, pHttpCode As %Integer = 500) As %Status
{
    Do ##class(Terminology.Core.Trace).LogError("native", "WriteError", "httpCode="_pHttpCode_" message="_pMessage)
    Do ##class(Terminology.Core.Trace).EndRequest("native", "request-error", "httpCode="_pHttpCode)
    Set %response.Status = pHttpCode
    Set %response.ContentType = "application/json"

    Set obj = {}
    Set obj.error = 1
    Set obj.message = pMessage

    Write obj.%ToJSON()
    Return $$$OK
}

// ==================== 药品目录术语（医保 NRDL / 商保 CBIH） ====================
ClassMethod DrugSearch() As %Status
{
    Set %response.ContentType = "application/json"
    Set cs = $Get(%request.Data("codeSystem",1))
    If cs = "" Set cs = "nrdl"
    Set q = $Get(%request.Data("q",1))
    Set limit = +$Get(%request.Data("limit",1))
    If limit = 0 Set limit = 20
    Set offset = +$Get(%request.Data("offset",1))
    Set j = ##class(Terminology.Drug.Utils).Search(cs, q, limit, offset)
    Write j
    Return $$$OK
}

ClassMethod DrugLookup() As %Status
{
    Set %response.ContentType = "application/json"
    Set cs = $Get(%request.Data("codeSystem",1))
    If cs = "" Set cs = "nrdl"
    Set code = $Get(%request.Data("code",1))
    Set j = ##class(Terminology.Drug.Utils).Lookup(cs, code)
    Write j
    Return $$$OK
}

ClassMethod DrugValidate() As %Status
{
    Set %response.ContentType = "application/json"
    Set cs = $Get(%request.Data("codeSystem",1))
    If cs = "" Set cs = "nrdl"
    Set code = $Get(%request.Data("code",1))
    Set j = ##class(Terminology.Drug.Utils).Validate(cs, code)
    Write j
    Return $$$OK
}

ClassMethod DrugCodeSystems() As %Status
{
    Set %response.ContentType = "application/json"
    Set arr = ##class(Terminology.Drug.Utils).CodeSystemIds()
    Write {"codeSystems":(arr)}.%ToJSON()
    Return $$$OK
}

}
