package com.hospitaloa.oa.collab.reminder.mapper;

import com.hospitaloa.oa.collab.reminder.domain.OaReminder;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaReminderMapper
{
    List<OaReminder> selectUnreadReminderList(@Param("userId") Long userId, @Param("limit") Integer limit);

    int selectUnreadReminderCount(@Param("userId") Long userId);

    int markReminderRead(@Param("reminderId") Long reminderId, @Param("userId") Long userId);

    int markAllRemindersRead(@Param("userId") Long userId);

    int insertDueScheduleReminders();

    int insertDueMeetingReminders();
}
