CREATE SCHEMA BDRE;
SET SCHEMA BDRE;
CREATE TABLE  bus_domain  (
   bus_domain_id  integer NOT NULL GENERATED BY DEFAULT AS IDENTITY (START WITH 1, INCREMENT BY 1),
   description  varchar(256) NOT NULL,
   bus_domain_name  varchar(45) NOT NULL,
   bus_domain_owner  varchar(45) NOT NULL,
  PRIMARY KEY ( bus_domain_id )
);

CREATE  TABLE users (
  username VARCHAR(45) NOT NULL ,
  password VARCHAR(45) NOT NULL ,
  enabled boolean DEFAULT true ,
  PRIMARY KEY (username));

CREATE TABLE user_roles (
  user_role_id INT NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
  username VARCHAR(45) NOT NULL,
  ROLE VARCHAR(45) NOT NULL,
  PRIMARY KEY (user_role_id),
  CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES users (username));


CREATE TABLE  batch_status  (
   batch_state_id  integer NOT NULL,
   description  varchar(45) NOT NULL,
  PRIMARY KEY ( batch_state_id )
);
CREATE TABLE  process_type  (
   process_type_id  integer NOT NULL,
   process_type_name  varchar(45) NOT NULL,
   parent_process_type_id  integer,
  PRIMARY KEY ( process_type_id )
);

CREATE TABLE exec_status (
  exec_state_id integer NOT NULL,
  description varchar(45) NOT NULL,
  PRIMARY KEY (exec_state_id)
);
CREATE TABLE workflow_type (
  workflow_id integer NOT NULL,
    workflow_type_name varchar(45) NOT NULL,
    PRIMARY KEY (workflow_id)
);

CREATE TABLE permission_type (
  permission_type_id integer(11) NOT NULL,
  permission_type_name varchar(45) NOT NULL,
  PRIMARY KEY (permission_type_id)
);


CREATE TABLE  servers  (
   server_id  integer NOT NULL   GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   server_type  varchar(45) NOT NULL,
   server_name  varchar(45) NOT NULL,
   server_metainfo  varchar(45) DEFAULT NULL,
   login_user  varchar(45) DEFAULT NULL,
   login_password  varchar(45) DEFAULT NULL,
   ssh_private_key  varchar(512) DEFAULT NULL,
   server_ip  varchar(45) DEFAULT NULL,
  PRIMARY KEY ( server_id )
);
CREATE TABLE  process_template  (
   process_template_id  integer NOT NULL   GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   description  varchar(256) NOT NULL,
   add_ts  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   process_name  varchar(45) NOT NULL,
   bus_domain_id  integer NOT NULL,
   process_type_id  integer NOT NULL,
   parent_process_id  integer DEFAULT NULL,
   can_recover  BOOLEAN NOT NULL DEFAULT true ,
   batch_cut_pattern  varchar(45) DEFAULT NULL,
   next_process_template_id  VARCHAR(256) DEFAULT '' NOT NULL,
   delete_flag  BOOLEAN NOT NULL DEFAULT false,
   workflow_id  integer DEFAULT 1,
  PRIMARY KEY ( process_template_id ),
  CONSTRAINT  bus_domain_id_template  FOREIGN KEY ( bus_domain_id ) REFERENCES  bus_domain  ( bus_domain_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  original_process_id1_template  FOREIGN KEY ( parent_process_id ) REFERENCES  process_template  ( process_template_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  workflow_id_template  FOREIGN KEY ( workflow_id ) REFERENCES  workflow_type  ( workflow_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  process_type_id1_template  FOREIGN KEY ( process_type_id ) REFERENCES  process_type  ( process_type_id ) ON DELETE NO ACTION ON UPDATE NO ACTION

);
CREATE TABLE properties_template (
  process_template_id integer NOT NULL,
  config_group varchar(128) NOT NULL,
  prop_temp_key varchar(128) NOT NULL,
  prop_temp_value varchar(2048) NOT NULL,
  description varchar(1028) NOT NULL,
  PRIMARY KEY (process_template_id,prop_temp_key),
  CONSTRAINT process_template_id5 FOREIGN KEY (process_template_id) REFERENCES process_template (process_template_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE process (
  process_id integer NOT NULL  GENERATED BY DEFAULT AS IDENTITY (START WITH 1, INCREMENT BY 1),
  description varchar(256) NOT NULL,
  add_ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  process_name varchar(45) NOT NULL,
  bus_domain_id integer NOT NULL,
  process_type_id integer NOT NULL,
  parent_process_id integer DEFAULT NULL,
  can_recover boolean DEFAULT true,
   process_code VARCHAR(256),
   user_name VARCHAR(45),
    owner_role_id integer(11),
    user_access_id integer(1)  DEFAULT '7',
    group_access_id integer(1)  DEFAULT '4',
    others_access_id integer(1)  DEFAULT '0',
  enqueuing_process_id integer NOT NULL DEFAULT 0,
  batch_cut_pattern varchar(45) DEFAULT NULL,
  next_process_id varchar(256) NOT NULL DEFAULT '',
  delete_flag boolean DEFAULT false,
  workflow_id integer DEFAULT 1,
  process_template_id integer DEFAULT 0,
  edit_ts TIMESTAMP AS NOW() NOT NULL,
  PRIMARY KEY (process_id),
  CONSTRAINT bus_domain_id FOREIGN KEY (bus_domain_id) REFERENCES bus_domain (bus_domain_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT original_process_id1 FOREIGN KEY (parent_process_id) REFERENCES process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT process_ibfk_1 FOREIGN KEY (process_template_id) REFERENCES process_template (process_template_id),
  CONSTRAINT process_type_id1 FOREIGN KEY (process_type_id) REFERENCES process_type (process_type_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT workflow_id FOREIGN KEY (workflow_id) REFERENCES workflow_type (workflow_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT permission_type_id1 FOREIGN KEY (user_access_id) REFERENCES permission_type (permission_type_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT permission_type_id2 FOREIGN KEY (group_access_id) REFERENCES permission_type (permission_type_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT permission_type_id3 FOREIGN KEY (others_access_id) REFERENCES permission_type (permission_type_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT owner_check FOREIGN KEY(owner_role_id) REFERENCES user_roles (user_role_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT user_contreint FOREIGN KEY (user_name) REFERENCES users (username) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE properties (
  process_id integer NOT NULL,
  config_group varchar(128) NOT NULL,
  prop_key varchar(128) NOT NULL,
  prop_value varchar(2048) NOT NULL,
  description varchar(1028) NOT NULL,
  PRIMARY KEY (process_id,prop_key),
  CONSTRAINT process_id4 FOREIGN KEY (process_id) REFERENCES process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE instance_exec (
  instance_exec_id bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
  process_id int NOT NULL,
  start_ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_ts timestamp  DEFAULT NULL,
  exec_state int NOT NULL,
  PRIMARY KEY (instance_exec_id),
  CONSTRAINT process_id_instance_exec FOREIGN KEY (process_id) REFERENCES process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT exec_state_instance_exec FOREIGN KEY (exec_state) REFERENCES exec_status (exec_state_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE batch (
  batch_id bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
  source_instance_exec_id bigint DEFAULT NULL,
  batch_type varchar(45) NOT NULL,
  PRIMARY KEY (batch_id),
  CONSTRAINT instance_exec_id FOREIGN KEY (source_instance_exec_id) REFERENCES instance_exec (instance_exec_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);



CREATE TABLE file (
  batch_id bigint NOT NULL,
  server_id int NOT NULL,
  path varchar(256) NOT NULL,
  file_size bigint NOT NULL,
  file_hash varchar(100) DEFAULT NULL,
  creation_ts TIMESTAMP AS NOW() NOT NULL,
  CONSTRAINT server_id FOREIGN KEY (server_id) REFERENCES servers (server_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT unique_batch FOREIGN KEY (batch_id) REFERENCES batch (batch_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE batch_consump_queue (
  source_batch_id bigint NOT NULL,
  target_batch_id bigint DEFAULT NULL,
  queue_id bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
  insert_ts TIMESTAMP AS NOW() NOT NULL,
  source_process_id int DEFAULT NULL,
  start_ts timestamp  DEFAULT NULL,
  end_ts timestamp  DEFAULT NULL,
  batch_state int NOT NULL,
  batch_marking varchar(45) DEFAULT NULL,
  process_id int NOT NULL,
  PRIMARY KEY (queue_id),
  CONSTRAINT batch_state_bcq FOREIGN KEY (batch_state) REFERENCES batch_status (batch_state_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT process_id_bcq FOREIGN KEY (process_id) REFERENCES process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT source_batch_bcq FOREIGN KEY (source_batch_id) REFERENCES batch (batch_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT target_batch_bcq FOREIGN KEY (target_batch_id) REFERENCES batch (batch_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE archive_consump_queue (
  source_batch_id bigint NOT NULL,
  target_batch_id bigint DEFAULT NULL,
  queue_id bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
  insert_ts TIMESTAMP AS NOW() NOT NULL,
  source_process_id int DEFAULT NULL,
  start_ts timestamp  DEFAULT NULL,
  end_ts timestamp  DEFAULT NULL,
  batch_state int NOT NULL,
  batch_marking varchar(45) DEFAULT NULL,
  process_id int NOT NULL,
  PRIMARY KEY (queue_id),
  CONSTRAINT process_id_archive_consump_queue FOREIGN KEY (process_id) REFERENCES process (process_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT batch_state_archive_consump_queue FOREIGN KEY (batch_state) REFERENCES batch_status (batch_state_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT source_batch_archive_consump_queue FOREIGN KEY (source_batch_id) REFERENCES batch (batch_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT target_batch_archive_consump_queue FOREIGN KEY (target_batch_id) REFERENCES batch (batch_id) ON DELETE NO ACTION ON UPDATE NO ACTION

);

CREATE TABLE  process_log  (
   log_id  bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   add_ts  timestamp,
   process_id  int NOT NULL,
   log_category  varchar(10) NOT NULL,
   message_id  varchar(128) NOT NULL,
   message  varchar(1024) NOT NULL,
   instance_ref  bigint,
  PRIMARY KEY ( log_id ),
  CONSTRAINT  process_id  FOREIGN KEY ( process_id ) REFERENCES  process  ( process_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE  intermediate  (
   uuid  varchar(64) NOT NULL,
   inter_key  varchar(128) NOT NULL,
   inter_value  varchar(2048) NOT NULL,
  PRIMARY KEY ( inter_key , uuid )
);
CREATE TABLE  lineage_node_type  (
   node_type_id  int NOT NULL,
   node_type_name  varchar(45) NOT NULL,
  PRIMARY KEY ( node_type_id )
);

CREATE TABLE  lineage_query_type  (
   query_type_id  INT NOT NULL,
   query_type_name  varchar(255) NOT NULL,
  PRIMARY KEY ( query_type_id )
);

CREATE TABLE  lineage_query  (
   query_id  varchar(100) NOT NULL,
   query_string  varchar(4000) ,
   query_type_id  int NOT NULL,
   create_ts  timestamp DEFAULT CURRENT_TIMESTAMP,
   process_id  int,
   instance_exec_id  bigint DEFAULT NULL,
  PRIMARY KEY ( query_id ),
  CONSTRAINT  query_type_id  FOREIGN KEY ( query_type_id ) REFERENCES  lineage_query_type  ( query_type_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  lineage_node  (
   node_id  varchar(100) NOT NULL,
   node_type_id  int NOT NULL,
   container_node_id  varchar(100) DEFAULT NULL,
   node_order  int DEFAULT 0,
   insert_ts  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   update_ts  timestamp  DEFAULT NULL,
   dot_string  varchar(4000),
   dot_label  varchar(4000),
   display_name  varchar(256) DEFAULT NULL,
  PRIMARY KEY ( node_id ),
  CONSTRAINT  conatiner_node_id  FOREIGN KEY ( container_node_id ) REFERENCES  lineage_node  ( node_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  node_type  FOREIGN KEY ( node_type_id ) REFERENCES  lineage_node_type  ( node_type_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE  lineage_relation  (
   relation_id  varchar(100) NOT NULL,
   src_node_id  varchar(100) DEFAULT NULL,
   target_node_id  varchar(100) DEFAULT NULL,
   query_id  varchar(100) NOT NULL,
   dot_string  varchar(4000),
  PRIMARY KEY ( relation_id ),
  CONSTRAINT  src_node_id  FOREIGN KEY ( src_node_id ) REFERENCES  lineage_node  ( node_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  target_node_id  FOREIGN KEY ( target_node_id ) REFERENCES  lineage_node  ( node_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  query_id  FOREIGN KEY ( query_id ) REFERENCES  lineage_query  ( query_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE deploy_status (
  deploy_status_id smallint NOT NULL,
  description varchar(45) NOT NULL,
  PRIMARY KEY (deploy_status_id)
);
CREATE TABLE general_config (
   config_group varchar(128) NOT NULL,
  gc_key varchar(128) NOT NULL,
  gc_value varchar(2048) ,
  description varchar(1028) NOT NULL,
  required boolean DEFAULT false NOT NULL,
  default_val varchar(2048)  ,
  type varchar(20)  DEFAULT 'text' NOT NULL,
  enabled boolean DEFAULT true,
  PRIMARY KEY (config_group,gc_key)
);
CREATE TABLE  process_deployment_queue  (
    deployment_id  bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
    process_id  int NOT NULL ,
    start_ts  timestamp  DEFAULT NULL,
    insert_ts  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_ts  timestamp DEFAULT NULL,
    deploy_status_id  smallint NOT NULL DEFAULT 1,
    user_name  varchar(45) NOT NULL,
    bus_domain_id  int NOT NULL,
    process_type_id  int NOT NULL,
    deploy_script_location  varchar(1000) DEFAULT NULL,
  PRIMARY KEY ( deployment_id ),
  CONSTRAINT  deploy_status_id  FOREIGN KEY ( deploy_status_id ) REFERENCES  deploy_status  ( deploy_status_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  deploy_process_id  FOREIGN KEY ( process_id ) REFERENCES  process  ( process_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  deploy_process_type_id  FOREIGN KEY ( process_type_id ) REFERENCES  process_type  ( process_type_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT  deploy_bus_domain_id  FOREIGN KEY ( bus_domain_id ) REFERENCES  bus_domain  ( bus_domain_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Docidsdb (
   docid bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1) ,
   url varchar(3000),
   PRIMARY KEY (docid)
);
CREATE TABLE Statisticsdb (
   uniqid bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   value bigint,
   name varchar(255),
   PRIMARY KEY (uniqid)
);
CREATE TABLE Pendingurlsdb (
   uniqid bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   pid bigint,
   instanceexecid bigint,
   url varchar(3000),
   docid int not null,
   parentdocid int not null,
   parenturl varchar(1000),
   depth smallint not null,
   domain varchar(255),
   subdomain varchar(255),
   path varchar(1000),
   anchor varchar(255),
   priority int not null,
   tag varchar(255),
   PRIMARY KEY (uniqid)
);
CREATE TABLE Weburlsdb (
   uniqid bigint NOT NULL  GENERATED BY DEFAULT  AS IDENTITY (START WITH 1, INCREMENT BY 1),
   pid bigint,
   instanceexecid bigint,
   url varchar(3000),
   docid int not null,
   parentdocid int not null,
   parenturl varchar(1000),
   depth smallint not null,
   domain varchar(255),
   subdomain varchar(255),
   path varchar(1000),
   anchor varchar(255),
   priority int not null,
   tag varchar(255),
   PRIMARY KEY (uniqid)
);

create table app_deployment_queue_status (
  app_deployment_status_id smallint not null,
  description varchar(45) not null,
  primary key (app_deployment_status_id)
);


create table app_deployment_queue (
  app_deployment_queue_id bigint not null generated by default  as identity (start with 1, increment by 1),
  process_id int not null,
  username varchar(45) not null,
  app_domain varchar(45) not null,
  app_name varchar(45) not null,
  app_deployment_status_id smallint not null,
  primary key (app_deployment_queue_id),
  constraint process_id_adq_constraint foreign key (process_id) references process(process_id) on delete no action on update no action,
  constraint adq_user_constraint foreign key (username) references users(username) on delete no action on update no action,
  constraint adq_state_constraint foreign key (app_deployment_status_id) references app_deployment_queue_status(app_deployment_status_id) on delete no action on update no action
);


create table installed_plugins (
  plugin_unique_id varchar(128) not null,
  plugin_id varchar(8) not null,
  name varchar(128),
  description varchar(128),
  version int(11) not null default 1,
  author varchar(128),
  add_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  plugin varchar(128),
  unistallable integer(1),
  primary key (plugin_unique_id)
);


create table plugin_dependency (
  dependency_id int(11) not null AUTO_INCREMENT,
  plugin_unique_id varchar(128) not null,
  dependent_plugin_unique_id varchar(128),
  primary key (dependency_id),
  constraint plugin_unique_id foreign key  (plugin_unique_id) references installed_plugins (plugin_unique_id) on delete no action on update no action,
  constraint dependent_plugin_unique_id foreign key (dependent_plugin_unique_id) references installed_plugins (plugin_unique_id) on delete no action on update no action
);

CREATE TABLE plugin_config (
  plugin_unique_id varchar(128) not null,
  config_group varchar(128),
  plugin_key int(11),
  plugin_value varchar(128),
  primary key (plugin_key,plugin_unique_id),
  constraint plugin_config_id foreign key (plugin_unique_id) references installed_plugins (plugin_unique_id) on delete no action on update no action
);