package com.hospitaloa.oa.collab.meeting.service.impl;

import com.hospitaloa.common.core.exception.ServiceException;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.collab.meeting.domain.OaMeeting;
import com.hospitaloa.oa.collab.meeting.domain.OaMeetingRoom;
import com.hospitaloa.oa.collab.meeting.mapper.OaMeetingMapper;
import com.hospitaloa.oa.collab.meeting.service.IOaMeetingService;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaMeetingServiceImpl implements IOaMeetingService
{
    @Autowired
    private OaMeetingMapper meetingMapper;

    @Override
    public List<OaMeeting> selectMeetingList(String meetingTitle, String meetingStatus)
    {
        return meetingMapper.selectMeetingList(meetingTitle, meetingStatus, SecurityUtils.getUserId());
    }

    @Override
    public OaMeeting selectMeetingById(Long meetingId)
    {
        return meetingMapper.selectMeetingById(meetingId, SecurityUtils.getUserId());
    }

    @Override
    public int insertMeeting(OaMeeting meeting)
    {
        meeting.setOrganizerId(SecurityUtils.getUserId());
        meeting.setOrganizerName(SecurityUtils.getUsername());
        meeting.setMeetingStatus(resolveMeetingStatus(meeting));
        meeting.setCreateBy(SecurityUtils.getUsername());
        return meetingMapper.insertMeeting(meeting);
    }

    @Override
    public int finishMeeting(Long meetingId)
    {
        OaMeeting meeting = selectMeetingById(meetingId);
        if (meeting == null)
        {
            throw new ServiceException("会议不存在或无权限访问");
        }
        if ("finished".equals(meeting.getMeetingStatus()))
        {
            return 1;
        }
        if (meeting.getEndTime() != null && meeting.getEndTime().after(new Date()))
        {
            throw new ServiceException("会议尚未结束，不能提前完成");
        }
        return meetingMapper.finishMeeting(meetingId, SecurityUtils.getUsername(), SecurityUtils.getUserId());
    }

    @Override
    public List<OaMeetingRoom> selectRoomList()
    {
        return meetingMapper.selectRoomList();
    }

    private String resolveMeetingStatus(OaMeeting meeting)
    {
        if (meeting.getMeetingStatus() != null && !meeting.getMeetingStatus().isEmpty())
        {
            return meeting.getMeetingStatus();
        }
        if (meeting.getEndTime() != null && meeting.getEndTime().before(new Date()))
        {
            return "finished";
        }
        return "scheduled";
    }
}
