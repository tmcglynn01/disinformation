--Create primary key sequences
create sequence seq_orgid
	start with 1000000 increment by 1 maxvalue 1050000;
create sequence seq_domainid
    start with 1 increment by 1 maxvalue 100000;
create sequence seq_queryid
	start with 10000000 increment by 1 maxvalue 11000000;

-- Create triggers for each of the sequences
create or replace trigger bu_trig_orgid
	before insert on orgs for each row
begin
	select seq_orgid.nextval into :new.orgid from dual;
end;
/
create or replace trigger bu_trig_domainid
	before insert on domains for each row
begin
    select seq_domainid.nextval into :new.domainid from dual;
end;
/
create or replace trigger bu_trig_queryid
	before insert on query for each row
begin
	select seq_queryid.nextval into :new.queryid from dual;
end;
/

--Start table creation
create table orgs (
	orgid 					number(7),
	organization			varchar2(100) not null,
	city					varchar2(100),
	state					varchar2(100),
	country					varchar2(100),
	constraint pk_orgid primary key (orgid)
);

create table domains (
    domainid                number(6),
    domain                  varchar2(50) not null,
    tld                     varchar2(12) not null,
    rank					number(7),
    registrar 				varchar2(100) not null,
    updated_date            timestamp with timezone not null,
    creation_date           timestamp with timezone not null,
    expiration_date         timestamp with timezone not null,
    dnssec                  varchar2(20),
    orgid                   number(7),
    trust                   varchar2(20) not null,
    domain_length			number(2) not null,
    keyword_length			number(2) not null,
    num_nameservers			number(2) not null,
    dom_age_days			number(8,2),
    dom_last_update_days	number(6,2),
    days_to_exp				number(8,2),
    update_to_exp			number(8,2),
    constraint pk_domainid primary key (domainid),
    constraint un_domain unique (domain),
    constraint ck_dnssec check (dnssec) IN ('signed', 'unsigned', 'unknown'),
    constraint fk_orgid foreign key (orgid)
    	references orgs on cascade,
    constraint ck_trust check (trust) in ('trust', 'fake', 'initial trust')
);

create table analytics_id (
	domainid 				number(6),
	ga_code					varchar2(20),
	prefix					varchar2(2) default 'UA',
	organizationid			number(8) not null,
	unitid					number(2) not null,
	constraint fk_domainid foreign key (domainid)
		references domains (domainid) on cascade,
);

create table query (
    queryid        	    number(8),
    domainid           	number(6),
    query_time          timestamp with timezone not null,
    constraint pk_queryid primary key (queryid),
    constraint fk_query_domainid foreign key (domainid)
        references domains (domainid) on cascade
);