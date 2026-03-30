package com.hospitaloa.oa.workflow.controller;

import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.workflow.domain.OaWorkflowApply;
import com.hospitaloa.oa.workflow.service.IOaWorkflowApplyService;
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
@RequestMapping("/workflow/apply")
public class OaWorkflowApplyController
{
    @Autowired
    private IOaWorkflowApplyService workflowApplyService;

    @RequiresPermissions(value = { "oa:workflow:apply", "oa:workflow:todo", "oa:workflow:done", "oa:workflow:todo:query", "oa:workflow:done:query" }, logical = Logical.OR)
    @GetMapping("/workbench")
    public AjaxResult workbench()
    {
        return AjaxResult.success(workflowApplyService.getWorkbench());
    }

    @RequiresPermissions(value = { "oa:workflow:apply", "oa:workflow:todo", "oa:workflow:done", "oa:workflow:todo:query", "oa:workflow:done:query" }, logical = Logical.OR)
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false, defaultValue = "apply") String tab,
                              @RequestParam(required = false) String processType,
                              @RequestParam(required = false) String title)
    {
        List<OaWorkflowApply> list = workflowApplyService.selectApplyList(tab, processType, title);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:workflow:apply", "oa:workflow:todo", "oa:workflow:done", "oa:workflow:todo:query", "oa:workflow:done:query" }, logical = Logical.OR)
    @GetMapping("/{applyId}")
    public AjaxResult getInfo(@PathVariable Long applyId)
    {
        return AjaxResult.success(workflowApplyService.selectApplyById(applyId));
    }

    @RequiresPermissions("oa:workflow:apply:add")
    @PostMapping
    public AjaxResult add(@RequestBody OaWorkflowApply apply)
    {
        return AjaxResult.success("提交成功", workflowApplyService.createApply(apply));
    }

    @RequiresPermissions("oa:workflow:apply:add")
    @PostMapping("/{applyId}/resubmit")
    public AjaxResult resubmit(@PathVariable Long applyId, @RequestBody OaWorkflowApply apply)
    {
        return AjaxResult.success("重新提交成功", workflowApplyService.resubmit(applyId, apply));
    }

    @RequiresPermissions(value = { "oa:workflow:todo", "oa:workflow:todo:query" }, logical = Logical.OR)
    @PostMapping("/{applyId}/approve")
    public AjaxResult approve(@PathVariable Long applyId, @RequestBody(required = false) Map<String, String> body)
    {
        return workflowApplyService.approve(applyId, body == null ? null : body.get("comment"));
    }

    @RequiresPermissions(value = { "oa:workflow:todo", "oa:workflow:todo:query" }, logical = Logical.OR)
    @PostMapping("/{applyId}/reject")
    public AjaxResult reject(@PathVariable Long applyId, @RequestBody(required = false) Map<String, String> body)
    {
        return workflowApplyService.reject(applyId, body == null ? null : body.get("comment"));
    }
}
