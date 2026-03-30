package com.hospitaloa.oa.workflow.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;

public class OaWorkflowTask extends BaseEntity
{
    private Long workflowTaskId;
    private Long applyId;
    private String taskName;
    private Long assigneeId;
    private String assigneeName;
    private String taskStatus;
    private String commentContent;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date completeTime;

    public Long getWorkflowTaskId() { return workflowTaskId; }
    public void setWorkflowTaskId(Long workflowTaskId) { this.workflowTaskId = workflowTaskId; }
    public Long getApplyId() { return applyId; }
    public void setApplyId(Long applyId) { this.applyId = applyId; }
    public String getTaskName() { return taskName; }
    public void setTaskName(String taskName) { this.taskName = taskName; }
    public Long getAssigneeId() { return assigneeId; }
    public void setAssigneeId(Long assigneeId) { this.assigneeId = assigneeId; }
    public String getAssigneeName() { return assigneeName; }
    public void setAssigneeName(String assigneeName) { this.assigneeName = assigneeName; }
    public String getTaskStatus() { return taskStatus; }
    public void setTaskStatus(String taskStatus) { this.taskStatus = taskStatus; }
    public String getCommentContent() { return commentContent; }
    public void setCommentContent(String commentContent) { this.commentContent = commentContent; }
    public Date getCompleteTime() { return completeTime; }
    public void setCompleteTime(Date completeTime) { this.completeTime = completeTime; }
}
