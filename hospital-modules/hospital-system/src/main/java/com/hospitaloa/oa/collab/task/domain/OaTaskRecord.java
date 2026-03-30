package com.hospitaloa.oa.collab.task.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;

public class OaTaskRecord
{
    private Long recordId;
    private Long taskId;
    private Long operatorId;
    private String operatorName;
    private String recordType;
    private String recordContent;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    public Long getRecordId() { return recordId; }
    public void setRecordId(Long recordId) { this.recordId = recordId; }
    public Long getTaskId() { return taskId; }
    public void setTaskId(Long taskId) { this.taskId = taskId; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
    public String getRecordType() { return recordType; }
    public void setRecordType(String recordType) { this.recordType = recordType; }
    public String getRecordContent() { return recordContent; }
    public void setRecordContent(String recordContent) { this.recordContent = recordContent; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
