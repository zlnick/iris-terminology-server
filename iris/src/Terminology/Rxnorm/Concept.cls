Class Terminology.Rxnorm.Concept Extends %Persistent [ DdlAllowed, SqlTableName = Concept ]
{

/// RXCUI：RxNorm 概念标识
Property Rxcui As %String(MAXLEN = 30) [ Required ];

/// RXAUI：atom 标识（同一概念可有多条名称/TTY）
Property RxaUI As %String(MAXLEN = 40);

/// TTY：术语类型（SCD/SBD/IN/PIN/BN/SY/PSN...）
Property Tty As %String(MAXLEN = 20) [ Required ];

/// STR：名称文本（英文）
Property Str As %String(MAXLEN = 1000) [ Required ];

Property Lang As %String(MAXLEN = 10) [ InitialExpression = "ENG" ];

Index IdxCuiTtyStr On (Rxcui, Tty, Str) [ Unique ];

Index IdxCui On (Rxcui);

Index IdxName On (Str);

}
