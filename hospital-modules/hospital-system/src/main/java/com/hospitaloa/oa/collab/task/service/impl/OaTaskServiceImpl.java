package com.hospitaloa.oa.collab.task.service.impl;

import com.hospitaloa.common.core.exception.ServiceException;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.collab.task.domain.OaTask;
import com.hospitaloa.oa.collab.task.domain.OaTaskRecord;
import com.hospitaloa.oa.collab.task.mapper.OaTaskMapper;
import com.hospitaloa.oa.collab.task.service.IOaTaskService;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaTaskServiceImpl implements IOaTaskService
{
    @Autowired
    private OaTaskMapper taskMapper;

    @Override
    public List<OaTask> selectTaskList(String taskTitle, String taskStatus)
    {
        return taskMapper.selectTaskList(taskTitle, taskStatus, SecurityUtils.getUserId(), SecurityUtils.getUsername());
    }

    @Override
    public OaTask selectTaskById(Long taskId)
    {
        return taskMapper.selectTaskById(taskId, SecurityUtils.getUserId(), SecurityUtils.getUsername());
    }

    @Override
    public int insertTask(OaTask task)
    {
        task.setPublisherId(SecurityUtils.getUserId());
        task.setPublisherName(SecurityUtils.getUsername());
        task.setCreateBy(SecurityUtils.getUsername());
        if (task.getTaskStatus() == null || task.getTaskStatus().isEmpty()) {
            task.setTaskStatus("pending");
        }
        int rows = taskMapper.insertTask(task);
        if (rows > 0) {
            addTaskRecord(task.getTaskId(), "创建任务");
        }
        return rows;
    }

    @Override
    public int completeTask(Long taskId)
    {
        OaTask task = selectTaskById(taskId);
        if (task == null)
        {
            throw new ServiceException("任务不存在或无权限访问");
        }
        if (!"completed".equals(task.getTaskStatus()))
        {
            if ("pending".equals(task.getTaskStatus()))
            {
                taskMapper.startTaskProcessing(taskId, SecurityUtils.getUsername(), SecurityUtils.getUserId(), SecurityUtils.getUsername());
                addTaskRecord(taskId, "任务开始处理");
            }
            int rows = taskMapper.completeTask(taskId, SecurityUtils.getUsername(), SecurityUtils.getUserId(), SecurityUtils.getUsername());
            if (rows > 0)
            {
                addTaskRecord(taskId, "任务已完成");
            }
            return rows;
        }
        return 1;
    }

    @Override
    public List<OaTaskRecord> selectTaskRecordList(Long taskId)
    {
        return taskMapper.selectTaskRecordList(taskId, SecurityUtils.getUserId(), SecurityUtils.getUsername());
    }

    @Override
    public int addTaskRecord(Long taskId, String recordContent)
    {
        OaTask task = selectTaskById(taskId);
        if (task == null)
        {
            throw new ServiceException("任务不存在或无权限访问");
        }
        if ("pending".equals(task.getTaskStatus()))
        {
            taskMapper.startTaskProcessing(taskId, SecurityUtils.getUsername(), SecurityUtils.getUserId(), SecurityUtils.getUsername());
        }
        OaTaskRecord record = new OaTaskRecord();
        record.setTaskId(taskId);
        record.setOperatorId(SecurityUtils.getUserId());
        record.setOperatorName(SecurityUtils.getUsername());
        record.setRecordType("follow");
        record.setRecordContent(recordContent);
        return taskMapper.insertTaskRecord(record);
    }

    @Override
    public Map<String, Object> getWorkbench()
    {
        List<OaTask> allList = selectTaskList(null, null);
        List<OaTask> pendingList = selectTaskList(null, "pending");
        List<OaTask> processingList = selectTaskList(null, "processing");
        List<OaTask> completedList = selectTaskList(null, "completed");
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("summary", Arrays.asList(
            buildSummary("我的任务", allList.size()),
            buildSummary("待处理", pendingList.size()),
            buildSummary("进行中", processingList.size()),
            buildSummary("已完成", completedList.size())
        ));
        result.put("tasks", allList.stream().limit(5).toArray());
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
