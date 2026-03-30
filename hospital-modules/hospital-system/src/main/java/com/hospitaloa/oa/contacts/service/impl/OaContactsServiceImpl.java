package com.hospitaloa.oa.contacts.service.impl;

import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.contacts.domain.OaContactGroup;
import com.hospitaloa.oa.contacts.domain.OaDeptContact;
import com.hospitaloa.oa.contacts.domain.OaStaffContact;
import com.hospitaloa.oa.contacts.mapper.OaContactsMapper;
import com.hospitaloa.oa.contacts.service.IOaContactsService;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaContactsServiceImpl implements IOaContactsService
{
    @Autowired
    private OaContactsMapper contactsMapper;

    @Override
    public List<OaStaffContact> selectStaffList(String keyword, Long deptId, Long groupId)
    {
        return contactsMapper.selectStaffList(keyword, deptId, groupId, SecurityUtils.getUserId());
    }

    @Override
    public List<OaDeptContact> selectDeptList(String keyword)
    {
        return contactsMapper.selectDeptList(keyword);
    }

    @Override
    public List<OaContactGroup> selectGroupList()
    {
        return contactsMapper.selectGroupList(SecurityUtils.getUserId());
    }

    @Override
    public List<OaStaffContact> selectGroupMembers(Long groupId, Long ownerId)
    {
        return contactsMapper.selectGroupMembers(groupId, ownerId);
    }

    @Override
    public int insertGroup(OaContactGroup group)
    {
        group.setOwnerId(SecurityUtils.getUserId());
        return contactsMapper.insertGroup(group);
    }

    @Override
    public Map<String, Object> getWorkbench(String keyword, Long deptId, Long groupId)
    {
        List<OaStaffContact> staffList = selectStaffList(keyword, deptId, groupId);
        List<OaDeptContact> deptList = selectDeptList(keyword);
        List<OaContactGroup> groupList = selectGroupList();
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("summary", Arrays.asList(
            buildSummary("人员数", staffList.size()),
            buildSummary("科室数", deptList.size()),
            buildSummary("我的分组", groupList.size())
        ));
        result.put("staffList", staffList);
        result.put("deptList", deptList);
        result.put("groupList", groupList);
        return result;
    }

    private Map<String, Object> buildSummary(String label, int value)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("label", label);
        item.put("value", value);
        return item;
    }
}
