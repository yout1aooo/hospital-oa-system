-- Future/unused OA schema for hospital-cloud.
-- Purpose: preserve planned OA tables that are not currently referenced by backend/frontend code.
-- Notes: do not include this file in the default bootstrap path until corresponding code is implemented.

SET NAMES utf8mb4;

USE `hospital-cloud`;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 审批流程扩展
-- ----------------------------
drop table if exists oa_process_def;
create table oa_process_def (
  process_def_id        bigint(20)      not null auto_increment comment '流程定义ID',
  process_code          varchar(64)     not null                comment '流程编码',
  process_name          varchar(100)    not null                comment '流程名称',
  form_key              varchar(64)     default ''              comment '表单标识',
  status                char(1)         default '0'             comment '状态（0正常 1停用）',
  remark                varchar(500)    default null            comment '备注',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (process_def_id),
  unique key uk_oa_process_def_code (process_code)
) engine=innodb comment='OA流程定义表';

drop table if exists oa_process_form;
create table oa_process_form (
  form_id               bigint(20)      not null auto_increment comment '表单ID',
  process_def_id        bigint(20)      not null                comment '流程定义ID',
  form_name             varchar(100)    not null                comment '表单名称',
  form_schema           longtext                                comment '表单结构定义',
  version_no            int(11)         default 1               comment '版本号',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (form_id)
) engine=innodb comment='OA流程表单表';

drop table if exists oa_process_instance;
create table oa_process_instance (
  instance_id           bigint(20)      not null auto_increment comment '流程实例ID',
  process_def_id        bigint(20)      not null                comment '流程定义ID',
  business_key          varchar(64)     default ''              comment '业务关联键',
  title                 varchar(200)    not null                comment '流程标题',
  applicant_id          bigint(20)      not null                comment '申请人ID',
  current_handler_id    bigint(20)      default null            comment '当前处理人ID',
  status                varchar(20)     not null                comment '状态',
  form_data             longtext                                comment '表单数据',
  submit_time           datetime                                comment '提交流程时间',
  finish_time           datetime                                comment '完成时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (instance_id)
) engine=innodb comment='OA流程实例表';

drop table if exists oa_process_task;
create table oa_process_task (
  task_id               bigint(20)      not null auto_increment comment '任务ID',
  instance_id           bigint(20)      not null                comment '流程实例ID',
  task_name             varchar(100)    not null                comment '任务名称',
  assignee_id           bigint(20)      default null            comment '办理人ID',
  status                varchar(20)     not null                comment '任务状态',
  due_time              datetime                                comment '截止时间',
  complete_time         datetime                                comment '完成时间',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (task_id)
) engine=innodb comment='OA流程任务表';

drop table if exists oa_process_comment;
create table oa_process_comment (
  comment_id            bigint(20)      not null auto_increment comment '意见ID',
  instance_id           bigint(20)      not null                comment '流程实例ID',
  task_id               bigint(20)      default null            comment '任务ID',
  user_id               bigint(20)      not null                comment '评论人ID',
  action_type           varchar(30)     default ''              comment '操作类型',
  comment_content       varchar(1000)   default ''              comment '意见内容',
  create_time           datetime                                comment '创建时间',
  primary key (comment_id)
) engine=innodb comment='OA流程意见表';

-- ----------------------------
-- 预留通知
-- ----------------------------
drop table if exists oa_notice;
create table oa_notice (
  notice_id             bigint(20)      not null auto_increment comment '通知ID',
  notice_title          varchar(200)    not null                comment '通知标题',
  notice_type           varchar(30)     default ''              comment '通知类型',
  publish_scope         varchar(255)    default ''              comment '发布范围',
  content               longtext                                comment '通知内容',
  status                char(1)         default '0'             comment '状态（0草稿 1已发布 2已下线）',
  publish_time          datetime                                comment '发布时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (notice_id)
) engine=innodb comment='OA通知表';

SET FOREIGN_KEY_CHECKS = 1;
