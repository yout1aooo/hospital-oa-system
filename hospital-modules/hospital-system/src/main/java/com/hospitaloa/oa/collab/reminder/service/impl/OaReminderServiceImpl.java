package com.hospitaloa.oa.collab.reminder.service.impl;

import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.collab.reminder.domain.OaReminder;
import com.hospitaloa.oa.collab.reminder.mapper.OaReminderMapper;
import com.hospitaloa.oa.collab.reminder.service.IOaReminderService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OaReminderServiceImpl implements IOaReminderService
{
    private static final int DEFAULT_LIMIT = 10;
    private static final int MAX_LIMIT = 50;

    @Autowired
    private OaReminderMapper reminderMapper;

    @Override
    public List<OaReminder> selectUnreadReminders(Integer limit)
    {
        int pageSize = limit == null ? DEFAULT_LIMIT : Math.max(1, Math.min(limit, MAX_LIMIT));
        return reminderMapper.selectUnreadReminderList(SecurityUtils.getUserId(), pageSize);
    }

    @Override
    public int selectUnreadCount()
    {
        return reminderMapper.selectUnreadReminderCount(SecurityUtils.getUserId());
    }

    @Override
    public int markReminderRead(Long reminderId)
    {
        return reminderMapper.markReminderRead(reminderId, SecurityUtils.getUserId());
    }

    @Override
    public int markAllRemindersRead()
    {
        return reminderMapper.markAllRemindersRead(SecurityUtils.getUserId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int scanDueReminders()
    {
        return reminderMapper.insertDueScheduleReminders() + reminderMapper.insertDueMeetingReminders();
    }
}
