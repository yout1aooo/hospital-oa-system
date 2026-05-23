package com.hospitaloa.oa.patient.controller;

import com.alibaba.excel.EasyExcel;
import com.hospitaloa.common.core.web.controller.BaseController;
import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.log.annotation.Log;
import com.hospitaloa.common.log.enums.BusinessType;
import com.hospitaloa.common.security.annotation.Logical;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.oa.patient.domain.OaPatient;
import com.hospitaloa.oa.patient.domain.OaPatientCase;
import com.hospitaloa.oa.patient.domain.OaPatientCaseExportRow;
import com.hospitaloa.oa.patient.domain.OaPatientExportRow;
import com.hospitaloa.oa.patient.service.IOaPatientService;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import java.util.stream.Collectors;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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

    @Log(title = "患者查询报表", businessType = BusinessType.EXPORT)
    @RequiresPermissions("oa:patient:export")
    @PostMapping("/export")
    public void export(HttpServletResponse response,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) String patientStatus,
                       @RequestParam(required = false) Long deptId,
                       @RequestParam(required = false) String doctorName,
                       @RequestParam(required = false) String beginAdmissionTime,
                       @RequestParam(required = false) String endAdmissionTime) throws IOException
    {
        List<OaPatientExportRow> rows = patientService
            .selectPatientList(keyword, patientStatus, deptId, doctorName, beginAdmissionTime, endAdmissionTime)
            .stream()
            .map(OaPatientExportRow::from)
            .collect(Collectors.toList());
        exportExcel(response, "患者查询报表", "患者查询报表", OaPatientExportRow.class, rows);
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

    @Log(title = "病例查询报表", businessType = BusinessType.EXPORT)
    @RequiresPermissions("oa:patient:case:export")
    @PostMapping("/case/export")
    public void caseExport(HttpServletResponse response,
                           @RequestParam(required = false) String keyword,
                           @RequestParam(required = false) String caseStatus,
                           @RequestParam(required = false) Long deptId,
                           @RequestParam(required = false) String doctorName,
                           @RequestParam(required = false) Long patientId) throws IOException
    {
        List<OaPatientCaseExportRow> rows = patientService
            .selectCaseList(keyword, caseStatus, deptId, doctorName, patientId)
            .stream()
            .map(OaPatientCaseExportRow::from)
            .collect(Collectors.toList());
        exportExcel(response, "病例查询报表", "病例查询报表", OaPatientCaseExportRow.class, rows);
    }

    @RequiresPermissions(value = { "oa:patient:case:list", "oa:patient:case:query" }, logical = Logical.OR)
    @GetMapping("/case/{caseId}")
    public AjaxResult getCaseInfo(@PathVariable Long caseId)
    {
        return AjaxResult.success(patientService.selectCaseById(caseId));
    }

    private <T> void exportExcel(HttpServletResponse response, String fileName, String sheetName,
                                 Class<T> head, List<T> rows) throws IOException
    {
        String encodedFileName = URLEncoder.encode(fileName, "UTF-8").replace("+", "%20");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        response.setHeader("Content-Disposition", "attachment;filename*=utf-8''" + encodedFileName + ".xlsx");
        EasyExcel.write(response.getOutputStream(), head)
            .autoCloseStream(false)
            .sheet(sheetName)
            .doWrite(rows);
    }
}
