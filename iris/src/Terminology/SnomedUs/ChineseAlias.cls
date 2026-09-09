Class Terminology.SnomedUs.ChineseAlias Extends %Persistent [ DdlAllowed, SqlTableName = ChineseAlias ]
{

/// 中文诊断名（国标 ICD-10 名称）
Property ZhName As %String(MAXLEN = 200) [ Required ];

/// 国标 ICD-10 码（可选，便于码侧反查）
Property CnCode As %String(MAXLEN = 20);

/// SNOMED CT 码（US Core 池）
Property Code As %String(MAXLEN = 30) [ Required ];

/// SNOMED 显示名
Property Display As %String(MAXLEN = 500);

Index IdxZh On (ZhName);

Index IdxCode On (Code);

}
