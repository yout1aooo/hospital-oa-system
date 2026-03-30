-- Active OA runtime schema for hospital-cloud.
-- Purpose: initialize only the OA business tables that are currently used by backend/frontend code.
-- Notes: run after 00_core_schema.sql. This file keeps existing table structures unchanged and excludes future/unused schema.

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
-- 统一文档中心
-- ----------------------------
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
  attachment_url        varchar(255)    default ''              comment '兼容附件地址',
  status                char(1)         default '0'             comment '状态（0草稿 1已发布 2已归档）',
  publish_time          datetime                                comment '发布时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (document_id)
) engine=innodb comment='OA统一文档中心表';

drop table if exists oa_document_attachment;
create table oa_document_attachment (
  attachment_id         bigint(20)      not null auto_increment comment '附件ID',
  document_id           bigint(20)      not null                comment '文档ID',
  file_name             varchar(255)    not null                comment '存储文件名',
  original_name         varchar(255)    not null                comment '原始文件名',
  content_type          varchar(100)    default ''              comment '文件类型',
  file_size             bigint(20)      default 0               comment '文件大小（字节）',
  file_url              varchar(255)    default ''              comment '文件服务访问地址',
  mongo_file_id         varchar(64)     default ''              comment 'Mongo GridFS文件ID（兼容历史数据）',
  sort_order            int(11)         default 0               comment '排序号',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (attachment_id),
  key idx_oa_document_attachment_doc (document_id, sort_order),
  unique key uk_oa_document_attachment_mongo_file_id (mongo_file_id)
) engine=innodb comment='OA文档附件表';

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

-- ----------------------------
-- 患者与病例查询
-- ----------------------------
drop table if exists oa_patient;
create table oa_patient (
  patient_id            bigint(20)      not null auto_increment comment '患者ID',
  patient_no            varchar(64)     not null                comment '患者编号',
  patient_name          varchar(64)     not null                comment '患者姓名',
  gender                char(1)         default '0'             comment '性别（0男 1女 2未知）',
  id_card_no            varchar(32)     default ''              comment '身份证号',
  phone_no              varchar(32)     default ''              comment '联系电话',
  birthday              date                                    comment '出生日期',
  dept_id               bigint(20)      default null            comment '归属科室ID',
  dept_name             varchar(100)    default ''              comment '归属科室名称',
  attending_doctor_id   bigint(20)      default null            comment '主治医生ID',
  attending_doctor_name varchar(64)     default ''              comment '主治医生姓名',
  inpatient_no          varchar(64)     default ''              comment '住院号',
  patient_status        varchar(20)     default 'active'        comment '患者状态',
  admission_time        datetime                                comment '入院时间',
  discharge_time        datetime                                comment '出院时间',
  remark                varchar(500)    default null            comment '备注',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (patient_id),
  unique key uk_oa_patient_no (patient_no),
  key idx_oa_patient_dept (dept_id),
  key idx_oa_patient_status (patient_status),
  key idx_oa_patient_admission (admission_time)
) engine=innodb comment='OA患者主档表';

drop table if exists oa_patient_case;
create table oa_patient_case (
  case_id               bigint(20)      not null auto_increment comment '病例ID',
  patient_id            bigint(20)      not null                comment '患者ID',
  case_no               varchar(64)     not null                comment '病例编号',
  case_title            varchar(200)    not null                comment '病例标题',
  visit_type            varchar(20)     default 'inpatient'     comment '就诊类型',
  case_status           varchar(20)     default 'draft'         comment '病例状态',
  diagnosis             varchar(500)    default ''              comment '诊断结果',
  chief_complaint       varchar(1000)   default ''              comment '主诉',
  treatment_plan        varchar(1000)   default ''              comment '诊疗方案',
  doctor_id             bigint(20)      default null            comment '接诊医生ID',
  doctor_name           varchar(64)     default ''              comment '接诊医生姓名',
  dept_id               bigint(20)      default null            comment '接诊科室ID',
  dept_name             varchar(100)    default ''              comment '接诊科室名称',
  visit_time            datetime                                comment '就诊时间',
  discharge_time        datetime                                comment '出院时间',
  create_by             varchar(64)     default ''              comment '创建者',
  create_time           datetime                                comment '创建时间',
  update_by             varchar(64)     default ''              comment '更新者',
  update_time           datetime                                comment '更新时间',
  primary key (case_id),
  unique key uk_oa_patient_case_no (case_no),
  key idx_oa_patient_case_patient (patient_id),
  key idx_oa_patient_case_status (case_status),
  key idx_oa_patient_case_visit_time (visit_time)
) engine=innodb comment='OA患者病例表';

drop table if exists oa_patient_access_log;
create table oa_patient_access_log (
  access_log_id         bigint(20)      not null auto_increment comment '访问日志ID',
  patient_id            bigint(20)      default null            comment '患者ID',
  case_id               bigint(20)      default null            comment '病例ID',
  access_type           varchar(20)     not null                comment '访问类型',
  operator_id           bigint(20)      not null                comment '操作人ID',
  operator_name         varchar(64)     default ''              comment '操作人姓名',
  dept_id               bigint(20)      default null            comment '操作人科室ID',
  dept_name             varchar(100)    default ''              comment '操作人科室名称',
  access_time           datetime                                comment '访问时间',
  access_ip             varchar(128)    default ''              comment '访问IP',
  remark                varchar(500)    default null            comment '备注',
  primary key (access_log_id),
  key idx_oa_patient_access_patient (patient_id),
  key idx_oa_patient_access_case (case_id),
  key idx_oa_patient_access_operator (operator_id),
  key idx_oa_patient_access_time (access_time)
) engine=innodb comment='OA患者访问审计日志表';

SET FOREIGN_KEY_CHECKS = 1;
