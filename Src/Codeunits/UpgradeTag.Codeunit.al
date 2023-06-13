codeunit 51594 "AVU Upgrade Tag Definitions"
{
    // Register the new upgrade tag for new companies when they are created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetAVFTemplateUpgradeTag());
    end;

    // Use methods to avoid hard-coding the tags. It is easy to remove afterwards because it's compiler-driven.
    procedure GetAVFTemplateUpgradeTag(): Text
    begin
        exit('Fxb-0001-TemplateUpgrade-20230613');
    end;
}