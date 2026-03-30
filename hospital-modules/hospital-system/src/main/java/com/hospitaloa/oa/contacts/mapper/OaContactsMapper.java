package com.hospitaloa.oa.contacts.mapper;

import com.hospitaloa.oa.contacts.domain.OaContactGroup;
import com.hospitaloa.oa.contacts.domain.OaDeptContact;
import com.hospitaloa.oa.contacts.domain.OaStaffContact;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaContactsMapper
{
    List<OaStaffContact> selectStaffList(@Param("keyword") String keyword, @Param("deptId") Long deptId,
                                         @Param("groupId") Long groupId, @Param("ownerId") Long ownerId);

    List<OaDeptContact> selectDeptList(@Param("keyword") String keyword);

    List<OaContactGroup> selectGroupList(@Param("ownerId") Long ownerId);

    List<OaStaffContact> selectGroupMembers(@Param("groupId") Long groupId, @Param("ownerId") Long ownerId);

    int insertGroup(OaContactGroup group);
}
