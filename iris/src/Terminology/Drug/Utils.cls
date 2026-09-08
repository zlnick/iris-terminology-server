/// 药品目录术语工具：检索/查询/校验/TSV 导入（nrdl + cbih）。
Class Terminology.Drug.Utils Extends %RegisteredObject
{

ClassMethod CodeSystemIds() As %DynamicArray
{
    Set arr = []
    Do arr.%Push("nrdl")
    Do arr.%Push("cbih")
    Quit arr
}

ClassMethod Search(pCodeSystemId As %String = "nrdl", pQuery As %String = "",
                   pLimit As %Integer = 20, pOffset As %Integer = 0) As %String
{
    Set o = {}
    Try {
        Set sql = "SELECT Code, Display, Form, Note, Category, SectionName, Extras, SrcPage "
                  _ "FROM Terminology_Drug.Code WHERE CodeSystemId = ?"
        If pQuery '= "" Set sql = sql _ " AND (Display %STARTSWITH ? OR Display [ ?)"
        Set sql = sql _ " ORDER BY Display"

        Set st = ##class(%SQL.Statement).%New()
        Set sc = st.%Prepare(sql)
        If $$$ISERR(sc) {
            Set o.error = $system.Status.GetOneErrorText(sc)
            Quit
        }
        Set rs = st.%Execute(pCodeSystemId, pQuery, pQuery)

        Set items = []
        Set count = 0
        While rs.%Next() {
            If count >= pOffset {
                If pLimit > 0, items.%Size() >= pLimit Quit
                Set it = {}
                Set it.code = rs.%Get("Code")
                Set it.display = rs.%Get("Display")
                Set it.form = rs.%Get("Form")
                Set it.note = rs.%Get("Note")
                Set it.category = rs.%Get("Category")
                Set it.section = rs.%Get("SectionName")
                Set it.extras = rs.%Get("Extras")
                Set it.srcPage = rs.%Get("SrcPage")
                Do items.%Push(it)
            }
            Set count = count + 1
        }
        Set o.codeSystemId = pCodeSystemId
        Set o.query = pQuery
        Set o.items = items
        Set o.count = items.%Size()
        Set o.total = count
    } Catch ex {
        Set o.error = ex.DisplayString()
    }
    Set j = o.%ToJSON()
    Quit j
}

ClassMethod Lookup(pCodeSystemId As %String = "nrdl", pCode As %String = "") As %String
{
    Set o = {}
    Try {
        Set sql = "SELECT Code, Display, Form, Note, Category, SectionName, Extras "
                  _ "FROM Terminology_Drug.Code WHERE CodeSystemId = ? AND Code = ?"
        Set st = ##class(%SQL.Statement).%New()
        Set sc = st.%Prepare(sql)
        If $$$ISERR(sc) {
            Set o.error = $system.Status.GetOneErrorText(sc)
        } Else {
            Set rs = st.%Execute(pCodeSystemId, pCode)
            If rs.%Next() {
                Set o.codeSystemId = pCodeSystemId
                Set o.found = 1
                Set it = {}
                Set it.code = rs.%Get("Code")
                Set it.display = rs.%Get("Display")
                Set it.form = rs.%Get("Form")
                Set it.note = rs.%Get("Note")
                Set it.category = rs.%Get("Category")
                Set it.section = rs.%Get("SectionName")
                Set it.extras = rs.%Get("Extras")
                Set o.item = it
            } Else {
                Set o.codeSystemId = pCodeSystemId
                Set o.found = 0
            }
        }
    } Catch ex {
        Set o.error = ex.DisplayString()
    }
    Set j = o.%ToJSON()
    Quit j
}

ClassMethod Validate(pCodeSystemId As %String = "nrdl", pCode As %String = "") As %String
{
    Set o = {}
    Set o.codeSystemId = pCodeSystemId
    Set o.code = pCode
    Set o.inactive = 0
    Try {
        Set sql = "SELECT COUNT(*) AS N FROM Terminology_Drug.Code WHERE CodeSystemId = ? AND Code = ?"
        Set st = ##class(%SQL.Statement).%New()
        Set sc = st.%Prepare(sql)
        If $$$ISERR(sc) {
            Set o.error = $system.Status.GetOneErrorText(sc)
            Set o.valid = 0
        } Else {
            Set rs = st.%Execute(pCodeSystemId, pCode)
            Set n = 0
            If rs.%Next() Set n = rs.%Get("N")
            Set o.valid = $Select(n > 0: 1, 1: 0)
        }
    } Catch ex {
        Set o.error = ex.DisplayString()
        Set o.valid = 0
    }
    Set j = o.%ToJSON()
    Quit j
}

ClassMethod ImportTSV(pDirectory As %String = "/terms-inbox") As %Status
{
    For csId = "nrdl", "cbih" {
        Set path = pDirectory _ "/" _ csId _ ".tsv"
        Set f = ##class(%File).%New(path)
        Set sc = f.Open("RU")
        If $$$ISERR(sc) {
            Write "跳过（无法打开）: ", path, " | ", $system.Status.GetOneErrorText(sc), !
            Continue
        }
        Set imported = 0
        Set skipped = 0
        Set first = 1
        While 'f.AtEnd {
            Set line = f.ReadLine()
            If first { Set first = 0 Continue }
            If line = "" Continue
            Set line = $ZSTRIP(line, "*C")
            Set c1 = $PIECE(line, $CHAR(9), 1)
            Set c2 = $PIECE(line, $CHAR(9), 2)
            Set c3 = $PIECE(line, $CHAR(9), 3)
            If (c1 = "") || (c2 = "") || (c3 = "") { Set skipped = skipped + 1 Continue }
            Set c4 = $PIECE(line, $CHAR(9), 4)
            Set c5 = $PIECE(line, $CHAR(9), 5)
            Set c6 = $PIECE(line, $CHAR(9), 6)
            Set c7 = $PIECE(line, $CHAR(9), 7)
            Set c8 = $PIECE(line, $CHAR(9), 8)
            Set c9 = +$PIECE(line, $CHAR(9), 9)

            Set row = ""
            &sql(SELECT %ID INTO :row FROM Terminology_Drug.Code WHERE CodeSystemId = :c1 AND Code = :c2)
            If SQLCODE = 0, row '= "" {
                &sql(UPDATE Terminology_Drug.Code SET Display = :c3, Form = :c4, Note = :c5,
                     Category = :c6, SectionName = :c7, Extras = :c8, SrcPage = :c9 WHERE %ID = :row)
            } Else {
                &sql(INSERT INTO Terminology_Drug.Code
                     (CodeSystemId, Code, Display, Form, Note, Category, SectionName, Extras, SrcPage)
                     VALUES (:c1, :c2, :c3, :c4, :c5, :c6, :c7, :c8, :c9))
            }
            If SQLCODE < 0 {
                Write "行导入失败 SQLCODE=", SQLCODE, " | ", $system.Status.GetErrorText(%msg), !
                Set skipped = skipped + 1
            } Else {
                Set imported = imported + 1
            }
        }
        Do f.Close()
        Write "术语集 ", csId, " 导入 ", imported, " 行（跳过/失败 ", skipped, "）", !
    }
    Quit $$$OK
}

// __PART2__
}

