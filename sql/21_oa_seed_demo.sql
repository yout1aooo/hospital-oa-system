-- Active OA demo seed data for hospital-cloud.
-- Purpose: seed only the OA tables currently used by code for local/demo initialization.
-- Notes: run after 00_core_schema.sql and 20_oa_runtime_schema.sql. Assumes core seed data already created user_id=1 and dept_id=100.

SET NAMES utf8mb4;

USE `hospital-cloud`;

SET FOREIGN_KEY_CHECKS = 0;

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

SET FOREIGN_KEY_CHECKS = 1;
