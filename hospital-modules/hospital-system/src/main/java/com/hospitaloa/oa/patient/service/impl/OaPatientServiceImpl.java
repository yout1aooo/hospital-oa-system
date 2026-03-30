package com.hospitaloa.oa.patient.service.impl;

import com.hospitaloa.common.core.exception.ServiceException;
import com.hospitaloa.common.core.utils.StringUtils;
import com.hospitaloa.common.core.utils.ip.IpUtils;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.oa.patient.domain.OaPatient;
import com.hospitaloa.oa.patient.domain.OaPatientAccessLog;
import com.hospitaloa.oa.patient.domain.OaPatientCase;
import com.hospitaloa.oa.patient.mapper.OaPatientMapper;
import com.hospitaloa.oa.patient.service.IOaPatientService;
import com.hospitaloa.system.api.domain.SysDept;
import com.hospitaloa.system.api.domain.SysUser;
import com.hospitaloa.system.api.model.LoginUser;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OaPatientServiceImpl implements IOaPatientService
{
    @Autowired
    private OaPatientMapper patientMapper;

    @Override
    public Map<String, Object> getWorkbench()
    {
        Map<String, Object> result = new LinkedHashMap<>();
        List<OaPatient> allPatients = patientMapper.selectPatientList(null, null, null, null, null, null);
        result.put("summary", Arrays.asList(
            buildSummary("患者总数", allPatients == null ? 0 : allPatients.size()),
            buildSummary("在院患者", patientMapper.countPatientByStatus("active") + patientMapper.countPatientByStatus("observation")),
            buildSummary("活动病例", patientMapper.countCaseByStatus("active")),
            buildSummary("已结案病例", patientMapper.countCaseByStatus("closed"))
        ));
        result.put("deptOptions", buildDeptOptions());
        result.put("patientStatusOptions", buildPatientStatusOptions());
        result.put("caseStatusOptions", buildCaseStatusOptions());
        return result;
    }

    @Override
    public List<OaPatient> selectPatientList(String keyword, String patientStatus, Long deptId,
                                             String doctorName, String beginAdmissionTime, String endAdmissionTime)
    {
        return patientMapper.selectPatientList(keyword, patientStatus, deptId, doctorName, beginAdmissionTime, endAdmissionTime);
    }

    @Override
    public OaPatient selectPatientById(Long patientId)
    {
        OaPatient patient = patientMapper.selectPatientById(patientId);
        if (patient == null)
        {
            throw new ServiceException("患者不存在");
        }
        patient.setCaseList(patientMapper.selectCaseList(null, null, null, null, patientId));
        insertAccessLog(patientId, null, "patient_detail", "查看患者详情");
        return patient;
    }

    @Override
    public List<OaPatientCase> selectCaseList(String keyword, String caseStatus, Long deptId,
                                              String doctorName, Long patientId)
    {
        return patientMapper.selectCaseList(keyword, caseStatus, deptId, doctorName, patientId);
    }

    @Override
    public OaPatientCase selectCaseById(Long caseId)
    {
        OaPatientCase patientCase = patientMapper.selectCaseById(caseId);
        if (patientCase == null)
        {
            throw new ServiceException("病例不存在");
        }
        insertAccessLog(patientCase.getPatientId(), caseId, "case_detail", "查看病例详情");
        return patientCase;
    }

    private List<Map<String, Object>> buildDeptOptions()
    {
        List<Map<String, Object>> options = new ArrayList<>();
        try
        {
            List<OaPatient> deptList = patientMapper.selectPatientDeptOptions();
            if (deptList == null || deptList.isEmpty())
            {
                return options;
            }
            for (OaPatient patient : deptList)
            {
                if (patient == null || patient.getDeptId() == null)
                {
                    continue;
                }
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("deptId", patient.getDeptId());
                item.put("deptName", patient.getDeptName());
                options.add(item);
            }
        }
        catch (Exception e)
        {
            // 科室选项加载失败不影响工作台整体
        }
        return options;
    }

    private List<Map<String, Object>> buildPatientStatusOptions()
    {
        return Arrays.asList(
            buildOption("active", "在院"),
            buildOption("observation", "留观"),
            buildOption("discharged", "已出院")
        );
    }

    private List<Map<String, Object>> buildCaseStatusOptions()
    {
        return Arrays.asList(
            buildOption("active", "进行中"),
            buildOption("review", "复诊跟踪"),
            buildOption("closed", "已结案")
        );
    }

    private Map<String, Object> buildSummary(String label, int value)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("label", label);
        item.put("value", value);
        return item;
    }

    private Map<String, Object> buildOption(String value, String label)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("value", value);
        item.put("label", label);
        return item;
    }

    private void insertAccessLog(Long patientId, Long caseId, String accessType, String remark)
    {
        OaPatientAccessLog accessLog = new OaPatientAccessLog();
        accessLog.setPatientId(patientId);
        accessLog.setCaseId(caseId);
        accessLog.setAccessType(accessType);
        accessLog.setOperatorId(SecurityUtils.getUserId());
        accessLog.setOperatorName(SecurityUtils.getUsername());
        accessLog.setAccessIp(IpUtils.getIpAddr());
        accessLog.setRemark(remark);
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser != null)
        {
            SysUser sysUser = loginUser.getSysUser();
            if (sysUser != null)
            {
                accessLog.setDeptId(sysUser.getDeptId());
                SysDept dept = sysUser.getDept();
                if (dept != null && StringUtils.isNotEmpty(dept.getDeptName()))
                {
                    accessLog.setDeptName(dept.getDeptName());
                }
            }
        }
        patientMapper.insertAccessLog(accessLog);
    }
}
