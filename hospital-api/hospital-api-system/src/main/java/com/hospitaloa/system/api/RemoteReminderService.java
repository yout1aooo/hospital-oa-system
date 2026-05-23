package com.hospitaloa.system.api;

import com.hospitaloa.common.core.constant.SecurityConstants;
import com.hospitaloa.common.core.constant.ServiceNameConstants;
import com.hospitaloa.common.core.domain.R;
import com.hospitaloa.system.api.factory.RemoteReminderFallbackFactory;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(contextId = "remoteReminderService", value = ServiceNameConstants.SYSTEM_SERVICE, fallbackFactory = RemoteReminderFallbackFactory.class)
public interface RemoteReminderService
{
    @PostMapping("/oa/reminder/scan")
    R<Integer> scanDueReminders(@RequestHeader(SecurityConstants.FROM_SOURCE) String source);
}
