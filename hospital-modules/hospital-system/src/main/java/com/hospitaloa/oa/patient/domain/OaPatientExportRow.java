package com.hospitaloa.oa.patient.domain;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.format.DateTimeFormat;
import java.util.Date;

public class OaPatientExportRow
{
    @ExcelProperty(value = "患者编号", index = 0)
    private String patientNo;

    @ExcelProperty(value = "患者姓名", index = 1)
    private String patientName;

    @ExcelProperty(value = "性别", index = 2)
    private String genderLabel;

    @ExcelProperty(value = "身份证号(脱敏)", index = 3)
    private String idCardNo;

    @ExcelProperty(value = "手机号(脱敏)", index = 4)
    private String phoneNo;

    @DateTimeFormat("yyyy-MM-dd")
    @ExcelProperty(value = "出生日期", index = 5)
    private Date birthday;

    @ExcelProperty(value = "科室", index = 6)
    private String deptName;

    @ExcelProperty(value = "主治医生", index = 7)
    private String attendingDoctorName;

    @ExcelProperty(value = "住院号", index = 8)
    private String inpatientNo;

    @ExcelProperty(value = "患者状态", index = 9)
    private String patientStatusLabel;

    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value = "入院时间", index = 10)
    private Date admissionTime;

    @DateTimeFormat("yyyy-MM-dd HH:mm:ss")
    @ExcelProperty(value = "出院时间", index = 11)
    private Date dischargeTime;

    @ExcelProperty(value = "病例数量", index = 12)
    private Integer caseCount;

    @ExcelProperty(value = "备注", index = 13)
    private String remark;

    public static OaPatientExportRow from(OaPatient patient)
    {
        OaPatientExportRow row = new OaPatientExportRow();
        row.setPatientNo(patient.getPatientNo());
        row.setPatientName(patient.getPatientName());
        row.setGenderLabel(patient.getGenderLabel());
        row.setIdCardNo(patient.getIdCardNo());
        row.setPhoneNo(patient.getPhoneNo());
        row.setBirthday(patient.getBirthday());
        row.setDeptName(patient.getDeptName());
        row.setAttendingDoctorName(patient.getAttendingDoctorName());
        row.setInpatientNo(patient.getInpatientNo());
        row.setPatientStatusLabel(patient.getPatientStatusLabel());
        row.setAdmissionTime(patient.getAdmissionTime());
        row.setDischargeTime(patient.getDischargeTime());
        row.setCaseCount(patient.getCaseCount());
        row.setRemark(patient.getRemark());
        return row;
    }

    public String getPatientNo() { return patientNo; }
    public void setPatientNo(String patientNo) { this.patientNo = patientNo; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getGenderLabel() { return genderLabel; }
    public void setGenderLabel(String genderLabel) { this.genderLabel = genderLabel; }
    public String getIdCardNo() { return idCardNo; }
    public void setIdCardNo(String idCardNo) { this.idCardNo = idCardNo; }
    public String getPhoneNo() { return phoneNo; }
    public void setPhoneNo(String phoneNo) { this.phoneNo = phoneNo; }
    public Date getBirthday() { return birthday; }
    public void setBirthday(Date birthday) { this.birthday = birthday; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public String getAttendingDoctorName() { return attendingDoctorName; }
    public void setAttendingDoctorName(String attendingDoctorName) { this.attendingDoctorName = attendingDoctorName; }
    public String getInpatientNo() { return inpatientNo; }
    public void setInpatientNo(String inpatientNo) { this.inpatientNo = inpatientNo; }
    public String getPatientStatusLabel() { return patientStatusLabel; }
    public void setPatientStatusLabel(String patientStatusLabel) { this.patientStatusLabel = patientStatusLabel; }
    public Date getAdmissionTime() { return admissionTime; }
    public void setAdmissionTime(Date admissionTime) { this.admissionTime = admissionTime; }
    public Date getDischargeTime() { return dischargeTime; }
    public void setDischargeTime(Date dischargeTime) { this.dischargeTime = dischargeTime; }
    public Integer getCaseCount() { return caseCount; }
    public void setCaseCount(Integer caseCount) { this.caseCount = caseCount; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
