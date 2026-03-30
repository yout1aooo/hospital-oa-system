-- =============================================================
-- hospital_cloud_init.sql
-- 合并初始化脚本：core schema + Quartz + OA runtime + OA seed data
-- 执行顺序：本文件一次性完成全库初始化
-- 不含 90_oa_future_schema.sql（未启用的预留表，单独管理）
-- 生成时间：2026-03-26
-- =============================================================


-- =============================================================
-- PART 1: 核心系统表 & 基础数据 (00_core_schema.sql)
-- =============================================================

-- Core bootstrap for hospital-cloud.
-- Purpose: initialize base system schema, seed users/roles/menus/dicts/config, and keep current behavior unchanged.
-- Notes: destructive for hospital-cloud; run before any OA extension scripts.

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS `hospital-cloud`;
CREATE DATABASE `hospital-cloud` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `hospital-cloud`;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1、部门表
-- ----------------------------
drop table if exists sys_dept;
create table sys_dept (
  dept_id           bigint(20)      not null auto_increment    comment '部门id',
  parent_id         bigint(20)      default 0                  comment '父部门id',
  ancestors         varchar(50)     default ''                 comment '祖级列表',
  dept_name         varchar(30)     default ''                 comment '部门名称',
  order_num         int(4)          default 0                  comment '显示顺序',
  leader            varchar(20)     default null               comment '负责人',
  phone             varchar(11)     default null               comment '联系电话',
  email             varchar(50)     default null               comment '邮箱',
  status            char(1)         default '0'                comment '部门状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (dept_id)
) engine=innodb auto_increment=200 comment = '部门表';

-- ----------------------------
-- 初始化-部门表数据
-- ----------------------------
insert into sys_dept values(100,  0,   '0',          '河口医院智能协同办公平台',   0, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(101,  100, '0,100',      '院务办公室', 1, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(102,  100, '0,100',      '医务科',     2, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(103,  101, '0,100,101',  '行政部',     1, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(104,  101, '0,100,101',  '人事科',     2, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(105,  101, '0,100,101',  '信息科',     3, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(106,  101, '0,100,101',  '财务科',     4, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(107,  101, '0,100,101',  '后勤保障科', 5, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(108,  102, '0,100,102',  '门诊部',     1, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(109,  102, '0,100,102',  '护理部',     2, 'admin', '15888888888', 'admin@hospital-oa-system.local', '0', '0', 'admin', sysdate(), '', null);


-- ----------------------------
-- 2、用户信息表
-- ----------------------------
drop table if exists sys_user;
create table sys_user (
  user_id           bigint(20)      not null auto_increment    comment '用户ID',
  dept_id           bigint(20)      default null               comment '部门ID',
  user_name         varchar(30)     not null                   comment '用户账号',
  nick_name         varchar(30)     not null                   comment '用户昵称',
  user_type         varchar(2)      default '00'               comment '用户类型（00系统用户）',
  email             varchar(50)     default ''                 comment '用户邮箱',
  phonenumber       varchar(11)     default ''                 comment '手机号码',
  sex               char(1)         default '0'                comment '用户性别（0男 1女 2未知）',
  avatar            varchar(100)    default ''                 comment '头像地址',
  password          varchar(100)    default ''                 comment '密码',
  status            char(1)         default '0'                comment '账号状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  login_ip          varchar(128)    default ''                 comment '最后登录IP',
  login_date        datetime                                   comment '最后登录时间',
  pwd_update_date   datetime                                   comment '密码最后更新时间',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (user_id)
) engine=innodb auto_increment=100 comment = '用户信息表';

-- ----------------------------
-- 初始化-用户信息表数据
-- ----------------------------
insert into sys_user values(1,  103, 'admin', 'admin', '00', 'admin@hospital-oa-system.local', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '系统管理员');
insert into sys_user values(2,  105, 'staff', 'staff', '00', 'staff@hospital-oa-system.local',  '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '系统测试用户');


-- ----------------------------
-- 3、岗位信息表
-- ----------------------------
drop table if exists sys_post;
create table sys_post
(
  post_id       bigint(20)      not null auto_increment    comment '岗位ID',
  post_code     varchar(64)     not null                   comment '岗位编码',
  post_name     varchar(50)     not null                   comment '岗位名称',
  post_sort     int(4)          not null                   comment '显示顺序',
  status        char(1)         not null                   comment '状态（0正常 1停用）',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''			       comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (post_id)
) engine=innodb comment = '岗位信息表';

-- ----------------------------
-- 初始化-岗位信息表数据
-- ----------------------------
insert into sys_post values(1, 'president',  '院长',       1, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(2, 'director',   '科室主任',   2, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(3, 'finance',    '财务人员',   3, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(4, 'staff',      '普通员工',   4, '0', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 4、角色信息表
-- ----------------------------
drop table if exists sys_role;
create table sys_role (
  role_id              bigint(20)      not null auto_increment    comment '角色ID',
  role_name            varchar(30)     not null                   comment '角色名称',
  role_key             varchar(100)    not null                   comment '角色权限字符串',
  role_sort            int(4)          not null                   comment '显示顺序',
  data_scope           char(1)         default '1'                comment '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  menu_check_strictly  tinyint(1)      default 1                  comment '菜单树选择项是否关联显示',
  dept_check_strictly  tinyint(1)      default 1                  comment '部门树选择项是否关联显示',
  status               char(1)         not null                   comment '角色状态（0正常 1停用）',
  del_flag             char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  create_by            varchar(64)     default ''                 comment '创建者',
  create_time          datetime                                   comment '创建时间',
  update_by            varchar(64)     default ''                 comment '更新者',
  update_time          datetime                                   comment '更新时间',
  remark               varchar(500)    default null               comment '备注',
  primary key (role_id)
) engine=innodb auto_increment=100 comment = '角色信息表';

-- ----------------------------
-- 初始化-角色信息表数据
-- ----------------------------
insert into sys_role values('1', '超级管理员',  'admin',  1, 1, 1, 1, '0', '0', 'admin', sysdate(), '', null, '超级管理员');
insert into sys_role values('2', '业务角色',    'common', 2, 2, 1, 1, '0', '0', 'admin', sysdate(), '', null, '业务角色');


-- ----------------------------
-- 5、菜单权限表
-- ----------------------------
drop table if exists sys_menu;
create table sys_menu (
  menu_id           bigint(20)      not null auto_increment    comment '菜单ID',
  menu_name         varchar(50)     not null                   comment '菜单名称',
  parent_id         bigint(20)      default 0                  comment '父菜单ID',
  order_num         int(4)          default 0                  comment '显示顺序',
  path              varchar(200)    default ''                 comment '路由地址',
  component         varchar(255)    default null               comment '组件路径',
  query             varchar(255)    default null               comment '路由参数',
  route_name        varchar(50)     default ''                 comment '路由名称',
  is_frame          int(1)          default 1                  comment '是否为外链（0是 1否）',
  is_cache          int(1)          default 0                  comment '是否缓存（0缓存 1不缓存）',
  menu_type         char(1)         default ''                 comment '菜单类型（M目录 C菜单 F按钮）',
  visible           char(1)         default 0                  comment '菜单状态（0显示 1隐藏）',
  status            char(1)         default 0                  comment '菜单状态（0正常 1停用）',
  perms             varchar(100)    default null               comment '权限标识',
  icon              varchar(100)    default '#'                comment '菜单图标',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default ''                 comment '备注',
  primary key (menu_id)
) engine=innodb auto_increment=2000 comment = '菜单权限表';

-- ----------------------------
-- 初始化-菜单信息表数据
-- ----------------------------
-- 一级菜单
insert into sys_menu values('1', '工作台',   '0', '1', 'workbench', null, '', '', 1, 0, 'M', '0', '0', '', 'dashboard', 'admin', sysdate(), '', null, 'OA 工作台目录');
insert into sys_menu values('2', '审批中心', '0', '2', 'workflow',  null, '', '', 1, 0, 'M', '0', '0', '', 'education', 'admin', sysdate(), '', null, '审批中心目录');
insert into sys_menu values('3', '通知文档', '0', '3', 'notice',    null, '', '', 1, 0, 'M', '0', '0', '', 'message',   'admin', sysdate(), '', null, '通知文档目录');
insert into sys_menu values('4', '会议任务', '0', '4', 'collab',    null, '', '', 1, 0, 'M', '0', '0', '', 'date',      'admin', sysdate(), '', null, '会议任务目录');
insert into sys_menu values('5', '通讯录',   '0', '5', 'contacts',  null, '', '', 1, 0, 'M', '0', '0', '', 'peoples',   'admin', sysdate(), '', null, '通讯录目录');
insert into sys_menu values('6', '系统管理', '0', '6', 'system',    null, '', '', 1, 0, 'M', '0', '0', '', 'system',    'admin', sysdate(), '', null, '系统管理目录');
insert into sys_menu values('7', '患者服务', '0', '7', 'patient',   null, '', '', 1, 0, 'M', '0', '0', '', 'user-solid', 'admin', sysdate(), '', null, '患者服务目录');
-- 二级菜单
insert into sys_menu values('100', 'OA工作台',   '1', '1', 'index',    'index',                   '', '', 1, 0, 'C', '0', '0', '',                        'dashboard', 'admin', sysdate(), '', null, 'OA 工作台菜单');
insert into sys_menu values('200', '我的申请',   '2', '1', 'apply',    'oa/workflow/index',       '{"tab":"apply"}',  '', 1, 0, 'C', '0', '0', 'oa:workflow:apply',       'form',      'admin', sysdate(), '', null, '我的申请菜单');
insert into sys_menu values('201', '我的待办',   '2', '2', 'todo',     'oa/workflow/index',       '{"tab":"todo"}',   '', 1, 0, 'C', '0', '0', 'oa:workflow:todo',        'clipboard', 'admin', sysdate(), '', null, '我的待办菜单');
insert into sys_menu values('202', '我的已办',   '2', '3', 'done',     'oa/workflow/index',       '{"tab":"done"}',   '', 1, 0, 'C', '0', '0', 'oa:workflow:done',        'check',     'admin', sysdate(), '', null, '我的已办菜单');
insert into sys_menu values('300', '通知中心',   '3', '1', 'center',   'system/notice/index',     '', '', 1, 0, 'C', '0', '0', 'system:notice:list',      'message',   'admin', sysdate(), '', null, '通知中心菜单');
insert into sys_menu values('301', '制度文档',   '3', '2', 'document', 'oa/notice/index',         '', '', 1, 0, 'C', '0', '0', 'oa:notice:document:list', 'documentation', 'admin', sysdate(), '', null, '制度文档菜单');
insert into sys_menu values('400', '会议管理',   '4', '1', 'meeting',  'oa/collab/index',         '{"tab":"meeting"}', '', 1, 0, 'C', '0', '0', 'oa:collab:meeting:list',  'date',      'admin', sysdate(), '', null, '会议管理菜单');
insert into sys_menu values('401', '任务督办',   '4', '2', 'task',     'oa/collab/index',         '{"tab":"task"}',    '', 1, 0, 'C', '0', '0', 'oa:collab:task:list',     'guide',     'admin', sysdate(), '', null, '任务督办菜单');
insert into sys_menu values('402', '日程提醒',   '4', '3', 'schedule', 'oa/collab/index',         '{"tab":"schedule"}','', 1, 0, 'C', '0', '0', 'oa:collab:schedule:list', 'clock',     'admin', sysdate(), '', null, '日程提醒菜单');
insert into sys_menu values('500', '通讯录查询', '5', '1', 'directory','oa/contacts/index',       '', '', 1, 0, 'C', '0', '0', 'oa:contacts:list',        'phone',     'admin', sysdate(), '', null, '通讯录查询菜单');
insert into sys_menu values('501', '人员管理',   '5', '2', 'user',     'system/user/index',       '', '', 1, 0, 'C', '0', '0', 'system:user:list',        'user',      'admin', sysdate(), '', null, '人员管理菜单');
insert into sys_menu values('502', '科室管理',   '5', '3', 'dept',     'system/dept/index',       '', '', 1, 0, 'C', '0', '0', 'system:dept:list',        'tree',      'admin', sysdate(), '', null, '科室管理菜单');
insert into sys_menu values('700', '患者查询',   '7', '1', 'query',    'oa/patient/index',        '{"tab":"patient"}', '', 1, 0, 'C', '0', '0', 'oa:patient:list',         'user',      'admin', sysdate(), '', null, '患者查询菜单');
insert into sys_menu values('701', '病例查询',   '7', '2', 'case',     'oa/patient/index',        '{"tab":"case"}',    '', 1, 0, 'C', '0', '0', 'oa:patient:case:list',    'documentation', 'admin', sysdate(), '', null, '病例查询菜单');
insert into sys_menu values('600', '角色管理',   '6', '1', 'role',     'system/role/index',       '', '', 1, 0, 'C', '0', '0', 'system:role:list',        'peoples',   'admin', sysdate(), '', null, '角色管理菜单');
insert into sys_menu values('601', '菜单管理',   '6', '2', 'menu',     'system/menu/index',       '', '', 1, 0, 'C', '0', '0', 'system:menu:list',        'tree-table','admin', sysdate(), '', null, '菜单管理菜单');
insert into sys_menu values('602', '岗位管理',   '6', '3', 'post',     'system/post/index',       '', '', 1, 0, 'C', '0', '0', 'system:post:list',        'post',      'admin', sysdate(), '', null, '岗位管理菜单');
insert into sys_menu values('603', '字典管理',   '6', '4', 'dict',     'system/dict/index',       '', '', 1, 0, 'C', '0', '0', 'system:dict:list',        'dict',      'admin', sysdate(), '', null, '字典管理菜单');
insert into sys_menu values('604', '参数设置',   '6', '5', 'config',   'system/config/index',     '', '', 1, 0, 'C', '0', '0', 'system:config:list',      'edit',      'admin', sysdate(), '', null, '参数设置菜单');
-- 审批中心按钮
insert into sys_menu values('1100', '发起申请', '200', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:workflow:apply:add',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1101', '待办查询', '201', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:workflow:todo:query',    '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1102', '已办查询', '202', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:workflow:done:query',    '#', 'admin', sysdate(), '', null, '');
-- 通知文档按钮
insert into sys_menu values('1035', '公告查询', '300', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1036', '公告新增', '300', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1037', '公告修改', '300', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1038', '公告删除', '300', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1103', '文档查询', '301', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:query',   '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1108', '文档新增', '301', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:add',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1109', '文档修改', '301', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:edit',    '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1110', '文档删除', '301', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:remove',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1111', '文档发布', '301', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:publish', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1112', '文档归档', '301', '6', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:notice:document:archive', '#', 'admin', sysdate(), '', null, '');
-- 会议任务按钮
insert into sys_menu values('1104', '会议查询', '400', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:collab:meeting:query',   '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1105', '任务查询', '401', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:collab:task:query',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1106', '日程查询', '402', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:collab:schedule:query',  '#', 'admin', sysdate(), '', null, '');
-- 通讯录按钮
insert into sys_menu values('1107', '通讯录查询', '500', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:contacts:query',       '#', 'admin', sysdate(), '', null, '');
-- 患者服务按钮
insert into sys_menu values('1113', '患者查询', '700', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:patient:query',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1114', '病例查询', '701', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:patient:case:query',    '#', 'admin', sysdate(), '', null, '');
-- 用户管理按钮
insert into sys_menu values('1000', '用户查询', '501', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1001', '用户新增', '501', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1002', '用户修改', '501', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1003', '用户删除', '501', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1004', '用户导出', '501', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1005', '用户导入', '501', '6',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1006', '重置密码', '501', '7',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd',       '#', 'admin', sysdate(), '', null, '');
-- 角色管理按钮
insert into sys_menu values('1007', '角色查询', '600', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1008', '角色新增', '600', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1009', '角色修改', '600', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1010', '角色删除', '600', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1011', '角色导出', '600', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export',         '#', 'admin', sysdate(), '', null, '');
-- 菜单管理按钮
insert into sys_menu values('1012', '菜单查询', '601', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1013', '菜单新增', '601', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1014', '菜单修改', '601', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1015', '菜单删除', '601', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove',         '#', 'admin', sysdate(), '', null, '');
-- 部门管理按钮
insert into sys_menu values('1016', '部门查询', '502', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1017', '部门新增', '502', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1018', '部门修改', '502', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1019', '部门删除', '502', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove',         '#', 'admin', sysdate(), '', null, '');
-- 岗位管理按钮
insert into sys_menu values('1020', '岗位查询', '602', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1021', '岗位新增', '602', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1022', '岗位修改', '602', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1023', '岗位删除', '602', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1024', '岗位导出', '602', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export',         '#', 'admin', sysdate(), '', null, '');
-- 字典管理按钮
insert into sys_menu values('1025', '字典查询', '603', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1026', '字典新增', '603', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1027', '字典修改', '603', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1028', '字典删除', '603', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1029', '字典导出', '603', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export',         '#', 'admin', sysdate(), '', null, '');
-- 参数设置按钮
insert into sys_menu values('1030', '参数查询', '604', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1031', '参数新增', '604', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1032', '参数修改', '604', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1033', '参数删除', '604', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1034', '参数导出', '604', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export',       '#', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 6、用户和角色关联表  用户N-1角色
-- ----------------------------
drop table if exists sys_user_role;
create table sys_user_role (
  user_id   bigint(20) not null comment '用户ID',
  role_id   bigint(20) not null comment '角色ID',
  primary key(user_id, role_id)
) engine=innodb comment = '用户和角色关联表';

-- ----------------------------
-- 初始化-用户和角色关联表数据
-- ----------------------------
insert into sys_user_role values ('1', '1');
insert into sys_user_role values ('2', '2');


-- ----------------------------
-- 7、角色和菜单关联表  角色1-N菜单
-- ----------------------------
drop table if exists sys_role_menu;
create table sys_role_menu (
  role_id   bigint(20) not null comment '角色ID',
  menu_id   bigint(20) not null comment '菜单ID',
  primary key(role_id, menu_id)
) engine=innodb comment = '角色和菜单关联表';

-- ----------------------------
-- 初始化-角色和菜单关联表数据
-- ----------------------------
insert into sys_role_menu values ('2', '1');
insert into sys_role_menu values ('2', '2');
insert into sys_role_menu values ('2', '3');
insert into sys_role_menu values ('2', '4');
insert into sys_role_menu values ('2', '5');
insert into sys_role_menu values ('2', '6');
insert into sys_role_menu values ('2', '100');
insert into sys_role_menu values ('2', '200');
insert into sys_role_menu values ('2', '201');
insert into sys_role_menu values ('2', '202');
insert into sys_role_menu values ('2', '300');
insert into sys_role_menu values ('2', '301');
insert into sys_role_menu values ('2', '400');
insert into sys_role_menu values ('2', '401');
insert into sys_role_menu values ('2', '402');
insert into sys_role_menu values ('2', '500');
insert into sys_role_menu values ('2', '501');
insert into sys_role_menu values ('2', '502');
insert into sys_role_menu values ('2', '600');
insert into sys_role_menu values ('2', '601');
insert into sys_role_menu values ('2', '602');
insert into sys_role_menu values ('2', '603');
insert into sys_role_menu values ('2', '604');
insert into sys_role_menu values ('2', '1000');
insert into sys_role_menu values ('2', '1001');
insert into sys_role_menu values ('2', '1002');
insert into sys_role_menu values ('2', '1003');
insert into sys_role_menu values ('2', '1004');
insert into sys_role_menu values ('2', '1005');
insert into sys_role_menu values ('2', '1006');
insert into sys_role_menu values ('2', '1007');
insert into sys_role_menu values ('2', '1008');
insert into sys_role_menu values ('2', '1009');
insert into sys_role_menu values ('2', '1010');
insert into sys_role_menu values ('2', '1011');
insert into sys_role_menu values ('2', '1012');
insert into sys_role_menu values ('2', '1013');
insert into sys_role_menu values ('2', '1014');
insert into sys_role_menu values ('2', '1015');
insert into sys_role_menu values ('2', '1016');
insert into sys_role_menu values ('2', '1017');
insert into sys_role_menu values ('2', '1018');
insert into sys_role_menu values ('2', '1019');
insert into sys_role_menu values ('2', '1020');
insert into sys_role_menu values ('2', '1021');
insert into sys_role_menu values ('2', '1022');
insert into sys_role_menu values ('2', '1023');
insert into sys_role_menu values ('2', '1024');
insert into sys_role_menu values ('2', '1025');
insert into sys_role_menu values ('2', '1026');
insert into sys_role_menu values ('2', '1027');
insert into sys_role_menu values ('2', '1028');
insert into sys_role_menu values ('2', '1029');
insert into sys_role_menu values ('2', '1030');
insert into sys_role_menu values ('2', '1031');
insert into sys_role_menu values ('2', '1032');
insert into sys_role_menu values ('2', '1033');
insert into sys_role_menu values ('2', '1034');
insert into sys_role_menu values ('2', '1035');
insert into sys_role_menu values ('2', '1036');
insert into sys_role_menu values ('2', '1037');
insert into sys_role_menu values ('2', '1038');
insert into sys_role_menu values ('2', '1100');
insert into sys_role_menu values ('2', '1101');
insert into sys_role_menu values ('2', '1102');
insert into sys_role_menu values ('2', '1103');
insert into sys_role_menu values ('2', '1104');
insert into sys_role_menu values ('2', '1105');
insert into sys_role_menu values ('2', '1106');
insert into sys_role_menu values ('2', '1107');
insert into sys_role_menu values ('2', '1108');
insert into sys_role_menu values ('2', '1109');
insert into sys_role_menu values ('2', '1110');
insert into sys_role_menu values ('2', '1111');
insert into sys_role_menu values ('2', '1112');
insert into sys_role_menu values ('2', '1113');
insert into sys_role_menu values ('2', '1114');
insert into sys_role_menu values ('2', '7');
insert into sys_role_menu values ('2', '700');
insert into sys_role_menu values ('2', '701');

-- ----------------------------
-- 8、角色和部门关联表  角色1-N部门
-- ----------------------------
drop table if exists sys_role_dept;
create table sys_role_dept (
  role_id   bigint(20) not null comment '角色ID',
  dept_id   bigint(20) not null comment '部门ID',
  primary key(role_id, dept_id)
) engine=innodb comment = '角色和部门关联表';

-- ----------------------------
-- 初始化-角色和部门关联表数据
-- ----------------------------
insert into sys_role_dept values ('2', '100');
insert into sys_role_dept values ('2', '101');
insert into sys_role_dept values ('2', '105');


-- ----------------------------
-- 9、用户与岗位关联表  用户1-N岗位
-- ----------------------------
drop table if exists sys_user_post;
create table sys_user_post
(
  user_id   bigint(20) not null comment '用户ID',
  post_id   bigint(20) not null comment '岗位ID',
  primary key (user_id, post_id)
) engine=innodb comment = '用户与岗位关联表';

-- ----------------------------
-- 初始化-用户与岗位关联表数据
-- ----------------------------
insert into sys_user_post values ('1', '1');
insert into sys_user_post values ('2', '2');


-- ----------------------------
-- 10、操作日志记录
-- ----------------------------
drop table if exists sys_oper_log;
create table sys_oper_log (
  oper_id           bigint(20)      not null auto_increment    comment '日志主键',
  title             varchar(50)     default ''                 comment '模块标题',
  business_type     int(2)          default 0                  comment '业务类型（0其它 1新增 2修改 3删除）',
  method            varchar(200)    default ''                 comment '方法名称',
  request_method    varchar(10)     default ''                 comment '请求方式',
  operator_type     int(1)          default 0                  comment '操作类别（0其它 1后台用户 2手机端用户）',
  oper_name         varchar(50)     default ''                 comment '操作人员',
  dept_name         varchar(50)     default ''                 comment '部门名称',
  oper_url          varchar(255)    default ''                 comment '请求URL',
  oper_ip           varchar(128)    default ''                 comment '主机地址',
  oper_location     varchar(255)    default ''                 comment '操作地点',
  oper_param        varchar(2000)   default ''                 comment '请求参数',
  json_result       varchar(2000)   default ''                 comment '返回参数',
  status            int(1)          default 0                  comment '操作状态（0正常 1异常）',
  error_msg         varchar(2000)   default ''                 comment '错误消息',
  oper_time         datetime                                   comment '操作时间',
  cost_time         bigint(20)      default 0                  comment '消耗时间',
  primary key (oper_id),
  key idx_sys_oper_log_bt (business_type),
  key idx_sys_oper_log_s  (status),
  key idx_sys_oper_log_ot (oper_time)
) engine=innodb auto_increment=100 comment = '操作日志记录';


-- ----------------------------
-- 11、字典类型表
-- ----------------------------
drop table if exists sys_dict_type;
create table sys_dict_type
(
  dict_id          bigint(20)      not null auto_increment    comment '字典主键',
  dict_name        varchar(100)    default ''                 comment '字典名称',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  status           char(1)         default '0'                comment '状态（0正常 1停用）',
  create_by        varchar(64)     default ''                 comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        varchar(64)     default ''                 comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_id),
  unique (dict_type)
) engine=innodb auto_increment=100 comment = '字典类型表';

insert into sys_dict_type values(1,  '用户性别', 'sys_user_sex',        '0', 'admin', sysdate(), '', null, '用户性别列表');
insert into sys_dict_type values(2,  '菜单状态', 'sys_show_hide',       '0', 'admin', sysdate(), '', null, '菜单状态列表');
insert into sys_dict_type values(3,  '系统开关', 'sys_normal_disable',  '0', 'admin', sysdate(), '', null, '系统开关列表');
insert into sys_dict_type values(4,  '任务状态', 'sys_job_status',      '0', 'admin', sysdate(), '', null, '任务状态列表');
insert into sys_dict_type values(5,  '任务分组', 'sys_job_group',       '0', 'admin', sysdate(), '', null, '任务分组列表');
insert into sys_dict_type values(6,  '系统是否', 'sys_yes_no',          '0', 'admin', sysdate(), '', null, '系统是否列表');
insert into sys_dict_type values(7,  '通知类型', 'sys_notice_type',     '0', 'admin', sysdate(), '', null, '通知类型列表');
insert into sys_dict_type values(8,  '通知状态', 'sys_notice_status',   '0', 'admin', sysdate(), '', null, '通知状态列表');
insert into sys_dict_type values(9,  '操作类型', 'sys_oper_type',       '0', 'admin', sysdate(), '', null, '操作类型列表');
insert into sys_dict_type values(10, '系统状态', 'sys_common_status',   '0', 'admin', sysdate(), '', null, '登录状态列表');


-- ----------------------------
-- 12、字典数据表
-- ----------------------------
drop table if exists sys_dict_data;
create table sys_dict_data
(
  dict_code        bigint(20)      not null auto_increment    comment '字典编码',
  dict_sort        int(4)          default 0                  comment '字典排序',
  dict_label       varchar(100)    default ''                 comment '字典标签',
  dict_value       varchar(100)    default ''                 comment '字典键值',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  css_class        varchar(100)    default null               comment '样式属性（其他样式扩展）',
  list_class       varchar(100)    default null               comment '表格回显样式',
  is_default       char(1)         default 'N'                comment '是否默认（Y是 N否）',
  status           char(1)         default '0'                comment '状态（0正常 1停用）',
  create_by        varchar(64)     default ''                 comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        varchar(64)     default ''                 comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_code)
) engine=innodb auto_increment=100 comment = '字典数据表';

insert into sys_dict_data values(1,  1,  '男',       '0',       'sys_user_sex',        '',   '',        'Y', '0', 'admin', sysdate(), '', null, '性别男');
insert into sys_dict_data values(2,  2,  '女',       '1',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别女');
insert into sys_dict_data values(3,  3,  '未知',     '2',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别未知');
insert into sys_dict_data values(4,  1,  '显示',     '0',       'sys_show_hide',       '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '显示菜单');
insert into sys_dict_data values(5,  2,  '隐藏',     '1',       'sys_show_hide',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '隐藏菜单');
insert into sys_dict_data values(6,  1,  '正常',     '0',       'sys_normal_disable',  '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(7,  2,  '停用',     '1',       'sys_normal_disable',  '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(8,  1,  '正常',     '0',       'sys_job_status',      '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(9,  2,  '暂停',     '1',       'sys_job_status',      '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(10, 1,  '默认',     'DEFAULT', 'sys_job_group',       '',   '',        'Y', '0', 'admin', sysdate(), '', null, '默认分组');
insert into sys_dict_data values(11, 2,  '系统',     'SYSTEM',  'sys_job_group',       '',   '',        'N', '0', 'admin', sysdate(), '', null, '系统分组');
insert into sys_dict_data values(12, 1,  '是',       'Y',       'sys_yes_no',          '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '系统默认是');
insert into sys_dict_data values(13, 2,  '否',       'N',       'sys_yes_no',          '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '系统默认否');
insert into sys_dict_data values(14, 1,  '通知',     '1',       'sys_notice_type',     '',   'warning', 'Y', '0', 'admin', sysdate(), '', null, '通知');
insert into sys_dict_data values(15, 2,  '公告',     '2',       'sys_notice_type',     '',   'success', 'N', '0', 'admin', sysdate(), '', null, '公告');
insert into sys_dict_data values(16, 1,  '正常',     '0',       'sys_notice_status',   '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(17, 2,  '关闭',     '1',       'sys_notice_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '关闭状态');
insert into sys_dict_data values(18, 99, '其他',     '0',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '其他操作');
insert into sys_dict_data values(19, 1,  '新增',     '1',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '新增操作');
insert into sys_dict_data values(20, 2,  '修改',     '2',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '修改操作');
insert into sys_dict_data values(21, 3,  '删除',     '3',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '删除操作');
insert into sys_dict_data values(22, 4,  '授权',     '4',       'sys_oper_type',       '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '授权操作');
insert into sys_dict_data values(23, 5,  '导出',     '5',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导出操作');
insert into sys_dict_data values(24, 6,  '导入',     '6',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导入操作');
insert into sys_dict_data values(25, 7,  '强退',     '7',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '强退操作');
insert into sys_dict_data values(26, 8,  '生成代码', '8',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '生成操作');
insert into sys_dict_data values(27, 9,  '清空数据', '9',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '清空操作');
insert into sys_dict_data values(28, 1,  '成功',     '0',       'sys_common_status',   '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(29, 2,  '失败',     '1',       'sys_common_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');


-- ----------------------------
-- 13、参数配置表
-- ----------------------------
drop table if exists sys_config;
create table sys_config (
  config_id         int(5)          not null auto_increment    comment '参数主键',
  config_name       varchar(100)    default ''                 comment '参数名称',
  config_key        varchar(100)    default ''                 comment '参数键名',
  config_value      varchar(500)    default ''                 comment '参数键值',
  config_type       char(1)         default 'N'                comment '系统内置（Y是 N否）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (config_id)
) engine=innodb auto_increment=100 comment = '参数配置表';

insert into sys_config values(1, '主框架页-默认皮肤样式名称',     'sys.index.skinName',               'skin-blue',     'Y', 'admin', sysdate(), '', null, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow' );
insert into sys_config values(2, '用户管理-账号初始密码',         'sys.user.initPassword',            '123456',        'Y', 'admin', sysdate(), '', null, '初始化密码 123456' );
insert into sys_config values(3, '主框架页-侧边栏主题',           'sys.index.sideTheme',              'theme-dark',    'Y', 'admin', sysdate(), '', null, '深色主题theme-dark，浅色主题theme-light' );
insert into sys_config values(4, '账号自助-是否开启用户注册功能', 'sys.account.registerUser',         'false',         'Y', 'admin', sysdate(), '', null, '是否开启注册用户功能（true开启，false关闭）');
insert into sys_config values(5, '用户登录-黑名单列表',           'sys.login.blackIPList',            '',              'Y', 'admin', sysdate(), '', null, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
insert into sys_config values(6, '用户管理-初始密码修改策略',     'sys.account.initPasswordModify',   '1',             'Y', 'admin', sysdate(), '', null, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
insert into sys_config values(7, '用户管理-账号密码更新周期',     'sys.account.passwordValidateDays', '0',             'Y', 'admin', sysdate(), '', null, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');


-- ----------------------------
-- 14、系统访问记录
-- ----------------------------
drop table if exists sys_logininfor;
create table sys_logininfor (
  info_id        bigint(20)     not null auto_increment   comment '访问ID',
  user_name      varchar(50)    default ''                comment '用户账号',
  ipaddr         varchar(128)   default ''                comment '登录IP地址',
  status         char(1)        default '0'               comment '登录状态（0成功 1失败）',
  msg            varchar(255)   default ''                comment '提示信息',
  access_time    datetime                                 comment '访问时间',
  primary key (info_id),
  key idx_sys_logininfor_s  (status),
  key idx_sys_logininfor_lt (access_time)
) engine=innodb auto_increment=100 comment = '系统访问记录';


-- ----------------------------
-- 15、定时任务调度表
-- ----------------------------
drop table if exists sys_job;
create table sys_job (
  job_id              bigint(20)    not null auto_increment    comment '任务ID',
  job_name            varchar(64)   default ''                 comment '任务名称',
  job_group           varchar(64)   default 'DEFAULT'          comment '任务组名',
  invoke_target       varchar(500)  not null                   comment '调用目标字符串',
  cron_expression     varchar(255)  default ''                 comment 'cron执行表达式',
  misfire_policy      varchar(20)   default '3'                comment '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  concurrent          char(1)       default '1'                comment '是否并发执行（0允许 1禁止）',
  status              char(1)       default '0'                comment '状态（0正常 1暂停）',
  create_by           varchar(64)   default ''                 comment '创建者',
  create_time         datetime                                 comment '创建时间',
  update_by           varchar(64)   default ''                 comment '更新者',
  update_time         datetime                                 comment '更新时间',
  remark              varchar(500)  default ''                 comment '备注信息',
  primary key (job_id, job_name, job_group)
) engine=innodb auto_increment=100 comment = '定时任务调度表';

insert into sys_job values(1, '系统默认（无参）', 'DEFAULT', 'hospitalTask.hospitalNoParams',        '0/10 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(2, '系统默认（有参）', 'DEFAULT', 'hospitalTask.hospitalParams(\'hospital\')',  '0/15 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(3, '系统默认（多参）', 'DEFAULT', 'hospitalTask.hospitalMultipleParams(\'hospital\', true, 2000L, 316.50D, 100)',  '0/20 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 16、定时任务调度日志表
-- ----------------------------
drop table if exists sys_job_log;
create table sys_job_log (
  job_log_id          bigint(20)     not null auto_increment    comment '任务日志ID',
  job_name            varchar(64)    not null                   comment '任务名称',
  job_group           varchar(64)    not null                   comment '任务组名',
  invoke_target       varchar(500)   not null                   comment '调用目标字符串',
  job_message         varchar(500)                              comment '日志信息',
  status              char(1)        default '0'                comment '执行状态（0正常 1失败）',
  exception_info      varchar(2000)  default ''                 comment '异常信息',
  create_time         datetime                                  comment '创建时间',
  primary key (job_log_id)
) engine=innodb comment = '定时任务调度日志表';


-- ----------------------------
-- 17、通知公告表
-- ----------------------------
drop table if exists sys_notice;
create table sys_notice (
  notice_id         int(4)          not null auto_increment    comment '公告ID',
  notice_title      varchar(50)     not null                   comment '公告标题',
  notice_type       char(1)         not null                   comment '公告类型（1通知 2公告）',
  notice_content    longblob        default null               comment '公告内容',
  status            char(1)         default '0'                comment '公告状态（0正常 1关闭）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(255)    default null               comment '备注',
  primary key (notice_id)
) engine=innodb auto_increment=10 comment = '通知公告表';

-- ----------------------------
-- 初始化-公告信息表数据
-- ----------------------------
insert into sys_notice values('1', '通知：hospital-oa-system 初始化完成', '2', 'hospital-oa-system 初始化数据已导入，可开始进行医院协同办公平台功能改造。', '0', 'admin', sysdate(), '', null, '系统管理员');
insert into sys_notice values('2', '维护通知：hospital-oa-system 数据维护窗口', '1', '系统将按计划执行初始化后的数据维护与功能配置，请相关人员提前做好准备。',   '0', 'admin', sysdate(), '', null, '系统管理员');


-- ----------------------------
-- 18、代码生成业务表
-- ----------------------------
drop table if exists gen_table;
create table gen_table (
  table_id          bigint(20)      not null auto_increment    comment '编号',
  table_name        varchar(200)    default ''                 comment '表名称',
  table_comment     varchar(500)    default ''                 comment '表描述',
  sub_table_name    varchar(64)     default null               comment '关联子表的表名',
  sub_table_fk_name varchar(64)     default null               comment '子表关联的外键名',
  class_name        varchar(100)    default ''                 comment '实体类名称',
  tpl_category      varchar(200)    default 'crud'             comment '使用的模板（crud单表操作 tree树表操作）',
  tpl_web_type      varchar(30)     default ''                 comment '前端模板类型（element-ui模版 element-plus模版）',
  package_name      varchar(100)                               comment '生成包路径',
  module_name       varchar(30)                                comment '生成模块名',
  business_name     varchar(30)                                comment '生成业务名',
  function_name     varchar(50)                                comment '生成功能名',
  function_author   varchar(50)                                comment '生成功能作者',
  gen_type          char(1)         default '0'                comment '生成代码方式（0zip压缩包 1自定义路径）',
  gen_path          varchar(200)    default '/'                comment '生成路径（不填默认项目路径）',
  options           varchar(1000)                              comment '其它生成选项',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (table_id)
) engine=innodb auto_increment=1 comment = '代码生成业务表';


-- ----------------------------
-- 19、代码生成业务表字段
-- ----------------------------
drop table if exists gen_table_column;
create table gen_table_column (
  column_id         bigint(20)      not null auto_increment    comment '编号',
  table_id          bigint(20)                                 comment '归属表编号',
  column_name       varchar(200)                               comment '列名称',
  column_comment    varchar(500)                               comment '列描述',
  column_type       varchar(100)                               comment '列类型',
  java_type         varchar(500)                               comment 'JAVA类型',
  java_field        varchar(200)                               comment 'JAVA字段名',
  is_pk             char(1)                                    comment '是否主键（1是）',
  is_increment      char(1)                                    comment '是否自增（1是）',
  is_required       char(1)                                    comment '是否必填（1是）',
  is_insert         char(1)                                    comment '是否为插入字段（1是）',
  is_edit           char(1)                                    comment '是否编辑字段（1是）',
  is_list           char(1)                                    comment '是否列表字段（1是）',
  is_query          char(1)                                    comment '是否查询字段（1是）',
  query_type        varchar(200)    default 'EQ'               comment '查询方式（等于、不等于、大于、小于、范围）',
  html_type         varchar(200)                               comment '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  dict_type         varchar(200)    default ''                 comment '字典类型',
  sort              int                                        comment '排序',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (column_id)
) engine=innodb auto_increment=1 comment = '代码生成业务表字段';


-- =============================================================
-- PART 2: Quartz 调度器表 (10_quartz_schema.sql)
-- =============================================================

-- Quartz bootstrap for hospital-cloud.
-- Purpose: initialize Quartz scheduler tables used by hospital-job.
-- Notes: run after core schema; only needed when scheduler/job module is enabled.


DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_SIMPROP_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;

-- ----------------------------
-- 1、存储每一个已配置的 jobDetail 的详细信息
-- ----------------------------
create table QRTZ_JOB_DETAILS (
    sched_name           varchar(120)    not null            comment '调度名称',
    job_name             varchar(200)    not null            comment '任务名称',
    job_group            varchar(200)    not null            comment '任务组名',
    description          varchar(250)    null                comment '相关介绍',
    job_class_name       varchar(250)    not null            comment '执行任务类名称',
    is_durable           varchar(1)      not null            comment '是否持久化',
    is_nonconcurrent     varchar(1)      not null            comment '是否并发',
    is_update_data       varchar(1)      not null            comment '是否更新数据',
    requests_recovery    varchar(1)      not null            comment '是否接受恢复执行',
    job_data             blob            null                comment '存放持久化job对象',
    primary key (sched_name, job_name, job_group)
) engine=innodb comment = '任务详细信息表';

-- ----------------------------
-- 2、 存储已配置的 Trigger 的信息
-- ----------------------------
create table QRTZ_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment '触发器的名字',
    trigger_group        varchar(200)    not null            comment '触发器所属组的名字',
    job_name             varchar(200)    not null            comment 'qrtz_job_details表job_name的外键',
    job_group            varchar(200)    not null            comment 'qrtz_job_details表job_group的外键',
    description          varchar(250)    null                comment '相关介绍',
    next_fire_time       bigint(13)      null                comment '上一次触发时间（毫秒）',
    prev_fire_time       bigint(13)      null                comment '下一次触发时间（默认为-1表示不触发）',
    priority             integer         null                comment '优先级',
    trigger_state        varchar(16)     not null            comment '触发器状态',
    trigger_type         varchar(8)      not null            comment '触发器的类型',
    start_time           bigint(13)      not null            comment '开始时间',
    end_time             bigint(13)      null                comment '结束时间',
    calendar_name        varchar(200)    null                comment '日程表名称',
    misfire_instr        smallint(2)     null                comment '补偿执行的策略',
    job_data             blob            null                comment '存放持久化job对象',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, job_name, job_group) references QRTZ_JOB_DETAILS(sched_name, job_name, job_group)
) engine=innodb comment = '触发器详细信息表';

-- ----------------------------
-- 3、 存储简单的 Trigger，包括重复次数，间隔，以及已触发的次数
-- ----------------------------
create table QRTZ_SIMPLE_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    repeat_count         bigint(7)       not null            comment '重复的次数统计',
    repeat_interval      bigint(12)      not null            comment '重复的间隔时间',
    times_triggered      bigint(10)      not null            comment '已经触发的次数',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = '简单触发器的信息表';

-- ----------------------------
-- 4、 存储 Cron Trigger，包括 Cron 表达式和时区信息
-- ---------------------------- 
create table QRTZ_CRON_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    cron_expression      varchar(200)    not null            comment 'cron表达式',
    time_zone_id         varchar(80)                         comment '时区',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = 'Cron类型的触发器表';

-- ----------------------------
-- 5、 Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型，JobStore 并不知道如何存储实例的时候)
-- ---------------------------- 
create table QRTZ_BLOB_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    blob_data            blob            null                comment '存放持久化Trigger对象',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = 'Blob类型的触发器表';

-- ----------------------------
-- 6、 以 Blob 类型存储存放日历信息， quartz可配置一个日历来指定一个时间范围
-- ---------------------------- 
create table QRTZ_CALENDARS (
    sched_name           varchar(120)    not null            comment '调度名称',
    calendar_name        varchar(200)    not null            comment '日历名称',
    calendar             blob            not null            comment '存放持久化calendar对象',
    primary key (sched_name, calendar_name)
) engine=innodb comment = '日历信息表';

-- ----------------------------
-- 7、 存储已暂停的 Trigger 组的信息
-- ---------------------------- 
create table QRTZ_PAUSED_TRIGGER_GRPS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    primary key (sched_name, trigger_group)
) engine=innodb comment = '暂停的触发器表';

-- ----------------------------
-- 8、 存储与已触发的 Trigger 相关的状态信息，以及相联 Job 的执行信息
-- ---------------------------- 
create table QRTZ_FIRED_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    entry_id             varchar(95)     not null            comment '调度器实例id',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    instance_name        varchar(200)    not null            comment '调度器实例名',
    fired_time           bigint(13)      not null            comment '触发的时间',
    sched_time           bigint(13)      not null            comment '定时器制定的时间',
    priority             integer         not null            comment '优先级',
    state                varchar(16)     not null            comment '状态',
    job_name             varchar(200)    null                comment '任务名称',
    job_group            varchar(200)    null                comment '任务组名',
    is_nonconcurrent     varchar(1)      null                comment '是否并发',
    requests_recovery    varchar(1)      null                comment '是否接受恢复执行',
    primary key (sched_name, entry_id)
) engine=innodb comment = '已触发的触发器表';

-- ----------------------------
-- 9、 存储少量的有关 Scheduler 的状态信息，假如是用于集群中，可以看到其他的 Scheduler 实例
-- ---------------------------- 
create table QRTZ_SCHEDULER_STATE (
    sched_name           varchar(120)    not null            comment '调度名称',
    instance_name        varchar(200)    not null            comment '实例名称',
    last_checkin_time    bigint(13)      not null            comment '上次检查时间',
    checkin_interval     bigint(13)      not null            comment '检查间隔时间',
    primary key (sched_name, instance_name)
) engine=innodb comment = '调度器状态表';

-- ----------------------------
-- 10、 存储程序的悲观锁的信息(假如使用了悲观锁)
-- ---------------------------- 
create table QRTZ_LOCKS (
    sched_name           varchar(120)    not null            comment '调度名称',
    lock_name            varchar(40)     not null            comment '悲观锁名称',
    primary key (sched_name, lock_name)
) engine=innodb comment = '存储的悲观锁信息表';

-- ----------------------------
-- 11、 Quartz集群实现同步机制的行锁表
-- ---------------------------- 
create table QRTZ_SIMPROP_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    str_prop_1           varchar(512)    null                comment 'String类型的trigger的第一个参数',
    str_prop_2           varchar(512)    null                comment 'String类型的trigger的第二个参数',
    str_prop_3           varchar(512)    null                comment 'String类型的trigger的第三个参数',
    int_prop_1           int             null                comment 'int类型的trigger的第一个参数',
    int_prop_2           int             null                comment 'int类型的trigger的第二个参数',
    long_prop_1          bigint          null                comment 'long类型的trigger的第一个参数',
    long_prop_2          bigint          null                comment 'long类型的trigger的第二个参数',
    dec_prop_1           numeric(13,4)   null                comment 'decimal类型的trigger的第一个参数',
    dec_prop_2           numeric(13,4)   null                comment 'decimal类型的trigger的第二个参数',
    bool_prop_1          varchar(1)      null                comment 'Boolean类型的trigger的第一个参数',
    bool_prop_2          varchar(1)      null                comment 'Boolean类型的trigger的第二个参数',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = '同步机制的行锁表';

commit;


-- =============================================================
-- PART 3: OA 业务运行表 (20_oa_runtime_schema.sql)
-- =============================================================

-- Active OA runtime schema for hospital-cloud.
-- Purpose: initialize only the OA business tables that are currently used by backend/frontend code.
-- Notes: run after 00_core_schema.sql. This file keeps existing table structures unchanged and excludes future/unused schema.




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



-- =============================================================
-- PART 4: OA 演示种子数据 (21_oa_seed_demo.sql)
-- =============================================================

-- Active OA demo seed data for hospital-cloud.
-- Purpose: seed only the OA tables currently used by code for local/demo initialization.
-- Notes: run after 00_core_schema.sql and 20_oa_runtime_schema.sql. Assumes core seed data already created user_id=1 and dept_id=100.




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

insert into oa_document_attachment (attachment_id, document_id, file_name, original_name, content_type, file_size, file_url, mongo_file_id, sort_order, create_by, create_time, update_by, update_time)
values
  (1, 1, 'policy-sample-1.pdf', '医疗质量安全管理制度-附件.pdf', 'application/pdf', 0, '', 'demo-gridfs-file-1', 1, 'admin', sysdate(), '', null),
  (2, 2, 'policy-sample-2.docx', '行政值班交接规范-模板.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 0, '', 'demo-gridfs-file-2', 1, 'admin', sysdate(), '', null);

insert into oa_document_read_log (read_log_id, document_id, user_id, read_status, read_time, confirm_time, create_time)
values
  (1, 1, 1, '0', null, null, sysdate()),
  (2, 2, 1, '1', sysdate(), null, sysdate()),
  (3, 3, 1, '2', sysdate(), sysdate(), sysdate());

insert into oa_meeting_room (room_id, room_name, location, capacity, equipment, status, create_by, create_time, update_by, update_time)
values
  (1, '三楼会议室', '门诊楼三层', 20, '投影、视频会议终端', '0', 'admin', sysdate(), '', null),
  (2, '远程会议室', '行政楼二层', 12, '摄像头、电子白板', '0', 'admin', sysdate(), '', null);

insert into oa_meeting (meeting_id, meeting_title, room_id, organizer_id, organizer_name, start_time, end_time, meeting_status, summary_content, create_by, create_time, update_by, update_time)
values
  (1, '院务协调会', 1, 1, '管理员', date_add(sysdate(), interval 1 hour), date_add(sysdate(), interval 2 hour), 'scheduled', '', 'admin', sysdate(), '', null),
  (2, '信息化建设周例会', 2, 1, '管理员', date_add(sysdate(), interval 3 hour), date_add(sysdate(), interval 4 hour), 'scheduled', '', 'admin', sysdate(), '', null);

insert into oa_task (task_id, task_title, task_type, publisher_id, publisher_name, assignee_id, assignee_name, priority_level, task_status, start_time, due_time, complete_time, content, create_by, create_time, update_by, update_time)
values
  (1, '整改任务跟进', '督办', 1, '管理员', 1, '管理员', 'high', 'pending', sysdate(), date_add(sysdate(), interval 1 day), null, '门诊流程优化任务需在截止前完成跟进。', 'admin', sysdate(), '', null),
  (2, '文档阅读催办', '通知', 1, '管理员', 1, '管理员', 'normal', 'processing', sysdate(), date_add(sysdate(), interval 2 day), null, '制度文档未读人员需要尽快确认。', 'admin', sysdate(), '', null);

insert into oa_task_record (record_id, task_id, operator_id, operator_name, record_type, record_content, create_time)
values
  (1, 1, 1, '管理员', 'create', '创建整改任务并指派责任人。', sysdate()),
  (2, 2, 1, '管理员', 'follow', '已发送制度文档提醒。', sysdate());

insert into oa_schedule (schedule_id, schedule_title, owner_id, start_time, end_time, remind_time, schedule_type, schedule_status, remark, create_time, update_time)
values
  (1, '门诊排班提醒', 1, date_add(sysdate(), interval 30 minute), date_add(sysdate(), interval 90 minute), date_add(sysdate(), interval 20 minute), '值班', 'pending', '请提前确认门诊排班。', sysdate(), null),
  (2, '周例会材料准备', 1, date_add(sysdate(), interval 5 hour), date_add(sysdate(), interval 6 hour), date_add(sysdate(), interval 4 hour), '会议', 'completed', '会议材料已整理完成。', sysdate(), sysdate());

insert into oa_staff_profile (profile_id, user_id, staff_no, job_title, office_phone, emergency_phone, campus_name, duty_name, specialty, create_time, update_time)
values
  (1, 1, 'HK-0001', '信息科工程师', '0759-8001001', '13800000001', '河口院区', '系统管理员', '医院信息化', sysdate(), null);

insert into oa_department_ext (ext_id, dept_id, dept_type, campus_name, office_location, service_phone, create_time, update_time)
values
  (1, 100, '行政职能', '河口院区', '行政楼三层', '0759-8002001', sysdate(), null);

insert into oa_contact_group (group_id, group_name, owner_id, member_ids, remark, create_time, update_time)
values
  (1, '行政联络组', 1, '1', '默认联系人分组', sysdate(), null);

insert into oa_patient (patient_id, patient_no, patient_name, gender, id_card_no, phone_no, birthday, dept_id, dept_name, attending_doctor_id, attending_doctor_name, inpatient_no, patient_status, admission_time, discharge_time, remark, create_by, create_time, update_by, update_time)
values
  (1, 'PT-202603-001', '张秀兰', '1', '440823198803126528', '13812345678', '1988-03-12', 100, '内科', 2, '李医生', 'ZY-0001', 'active', date_sub(sysdate(), interval 3 day), null, '高血压复诊患者', 'admin', sysdate(), '', null),
  (2, 'PT-202603-002', '陈国强', '0', '440823197511083214', '13922334455', '1975-11-08', 101, '外科', 1, '管理员', 'ZY-0002', 'discharged', date_sub(sysdate(), interval 12 day), date_sub(sysdate(), interval 2 day), '术后恢复良好', 'admin', sysdate(), '', null),
  (3, 'PT-202603-003', '黄美玲', '1', '440823199410216842', '13755667788', '1994-10-21', 105, '儿科', 2, '李医生', 'ZY-0003', 'observation', date_sub(sysdate(), interval 1 day), null, '留观中', 'admin', sysdate(), '', null);

insert into oa_patient_case (case_id, patient_id, case_no, case_title, visit_type, case_status, diagnosis, chief_complaint, treatment_plan, doctor_id, doctor_name, dept_id, dept_name, visit_time, discharge_time, create_by, create_time, update_by, update_time)
values
  (1, 1, 'CASE-202603-001', '高血压随访病例', 'outpatient', 'review', '原发性高血压', '头晕、血压波动', '继续口服降压药并监测血压', 2, '李医生', 100, '内科', date_sub(sysdate(), interval 2 day), null, 'admin', sysdate(), '', null),
  (2, 1, 'CASE-202603-002', '内科住院观察', 'inpatient', 'active', '高血压合并心悸', '夜间心悸伴血压升高', '完善心电图及动态血压监测', 2, '李医生', 100, '内科', date_sub(sysdate(), interval 1 day), null, 'admin', sysdate(), '', null),
  (3, 2, 'CASE-202603-003', '阑尾术后复查', 'inpatient', 'closed', '急性阑尾炎术后', '伤口复查', '继续换药，三日后门诊复查', 1, '管理员', 101, '外科', date_sub(sysdate(), interval 10 day), date_sub(sysdate(), interval 2 day), 'admin', sysdate(), '', null),
  (4, 3, 'CASE-202603-004', '发热留观记录', 'emergency', 'active', '上呼吸道感染', '发热、咳嗽', '对症退热并观察体温变化', 2, '李医生', 105, '儿科', date_sub(sysdate(), interval 12 hour), null, 'admin', sysdate(), '', null);

insert into oa_patient_access_log (access_log_id, patient_id, case_id, access_type, operator_id, operator_name, dept_id, dept_name, access_time, access_ip, remark)
values
  (1, 1, null, 'patient_detail', 1, '管理员', 100, '内科', sysdate(), '127.0.0.1', '初始化演示患者详情访问日志'),
  (2, 1, 2, 'case_detail', 1, '管理员', 100, '内科', sysdate(), '127.0.0.1', '初始化演示病例详情访问日志');

