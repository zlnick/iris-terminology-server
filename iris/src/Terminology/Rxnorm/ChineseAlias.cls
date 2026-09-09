Class Terminology.Rxnorm.ChineseAlias Extends %Persistent [ DdlAllowed, SqlTableName = ChineseAlias ]
{

/// 中文名称（医保/商保目录药名或通用名/商品名音译）
Property ZhName As %String(MAXLEN = 200) [ Required ];

/// RxNorm RXCUI（resolve 到 IN/SCD/BN 任一层；无对应时为空）
Property Rxcui As %String(MAXLEN = 30);

/// 英文名称（RxNorm 主名）
Property EnName As %String(MAXLEN = 500);

/// 匹配到的 TTY 层（IN/SCD/BN；空 = RxNorm 无对应）
Property Tty As %String(MAXLEN = 20);

/// 来源/说明：医保目录 / 商保目录 / 商品名音译
Property Source As %String(MAXLEN = 100);

Index IdxZh On (ZhName);

Index IdxCui On (Rxcui);

}
