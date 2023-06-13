codeunit 51595 "AVU Template Upgrade"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AVGUpgradeTagDefinitions: Codeunit "AVU Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(AVGUpgradeTagDefinitions.GetAVFTemplateUpgradeTag()) then
            exit;

        UpgradeCustomerTemplates();
        UpgradeVendorTemplates();
        UpgradeItemTemplates();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(AVGUpgradeTagDefinitions.GetAVFTemplateUpgradeTag());
    end;

    local procedure UpgradeItemTemplates()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        ItemTempl: Record "Item Templ.";
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        TemplateRecordRef: RecordRef;
        TemplateFieldRef: FieldRef;
        GlobalLanguageID: Integer;
    begin
        GlobalLanguageID := GlobalLanguage();
        if FindConfigTemplateHeader(ConfigTemplateHeader, Database::Item) then
            repeat
                if InsertNewItemTemplate(ItemTempl, ConfigTemplateHeader.Code, ConfigTemplateHeader.Description) then;
                TemplateRecordRef.Open(Database::"Item Templ.");
                TemplateRecordRef.GetTable(ItemTempl);

                if FindConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code) then
                    repeat
                        if ConfigTemplateLine."Language ID" <> 0 then
                            GlobalLanguage(ConfigTemplateLine."Language ID")
                        else
                            GlobalLanguage(GlobalLanguageID);
                        if ConfigTemplateFieldCanBeProcessed(ConfigTemplateLine, Database::"Item Templ.") then begin
                            TemplateFieldRef := TemplateRecordRef.Field(ConfigTemplateLine."Field ID");
                            ConfigValidateManagement.EvaluateValue(TemplateFieldRef, ConfigTemplateLine."Default Value", false);
                        end;
                    until ConfigTemplateLine.Next() = 0;

                TemplateRecordRef.Modify();
                TemplateRecordRef.Close();
            until ConfigTemplateHeader.Next() = 0;
        GlobalLanguage(GlobalLanguageID);
    end;

    local procedure UpgradeCustomerTemplates()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        CustomerTempl: Record "Customer Templ.";
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        TemplateRecordRef: RecordRef;
        TemplateFieldRef: FieldRef;
        GlobalLanguageID: Integer;
    begin
        GlobalLanguageID := GlobalLanguage();
        if FindConfigTemplateHeader(ConfigTemplateHeader, Database::Customer) then
            repeat
                if InsertNewCustomerTemplate(CustomerTempl, ConfigTemplateHeader.Code, ConfigTemplateHeader.Description) then;
                TemplateRecordRef.Open(Database::"Customer Templ.");
                TemplateRecordRef.GetTable(CustomerTempl);

                if FindConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code) then
                    repeat
                        if ConfigTemplateLine."Language ID" <> 0 then
                            GlobalLanguage(ConfigTemplateLine."Language ID")
                        else
                            GlobalLanguage(GlobalLanguageID);
                        if ConfigTemplateFieldCanBeProcessed(ConfigTemplateLine, Database::"Customer Templ.") then begin
                            TemplateFieldRef := TemplateRecordRef.Field(ConfigTemplateLine."Field ID");
                            ConfigValidateManagement.EvaluateValue(TemplateFieldRef, ConfigTemplateLine."Default Value", false);
                        end;
                    until ConfigTemplateLine.Next() = 0;

                TemplateRecordRef.Modify();
                TemplateRecordRef.Close();
            until ConfigTemplateHeader.Next() = 0;
        GlobalLanguage(GlobalLanguageID);
    end;

    local procedure UpgradeVendorTemplates()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        VendorTempl: Record "Vendor Templ.";
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        TemplateRecordRef: RecordRef;
        TemplateFieldRef: FieldRef;
        GlobalLanguageID: Integer;
    begin
        GlobalLanguageID := GlobalLanguage();
        if FindConfigTemplateHeader(ConfigTemplateHeader, Database::Vendor) then
            repeat
                if InsertNewVendorTemplate(VendorTempl, ConfigTemplateHeader.Code, ConfigTemplateHeader.Description) then;
                TemplateRecordRef.Open(Database::"Vendor Templ.");
                TemplateRecordRef.GetTable(VendorTempl);

                if FindConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code) then
                    repeat
                        if ConfigTemplateLine."Language ID" <> 0 then
                            GlobalLanguage(ConfigTemplateLine."Language ID")
                        else
                            GlobalLanguage(GlobalLanguageID);
                        if ConfigTemplateFieldCanBeProcessed(ConfigTemplateLine, Database::"Vendor Templ.") then begin
                            TemplateFieldRef := TemplateRecordRef.Field(ConfigTemplateLine."Field ID");
                            ConfigValidateManagement.EvaluateValue(TemplateFieldRef, ConfigTemplateLine."Default Value", false);
                        end;
                    until ConfigTemplateLine.Next() = 0;

                TemplateRecordRef.Modify();
                TemplateRecordRef.Close();
            until ConfigTemplateHeader.Next() = 0;
        GlobalLanguage(GlobalLanguageID);
    end;

    local procedure FindConfigTemplateHeader(var ConfigTemplateHeader: Record "Config. Template Header"; TableId: Integer): Boolean
    begin
        ConfigTemplateHeader.SetRange("Table ID", TableId);
        ConfigTemplateHeader.SetRange(Enabled, true);
        exit(ConfigTemplateHeader.FindSet());
    end;

    local procedure FindConfigTemplateLine(var ConfigTemplateLine: Record "Config. Template Line"; ConfigTemplateHeaderCode: Code[10]): Boolean
    begin
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeaderCode);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.SetFilter("Field ID", '<>0');
        ConfigTemplateLine.SetFilter("Default Value", '<>''''');
        exit(ConfigTemplateLine.FindSet());
    end;

    local procedure InsertNewCustomerTemplate(var CustomerTempl: Record "Customer Templ."; TemplateCode: Code[20]; TemplateDescription: Text[100]): Boolean
    begin
        if CustomerTempl.Get(TemplateCode) then
            exit(false);

        CustomerTempl.Init();
        CustomerTempl.Code := TemplateCode;
        CustomerTempl.Description := TemplateDescription;
        exit(CustomerTempl.Insert());
    end;

    local procedure InsertNewVendorTemplate(var VendorTempl: Record "Vendor Templ."; TemplateCode: Code[20]; TemplateDescription: Text[100]): Boolean
    begin
        if VendorTempl.Get(TemplateCode) then
            exit(false);

        VendorTempl.Init();
        VendorTempl.Code := TemplateCode;
        VendorTempl.Description := TemplateDescription;
        exit(VendorTempl.Insert());
    end;

    local procedure InsertNewItemTemplate(var ItemTempl: Record "Item Templ."; TemplateCode: Code[20]; TemplateDescription: Text[100]): Boolean
    begin
        if ItemTempl.Get(TemplateCode) then
            exit(false);

        ItemTempl.Init();
        ItemTempl.Code := TemplateCode;
        ItemTempl.Description := TemplateDescription;
        exit(ItemTempl.Insert());
    end;

    local procedure ConfigTemplateFieldCanBeProcessed(ConfigTemplateLine: Record "Config. Template Line"; TemplateTableId: Integer): Boolean
    var
        ConfigTemplateField: Record Field;
        NewTemplateField: Record Field;
    begin
        if not ConfigTemplateField.Get(ConfigTemplateLine."Table ID", ConfigTemplateLine."Field ID") then
            exit(false);

        if not NewTemplateField.Get(TemplateTableId, ConfigTemplateLine."Field ID") then
            exit(false);

        if (ConfigTemplateField.Class <> ConfigTemplateField.Class::Normal) or (NewTemplateField.Class <> NewTemplateField.Class::Normal) or
            (ConfigTemplateField.Type <> NewTemplateField.Type) or (ConfigTemplateField.FieldName <> NewTemplateField.FieldName)
        then
            exit(false);

        exit(true);
    end;
}