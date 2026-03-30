package com.hospitaloa.oa.collab.meeting.controller;

import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.collab.meeting.domain.OaMeeting;
import com.hospitaloa.oa.collab.meeting.service.IOaMeetingService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oa/meeting")
public class OaMeetingController extends BaseController
{
    @Autowired
    private IOaMeetingService meetingService;

    @RequiresPermissions(value = { "oa:collab:meeting:list", "oa:collab:meeting:query" }, logical = Logical.OR)
    @GetMapping("/rooms")
    public AjaxResult rooms()
    {
        return AjaxResult.success(meetingService.selectRoomList());
    }

    @RequiresPermissions(value = { "oa:collab:meeting:list", "oa:collab:meeting:query" }, logical = Logical.OR)
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String meetingTitle,
                              @RequestParam(required = false) String meetingStatus)
    {
        List<OaMeeting> list = meetingService.selectMeetingList(meetingTitle, meetingStatus);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:collab:meeting:list", "oa:collab:meeting:query" }, logical = Logical.OR)
    @GetMapping("/{meetingId}")
    public AjaxResult getInfo(@PathVariable Long meetingId)
    {
        return AjaxResult.success(meetingService.selectMeetingById(meetingId));
    }

    @RequiresPermissions("oa:collab:meeting:list")
    @PostMapping
    public AjaxResult add(@RequestBody OaMeeting meeting)
    {
        meetingService.insertMeeting(meeting);
        return AjaxResult.success("新增成功", meetingService.selectMeetingById(meeting.getMeetingId()));
    }

    @RequiresPermissions("oa:collab:meeting:list")
    @PostMapping("/{meetingId}/finish")
    public AjaxResult finish(@PathVariable Long meetingId)
    {
        meetingService.finishMeeting(meetingId);
        return AjaxResult.success("会议已完成", meetingService.selectMeetingById(meetingId));
    }
}
