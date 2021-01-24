<!-- DO NOT EDIT THIS FILE DIRECTLY - it is generated from source file src/CONSOLE.pks -->
<!-- markdownlint-disable MD003 MD012 MD033 -->

Oracle Instrumentation Console
==============================

- [Package console](#console)
- [Procedure permanent](#permanent)
- [Procedure error](#error)
- [Procedure warn](#warn)
- [Procedure info](#info)
- [Procedure log](#log)
- [Procedure debug](#debug)
- [Procedure trace](#trace)
- [Procedure assert](#assert)
- [Procedure action](#action)
- [Function my_client_identifier](#my_client_identifier)
- [Procedure init](#init)
- [Procedure clear](#clear)
- [Function get_call_stack](#get_call_stack)
- [Function my_log_level](#my_log_level)
- [Function version](#version)
- [Function context_available_yn](#context_available_yn)


<h2><a id="console"></a>Package console</h2>
<!----------------------------------------->

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

DEPENDENCIES

Oracle DB >= 12.1

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

SIGNATURE

```sql
package console authid definer is

c_name    constant varchar2(30 byte) := 'Oracle Instrumentation Console';
c_version constant varchar2(10 byte) := '0.3.1';
c_url     constant varchar2(40 byte) := 'https://github.com/ogobrecht/console';
c_license constant varchar2(10 byte) := 'MIT';
c_author  constant varchar2(20 byte) := 'Ottmar Gobrecht';

c_permanent constant integer := 0;
c_error     constant integer := 1;
c_warning   constant integer := 2;
c_info      constant integer := 3;
c_verbose   constant integer := 4;
```


<h2><a id="permanent"></a>Procedure permanent</h2>
<!----------------------------------------------->

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

SIGNATURE

```sql
procedure permanent (p_message clob);
```


<h2><a id="error"></a>Procedure error</h2>
<!--------------------------------------->

Log a message with the level 1 (error) and call also `console.clear` to reset
the session action attribute.

SIGNATURE

```sql
procedure error (
  p_message    clob     default null,
  p_user_agent varchar2 default null
);
```


<h2><a id="warn"></a>Procedure warn</h2>
<!------------------------------------->

Log a message with the level 2 (warning).

SIGNATURE

```sql
procedure warn (
  p_message    clob,
  p_user_agent varchar2 default null
);
```


<h2><a id="info"></a>Procedure info</h2>
<!------------------------------------->

Log a message with the level 3 (info).

SIGNATURE

```sql
procedure info (
  p_message    clob,
  p_user_agent varchar2 default null
);
```


<h2><a id="log"></a>Procedure log</h2>
<!----------------------------------->

Log a message with the level 3 (info).

SIGNATURE

```sql
procedure log(
  p_message    clob,
  p_user_agent varchar2 default null
);
```


<h2><a id="debug"></a>Procedure debug</h2>
<!--------------------------------------->

Log a message with the level 4 (verbose).

SIGNATURE

```sql
procedure debug (
  p_message    clob,
  p_user_agent varchar2 default null
);
```


<h2><a id="trace"></a>Procedure trace</h2>
<!--------------------------------------->

Logs a call stack with the level 3 (info).

SIGNATURE

```sql
procedure trace (
  p_message    clob     default null,
  p_user_agent varchar2 default null
);
```


<h2><a id="assert"></a>Procedure assert</h2>
<!----------------------------------------->

If the given expression evaluates to false an error is raised with the given message.

EXAMPLE

```sql
declare
  x number := 5;
  y number := 3;
begin
  console.assert(
    x < y,
    'X should be less then Y (x=' || to_char(x) || ', y=' || to_char(y) || ')'
  );
exception
  when others then
    console.error;
    raise;
end;
/
```

SIGNATURE

```sql
procedure assert (
  p_expression boolean,
  p_message    varchar2
);
```


<h2><a id="action"></a>Procedure action</h2>
<!----------------------------------------->

An alias for dbms_application_info.set_action.

Use the given action to set the session action attribute (in memory operation,
does not log anything). This attribute is then visible in the system session
views, the user environment and will be logged within all console logging
methods.

When you set the action attribute with `console.action` you should also reset it
when you have finished your work to prevent wrong info in the system and your
logging for subsequent method calls.

The action is automatically cleared in the method `console.error`.

EXAMPLE

```sql
begin
  console.action('My process/task');
  -- do your stuff here...
  console.action(null);
exception
  when others then
    console.error('something went wrong'); --also clears action
    raise;
end;
/
```

SIGNATURE

```sql
procedure action (
  p_action varchar2
);
```


<h2><a id="my_client_identifier"></a>Function my_client_identifier</h2>
<!-------------------------------------------------------------------->

Returns the current session identifier of the own session. This information is cached in a
package variable and determined on package initialization.

```sql
select console.context_available_yn from dual;
```

SIGNATURE

```sql
function my_client_identifier return varchar2;
```


<h2><a id="init"></a>Procedure init</h2>
<!------------------------------------->

Starts the logging for a specific session.

To avoid spoiling the context with very long input the p_client_id parameter is
truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own client identifier.

EXAMPLES

```sql
-- Dive into your own session with the default level of 3 (info) and the
-- default duration of 60 (minutes).
exec console.init;

-- With level 4 (verbose) for the next 15 minutes.
exec console.init(4, 15);

-- Using a constant for the level
exec console.init(console.c_verbose, 90);

-- Debug an APEX session...
exec console.init('APEX:8805903776765', 4, 90);

-- ... with the defaults
exec console.init('APEX:8805903776765');

-- Debug another session
begin
  console.init(
    p_client_id => 'APEX:8805903776765',
    p_level     => console.c_verbose,
    p_duration  => 15
  );
end;
/
```

SIGNATURE

```sql
procedure init (
  p_client_id  varchar2,               -- client_identifier or unique_session_id
  p_level    integer default c_info, -- 2 (warning), 3 (info) or 4 (verbose)
  p_duration integer default 60      -- duration in minutes
);
```


<h2><a id="clear"></a>Procedure clear</h2>
<!--------------------------------------->

Stops the logging for a specific session and clears the info in the global
context for it.

Please note that we always log the levels errors and permanent to keep a record
of things that are going wrong.

EXAMPLE

```sql
begin
  console.('My process/task');

  -- your stuff here...

  console.clear;
exception
  when others then
    console.error('something went wrong'); -- calls also console.clear
    raise;
end;
/
```

SIGNATURE

```sql
procedure clear (
  p_client_id varchar2 default my_client_identifier -- client_identifier or unique_session_id
);
```


<h2><a id="get_call_stack"></a>Function get_call_stack</h2>
<!-------------------------------------------------------->

Gets the current call stack and if an error was raised also the error stack and
the error backtrace. Is used internally by the console methods error and trace
and also, if you set on other console methods the parameter p_trace to true.

The console package itself is excluded from the trace as you normally would
trace you business logic and not your instrumentation code.

```sql
set serveroutput on
begin
  dbms_output.put_line(console.get_call_stack);
end;
/
```

The code above will output `- Call Stack: __anonymous_block (2)`

SIGNATURE

```sql
function get_call_stack return varchar2;
```


<h2><a id="my_log_level"></a>Function my_log_level</h2>
<!---------------------------------------------------->

Returns the current log level of the own session. This information is cached in a
package variable for performance reasons and reevaluated every 10 seconds.

```sql
select console.context_available_yn from dual;
```

SIGNATURE

```sql
function my_log_level return integer;
```


<h2><a id="version"></a>Function version</h2>
<!------------------------------------------>

returns the version information from the console package.


```sql
select console.version from dual;
```

SIGNATURE

```sql
function version return varchar2;
```


<h2><a id="context_available_yn"></a>Function context_available_yn</h2>
<!-------------------------------------------------------------------->

Checks the availability of the global context. Returns `Y`, if available and `N`
if not.

If the global context is not available we simulate it by using a package
variable. In this case you can only set your own session in logging mode with a
level of 2 (warning) or higher, because other sessions are not able to read the
package variable value in your session - this works only with a global
accessible context.

```sql
select console.context_available_yn from dual;
```

SIGNATURE

```sql
function context_available_yn return varchar2;
```


