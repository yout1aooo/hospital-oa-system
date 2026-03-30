package com.hospitaloa.oa.contacts.domain;

public class OaDeptContact
{
    private Long deptId;
    private Long parentId;
    private String deptName;
    private String leader;
    private String phone;
    private String email;
    private String deptType;
    private String campusName;
    private String officeLocation;
    private String servicePhone;

    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public String getLeader() { return leader; }
    public void setLeader(String leader) { this.leader = leader; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getDeptType() { return deptType; }
    public void setDeptType(String deptType) { this.deptType = deptType; }
    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }
    public String getOfficeLocation() { return officeLocation; }
    public void setOfficeLocation(String officeLocation) { this.officeLocation = officeLocation; }
    public String getServicePhone() { return servicePhone; }
    public void setServicePhone(String servicePhone) { this.servicePhone = servicePhone; }
}
