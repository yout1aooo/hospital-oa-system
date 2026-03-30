package com.hospitaloa.oa.collab.meeting.mapper;

import com.hospitaloa.oa.collab.meeting.domain.OaMeeting;
import com.hospitaloa.oa.collab.meeting.domain.OaMeetingRoom;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaMeetingMapper
{
    List<OaMeeting> selectMeetingList(@Param("meetingTitle") String meetingTitle,
                                      @Param("meetingStatus") String meetingStatus,
                                      @Param("userId") Long userId);

    OaMeeting selectMeetingById(@Param("meetingId") Long meetingId, @Param("userId") Long userId);

    int insertMeeting(OaMeeting meeting);

    int finishMeeting(@Param("meetingId") Long meetingId,
                      @Param("updateBy") String updateBy,
                      @Param("userId") Long userId);

    List<OaMeetingRoom> selectRoomList();
}
