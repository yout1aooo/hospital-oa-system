package com.hospitaloa.oa.collab.meeting.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;

public class OaMeeting extends BaseEntity
{
    private Long meetingId;
    private String meetingTitle;
    private Long roomId;
    private String roomName;
    private Long organizerId;
    private String organizerName;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;
    private String meetingStatus;
    private String meetingStatusLabel;
    private String summaryContent;

    public Long getMeetingId() { return meetingId; }
    public void setMeetingId(Long meetingId) { this.meetingId = meetingId; }
    public String getMeetingTitle() { return meetingTitle; }
    public void setMeetingTitle(String meetingTitle) { this.meetingTitle = meetingTitle; }
    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }
    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }
    public Long getOrganizerId() { return organizerId; }
    public void setOrganizerId(Long organizerId) { this.organizerId = organizerId; }
    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public String getMeetingStatus() { return meetingStatus; }
    public void setMeetingStatus(String meetingStatus) { this.meetingStatus = meetingStatus; }
    public String getMeetingStatusLabel() { return meetingStatusLabel; }
    public void setMeetingStatusLabel(String meetingStatusLabel) { this.meetingStatusLabel = meetingStatusLabel; }
    public String getSummaryContent() { return summaryContent; }
    public void setSummaryContent(String summaryContent) { this.summaryContent = summaryContent; }
}
