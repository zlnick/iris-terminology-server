/// 药品目录术语（医保 NRDL / 商保 CBIH）——中文名称 + 剂型/备注等，供检索与校验。
Class Terminology.Drug.Code Extends %Persistent
{

/// 术语集 ID：nrdl=国家医保药品目录；cbih=商业健康保险创新药品目录
Property CodeSystemId As %String(MAXLEN = 20);

/// 稳定术语代码（如 NRDL-XXXXXXXXXX / CB-XXXXXXXXXX）
Property Code As %String(MAXLEN = 40);

/// 药品名称（中文 Display）
Property Display As %String(MAXLEN = 200);

/// 剂型（医保目录）
Property Form As %String(MAXLEN = 120);

/// 备注（支付限制等）
Property Note As %String(MAXLEN = 500);

/// 药品分类代码（ATC 风格前缀，部分行）
Property Category As %String(MAXLEN = 80);

/// 目录分节（西药/中成药/谈判/饮片/商保创新药）
Property SectionName As %String(MAXLEN = 40);

/// 附加 JSON（商保：brand/indication/holder/authorized/valid）
Property Extras As %String(MAXLEN = 2000);

/// 来源 PDF 页
Property SrcPage As %Integer;

Index IdxCS On (CodeSystemId, Code) [ Unique ];

Index IdxDisplay On Display;

Storage Default
{
<Data name="CodeDefaultData">
<Value name="1"><Value>%%CLASSNAME</Value></Value>
<Value name="2"><Value>CodeSystemId</Value></Value>
<Value name="3"><Value>Code</Value></Value>
<Value name="4"><Value>Display</Value></Value>
<Value name="5"><Value>Form</Value></Value>
<Value name="6"><Value>Note</Value></Value>
<Value name="7"><Value>Category</Value></Value>
<Value name="8"><Value>SectionName</Value></Value>
<Value name="9"><Value>Extras</Value></Value>
<Value name="10"><Value>SrcPage</Value></Value>
</Data>
<DataLocation>^Terminology.Drug.CodeD</DataLocation>
<DefaultData>CodeDefaultData</DefaultData>
<IdLocation>^Terminology.Drug.CodeD</IdLocation>
<IndexLocation>^Terminology.Drug.CodeI</IndexLocation>
<StreamLocation>^Terminology.Drug.CodeS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
