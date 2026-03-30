package com.hospitaloa.oa.workflow.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;
import java.util.List;

public class OaWorkflowApply extends BaseEntity
{
    private Long applyId;
    private String processType;
    private String processTypeLabel;
    private String title;
    private String formNo;
    private String status;
    private String statusLabel;
    private Long applicantId;
    private String applicantName;
    private Long currentHandlerId;
    private String currentHandlerName;
    private String reason;
    private Double amount;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date startDate;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date endDate;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date submitTime;
    private List<OaWorkflowTask> taskList;

    public Long getApplyId() { return applyId; }
    public void setApplyId(Long applyId) { this.applyId = applyId; }
    public String getProcessType() { return processType; }
    public void setProcessType(String processType) { this.processType = processType; }
    public String getProcessTypeLabel() { return processTypeLabel; }
    public void setProcessTypeLabel(String processTypeLabel) { this.processTypeLabel = processTypeLabel; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getFormNo() { return formNo; }
    public void setFormNo(String formNo) { this.formNo = formNo; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStatusLabel() { return statusLabel; }
    public void setStatusLabel(String statusLabel) { this.statusLabel = statusLabel; }
    public Long getApplicantId() { return applicantId; }
    public void setApplicantId(Long applicantId) { this.applicantId = applicantId; }
    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }
    public Long getCurrentHandlerId() { return currentHandlerId; }
    public void setCurrentHandlerId(Long currentHandlerId) { this.currentHandlerId = currentHandlerId; }
    public String getCurrentHandlerName() { return currentHandlerName; }
    public void setCurrentHandlerName(String currentHandlerName) { this.currentHandlerName = currentHandlerName; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    public Date getSubmitTime() { return submitTime; }
    public void setSubmitTime(Date submitTime) { this.submitTime = submitTime; }
    public List<OaWorkflowTask> getTaskList() { return taskList; }
    public void setTaskList(List<OaWorkflowTask> taskList) { this.taskList = taskList; }
}
