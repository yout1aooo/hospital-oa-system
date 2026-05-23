-- 患者/病例报表导出权限补丁
-- 适用于已经导入过基础菜单的现有数据库；全量初始化脚本已内置同样权限。

insert into sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
select 1115, '患者导出', 700, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:patient:export', '#',
       'admin', sysdate(), '', null, ''
where not exists (select 1 from sys_menu where menu_id = 1115);

insert into sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
select 1116, '病例导出', 701, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'oa:patient:case:export', '#',
       'admin', sysdate(), '', null, ''
where not exists (select 1 from sys_menu where menu_id = 1116);

insert into sys_role_menu (role_id, menu_id)
select 2, 1115
where exists (select 1 from sys_role where role_id = 2)
  and not exists (select 1 from sys_role_menu where role_id = 2 and menu_id = 1115);

insert into sys_role_menu (role_id, menu_id)
select 2, 1116
where exists (select 1 from sys_role where role_id = 2)
  and not exists (select 1 from sys_role_menu where role_id = 2 and menu_id = 1116);
