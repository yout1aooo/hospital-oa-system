package com.hospitaloa.oa.collab.reminder.controller;

import com.hospitaloa.common.core.domain.R;
import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.security.annotation.InnerAuth;
import com.hospitaloa.common.security.annotation.RequiresLogin;
import com.hospitaloa.oa.collab.reminder.service.IOaReminderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oa/reminder")
public class OaReminderController extends BaseController
{
    @Autowired
    private IOaReminderService reminderService;

    @RequiresLogin
    @GetMapping("/unread")
    public AjaxResult unread(@RequestParam(required = false) Integer limit)
    {
        return AjaxResult.success(reminderService.selectUnreadReminders(limit));
    }

    @RequiresLogin
    @GetMapping("/unread/count")
    public AjaxResult unreadCount()
    {
        return AjaxResult.success(reminderService.selectUnreadCount());
    }

    @RequiresLogin
    @PutMapping("/{reminderId}/read")
    public AjaxResult read(@PathVariable Long reminderId)
    {
        reminderService.markReminderRead(reminderId);
        return AjaxResult.success();
    }

    @RequiresLogin
    @PutMapping("/read-all")
    public AjaxResult readAll()
    {
        reminderService.markAllRemindersRead();
        return AjaxResult.success();
    }

    @InnerAuth
    @PostMapping("/scan")
    public R<Integer> scanDueReminders()
    {
        return R.ok(reminderService.scanDueReminders());
    }
}
