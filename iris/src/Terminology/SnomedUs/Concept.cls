Class Terminology.SnomedUs.Concept Extends %Persistent [ DdlAllowed, SqlTableName = Concept ]
{

/// SNOMED CT 概念码（US Core Condition Codes 值集公开展开样本）
Property Code As %String(MAXLEN = 30) [ Required ];

/// SNOMED CT 首选显示名（英文）
Property Display As %String(MAXLEN = 1000) [ Required ];

Index IdxCode On (Code) [ Unique ];

Index IdxDisplay On (Display);

}
