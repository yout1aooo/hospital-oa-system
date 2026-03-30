package com.hospitaloa.oa.collab.schedule.service.impl;

import com.hospitaloa.common.core.exception.ServiceException;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.collab.schedule.domain.OaSchedule;
import com.hospitaloa.oa.collab.schedule.mapper.OaScheduleMapper;
import com.hospitaloa.oa.collab.schedule.service.IOaScheduleService;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaScheduleServiceImpl implements IOaScheduleService
{
    @Autowired
    private OaScheduleMapper scheduleMapper;

    @Override
    public List<OaSchedule> selectScheduleList(String scheduleTitle, String scheduleStatus)
    {
        return scheduleMapper.selectScheduleList(scheduleTitle, scheduleStatus, SecurityUtils.getUserId());
    }

    @Override
    public OaSchedule selectScheduleById(Long scheduleId)
    {
        return scheduleMapper.selectScheduleById(scheduleId, SecurityUtils.getUserId());
    }

    @Override
    public int insertSchedule(OaSchedule schedule)
    {
        schedule.setOwnerId(SecurityUtils.getUserId());
        schedule.setOwnerName(SecurityUtils.getUsername());
        schedule.setScheduleStatus(schedule.getScheduleStatus() == null || schedule.getScheduleStatus().isEmpty() ? "pending" : schedule.getScheduleStatus());
        schedule.setCreateBy(SecurityUtils.getUsername());
        return scheduleMapper.insertSchedule(schedule);
    }

    @Override
    public int finishSchedule(Long scheduleId)
    {
        OaSchedule schedule = selectScheduleById(scheduleId);
        if (schedule == null)
        {
            throw new ServiceException("日程不存在或无权限访问");
        }
        if ("completed".equals(schedule.getScheduleStatus()))
        {
            return 1;
        }
        return scheduleMapper.finishSchedule(scheduleId, SecurityUtils.getUsername(), SecurityUtils.getUserId());
    }

    @Override
    public Map<String, Object> getWorkbench()
    {
        List<OaSchedule> allList = selectScheduleList(null, null);
        List<OaSchedule> pendingList = selectScheduleList(null, "pending");
        List<OaSchedule> completedList = selectScheduleList(null, "completed");
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("summary", Arrays.asList(
            buildSummary("我的日程", allList.size()),
            buildSummary("待处理", pendingList.size()),
            buildSummary("已完成", completedList.size())
        ));
        result.put("schedules", allList.stream().limit(5).toArray());
        return result;
    }

    private Map<String, Object> buildSummary(String label, int value)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("label", label);
        item.put("value", value);
        return item;
    }
}
