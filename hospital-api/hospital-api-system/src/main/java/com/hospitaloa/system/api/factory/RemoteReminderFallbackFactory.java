package com.hospitaloa.system.api.factory;

import com.hospitaloa.common.core.domain.R;
import com.hospitaloa.system.api.RemoteReminderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.openfeign.FallbackFactory;
import org.springframework.stereotype.Component;

@Component
public class RemoteReminderFallbackFactory implements FallbackFactory<RemoteReminderService>
{
    private static final Logger log = LoggerFactory.getLogger(RemoteReminderFallbackFactory.class);

    @Override
    public RemoteReminderService create(Throwable throwable)
    {
        log.error("Remote reminder service call failed: {}", throwable.getMessage());
        return new RemoteReminderService()
        {
            @Override
            public R<Integer> scanDueReminders(String source)
            {
                return R.fail("Scan due reminders failed: " + throwable.getMessage());
            }
        };
    }
}
