SET NAMES utf8mb4;

USE `hospital-cloud`;

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 审批申请
-- ----------------------------
drop table if exists oa_workflow_apply;
create table oa_workflow_apply (
  apply_id              bigint(20)      not null auto_increment comment '申请ID',
  process_type          varchar(30)     not null                comment '流程类型',
  title                 varchar(200)    not null                comment '申请标题',
  form_no               varchar(64)     not null                comment '申请单号',
  applicant_id          bigint(20)      not null                comment '申请人ID',
  applicant_name        varchar(64)     default ''              comment '申请人姓名',
  current_handler_id    bigint(20)      default null            comment '当前处理人ID',
  current_handler_name  varchar(64)     default ''              comment '当前处理人',
  status                varchar(20)     not null                comment '流程状态',
  reason                varchar(1000)   default ''              comment '申请事由',
  amount                decimal(10,2)   default null            comment '报销金额',
  start_date            date                                    comment '开始日期',
  end_date              date                                    comment '结束日期',
  submit_time           datetime                                comment '提交时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (apply_id),
  unique key uk_oa_workflow_apply_form_no (form_no)
) engine=innodb comment='OA申请单表';

drop table if exists oa_workflow_task;
create table oa_workflow_task (
  workflow_task_id      bigint(20)      not null auto_increment comment '审批任务ID',
  apply_id              bigint(20)      not null                comment '申请ID',
  task_name             varchar(100)    not null                comment '任务名称',
  assignee_id           bigint(20)      default null            comment '处理人ID',
  assignee_name         varchar(64)     default ''              comment '处理人姓名',
  task_status           varchar(20)     not null                comment '任务状态',
  comment_content       varchar(1000)   default ''              comment '审批意见',
  create_time           datetime                                comment '创建时间',
  complete_time         datetime                                comment '完成时间',
  primary key (workflow_task_id)
) engine=innodb comment='OA审批任务表';

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
-- 通知与统一文档中心
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

drop table if exists oa_document_category;
create table oa_document_category (
  category_id           bigint(20)      not null auto_increment comment '分类ID',
  category_name         varchar(100)    not null                comment '分类名称',
  parent_id             bigint(20)      default 0               comment '父分类ID',
  order_num             int(11)         default 0               comment '排序号',
  status                char(1)         default '0'             comment '状态（0正常 1停用）',
  remark                varchar(500)    default null            comment '备注',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (category_id)
) engine=innodb comment='OA文档分类表';

drop table if exists oa_document;
create table oa_document (
  document_id           bigint(20)      not null auto_increment comment '文档ID',
  category_id           bigint(20)      default null            comment '分类ID',
  document_type         varchar(30)     default 'policy'        comment '文档类型（policy制度 notice通知附件 official公文资料）',
  document_title        varchar(200)    not null                comment '文档标题',
  document_no           varchar(64)     default ''              comment '文档编号',
  content               longtext                                comment '文档内容',
  attachment_url        varchar(255)    default ''              comment '附件地址',
  status                char(1)         default '0'             comment '状态（0草稿 1已发布 2已归档）',
  publish_time          datetime                                comment '发布时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (document_id)
) engine=innodb comment='OA统一文档中心表';

drop table if exists oa_document_read_log;
create table oa_document_read_log (
  read_log_id           bigint(20)      not null auto_increment comment '阅读记录ID',
  document_id           bigint(20)      not null                comment '文档ID',
  user_id               bigint(20)      not null                comment '用户ID',
  read_status           char(1)         default '0'             comment '阅读状态（0未读 1已读 2已确认）',
  read_time             datetime                                comment '阅读时间',
  confirm_time          datetime                                comment '确认时间',
  create_time           datetime                                comment '创建时间',
  primary key (read_log_id),
  unique key uk_oa_document_user (document_id, user_id)
) engine=innodb comment='OA文档阅读记录表';

insert into oa_document_category (category_id, category_name, parent_id, order_num, status, remark, create_by, create_time, update_by, update_time)
values
  (1, '医院制度', 0, 1, '0', '制度文件', 'admin', sysdate(), '', null),
  (2, '行政规范', 0, 2, '0', '行政办公规范', 'admin', sysdate(), '', null),
  (3, '公文资料', 0, 3, '0', '统一文档中心分类', 'admin', sysdate(), '', null);

insert into oa_document (document_id, category_id, document_type, document_title, document_no, content, attachment_url, status, publish_time, create_by, create_time, update_by, update_time)
values
  (1, 1, 'policy', '医疗质量安全管理制度', 'DOC-202603-001', '请各科室组织学习医疗质量安全管理制度，并完成阅读确认。', '', '1', sysdate(), 'admin', sysdate(), '', null),
  (2, 2, 'policy', '行政值班交接规范', 'DOC-202603-002', '行政值班人员需按规范完成交接登记与异常上报。', '', '1', sysdate(), 'admin', sysdate(), '', null),
  (3, 3, 'official', '院感培训考核办法', 'DOC-202603-003', '本制度文档已归档，供后续查阅。', '', '2', sysdate(), 'admin', sysdate(), '', null);

insert into oa_document_read_log (read_log_id, document_id, user_id, read_status, read_time, confirm_time, create_time)
values
  (1, 1, 1, '0', null, null, sysdate()),
  (2, 2, 1, '1', sysdate(), null, sysdate()),
  (3, 3, 1, '2', sysdate(), sysdate(), sysdate());

-- ----------------------------
-- 会议协同
-- ----------------------------
drop table if exists oa_meeting_room;
create table oa_meeting_room (
  room_id               bigint(20)      not null auto_increment comment '会议室ID',
  room_name             varchar(100)    not null                comment '会议室名称',
  location              varchar(200)    default ''              comment '位置',
  capacity              int(11)         default 0               comment '容纳人数',
  equipment             varchar(500)    default ''              comment '设备说明',
  status                char(1)         default '0'             comment '状态（0可用 1停用）',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (room_id)
) engine=innodb comment='OA会议室表';

drop table if exists oa_meeting;
create table oa_meeting (
  meeting_id            bigint(20)      not null auto_increment comment '会议ID',
  meeting_title         varchar(200)    not null                comment '会议主题',
  room_id               bigint(20)      default null            comment '会议室ID',
  organizer_id          bigint(20)      not null                comment '组织人ID',
  organizer_name        varchar(64)     default ''              comment '组织人姓名',
  start_time            datetime                                comment '开始时间',
  end_time              datetime                                comment '结束时间',
  meeting_status        varchar(20)     default 'draft'         comment '会议状态',
  summary_content       longtext                                comment '会议纪要',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (meeting_id)
) engine=innodb comment='OA会议表';

insert into oa_meeting_room (room_id, room_name, location, capacity, equipment, status, create_by, create_time, update_by, update_time)
values
  (1, '三楼会议室', '门诊楼三层', 20, '投影、视频会议终端', '0', 'admin', sysdate(), '', null),
  (2, '远程会议室', '行政楼二层', 12, '摄像头、电子白板', '0', 'admin', sysdate(), '', null);

insert into oa_meeting (meeting_id, meeting_title, room_id, organizer_id, organizer_name, start_time, end_time, meeting_status, summary_content, create_by, create_time, update_by, update_time)
values
  (1, '院务协调会', 1, 1, '管理员', date_add(sysdate(), interval 1 hour), date_add(sysdate(), interval 2 hour), 'scheduled', '', 'admin', sysdate(), '', null),
  (2, '信息化建设周例会', 2, 1, '管理员', date_add(sysdate(), interval 3 hour), date_add(sysdate(), interval 4 hour), 'scheduled', '', 'admin', sysdate(), '', null);

-- ----------------------------
-- 任务督办
-- ----------------------------
drop table if exists oa_task;
create table oa_task (
  task_id               bigint(20)      not null auto_increment comment '任务ID',
  task_title            varchar(200)    not null                comment '任务标题',
  task_type             varchar(30)     default ''              comment '任务类型',
  publisher_id          bigint(20)      not null                comment '发布人ID',
  publisher_name        varchar(64)     default ''              comment '发布人姓名',
  assignee_id           bigint(20)      default null            comment '执行人ID',
  assignee_name         varchar(64)     default ''              comment '执行人姓名',
  priority_level        varchar(20)     default 'normal'        comment '优先级',
  task_status           varchar(20)     default 'pending'       comment '任务状态',
  start_time            datetime                                comment '开始时间',
  due_time              datetime                                comment '截止时间',
  complete_time         datetime                                comment '完成时间',
  content               longtext                                comment '任务内容',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (task_id)
) engine=innodb comment='OA任务表';

drop table if exists oa_task_record;
create table oa_task_record (
  record_id             bigint(20)      not null auto_increment comment '任务记录ID',
  task_id               bigint(20)      not null                comment '任务ID',
  operator_id           bigint(20)      not null                comment '操作人ID',
  operator_name         varchar(64)     default ''              comment '操作人姓名',
  record_type           varchar(30)     default ''              comment '记录类型',
  record_content        varchar(1000)   default ''              comment '记录内容',
  create_time           datetime                                comment '创建时间',
  primary key (record_id)
) engine=innodb comment='OA任务跟进记录表';

insert into oa_task (task_id, task_title, task_type, publisher_id, publisher_name, assignee_id, assignee_name, priority_level, task_status, start_time, due_time, complete_time, content, create_by, create_time, update_by, update_time)
values
  (1, '整改任务跟进', '督办', 1, '管理员', 1, '管理员', 'high', 'pending', sysdate(), date_add(sysdate(), interval 1 day), null, '门诊流程优化任务需在截止前完成跟进。', 'admin', sysdate(), '', null),
  (2, '文档阅读催办', '通知', 1, '管理员', 1, '管理员', 'normal', 'processing', sysdate(), date_add(sysdate(), interval 2 day), null, '制度文档未读人员需要尽快确认。', 'admin', sysdate(), '', null);

insert into oa_task_record (record_id, task_id, operator_id, operator_name, record_type, record_content, create_time)
values
  (1, 1, 1, '管理员', 'create', '创建整改任务并指派责任人。', sysdate()),
  (2, 2, 1, '管理员', 'follow', '已发送制度文档提醒。', sysdate());

-- ----------------------------
-- 日程提醒
-- ----------------------------
drop table if exists oa_schedule;
create table oa_schedule (
  schedule_id           bigint(20)      not null auto_increment comment '日程ID',
  schedule_title        varchar(200)    not null                comment '日程标题',
  owner_id              bigint(20)      not null                comment '所属人ID',
  start_time            datetime                                comment '开始时间',
  end_time              datetime                                comment '结束时间',
  remind_time           datetime                                comment '提醒时间',
  schedule_type         varchar(30)     default ''              comment '日程类型',
  schedule_status       varchar(20)     default 'pending'       comment '日程状态',
  remark                varchar(500)    default null            comment '备注',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (schedule_id)
) engine=innodb comment='OA日程表';

-- ----------------------------
-- 通讯录与组织增强
-- ----------------------------
drop table if exists oa_staff_profile;
create table oa_staff_profile (
  profile_id            bigint(20)      not null auto_increment comment '档案ID',
  user_id               bigint(20)      not null                comment '用户ID',
  staff_no              varchar(64)     default ''              comment '工号',
  job_title             varchar(100)    default ''              comment '职称',
  office_phone          varchar(30)     default ''              comment '办公电话',
  emergency_phone       varchar(30)     default ''              comment '值班联系方式',
  campus_name           varchar(100)    default ''              comment '院区名称',
  duty_name             varchar(100)    default ''              comment '职务名称',
  specialty             varchar(255)    default ''              comment '专业方向',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (profile_id),
  unique key uk_oa_staff_profile_user (user_id)
) engine=innodb comment='OA人员档案扩展表';

drop table if exists oa_department_ext;
create table oa_department_ext (
  ext_id                bigint(20)      not null auto_increment comment '扩展ID',
  dept_id               bigint(20)      not null                comment '部门ID',
  dept_type             varchar(30)     default ''              comment '部门类型',
  campus_name           varchar(100)    default ''              comment '所属院区',
  office_location       varchar(200)    default ''              comment '办公地点',
  service_phone         varchar(30)     default ''              comment '科室电话',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (ext_id),
  unique key uk_oa_department_ext_dept (dept_id)
) engine=innodb comment='OA部门扩展表';

drop table if exists oa_contact_group;
create table oa_contact_group (
  group_id              bigint(20)      not null auto_increment comment '分组ID',
  group_name            varchar(100)    not null                comment '分组名称',
  owner_id              bigint(20)      not null                comment '创建人ID',
  member_ids            varchar(1000)   default ''              comment '成员ID列表',
  remark                varchar(500)    default null            comment '备注',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (group_id)
) engine=innodb comment='OA联系人分组表';

insert into oa_staff_profile (profile_id, user_id, staff_no, job_title, office_phone, emergency_phone, campus_name, duty_name, specialty, create_time, update_time)
values
  (1, 1, 'HK-0001', '信息科工程师', '0759-8001001', '13800000001', '河口院区', '系统管理员', '医院信息化', sysdate(), null);

insert into oa_department_ext (ext_id, dept_id, dept_type, campus_name, office_location, service_phone, create_time, update_time)
values
  (1, 100, '行政职能', '河口院区', '行政楼三层', '0759-8002001', sysdate(), null);

insert into oa_contact_group (group_id, group_name, owner_id, member_ids, remark, create_time, update_time)
values
  (1, '行政联络组', 1, '1', '默认联系人分组', sysdate(), null);

SET FOREIGN_KEY_CHECKS = 1;
