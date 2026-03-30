package com.hospitaloa.oa.collab.schedule.service;

import com.hospitaloa.oa.collab.schedule.domain.OaSchedule;
import java.util.List;
import java.util.Map;

public interface IOaScheduleService
{
    List<OaSchedule> selectScheduleList(String scheduleTitle, String scheduleStatus);

    OaSchedule selectScheduleById(Long scheduleId);

    int insertSchedule(OaSchedule schedule);

    int finishSchedule(Long scheduleId);

    Map<String, Object> getWorkbench();
}
