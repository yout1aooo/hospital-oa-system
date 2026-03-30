package com.hospitaloa.oa.workflow.service.impl;

import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.workflow.domain.OaWorkflowApply;
import com.hospitaloa.oa.workflow.domain.OaWorkflowTask;
import com.hospitaloa.oa.workflow.mapper.OaWorkflowApplyMapper;
import com.hospitaloa.oa.workflow.mapper.OaWorkflowTaskMapper;
import com.hospitaloa.oa.workflow.service.IOaWorkflowApplyService;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaWorkflowApplyServiceImpl implements IOaWorkflowApplyService
{
    private static final Long DEFAULT_APPROVER_ID = 2L;
    private static final String DEFAULT_APPROVER_NAME = "科室负责人";
    private static final String DEFAULT_TASK_NAME = "科室负责人审批";

    @Autowired
    private OaWorkflowApplyMapper applyMapper;

    @Autowired
    private OaWorkflowTaskMapper taskMapper;

    @Override
    public Map<String, Object> getWorkbench()
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("summary", Arrays.asList(
            buildSummary("我的申请", countByTab("apply")),
            buildSummary("我的待办", countByTab("todo")),
            buildSummary("我的已办", countByTab("done"))
        ));
        result.put("types", Arrays.asList(
            buildOption("leave", "请假申请"),
            buildOption("expense", "报销申请")
        ));
        result.put("recentApplies", selectApplyList("apply", null, null).stream().limit(5).toArray());
        return result;
    }

    @Override
    public List<OaWorkflowApply> selectApplyList(String tab, String processType, String title)
    {
        return applyMapper.selectApplyList(tab, processType, title, SecurityUtils.getUserId());
    }

    @Override
    public OaWorkflowApply selectApplyById(Long applyId)
    {
        OaWorkflowApply apply = applyMapper.selectApplyById(applyId, SecurityUtils.getUserId());
        if (apply != null) {
            apply.setTaskList(taskMapper.selectTaskListByApplyId(applyId));
        }
        return apply;
    }

    @Override
    public OaWorkflowApply createApply(OaWorkflowApply apply)
    {
        apply.setApplicantId(SecurityUtils.getUserId());
        apply.setApplicantName(defaultValue(apply.getApplicantName(), SecurityUtils.getUsername()));
        apply.setCurrentHandlerId(DEFAULT_APPROVER_ID);
        apply.setCurrentHandlerName(DEFAULT_TASK_NAME);
        apply.setStatus("审批中");
        apply.setSubmitTime(new Date());
        apply.setCreateBy(SecurityUtils.getUsername());
        apply.setFormNo(buildFormNo(apply.getProcessType()));
        applyMapper.insertApply(apply);
        insertPendingTask(apply.getApplyId());
        return selectApplyById(apply.getApplyId());
    }

    @Override
    public OaWorkflowApply resubmit(Long applyId, OaWorkflowApply form)
    {
        OaWorkflowApply apply = applyMapper.selectApplyById(applyId, SecurityUtils.getUserId());
        if (apply == null) {
            throw new IllegalArgumentException("申请不存在");
        }
        if (!SecurityUtils.getUserId().equals(apply.getApplicantId())) {
            throw new IllegalArgumentException("仅申请人可重新提交");
        }
        if (!"已驳回".equals(apply.getStatus())) {
            throw new IllegalArgumentException("当前申请不可重新提交");
        }
        apply.setTitle(form.getTitle());
        apply.setReason(form.getReason());
        apply.setAmount(form.getAmount());
        apply.setStartDate(form.getStartDate());
        apply.setEndDate(form.getEndDate());
        apply.setSubmitTime(new Date());
        apply.setCurrentHandlerId(DEFAULT_APPROVER_ID);
        apply.setCurrentHandlerName(DEFAULT_TASK_NAME);
        apply.setStatus("审批中");
        apply.setUpdateBy(SecurityUtils.getUsername());
        applyMapper.updateApply(apply);
        insertPendingTask(applyId);
        return selectApplyById(applyId);
    }

    @Override
    public AjaxResult approve(Long applyId, String comment)
    {
        OaWorkflowApply apply = applyMapper.selectApplyById(applyId, SecurityUtils.getUserId());
        if (apply == null) {
            return AjaxResult.error("申请不存在");
        }
        if (!"审批中".equals(apply.getStatus())) {
            return AjaxResult.error("当前申请不可审批");
        }
        if (!SecurityUtils.getUserId().equals(apply.getCurrentHandlerId())) {
            return AjaxResult.error("当前申请不属于你的待办");
        }
        OaWorkflowTask task = taskMapper.selectLatestTaskByApplyId(applyId);
        if (task == null) {
            return AjaxResult.error("审批任务不存在");
        }
        if (!"待处理".equals(task.getTaskStatus())) {
            return AjaxResult.error("当前审批任务已处理");
        }
        task.setTaskStatus("已通过");
        task.setCommentContent(defaultValue(comment, "审批通过"));
        task.setCompleteTime(new Date());
        taskMapper.updateTask(task);
        apply.setStatus("已完成");
        apply.setCurrentHandlerId(null);
        apply.setCurrentHandlerName("已归档");
        apply.setUpdateBy(SecurityUtils.getUsername());
        applyMapper.updateApply(apply);
        return AjaxResult.success("审批通过", selectApplyById(applyId));
    }

    @Override
    public AjaxResult reject(Long applyId, String comment)
    {
        OaWorkflowApply apply = applyMapper.selectApplyById(applyId, SecurityUtils.getUserId());
        if (apply == null) {
            return AjaxResult.error("申请不存在");
        }
        if (!"审批中".equals(apply.getStatus())) {
            return AjaxResult.error("当前申请不可审批");
        }
        if (!SecurityUtils.getUserId().equals(apply.getCurrentHandlerId())) {
            return AjaxResult.error("当前申请不属于你的待办");
        }
        OaWorkflowTask task = taskMapper.selectLatestTaskByApplyId(applyId);
        if (task == null) {
            return AjaxResult.error("审批任务不存在");
        }
        if (!"待处理".equals(task.getTaskStatus())) {
            return AjaxResult.error("当前审批任务已处理");
        }
        task.setTaskStatus("已驳回");
        task.setCommentContent(defaultValue(comment, "审批驳回"));
        task.setCompleteTime(new Date());
        taskMapper.updateTask(task);
        apply.setStatus("已驳回");
        apply.setCurrentHandlerId(apply.getApplicantId());
        apply.setCurrentHandlerName("申请人修改后重提");
        apply.setUpdateBy(SecurityUtils.getUsername());
        applyMapper.updateApply(apply);
        return AjaxResult.success("审批驳回", selectApplyById(applyId));
    }

    private void insertPendingTask(Long applyId)
    {
        OaWorkflowTask task = new OaWorkflowTask();
        task.setApplyId(applyId);
        task.setTaskName(DEFAULT_TASK_NAME);
        task.setAssigneeId(DEFAULT_APPROVER_ID);
        task.setAssigneeName(DEFAULT_APPROVER_NAME);
        task.setTaskStatus("待处理");
        task.setCommentContent("");
        taskMapper.insertTask(task);
    }

    private int countByTab(String tab)
    {
        return selectApplyList(tab, null, null).size();
    }

    private Map<String, Object> buildSummary(String label, int value)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("label", label);
        item.put("value", value);
        return item;
    }

    private Map<String, Object> buildOption(String value, String label)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("value", value);
        item.put("label", label);
        return item;
    }

    private String buildFormNo(String processType)
    {
        String prefix = "leave".equals(processType) ? "OA-LEAVE-" : "OA-EXP-";
        return prefix + new SimpleDateFormat("yyyyMMHHmmss", Locale.CHINA).format(new Date());
    }

    private String defaultValue(String value, String defaultValue)
    {
        return value == null || value.isEmpty() ? defaultValue : value;
    }
}
