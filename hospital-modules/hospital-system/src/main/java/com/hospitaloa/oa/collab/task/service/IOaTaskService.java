package com.hospitaloa.oa.collab.task.service;

import com.hospitaloa.oa.collab.task.domain.OaTask;
import com.hospitaloa.oa.collab.task.domain.OaTaskRecord;
import java.util.List;
import java.util.Map;

public interface IOaTaskService
{
    List<OaTask> selectTaskList(String taskTitle, String taskStatus);

    OaTask selectTaskById(Long taskId);

    int insertTask(OaTask task);

    int completeTask(Long taskId);

    List<OaTaskRecord> selectTaskRecordList(Long taskId);

    int addTaskRecord(Long taskId, String recordContent);

    Map<String, Object> getWorkbench();
}
