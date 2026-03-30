package com.hospitaloa.oa.collab.schedule.controller;

import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.collab.schedule.domain.OaSchedule;
import com.hospitaloa.oa.collab.schedule.service.IOaScheduleService;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oa/schedule")
public class OaScheduleController extends BaseController
{
    @Autowired
    private IOaScheduleService scheduleService;

    @RequiresPermissions(value = { "oa:collab:schedule:list", "oa:collab:schedule:query" }, logical = Logical.OR)
    @GetMapping("/workbench")
    public AjaxResult workbench()
    {
        Map<String, Object> data = scheduleService.getWorkbench();
        return AjaxResult.success(data);
    }

    @RequiresPermissions(value = { "oa:collab:schedule:list", "oa:collab:schedule:query" }, logical = Logical.OR)
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String scheduleTitle,
                              @RequestParam(required = false) String scheduleStatus)
    {
        List<OaSchedule> list = scheduleService.selectScheduleList(scheduleTitle, scheduleStatus);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:collab:schedule:list", "oa:collab:schedule:query" }, logical = Logical.OR)
    @GetMapping("/{scheduleId}")
    public AjaxResult getInfo(@PathVariable Long scheduleId)
    {
        return AjaxResult.success(scheduleService.selectScheduleById(scheduleId));
    }

    @RequiresPermissions("oa:collab:schedule:list")
    @PostMapping
    public AjaxResult add(@RequestBody OaSchedule schedule)
    {
        scheduleService.insertSchedule(schedule);
        return AjaxResult.success("新增成功", scheduleService.selectScheduleById(schedule.getScheduleId()));
    }

    @RequiresPermissions("oa:collab:schedule:list")
    @PostMapping("/{scheduleId}/finish")
    public AjaxResult finish(@PathVariable Long scheduleId)
    {
        scheduleService.finishSchedule(scheduleId);
        return AjaxResult.success("日程已完成", scheduleService.selectScheduleById(scheduleId));
    }
}
