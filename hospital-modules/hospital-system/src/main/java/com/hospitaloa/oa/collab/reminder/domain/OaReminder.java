package com.hospitaloa.oa.collab.reminder.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;

public class OaReminder extends BaseEntity
{
    private Long reminderId;
    private Long userId;
    private String sourceType;
    private Long sourceId;
    private String reminderTitle;
    private String reminderContent;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date remindTime;
    private String readStatus;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date readTime;

    public Long getReminderId() { return reminderId; }
    public void setReminderId(Long reminderId) { this.reminderId = reminderId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getSourceType() { return sourceType; }
    public void setSourceType(String sourceType) { this.sourceType = sourceType; }
    public Long getSourceId() { return sourceId; }
    public void setSourceId(Long sourceId) { this.sourceId = sourceId; }
    public String getReminderTitle() { return reminderTitle; }
    public void setReminderTitle(String reminderTitle) { this.reminderTitle = reminderTitle; }
    public String getReminderContent() { return reminderContent; }
    public void setReminderContent(String reminderContent) { this.reminderContent = reminderContent; }
    public Date getRemindTime() { return remindTime; }
    public void setRemindTime(Date remindTime) { this.remindTime = remindTime; }
    public String getReadStatus() { return readStatus; }
    public void setReadStatus(String readStatus) { this.readStatus = readStatus; }
    public Date getReadTime() { return readTime; }
    public void setReadTime(Date readTime) { this.readTime = readTime; }
}
