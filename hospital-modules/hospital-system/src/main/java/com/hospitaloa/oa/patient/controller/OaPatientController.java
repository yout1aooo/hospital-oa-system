package com.hospitaloa.oa.patient.controller;

import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.patient.domain.OaPatient;
import com.hospitaloa.oa.patient.domain.OaPatientCase;
import com.hospitaloa.oa.patient.service.IOaPatientService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/oa/patient")
public class OaPatientController extends BaseController
{
    @Autowired
    private IOaPatientService patientService;

    @RequiresPermissions(value = { "oa:patient:list", "oa:patient:case:list", "oa:patient:query", "oa:patient:case:query" }, logical = Logical.OR)
    @GetMapping("/workbench")
    public AjaxResult workbench()
    {
        return AjaxResult.success(patientService.getWorkbench());
    }

    @RequiresPermissions(value = { "oa:patient:list", "oa:patient:query" }, logical = Logical.OR)
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String keyword,
                              @RequestParam(required = false) String patientStatus,
                              @RequestParam(required = false) Long deptId,
                              @RequestParam(required = false) String doctorName,
                              @RequestParam(required = false) String beginAdmissionTime,
                              @RequestParam(required = false) String endAdmissionTime)
    {
        List<OaPatient> list = patientService.selectPatientList(keyword, patientStatus, deptId, doctorName, beginAdmissionTime, endAdmissionTime);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:patient:list", "oa:patient:query" }, logical = Logical.OR)
    @GetMapping("/{patientId}")
    public AjaxResult getInfo(@PathVariable Long patientId)
    {
        return AjaxResult.success(patientService.selectPatientById(patientId));
    }

    @RequiresPermissions(value = { "oa:patient:case:list", "oa:patient:case:query" }, logical = Logical.OR)
    @GetMapping("/case/list")
    public TableDataInfo caseList(@RequestParam(required = false) String keyword,
                                  @RequestParam(required = false) String caseStatus,
                                  @RequestParam(required = false) Long deptId,
                                  @RequestParam(required = false) String doctorName,
                                  @RequestParam(required = false) Long patientId)
    {
        List<OaPatientCase> list = patientService.selectCaseList(keyword, caseStatus, deptId, doctorName, patientId);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions(value = { "oa:patient:case:list", "oa:patient:case:query" }, logical = Logical.OR)
    @GetMapping("/case/{caseId}")
    public AjaxResult getCaseInfo(@PathVariable Long caseId)
    {
        return AjaxResult.success(patientService.selectCaseById(caseId));
    }
}
