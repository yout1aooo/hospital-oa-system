package com.hospitaloa.oa.patient.domain;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.format.DateTimeFormat;
import java.util.Date;

public class OaPatientCaseExportRow
{
    @ExcelProperty(value = "病例编号", index = 0)
    private String caseNo;

    @ExcelProperty(value = "病例标题", index = 1)
    private String caseTitle;

    @ExcelProperty(value = "患者编号", index = 2)
    private String patientNo;

    @ExcelProperty(value = "患者姓名", index = 3)
    private String patientName;

    @ExcelProperty(value = "就诊类型", index = 4)
    private String visitTypeLabel;

    @ExcelProperty(value = "病例状态", index = 5)
    private String caseStatusLabel;

    @ExcelProperty(value = "诊断结果", index = 6)
    private String diagnosis;

    @ExcelProperty(value = "主诉", index = 7)
    private String chiefComplaint;

    @ExcelProperty(value = "诊疗方案", index = 8)
    private String treatmentPlan;

    @ExcelProperty(value = "接诊医生", index = 9)
    private String doctorName;

    @ExcelProperty(value = "科室", index = 10)
    private String deptName;

    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value = "就诊时间", index = 11)
    private Date visitTime;

    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value = "出院时间", index = 12)
    private Date dischargeTime;

    public static OaPatientCaseExportRow from(OaPatientCase patientCase)
    {
        OaPatientCaseExportRow row = new OaPatientCaseExportRow();
        row.setCaseNo(patientCase.getCaseNo());
        row.setCaseTitle(patientCase.getCaseTitle());
        row.setPatientNo(patientCase.getPatientNo());
        row.setPatientName(patientCase.getPatientName());
        row.setVisitTypeLabel(patientCase.getVisitTypeLabel());
        row.setCaseStatusLabel(patientCase.getCaseStatusLabel());
        row.setDiagnosis(patientCase.getDiagnosis());
        row.setChiefComplaint(patientCase.getChiefComplaint());
        row.setTreatmentPlan(patientCase.getTreatmentPlan());
        row.setDoctorName(patientCase.getDoctorName());
        row.setDeptName(patientCase.getDeptName());
        row.setVisitTime(patientCase.getVisitTime());
        row.setDischargeTime(patientCase.getDischargeTime());
        return row;
    }

    public String getCaseNo() { return caseNo; }
    public void setCaseNo(String caseNo) { this.caseNo = caseNo; }
    public String getCaseTitle() { return caseTitle; }
    public void setCaseTitle(String caseTitle) { this.caseTitle = caseTitle; }
    public String getPatientNo() { return patientNo; }
    public void setPatientNo(String patientNo) { this.patientNo = patientNo; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getVisitTypeLabel() { return visitTypeLabel; }
    public void setVisitTypeLabel(String visitTypeLabel) { this.visitTypeLabel = visitTypeLabel; }
    public String getCaseStatusLabel() { return caseStatusLabel; }
    public void setCaseStatusLabel(String caseStatusLabel) { this.caseStatusLabel = caseStatusLabel; }
    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }
    public String getChiefComplaint() { return chiefComplaint; }
    public void setChiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; }
    public String getTreatmentPlan() { return treatmentPlan; }
    public void setTreatmentPlan(String treatmentPlan) { this.treatmentPlan = treatmentPlan; }
    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public Date getVisitTime() { return visitTime; }
    public void setVisitTime(Date visitTime) { this.visitTime = visitTime; }
    public Date getDischargeTime() { return dischargeTime; }
    public void setDischargeTime(Date dischargeTime) { this.dischargeTime = dischargeTime; }
}
