Class Terminology.Icd10.Concept Extends %Persistent [ DdlAllowed, SqlTableName = Concept ]
{

/// 国标主要诊断编码（A 列已剥 †，如 A01.001）
Property Code As %String(MAXLEN = 20) [ Required ];

/// 疾病名称（已清洗 †/*）
Property Name As %String(MAXLEN = 500) [ Required ];

/// 原 Excel A 列带 †（国标语义：该病因码在"病因/表现"双轴中有 * 表现附码）
Property Dagger As %Boolean [ InitialExpression = 0 ];

Index IdxCode On (Code) [ Unique ];

Index IdxName On (Name);

}
