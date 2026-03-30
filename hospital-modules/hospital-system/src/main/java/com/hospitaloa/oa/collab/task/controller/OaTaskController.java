package com.hospitaloa.oa.collab.task.controller;

import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.collab.task.domain.OaTask;
import com.hospitaloa.oa.collab.task.service.IOaTaskService;
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
@RequestMapping("/oa/task")
public class OaTaskController extends BaseController
{
    @Autowired
    private IOaTaskService taskService;

    @RequiresPermissions(value = { "oa:collab:task:list", "oa:collab:task:query" }, logical = Logical.OR)
    @GetMapping("/workbench")
    public AjaxResult workbench()
    {
        Map<String, Object> data = taskService.getWorkbench();
        return AjaxResult.success(data);
    }

    @RequiresPermissions(value = { "oa:collab:task:list", "oa:collab:task:query" }, logical = Logical.OR)
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String taskTitle,
                              @RequestParam(required = false) String taskStatus)
    {
        List<OaTask> list = taskService.selectTaskList(taskTitle, taskStatus);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:collab:task:list", "oa:collab:task:query" }, logical = Logical.OR)
    @GetMapping("/{taskId}")
    public AjaxResult getInfo(@PathVariable Long taskId)
    {
        AjaxResult result = AjaxResult.success(taskService.selectTaskById(taskId));
        result.put("records", taskService.selectTaskRecordList(taskId));
        return result;
    }

    @RequiresPermissions("oa:collab:task:list")
    @PostMapping
    public AjaxResult add(@RequestBody OaTask task)
    {
        taskService.insertTask(task);
        return AjaxResult.success("新增成功", taskService.selectTaskById(task.getTaskId()));
    }

    @RequiresPermissions("oa:collab:task:list")
    @PostMapping("/{taskId}/complete")
    public AjaxResult complete(@PathVariable Long taskId)
    {
        taskService.completeTask(taskId);
        return AjaxResult.success("任务已完成", taskService.selectTaskById(taskId));
    }

    @RequiresPermissions("oa:collab:task:list")
    @PostMapping("/{taskId}/record")
    public AjaxResult addRecord(@PathVariable Long taskId, @RequestBody(required = false) Map<String, String> body)
    {
        taskService.addTaskRecord(taskId, body == null ? "任务跟进" : body.getOrDefault("recordContent", "任务跟进"));
        return AjaxResult.success(taskService.selectTaskRecordList(taskId));
    }
}
