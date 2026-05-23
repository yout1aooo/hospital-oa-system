package com.hospitaloa.oa.collab.reminder.service;

import com.hospitaloa.oa.collab.reminder.domain.OaReminder;
import java.util.List;

public interface IOaReminderService
{
    List<OaReminder> selectUnreadReminders(Integer limit);

    int selectUnreadCount();

    int markReminderRead(Long reminderId);

    int markAllRemindersRead();

    int scanDueReminders();
}
