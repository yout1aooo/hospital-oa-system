package com.hospitaloa.oa.workflow.mapper;

import com.hospitaloa.oa.workflow.domain.OaWorkflowTask;
import java.util.List;

public interface OaWorkflowTaskMapper
{
    OaWorkflowTask selectLatestTaskByApplyId(Long applyId);

    List<OaWorkflowTask> selectTaskListByApplyId(Long applyId);

    int insertTask(OaWorkflowTask task);

    int updateTask(OaWorkflowTask task);
}
