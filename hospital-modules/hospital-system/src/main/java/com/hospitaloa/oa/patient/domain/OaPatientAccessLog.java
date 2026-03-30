package com.hospitaloa.oa.patient.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;

public class OaPatientAccessLog
{
    private Long accessLogId;
    private Long patientId;
    private Long caseId;
    private String accessType;
    private Long operatorId;
    private String operatorName;
    private Long deptId;
    private String deptName;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date accessTime;
    private String accessIp;
    private String remark;

    public Long getAccessLogId() { return accessLogId; }
    public void setAccessLogId(Long accessLogId) { this.accessLogId = accessLogId; }
    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public Long getCaseId() { return caseId; }
    public void setCaseId(Long caseId) { this.caseId = caseId; }
    public String getAccessType() { return accessType; }
    public void setAccessType(String accessType) { this.accessType = accessType; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public Date getAccessTime() { return accessTime; }
    public void setAccessTime(Date accessTime) { this.accessTime = accessTime; }
    public String getAccessIp() { return accessIp; }
    public void setAccessIp(String accessIp) { this.accessIp = accessIp; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
