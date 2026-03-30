package com.hospitaloa.oa.collab.schedule.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;

public class OaSchedule extends BaseEntity
{
    private Long scheduleId;
    private String scheduleTitle;
    private Long ownerId;
    private String ownerName;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date remindTime;
    private String scheduleType;
    private String scheduleStatus;
    private String scheduleStatusLabel;
    private String remark;

    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public String getScheduleTitle() { return scheduleTitle; }
    public void setScheduleTitle(String scheduleTitle) { this.scheduleTitle = scheduleTitle; }
    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public Date getRemindTime() { return remindTime; }
    public void setRemindTime(Date remindTime) { this.remindTime = remindTime; }
    public String getScheduleType() { return scheduleType; }
    public void setScheduleType(String scheduleType) { this.scheduleType = scheduleType; }
    public String getScheduleStatus() { return scheduleStatus; }
    public void setScheduleStatus(String scheduleStatus) { this.scheduleStatus = scheduleStatus; }
    public String getScheduleStatusLabel() { return scheduleStatusLabel; }
    public void setScheduleStatusLabel(String scheduleStatusLabel) { this.scheduleStatusLabel = scheduleStatusLabel; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
