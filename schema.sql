set verify off;
prompt This script creates necessary objects for the disinformation database.
prompt Please provide a username to run the script
prompt
accept v_username prompt 'Enter your user name: '
savepoint user_entry;

create sequence seq_domain_id
    start with 1 increment by 1 maxvalue 100000;
create sequence seq_dns_record_id
    start with 2000000 increment by 1 maxvalue 2999999;
create sequence seq_ns_record_id
    start with 3000000 increment by 1 maxvalue 3999999;
create sequence seq_query_id
    start with 4000000 increment by 1 maxvalue 4999999;
savepoint sequence_creation;

--Create the registrars table using the registrar IANA ID as the primary key.
create table registrars (
    reg_iana_id             number,
    reg_name                varchar2(50) not null,
    reg_whois_server        varchar2(100),
    reg_url                 varchar2(100),
    reg_abuse_phone         varchar2(20),
    reg_abuse_email         varchar2(40),
    constraint pk_reg_iana_id primary key (reg_iana_id),
    constraint un_reg_name unique (reg_name),
    constraint un_reg_url unique (reg_url)
);

create table domains (
    domain_id               number,
    reg_iana_id             number,
    domain_name             varchar2(50) not null,
    ipv4_address            varchar2(16) not null,
    registry_domain_id      varchar2(20) not null,
    last_updated            timestamp not null,
    creation_datetime       timestamp not null,
    reg_expiration          timestamp not null,
    delete_prohibted        boolean,
    transfer_prohibited     boolean,
    update_prohibited       boolean,
    org                     varchar2(50),
    jurisdiction            varchar2(50),
    country                 varchar2(50),
    constraint pk_domain_id primary key (domain_id),
    constraint fk_reg_iana_id foreign key (reg_iana_id)
        references registrars (reg_iana_id),
    constraint un_registry_domain_id unique (registry_domain_id)
);

create table determinations (
    domain_id               number,
    determination           char(4) default 'UNKN',
    constraint fk_determinations_domain_id foreign key (domain_id)
        references domains (domain_id),
    constraint ck_determination
        check (determination in ('SUSP', 'OKAY', 'UNKN'))
);

create table dns_records (
    domain_id               number,
    record_id               number,
    direction               varchar2(3),
    record_type             varchar2(5),
    ipv4_address            varchar2(16),
    ttl                     number,
    priority                number,
    content                 varchar2(1000),
    constraint pk_record_id primary key (record_id),
    constraint fk_dns_domain_id foreign key (domain_id)
        references domains (domain_id),
    constraint ck_direction check (direction in ('OUT', 'IN')),
    constraint ck_record_type check
        (record_type in ('A', 'AAAA', 'ALIAS', 'CNAME', 'MX',
                         'NS', 'PTR', 'SOA', 'SRV', 'TXT'))
);

create table name_servers (
    ns_record_id        number,
    dns_record_id       number,
    ns_address          varchar2(100)
    constraint pk_ns_record_id primary key (ns_record_id)
    constraint fk_ns_dns_record_id foreign key (dns_records)
        references dns_records (record_id)
);

create table query (
    query_id            number,
    domain_id           number,
    query_time          timestamp,
    constraint pk_query_id primary key (query_id),
    constraint fk_query_domain_id foreign key (domain_id)
        references domains (domain_id)
);

create table domain_metadata (
    domain_id               number,
    query_id                number,
    description             varchar2(1000),
    author                  varchar2(50),
    title                   varchar2(50),
    has_google_analytics    boolean not null,
    analytics_id            varchar2(25),
    constraint fk_metadata_domain_id foreign key (domain_id)
        references domains (domain_id)
    constraint fk_metadata_query_id foreign key (query_id)
        references query (query_id)
);
savepoint table_creation;

-- Create triggers for each of the sequences
create or replace trigger bu_trig_domain_id
before insert on domains for each row
begin
    select seq_domain_id.nextval into :new.domain_id from dual;
end;
/
create or replace trigger bu_trig_dns_record_id
before insert on dns_records for each row
begin
    select seq_dns_record_id.nextval into :new.record_id from dual;
end;
/
create or replace trigger bu_trig_ns_record_id
before insert on name_servers for each row
begin
    select seq_ns_record_id.nextval into :new.ns_record_id from dual;
end;
/
create or replace trigger biu_trig_query_id
before insert or update on query for each row
begin
    select seq_query_id.nextval into :new.query_id from dual;
end;
/
savepoint create_triggers;

create or replace directory input_data as 'C:\rstudio\disinformation\database';
grant read on directory input_data to &v_username;
create table ext_domain_determinations (
        reg_iana_id             number not null,
        domain_name             varchar2(50) not null,
        ipv4_address            varchar2(16) not null,
        registry_domain_id      varchar2(20) not null,
        last_updated            timestamp not null,
        creation_datetime       timestamp not null,
        reg_expiration          timestamp not null,
        delete_prohibted        boolean,
        transfer_prohibited     boolean,
        update_prohibited       boolean,
        org                     varchar2(50),
        jurisdiction            varchar2(50),
        country                 varchar2(50)
)
organization external (
    type ORACLE_LOADER default directory input_data
    access parameters (records delimited by newline
                       fields (domain_name, determination))
   )
location ('database_input_file.csv');
insert into domains as select * from ext_domain_determinations;
savepoint connect_external_table;
truncate table ext_domain_determinations on delete cascade;
