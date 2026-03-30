package com.hospitaloa.oa.workflow.service;

import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.oa.workflow.domain.OaWorkflowApply;
import java.util.List;
import java.util.Map;

public interface IOaWorkflowApplyService
{
    Map<String, Object> getWorkbench();

    List<OaWorkflowApply> selectApplyList(String tab, String processType, String title);

    OaWorkflowApply selectApplyById(Long applyId);

    OaWorkflowApply createApply(OaWorkflowApply apply);

    OaWorkflowApply resubmit(Long applyId, OaWorkflowApply apply);

    AjaxResult approve(Long applyId, String comment);

    AjaxResult reject(Long applyId, String comment);
}
