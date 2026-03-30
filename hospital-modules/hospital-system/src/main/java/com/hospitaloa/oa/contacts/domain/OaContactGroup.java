package com.hospitaloa.oa.contacts.domain;

import com.hospitaloa.common.core.web.domain.BaseEntity;

public class OaContactGroup extends BaseEntity
{
    private Long groupId;
    private String groupName;
    private Long ownerId;
    private String memberIds;
    private String remark;

    public Long getGroupId() { return groupId; }
    public void setGroupId(Long groupId) { this.groupId = groupId; }
    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }
    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }
    public String getMemberIds() { return memberIds; }
    public void setMemberIds(String memberIds) { this.memberIds = memberIds; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
