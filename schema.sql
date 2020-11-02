--Start table creation
create table orgs (
	orgid 					integer                 primary key,
	organization			varchar(100)            not null,
	city					varchar(100),
	state					varchar(100),
	country					varchar(100),
);

create table domains (
    domainid                integer                 primary key,
    domain                  varchar(50)             not null unique,
    tld                     varchar(12)             not null,
    rank					integer,
    registrar 				varchar(100)            not null,
    updated_date            timestamp with timezone not null,
    creation_date           timestamp with timezone not null,
    expiration_date         timestamp with timezone not null,
    orgid                   integer,
    trust                   varchar(20)             not null,
    domain_length			smallint                not null,
    keyword_length			smallint                not null,
    num_nameservers			smallint                not null,
    score                   numeric(6,6)            not null,
    domain_age  			numeric(6,2) generated always as (current_timestamp - creation_date) stored,
    time_from_update    	numeric(6,2) generated always as (current_timestamp - updated_date) stored,
    days_to_exp				numeric(8,2) generated always as (expiration_date - current_timestamp) stored,
    constraint ck_dnssec check (dnssec) IN ('signed', 'unsigned', 'unknown'),
    constraint ck_trust check (trust) in ('trust', 'fake', 'initial trust'),
    constraint fk_orgid foreign key (orgid) references orgs on cascade
);

create table analytics_id (
	domainid 				integer,
	organizationid			integer                 not null,
	unitid					integer                 not null,
	constraint fk_domainid foreign key (domainid) references domains (domainid) on cascade,
);

create table query (
    queryid        	    integer                     primary key,
    domainid           	integer,
    query_time          timestamp with timezone     not null,
    constraint fk_query_domainid foreign key (domainid) references domains (domainid) on cascade
);