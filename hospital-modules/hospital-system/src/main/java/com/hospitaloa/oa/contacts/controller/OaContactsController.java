package com.hospitaloa.oa.contacts.controller;

import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.contacts.domain.OaContactGroup;
import com.hospitaloa.oa.contacts.service.IOaContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oa/contacts")
public class OaContactsController extends BaseController
{
    @Autowired
    private IOaContactsService contactsService;

    @RequiresPermissions("oa:contacts:list")
    @GetMapping("/workbench")
    public AjaxResult workbench(@RequestParam(required = false) String keyword,
                                @RequestParam(required = false) Long deptId,
                                @RequestParam(required = false) Long groupId)
    {
        return AjaxResult.success(contactsService.getWorkbench(keyword, deptId, groupId));
    }

    @RequiresPermissions("oa:contacts:query")
    @GetMapping("/staff/list")
    public AjaxResult staffList(@RequestParam(required = false) String keyword,
                                @RequestParam(required = false) Long deptId,
                                @RequestParam(required = false) Long groupId)
    {
        return AjaxResult.success(contactsService.selectStaffList(keyword, deptId, groupId));
    }

    @RequiresPermissions("oa:contacts:query")
    @GetMapping("/dept/list")
    public AjaxResult deptList(@RequestParam(required = false) String keyword)
    {
        return AjaxResult.success(contactsService.selectDeptList(keyword));
    }

    @RequiresPermissions("oa:contacts:query")
    @GetMapping("/group/list")
    public AjaxResult groupList()
    {
        return AjaxResult.success(contactsService.selectGroupList());
    }

    @RequiresPermissions("oa:contacts:query")
    @GetMapping("/group/members")
    public AjaxResult groupMembers(@RequestParam Long groupId)
    {
        return AjaxResult.success(contactsService.selectGroupMembers(groupId, SecurityUtils.getUserId()));
    }

    @RequiresPermissions("oa:contacts:query")
    @PostMapping("/group")
    public AjaxResult addGroup(@RequestBody OaContactGroup group)
    {
        contactsService.insertGroup(group);
        return AjaxResult.success("新增成功");
    }
}
