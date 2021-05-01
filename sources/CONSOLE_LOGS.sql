declare
  v_count pls_integer;
  --
  procedure create_index (
    p_type        varchar2,
    p_column_list varchar2,
    p_postfix     varchar2)
  is
  begin
    with t as (
      select listagg(column_name, ', ') within group(order by column_position) as index_column_list
        from user_ind_columns
      where table_name = 'CONSOLE_LOGS'
      group by index_name
    )
    select count(*)
      into v_count
      from t
    where index_column_list = p_column_list;
    if v_count = 0 then
      dbms_output.put_line('- Index for CONSOLE_LOGS column list ' || p_column_list || ' not found, run creation command');
      execute immediate 'create ' || p_type || ' index CONSOLE_LOGS_' || p_postfix || ' on CONSOLE_LOGS (' || p_column_list || ')';
    else
      dbms_output.put_line('- Index for CONSOLE_LOGS column list ' || p_column_list || ' found, no action required');
    end if;
  end;
  --
begin

  --create table
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_LOGS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_LOGS not found, run creation command');
    execute immediate q'{
      create table console_logs (
        log_id             number   (   *,0)     generated by default  on null   as identity,
        log_systime        timestamp                                   not null  ,
        level_id           number   (   1,0)                           not null  ,
        level_name         varchar2 (  10 byte)                        not null  ,
        permanent          varchar2 (   1 byte)                        not null  ,
        scope              varchar2 ( 256 byte)                                  ,
        message            clob                                                  ,
        error_code         number   (  10,0)                                     ,
        call_stack         varchar2 (4000 byte)                                  ,
        session_user       varchar2 (  32 byte)                                  ,
        module             varchar2 (  48 byte)                                  ,
        action             varchar2 (  32 byte)                                  ,
        client_info        varchar2 (  64 byte)                                  ,
        client_identifier  varchar2 (  64 byte)                                  ,
        ip_address         varchar2 (  48 byte)                                  ,
        host               varchar2 (  64 byte)                                  ,
        os_user            varchar2 (  64 byte)                                  ,
        os_user_agent      varchar2 ( 200 byte)                                  ,
        --
        constraint  console_logs_pk  primary key (log_id)                        ,
        constraint  console_logs_ck  check       (permanent in ('Y','N'))
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LOGS found, no action required');
  end if;

  --FIXME: which way should we go with indexes?
    create_index (null    , 'LOG_SYSTIME, LEVEL_ID', 'IX');
  --create_index (null    , 'LOG_SYSTIME'          , 'IX1');
  --create_index ('bitmap', 'LEVEL_ID, LEVEL_NAME' , 'IX2');
  --create_index ('bitmap', 'PERMANENT'            , 'IX3');

end;
/

comment on table  console_logs                   is 'Table for log entries of the package CONSOLE. Column names are mostly driven by the attribute names of SYS_CONTEXT(''USERENV'') and DBMS_SESSION for easier mapping and clearer context.';
comment on column console_logs.log_id            is 'Primary key based on a sequence.';
comment on column console_logs.log_systime       is 'Log systimestamp.';
comment on column console_logs.level_id          is 'Level ID. Can be 0 (permanent), 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).';
comment on column console_logs.level_name        is 'Level name. Can be Permanent, Error, Warning, Info or Verbose.';
comment on column console_logs.permanent         is 'If Y the log entry will not be deleted when calling CONSOLE.PURGE or CONSOLE.PURGE_ALL.';
comment on column console_logs.scope             is 'The current unit/module in which the log was generated (OWNER.PACKAGE.MODULE.SUBMODULE, line number). Couls also be an external scope provided by the user.';
comment on column console_logs.message           is 'The log message itself.';
comment on column console_logs.error_code        is 'The error code. Is normally the SQLCODE, but could also be a user error code when log entry was coming from external (user interface, ETL preprocessing, whatever...)';
comment on column console_logs.call_stack        is 'The call_stack and in case of an error also the error stack and error backtrace. Could also be an external call stack provided by the user.';
comment on column console_logs.session_user      is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.module            is 'The application name (module). Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.action            is 'The action/position in the module (application name). Can be set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info       is 'The client information. Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_identifier is 'The client identifier. Can be set by an application using the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address        is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then it is set to ::1.';
comment on column console_logs.host              is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user           is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent     is 'Operating system user agent (for example web browser engine). This information will only be available, if actively provided to one of the console log methods. For APEX we will have a plug-in in the future to log client side JavaScript errors - then this attribute will be interesting.';



