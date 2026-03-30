package com.hospitaloa.oa.patient.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;
import java.util.List;

public class OaPatient extends BaseEntity
{
    private Long patientId;
    private String patientNo;
    private String patientName;
    private String gender;
    private String genderLabel;
    private String idCardNo;
    private String phoneNo;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birthday;
    private Long deptId;
    private String deptName;
    private Long attendingDoctorId;
    private String attendingDoctorName;
    private String inpatientNo;
    private String patientStatus;
    private String patientStatusLabel;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date admissionTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date dischargeTime;
    private Integer caseCount;
    private List<OaPatientCase> caseList;

    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public String getPatientNo() { return patientNo; }
    public void setPatientNo(String patientNo) { this.patientNo = patientNo; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getGenderLabel() { return genderLabel; }
    public void setGenderLabel(String genderLabel) { this.genderLabel = genderLabel; }
    public String getIdCardNo() { return idCardNo; }
    public void setIdCardNo(String idCardNo) { this.idCardNo = idCardNo; }
    public String getPhoneNo() { return phoneNo; }
    public void setPhoneNo(String phoneNo) { this.phoneNo = phoneNo; }
    public Date getBirthday() { return birthday; }
    public void setBirthday(Date birthday) { this.birthday = birthday; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public Long getAttendingDoctorId() { return attendingDoctorId; }
    public void setAttendingDoctorId(Long attendingDoctorId) { this.attendingDoctorId = attendingDoctorId; }
    public String getAttendingDoctorName() { return attendingDoctorName; }
    public void setAttendingDoctorName(String attendingDoctorName) { this.attendingDoctorName = attendingDoctorName; }
    public String getInpatientNo() { return inpatientNo; }
    public void setInpatientNo(String inpatientNo) { this.inpatientNo = inpatientNo; }
    public String getPatientStatus() { return patientStatus; }
    public void setPatientStatus(String patientStatus) { this.patientStatus = patientStatus; }
    public String getPatientStatusLabel() { return patientStatusLabel; }
    public void setPatientStatusLabel(String patientStatusLabel) { this.patientStatusLabel = patientStatusLabel; }
    public Date getAdmissionTime() { return admissionTime; }
    public void setAdmissionTime(Date admissionTime) { this.admissionTime = admissionTime; }
    public Date getDischargeTime() { return dischargeTime; }
    public void setDischargeTime(Date dischargeTime) { this.dischargeTime = dischargeTime; }
    public Integer getCaseCount() { return caseCount; }
    public void setCaseCount(Integer caseCount) { this.caseCount = caseCount; }
    public List<OaPatientCase> getCaseList() { return caseList; }
    public void setCaseList(List<OaPatientCase> caseList) { this.caseList = caseList; }
}
