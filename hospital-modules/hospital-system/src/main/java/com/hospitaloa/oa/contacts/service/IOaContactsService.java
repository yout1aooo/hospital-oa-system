package com.hospitaloa.oa.contacts.service;

import com.hospitaloa.oa.contacts.domain.OaContactGroup;
import com.hospitaloa.oa.contacts.domain.OaDeptContact;
import com.hospitaloa.oa.contacts.domain.OaStaffContact;
import java.util.List;
import java.util.Map;

public interface IOaContactsService
{
    List<OaStaffContact> selectStaffList(String keyword, Long deptId, Long groupId);

    List<OaDeptContact> selectDeptList(String keyword);

    List<OaContactGroup> selectGroupList();

    List<OaStaffContact> selectGroupMembers(Long groupId, Long ownerId);

    int insertGroup(OaContactGroup group);

    Map<String, Object> getWorkbench(String keyword, Long deptId, Long groupId);
}
