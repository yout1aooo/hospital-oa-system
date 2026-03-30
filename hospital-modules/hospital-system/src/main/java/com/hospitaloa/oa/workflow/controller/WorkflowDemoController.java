package com.hospitaloa.oa.workflow.controller;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/workflow")
public class WorkflowDemoController
{
    @GetMapping("/health")
    public Map<String, Object> health()
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("module", "hospital-system");
        result.put("status", "UP");
        result.put("features", new String[]{"请假审批", "报销审批", "采购审批", "用印审批"});
        return result;
    }
}
