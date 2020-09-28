create table registrar_info (
    reg_iana_id    number,
    reg_whois_serv  varchar2(50),
    reg_name        varchar2(50),
    reg_url         varchar2(50),
    reg_abuse_email varchar2(50),
    reg_abuse_phone varchar2(50),
    constraint pk_reg_iana_id primary key (reg_iana_id)
);

create sequence seq_query_id start with 100000 increment by 1 nomaxvalue;
create table query (
    query_id        number,
    query_time      timestamp,
    domain_id       number,
    domain_name     varchar2(50) not null,
    constraint pk_query_id primary key (query_id)
);
create or replace trigger trig_biu_query_id
before insert on query
for each row
begin
    select seq_query_id.nextval into :new.query_id from dual;
end;
/

create sequence seq_domain_id start with 300000 increment by 1 nomaxvalue;
create table domains (
    domain_id       number,
    domain_name     varchar2(50) not null,
    dn_entry_date   date default systimestamp,
    source          varchar2(50) not null,
    expires_on      date not null,
    registered_on   date not null,
    updated_on      date not null,
    reg_iana_id     number,
    reg_domain_id   varchar2(50),
    last_update     timestamp,
    cli_upd_prohib  boolean,
    cli_trn_prohib  boolean,
    cli_del_prohib  boolean,
    dm_organization varchar2(50),
    dm_jurisdiction varchar2(50),
    dm_country      varchar2(50),
    dm_email        varchar2(50),
    ad_organization varchar2(50),
    ad_state        varchar2(50),
    ad_country      varchar2(50),
    ad_email        varchar2(50),
    th_organization varchar2(50),
    th_state        varchar2(50),
    th_country      varchar2(50),
    th_email        varchar2(50),
    ns              varchar2(50),
    ndssec          boolean,
    constraint pk_domain_id primary key (domain_id),
    constraint fk_reg_iana_id foreign key (reg_iana_id)
        references registrar_info (reg_iana_id)
    constraint fk_query_id foreign key (query_id)
        references query(query_id)
);
create or replace trigger trig_biu_domain_id
before insert on domains
for each row
begin
    select seq_domain_id.nextval into :new.domain_id from dual;
end;
/
create or replace trigger trig_stamp_last_update
before update on domains
for each row
begin
    select systimestamp into :new.last_update from dual;
end;
/

create sequence seq_hostname_id start with 1 nomaxvalue;
create table dns_records (
    hostname_id     number,
    hostname        varchar2(50) not null,
    record_type     varchar2(4),
    ttl             number,
    priority        number,
    content         text,
    constraint pk_hostname_id primary key (hostname_id),
    constraint ck_record_type check (record_type)
        in ('SOA', 'NS', 'A', 'AAAA', 'MX', 'CNAME')
);
create or replace trigger trig_biu_dns_records
before insert on dns_records
for each row
begin
    select seq_hostname_id.nextval into :new.hostname_id from dual;
end;
/

create table domain_metadata (
    domain_id       varchar2(50),
    query_id        number,
    desciption      text,
    author          text,
    title           varchar2(100),
    goog_analytics  boolean not null,
    ga_id           varchar2(20),
    constraint fk_domain_id foreign key (domain_id)
        references domains (domain_id),
    constraint fk_query_id_metadata foreign key (query_id)
        references query (query_id)
)
