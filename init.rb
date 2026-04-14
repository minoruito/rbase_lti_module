# Include hook code here
require './lib/rbase/plugin_module'

Rbase::PluginModule.register(
  "RbaseLtiModule::SystemSettingExt",
  "RbaseLtiModule::AdminUserExt",
  "RbaseLtiModule::AdminSettingExt",
  "RbaseLtiModule::CustomFieldExt",
  "RbaseLtiModule::ApplicationHelperExt",
  "RbaseLtiModule::TopHelperExt",
)