package com.hospitaloa.job.task;

import com.hospitaloa.common.core.constant.SecurityConstants;
import com.hospitaloa.common.core.domain.R;
import com.hospitaloa.system.api.RemoteReminderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component("oaReminderJobTask")
public class OaReminderJobTask
{
    private static final Logger log = LoggerFactory.getLogger(OaReminderJobTask.class);

    @Autowired
    private RemoteReminderService remoteReminderService;

    public void scanDueReminders()
    {
        R<Integer> result = remoteReminderService.scanDueReminders(SecurityConstants.INNER);
        if (result == null || R.isError(result))
        {
            String message = result == null ? "empty response" : result.getMsg();
            throw new IllegalStateException("Scan due reminders failed: " + message);
        }

        Integer createdCount = result.getData();
        if (createdCount != null && createdCount > 0)
        {
            log.info("Created {} due OA reminders", createdCount);
        }
    }
}
