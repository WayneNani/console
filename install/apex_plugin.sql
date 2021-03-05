--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js
prompt ORACLE INSTRUMENTATION CONSOLE: INSTALL APEX PLUG-IN
prompt - application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_200200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2020.10.01'
,p_release=>'20.2.0.00.20'
,p_default_workspace_id=>100000
,p_default_application_id=>100
,p_default_id_offset=>34698863762663877
,p_default_owner=>'PLAYGROUND_DATA'
);
end;
/

prompt - application 100 - Playground
--
-- Application Export:
--   Application:     100
--   Name:            Playground
--   Date and Time:   20:16 Monday March 1, 2021
--   Exported By:     OGOBRECHT
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 36295154520053378
--   Manifest End
--   Version:         20.2.0.00.20
--   Instance ID:     9947149746035591
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt - application/shared_components/plugins/dynamic_action/com_ogobrecht_console
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(36295154520053378)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.OGOBRECHT.CONSOLE'
,p_display_name=>'Oracle Instrumentation Console'
,p_category=>'NOTIFICATION'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_api_version=>2
,p_render_function=>'console.apex_plugin_render'
,p_ajax_function=>'console.apex_plugin_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'testus'
,p_about_url=>'https://github.com/ogobrecht/console'
,p_files_version=>7
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '766172206f7261436f6e736f6c65203d207b7d3b0d0a6f7261436f6e736f6c652e696e6974203d2066756e6374696f6e202829207b0d0a202020202f2f20446566696e652067656e65726963206c6f672066756e6374696f6e2077697468206c6576656c';
wwv_flow_api.g_varchar2_table(2) := '20706172616d6574657220666f72206c61746572207573650d0a202020206f7261436f6e736f6c652e6c6f67203d2066756e6374696f6e20286c6576656c2c206d6573736167652c2073636f70652c20737461636b29207b0d0a20202020202020206170';
wwv_flow_api.g_varchar2_table(3) := '65782e7365727665722e706c7567696e280d0a2020202020202020202020206f7261436f6e736f6c652e61706578506c7567696e49642c0d0a2020202020202020202020207b0d0a202020202020202020202020202020207830313a206c6576656c2c0d';
wwv_flow_api.g_varchar2_table(4) := '0a202020202020202020202020202020207830323a206d6573736167652c0d0a202020202020202020202020202020207830333a2073636f70652c0d0a202020202020202020202020202020207830343a20737461636b2c0d0a20202020202020202020';
wwv_flow_api.g_varchar2_table(5) := '202020202020705f64656275673a202476282770646562756727290d0a2020202020202020202020207d2c0d0a2020202020202020202020207b0d0a20202020202020202020202020202020737563636573733a2066756e6374696f6e20286461746153';
wwv_flow_api.g_varchar2_table(6) := '7472696e6729207b0d0a20202020202020202020202020202020202020206966202864617461537472696e6720213d2027535543434553532729207b0d0a2020202020202020202020202020202020202020202020206f7261436f6e736f6c652e657272';
wwv_flow_api.g_varchar2_table(7) := '6f7228274f7261636c6520496e737472756d656e746174696f6e20436f6e736f6c653a20414a41582063616c6c2068616420736572766572207369646520504c2f53514c206572726f723a2027202b2064617461537472696e67202b20272e27293b0d0a';
wwv_flow_api.g_varchar2_table(8) := '20202020202020202020202020202020202020207d0d0a202020202020202020202020202020207d2c0d0a202020202020202020202020202020206572726f723a2066756e6374696f6e20287868722c207374617475732c206572726f725468726f776e';
wwv_flow_api.g_varchar2_table(9) := '29207b0d0a20202020202020202020202020202020202020206f7261436f6e736f6c652e6572726f7228274f7261636c6520496e737472756d656e746174696f6e20436f6e736f6c653a20414a41582063616c6c207465726d696e617465642077697468';
wwv_flow_api.g_varchar2_table(10) := '206572726f72733a2027202b206572726f725468726f776e202b20272e27293b0d0a202020202020202020202020202020207d2c0d0a2020202020202020202020202020202064617461547970653a202774657874270d0a202020202020202020202020';
wwv_flow_api.g_varchar2_table(11) := '7d0d0a2020202020202020293b0d0a20202020202020202f2f2043616c6c20746865206f726967696e616c20636f6e736f6c652e7878782066756e6374696f6e2e0d0a202020202020202073776974636820286c6576656c29207b0d0a20202020202020';
wwv_flow_api.g_varchar2_table(12) := '20202020206361736520274572726f72273a0d0a2020202020202020202020206f7261436f6e736f6c652e6572726f722e6170706c7928636f6e736f6c652c20617267756d656e7473293b0d0a202020202020202020202020627265616b3b0d0a202020';
wwv_flow_api.g_varchar2_table(13) := '2020202020202020206361736520275761726e696e67273a0d0a2020202020202020202020206f7261436f6e736f6c652e7761726e2e6170706c7928636f6e736f6c652c20617267756d656e7473293b0d0a202020202020202020202020627265616b3b';
wwv_flow_api.g_varchar2_table(14) := '0d0a202020202020202020202020636173652027496e666f273a0d0a2020202020202020202020206f7261436f6e736f6c652e696e666f2e6170706c7928636f6e736f6c652c20617267756d656e7473293b0d0a20202020202020202020202062726561';
wwv_flow_api.g_varchar2_table(15) := '6b3b0d0a202020202020202020202020636173652027566572626f7365273a0d0a2020202020202020202020206f7261436f6e736f6c652e64656275672e6170706c7928636f6e736f6c652c20617267756d656e7473293b0d0a20202020202020202020';
wwv_flow_api.g_varchar2_table(16) := '2020627265616b3b0d0a20202020202020207d0d0a0d0a202020207d3b0d0a0d0a202020202f2f205361766520746865206f726967696e616c206572726f72206d6574686f640d0a202020206f7261436f6e736f6c652e6572726f72203d20636f6e736f';
wwv_flow_api.g_varchar2_table(17) := '6c652e6572726f723b0d0a202020202f2f205265646566696e6520636f6e736f6c652e6572726f72206d6574686f642077697468206120637573746f6d2066756e6374696f6e0d0a20202020636f6e736f6c652e6572726f72203d2066756e6374696f6e';
wwv_flow_api.g_varchar2_table(18) := '20286d65737361676529207b206f7261436f6e736f6c652e6c6f6728274572726f72272c206d657373616765297d3b0d0a7d3b0d0a0d0a0d0a2f2f68747470733a2f2f646576656c6f7065722e6d6f7a696c6c612e6f72672f656e2d55532f646f63732f';
wwv_flow_api.g_varchar2_table(19) := '5765622f4150492f476c6f62616c4576656e7448616e646c6572732f6f6e6572726f720d0a2f2a0d0a77696e646f772e6f6e6572726f72203d2066756e6374696f6e20286d73672c2075726c2c206c696e654e6f2c20636f6c756d6e4e6f2c206572726f';
wwv_flow_api.g_varchar2_table(20) := '7229207b0d0a202076617220737472696e67203d206d73672e746f4c6f7765724361736528293b0d0a202076617220737562737472696e67203d2022736372697074206572726f72223b0d0a202069662028737472696e672e696e6465784f6628737562';
wwv_flow_api.g_varchar2_table(21) := '737472696e6729203e202d31297b0d0a20202020616c6572742827536372697074204572726f723a205365652042726f7773657220436f6e736f6c6520666f722044657461696c27293b0d0a20207d20656c7365207b0d0a20202020766172206d657373';
wwv_flow_api.g_varchar2_table(22) := '616765203d205b0d0a202020202020274d6573736167653a2027202b206d73672c0d0a2020202020202755524c3a2027202b2075726c2c0d0a202020202020274c696e653a2027202b206c696e654e6f2c0d0a20202020202027436f6c756d6e3a202720';
wwv_flow_api.g_varchar2_table(23) := '2b20636f6c756d6e4e6f2c0d0a202020202020274572726f72206f626a6563743a2027202b204a534f4e2e737472696e67696679286572726f72290d0a202020205d2e6a6f696e2827202d2027293b0d0a0d0a20202020616c657274286d657373616765';
wwv_flow_api.g_varchar2_table(24) := '293b0d0a20207d0d0a0d0a202072657475726e2066616c73653b0d0a7d3b0d0a0d0a2a2f';

end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(36299187405943315)
,p_plugin_id=>wwv_flow_api.id(36295154520053378)
,p_file_name=>'console.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt - application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt - finished