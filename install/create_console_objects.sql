REMARK: DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT src/build.js
set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select 'create_console_objects_' || to_char(sysdate,'yyyymmdd_hh24miss')
       || '.log' as logfile from dual;
spool &logfile

prompt
prompt Create Database Objects for Oracle Instrumentation Console
prompt ================================================================================

prompt (1) Set install log to &logfile

prompt (2) Set compiler flags
DECLARE
  v_apex_installed VARCHAR2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_utils_public   VARCHAR2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
BEGIN
  FOR i IN (SELECT 1
              FROM all_objects
             WHERE object_type = 'SYNONYM'
               AND object_name = 'APEX_EXPORT')
  LOOP
    v_apex_installed := 'TRUE';
  END LOOP;

  -- Show unset compiler flags as errors (results for example in errors like "PLW-06003: unknown inquiry directive '$$UTILS_PUBLIC'")
  EXECUTE IMMEDIATE 'alter session set plsql_warnings = ''ENABLE:6003''';
  -- Finally set compiler flags
  EXECUTE IMMEDIATE 'alter session set plsql_ccflags = '''
    || 'apex_installed:' || v_apex_installed || ','
    || 'utils_public:'   || v_utils_public   || '''';
END;
/

prompt (3) Create or alter table console_logs
--For development only - uncomment temporarely when you need it:
begin for i in (select 1 from user_tables where table_name = 'CONSOLE_LOGS') loop execute immediate 'drop table console_logs purge'; end loop; end;
/

declare
  v_name varchar2(30 char) := 'CONSOLE_LOGS';
begin
  for i in (
    select v_name from dual
    minus
    select table_name from user_tables where table_name = v_name
  )
  loop
    execute immediate q'{
      create table console_logs (
        log_id             integer                                               generated by default on null as identity,
        log_time           timestamp with local time zone  default systimestamp  not null  ,
        log_level          integer                                                         ,
        action             varchar2(  64 char)                                             ,
        message            clob                                                            ,
        call_stack         varchar2(1000 char)                                             ,
        module             varchar2(  64 char)                                             ,
        client_info        varchar2(  64 char)                                             ,
        session_user       varchar2(  32 char)                                             ,
        unique_session_id  varchar2(  16 char)                                             ,
        client_identifier  varchar2(  64 char)                                             ,
        ip_address         varchar2(  32 char)                                             ,
        host               varchar2(  64 char)                                             ,
        os_user            varchar2(  64 char)                                             ,
        os_user_agent      varchar2( 200 char)                                             ,
        instance           integer                                                         ,
        instance_name      varchar2(  32 char)                                             ,
        service_name       varchar2(  64 char)                                             ,
        sid                integer                                                         ,
        sessionid          varchar2(  64 char)                                             ,
        --
        constraint console_logs_check_level check (log_level in (0,1,2,3,4))
      )
    }';
  end loop;
end;
/

comment on table console_logs is 'Table for log entries of the package CONSOLE.';
comment on column console_logs.log_id is 'Primary key.';
comment on column console_logs.log_time is 'Log entry timestamp. Required for the CONSOLE.PURGE method.';
comment on column console_logs.log_level is 'Log entry level. Can be 0 (permanent), 1 (error), 2 (warn) or 3 (debug).';
comment on column console_logs.message is 'The log message.';
comment on column console_logs.call_stack is 'The call_stack will only be provided on log level 1 (call of console.error).';
comment on column console_logs.module is 'The application name (module) set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.action is 'Identifies the position in the module (application name) and is set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info is 'Client information that can be stored by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.session_user is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.unique_session_id is 'An identifier that is unique for all sessions currently connected to the database. Provided by DBMS_SESSION.UNIQUE_SESSION_ID. Is constructed by sid, serial# and inst_id from (g)v$session (undocumented, there is no official way to construct this ID by yourself, but we need to do this to identify a session).';
comment on column console_logs.client_identifier is 'Returns an identifier that is set by the application through the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then ::1 is returned.';
comment on column console_logs.host is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent is 'Operating system user agent (web browser engine). This information will only be available, if we overwrite the console.error method of the client browser and bring these errors back to the server. For APEX we will have a plug-in in the future to do this.';
comment on column console_logs.instance is 'The instance identification number of the current instance.';
comment on column console_logs.instance_name is 'The name of the instance.';
comment on column console_logs.service_name is 'The name of the service to which a given session is connected.';
comment on column console_logs.sid is 'The session ID (can be the same on different instances).';
comment on column console_logs.sessionid is 'The auditing session identifier. You cannot use this attribute in distributed SQL statements.';


/*
call_stack varchar2(1000),
client_identifier varchar2(64),
sessionid varchar2(64),
instance_name varchar2(32),
msg varchar2(4000),

*/

prompt (4) Compile package console (spec)
create or replace package console authid current_user is

c_name        constant varchar2(30 char) := 'Oracle Instrumentation Console';
c_version     constant varchar2(10 char) := '0.1.0';
c_url         constant varchar2(40 char) := 'https://github.com/ogobrecht/console';
c_license     constant varchar2(10 char) := 'MIT';
c_license_url constant varchar2(60 char) := 'https://github.com/ogobrecht/console/blob/main/LICENSE';
c_author      constant varchar2(20 char) := 'Ottmar Gobrecht';

c_level_permanent constant integer := 0;
c_level_error     constant integer := 1;
c_level_warning   constant integer := 2;
c_level_info      constant integer := 3;
c_level_verbose   constant integer := 4;

/**

Oracle Instrumentation Console
==============================

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

DEPENDENCIES

Oracle DB >= 18.x??? will mainly depend on the call stack facilities of the
release, we will see...

INSTALLATION

- Download the [latest
  version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest)
  and unzip it or clone the repository
- Go into the project subdirectory named install and use SQL*Plus (or another
  tool which can run SQL scripts)

The installation itself is splitted into two mandatory and two optional steps:

1. Create a context with a privileged user
    - `create_context.sql`
    - Maybe your DBA needs to do that for you once
2. Install the tool itself in your desired target schema
    - `create_console_objects.sql`
    - User needs the rights to create a package, a table and views
    - Do this step on every new release of the tool
3. Optional: When installed in a central tools schema you may want to grant
   execute rights on the package and select rights on the views to public or
   other schemas
    - `grant_rights_to_client_schema.sql`
4. Optional: When you want to use it in another schema you may want to create
   synonyms there for easier access
    - `create_synonyms_in_client_schema.sql`

UNINSTALLATION

Hopefully you will never need this...

FIXME: Create uninstall scripts

**/


--------------------------------------------------------------------------------
-- CONSTANTS, TYPES
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------
procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

**/

procedure error (
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 1 (error) and call also `console.clear` to reset
the session action attribute.

**/

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 2 (warning).

**/

procedure info(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

procedure log(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 4 (verbose).

**/

procedure assert(
  p_expression in boolean,
  p_message    in varchar2
);
/**

If the given expression evaluates to false an error is raised with the given message.

EXAMPLE

```sql
begin
  console.assert(5 < 3, 'test assertion');
exception
  when others then
    console.error('something went wrong');
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure init(
  p_action varchar2
);
/**

Use the given action to set the session action attribute (in memory operation,
does not log anything).

This attribute is then visible in the system session views, the user environment
and will be logged within all console logging methods.

EXAMPLE

```sql
begin
  console.init('My process/task');
  -- do your stuff here...
  console.clear;
exception
  when others then
    console.error('something went wrong');
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure clear;
/**

Reset the session action attribute (in memory operation, does not log anything).

When you set the action attribute with `console.init` you should also call
`console.clear` to reset it to avoid wrong info in the system and your logging.

Is called automatically in `console.error`.

EXAMPLE

```sql
begin
  console.init('My process/task');

  -- your stuff here...

  console.clear;
exception
  when others then
    console.error('something went wrong'); -- calls also console.clear
    raise;
end;
{{/}}
```

**/


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

function get_unique_session_id
  return varchar2;
/**

Get the unique session id for debugging of the own session.

Returns the ID provided by DBMS_SESSION.UNIQUE_SESSION_ID.

**/


function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1
) return varchar2;
/**

Get the unique session id for debugging of another session.

Calculates the ID out of three parameters:

```sql
v_session_id := ltrim(to_char(p_sid,     '000x'))
             || ltrim(to_char(p_serial,  '000x'))
             || ltrim(to_char(p_inst_id, '0000'));
```

This method to calculate the unique session ID is not documented by Oracle. It
seems to work, but we have no guarantee, that it is working forever or under all
circumstances.

The first two parts seems to work, the part three for the inst_id is only a
guess and should work fine from zero to nine. But above I have no experience.
Does anybody have a RAC running with more then nine instances? Please let me
know - maybe I need to calculate here also with a hex format mask...

Hint: When checking in a session, if the logging is enabled or when we create a
log entry, we always use DBMS_SESSION.UNIQUE_SESSION_ID. All the helper methods
here to calculate the unique session id are only existing for the purpose to
start the logging of another session and to set the global context in a way the
targeted session can compare against with with DBMS_SESSION.UNIQUE_SESSION_ID or
SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'). Unfortunately the unique session id
is not provided in the (g)v$session views (the client_identifier is) - so we
need to calculate it by ourselfes. It is worth to note that the schema were the
console package is installed does not need any higher privileges and does
therefore not read from the (g)v$session view. In other words: When you want to
debug another session you need to have a way to find the target session - for
APEX this is easy - the client identifier is set by APEX and can be calculated
by looking at your session id in the browser URL. For a specific, non shared
session you can use the (g)v$session view to calculate the unique session ID by
providing at least sid and serial.

**/


function get_sid_serial_inst_id (
  p_unique_session_id varchar2
) return varchar2;
/**

Calculates the sid, serial and inst_id out of a unique session ID as it is
provided by DBMS_SESSION.UNIQUE_SESSION_ID.

Is for informational purposes and to map a recent log entry back to a maybe
running session.

The same as with `get_unique_session_id`: I have no idea if the calculation is
correct. It works currently and is implementes in this way:

```sql
v_sid_serial_inst_id :=
     to_char(to_number(substr(p_unique_session_id, 1, 4), '000x')) || ', '
  || to_char(to_number(substr(p_unique_session_id, 5, 4), '000x')) || ', '
  || to_char(to_number(substr(p_unique_session_id, 9, 4), '0000'));
```

**/


procedure set_module(
  p_module varchar2,
  p_action varchar2 default null
);
/**

An alias for `dbms_application_info.set_module`.

**/



procedure set_action(
  p_action varchar2
);
/**

An alias for `dbms_application_info.set_action`.

**/

--------------------------------------------------------------------------------
-- INTERNAL UTILITIES (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

procedure log_internal (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
);

function logging_enabled return boolean;

function call_stack return varchar2;

$end

end console;
/

show errors

prompt (5) Compile package console (body)
create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

c_tab          constant varchar2(1 byte) := chr(9);
c_cr           constant varchar2(1 byte) := chr(13);
c_lf           constant varchar2(1 byte) := chr(10);
c_crlf         constant varchar2(2 byte) := chr(13) || chr(10);
c_at           constant varchar2(1 byte) := '@';
c_hash         constant varchar2(1 byte) := '#';
c_slash        constant varchar2(1 byte) := '/';
c_vc_max_size  constant pls_integer := 32767;

subtype vc16    is varchar2(   16 char);
subtype vc32    is varchar2(   32 char);
subtype vc64    is varchar2(   64 char);
subtype vc128   is varchar2(  128 char);
subtype vc255   is varchar2(  255 char);
subtype vc500   is varchar2(  500 char);
subtype vc1000  is varchar2( 1000 char);
subtype vc2000  is varchar2( 2000 char);
subtype vc4000  is varchar2( 4000 char);
subtype vc_max  is varchar2(32767 char);

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

procedure log_internal (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
);

function logging_enabled return boolean;

function call_stack return varchar2;

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_permanent, p_message, p_trace, p_user_agent);
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_error, p_message, p_trace, p_user_agent);
  clear;
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_warning  , p_message, p_trace, p_user_agent);
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_info, p_message, p_trace, p_user_agent);
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_info, p_message, p_trace, p_user_agent);
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  log_internal (c_level_verbose, p_message, p_trace, p_user_agent);
end debug;

--------------------------------------------------------------------------------

procedure assert(
  p_expression in boolean,
  p_message    in varchar2
) is
begin
  if not p_expression then
    raise_application_error(-20000, p_message);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure init(
  p_action varchar2
) is
begin
  dbms_application_info.set_action(p_action);
end init;

--------------------------------------------------------------------------------

procedure clear is
begin
  dbms_application_info.set_action(null);
end;

--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

/*

Some Useful Links
-----------------

- [DBMS_SESSION: Managing Sessions From a Connection Pool in Oracle
  Databases](https://oracle-base.com/articles/misc/dbms_session)


*/

function get_unique_session_id return varchar2 is
begin
  return dbms_session.unique_session_id;
end get_unique_session_id;

--------------------------------------------------------------------------------

function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1) return varchar2
is
  v_inst_id integer;
  v_return  vc16;
begin
  v_inst_id := coalesce(p_inst_id, 1); -- param default 1 does not mean the user cannot provide null ;-)
  if p_sid is null or p_serial is null then
    raise_application_error (
      -20000,
      'You need to specify at least p_sid and p_serial to calculate a unique session ID.');
  else
    v_return := ltrim(to_char(p_sid,     '000x'))
             || ltrim(to_char(p_serial,  '000x'))
             || ltrim(to_char(v_inst_id, '0000'));
  end if;
  return v_return;
end get_unique_session_id;

--------------------------------------------------------------------------------

function get_sid_serial_inst_id (p_unique_session_id varchar2) return varchar2 is
  v_return vc32;
begin
  if p_unique_session_id is null then
    raise_application_error (
      -20000,
      'You need to specify p_unique_session_id to calculate the sid, serial and host_id.');
  elsif length(p_unique_session_id) != 12 then
    raise_application_error (
      -20000,
      'We use here typically a 12 character long unique session identifier like it is provided by DBMS_SESSION.UNIQUE_SESSION_ID.');
  else
    v_return := to_char(to_number(substr(p_unique_session_id, 1, 4), '000x')) || ', '
             || to_char(to_number(substr(p_unique_session_id, 5, 4), '000x')) || ', '
             || to_char(to_number(substr(p_unique_session_id, 9, 4), '0000'));
  end if;
  return v_return;
end get_sid_serial_inst_id;

--------------------------------------------------------------------------------

procedure set_module(
  p_module varchar2,
  p_action varchar2 default null
) is
begin
  dbms_application_info.set_module(p_module, p_action);
end set_module;

--------------------------------------------------------------------------------

procedure set_action(
  p_action varchar2
) is
begin
  dbms_application_info.set_action(p_action);
end set_action;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

procedure log_internal (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
) is
  pragma autonomous_transaction;
  v_call_stack varchar2(1000 char);
begin
  if p_level <= c_level_error or logging_enabled then
    if p_trace then
      v_call_stack := substr(call_stack, 1, 1000);
    end if;
    dbms_output.put_line(p_message);
    insert into console_logs (
      log_level,
      message,
      call_stack,
      module,
      action,
      client_info,
      session_user,
      unique_session_id,
      client_identifier,
      ip_address,
      host,
      os_user,
      os_user_agent,
      instance,
      instance_name,
      service_name,
      sid,
      sessionid)
    values (
      p_level,
      p_message,
      v_call_stack,
      sys_context('USERENV', 'MODULE'),
      sys_context('USERENV', 'ACTION'),
      sys_context('USERENV', 'CLIENT_INFO'),
      sys_context('USERENV', 'SESSION_USER'),
      dbms_session.unique_session_id,
      sys_context('USERENV', 'CLIENT_IDENTIFIER'),
      sys_context('USERENV', 'IP_ADDRESS'),
      sys_context('USERENV', 'HOST'),
      sys_context('USERENV', 'OS_USER'),
      substr(p_user_agent, 1, 200),
      sys_context('USERENV', 'INSTANCE'),
      sys_context('USERENV', 'INSTANCE_NAME'),
      sys_context('USERENV', 'SERVICE_NAME'),
      sys_context('USERENV', 'SID'),
      sys_context('USERENV', 'SESSIONID'));
    commit;
  end if;
end log_internal;

--------------------------------------------------------------------------------

function logging_enabled return boolean
is
begin
  return true; --FIXME: implement
end logging_enabled;

--------------------------------------------------------------------------------

function call_stack return varchar2
is
begin
  return 'dummy'; --FIXME: implement
end call_stack;

end console;
/

show errors

prompt ================================================================================
prompt Finished
prompt
