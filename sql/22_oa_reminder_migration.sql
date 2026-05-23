-- OA reminder runtime migration.
-- Run this on an existing hospital-cloud database before enabling reminder polling.

create table if not exists oa_reminder (
  reminder_id           bigint(20)      not null auto_increment comment '提醒ID',
  user_id               bigint(20)      not null                comment '接收用户ID',
  source_type           varchar(30)     not null                comment '来源类型（schedule日程 meeting会议）',
  source_id             bigint(20)      not null                comment '来源业务ID',
  reminder_title        varchar(200)    not null                comment '提醒标题',
  reminder_content      varchar(500)    default null            comment '提醒内容',
  remind_time           datetime                                comment '提醒时间',
  read_status           char(1)         default '0'             comment '读取状态（0未读 1已读）',
  read_time             datetime                                comment '读取时间',
  create_time           datetime                                comment '创建时间',
  update_time           datetime                                comment '更新时间',
  primary key (reminder_id),
  unique key uk_oa_reminder_source_user (source_type, source_id, user_id),
  key idx_oa_reminder_user_read (user_id, read_status, remind_time)
) engine=innodb comment='OA个人提醒表';

insert into sys_job (
  job_name, job_group, invoke_target, cron_expression, misfire_policy, concurrent, status,
  create_by, create_time, update_by, update_time, remark
)
select 'OA reminder scan',
       'DEFAULT',
       'oaReminderJobTask.scanDueReminders()',
       '0 0/1 * * * ?',
       '3',
       '1',
       '0',
       'admin',
       sysdate(),
       '',
       null,
       'Scan due schedule and meeting reminders'
where not exists (
  select 1
  from sys_job
  where invoke_target = 'oaReminderJobTask.scanDueReminders()'
);
