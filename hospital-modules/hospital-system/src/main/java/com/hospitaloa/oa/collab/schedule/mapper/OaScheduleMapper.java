package com.hospitaloa.oa.collab.schedule.mapper;

import com.hospitaloa.oa.collab.schedule.domain.OaSchedule;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaScheduleMapper
{
    List<OaSchedule> selectScheduleList(@Param("scheduleTitle") String scheduleTitle,
                                        @Param("scheduleStatus") String scheduleStatus,
                                        @Param("ownerId") Long ownerId);

    OaSchedule selectScheduleById(@Param("scheduleId") Long scheduleId, @Param("ownerId") Long ownerId);

    int insertSchedule(OaSchedule schedule);

    int finishSchedule(@Param("scheduleId") Long scheduleId,
                       @Param("updateBy") String updateBy,
                       @Param("ownerId") Long ownerId);
}
