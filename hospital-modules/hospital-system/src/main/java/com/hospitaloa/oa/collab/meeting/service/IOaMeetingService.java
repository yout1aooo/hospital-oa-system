package com.hospitaloa.oa.collab.meeting.service;

import com.hospitaloa.oa.collab.meeting.domain.OaMeeting;
import com.hospitaloa.oa.collab.meeting.domain.OaMeetingRoom;
import java.util.List;

public interface IOaMeetingService
{
    List<OaMeeting> selectMeetingList(String meetingTitle, String meetingStatus);

    OaMeeting selectMeetingById(Long meetingId);

    int insertMeeting(OaMeeting meeting);

    int finishMeeting(Long meetingId);

    List<OaMeetingRoom> selectRoomList();
}
