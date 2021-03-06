-- Модифицируйте скрипт создания пользователя, приведенный в
-- примере. Добавьте в скрипт создание профиля с ограничениями
-- на количество параллельных сеансов и время простоя.
-- Организуйте привязку создаваемого пользователя к профилю.

REM
REM                Version 0.01.0000
REM             Database creation script
REM
REM      This script must be run under SYS account
REM

set verify off

prompt Creating profile...

accept profile_name prompt 'Please enter the name of the profile to generate: '
accept profile_parallel prompt 'Please enter the limit of parallel profile sessions: '
accept profile_max_idle_time prompt 'Please enter max idle time for profile: '

rem dropping the profile if already exists
declare
        res number;
begin
        select count(1) into res from DBA_PROFILES where upper(profile) = upper('&profile_name');

        if res <> 0 then
                execute immediate 'drop profile ' || upper('&profile_name') || ' cascade';
        end if;
end;
/

create profile &profile_name limit IDLE_TIME &profile_max_idle_time SESSIONS_PER_USER &profile_parallel;

prompt profile created...


prompt Creating schema user...

accept schema_name prompt 'Please enter the name of the schema to generate: '
accept schema_password prompt 'Please enter the password of the schema: '
accept oracle_service prompt 'Please enter the Oracle service name: '

rem dropping the user if already exists
declare
        res number;
begin
        select count(1) into res from all_users where upper(username) = upper('&schema_name');

        if res <> 0 then
                execute immediate 'drop user ' || upper('&schema_name') || ' cascade';
        end if;
end;
/

create user &schema_name identified by &schema_password PROFILE &profile_name;
grant connect to &schema_name;
grant create table to &schema_name;
grant create sequence to &schema_name;
grant create view to &schema_name;

prompt user created...

-- On server run `sqlplus sys as sysdba @2_example_user_creation_script.sql`