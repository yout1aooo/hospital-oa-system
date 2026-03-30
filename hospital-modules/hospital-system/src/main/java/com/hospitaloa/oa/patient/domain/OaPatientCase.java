package com.hospitaloa.oa.patient.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;

public class OaPatientCase extends BaseEntity
{
    private Long caseId;
    private Long patientId;
    private String patientNo;
    private String patientName;
    private String caseNo;
    private String caseTitle;
    private String visitType;
    private String visitTypeLabel;
    private String caseStatus;
    private String caseStatusLabel;
    private String diagnosis;
    private String chiefComplaint;
    private String treatmentPlan;
    private Long doctorId;
    private String doctorName;
    private Long deptId;
    private String deptName;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date visitTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date dischargeTime;

    public Long getCaseId() { return caseId; }
    public void setCaseId(Long caseId) { this.caseId = caseId; }
    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public String getPatientNo() { return patientNo; }
    public void setPatientNo(String patientNo) { this.patientNo = patientNo; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getCaseNo() { return caseNo; }
    public void setCaseNo(String caseNo) { this.caseNo = caseNo; }
    public String getCaseTitle() { return caseTitle; }
    public void setCaseTitle(String caseTitle) { this.caseTitle = caseTitle; }
    public String getVisitType() { return visitType; }
    public void setVisitType(String visitType) { this.visitType = visitType; }
    public String getVisitTypeLabel() { return visitTypeLabel; }
    public void setVisitTypeLabel(String visitTypeLabel) { this.visitTypeLabel = visitTypeLabel; }
    public String getCaseStatus() { return caseStatus; }
    public void setCaseStatus(String caseStatus) { this.caseStatus = caseStatus; }
    public String getCaseStatusLabel() { return caseStatusLabel; }
    public void setCaseStatusLabel(String caseStatusLabel) { this.caseStatusLabel = caseStatusLabel; }
    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }
    public String getChiefComplaint() { return chiefComplaint; }
    public void setChiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; }
    public String getTreatmentPlan() { return treatmentPlan; }
    public void setTreatmentPlan(String treatmentPlan) { this.treatmentPlan = treatmentPlan; }
    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }
    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public Date getVisitTime() { return visitTime; }
    public void setVisitTime(Date visitTime) { this.visitTime = visitTime; }
    public Date getDischargeTime() { return dischargeTime; }
    public void setDischargeTime(Date dischargeTime) { this.dischargeTime = dischargeTime; }
}
