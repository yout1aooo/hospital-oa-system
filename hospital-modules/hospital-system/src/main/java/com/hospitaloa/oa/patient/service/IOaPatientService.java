package com.hospitaloa.oa.patient.service;

import com.hospitaloa.oa.patient.domain.OaPatient;
import com.hospitaloa.oa.patient.domain.OaPatientCase;
import java.util.List;
import java.util.Map;

public interface IOaPatientService
{
    Map<String, Object> getWorkbench();

    List<OaPatient> selectPatientList(String keyword, String patientStatus, Long deptId,
                                      String doctorName, String beginAdmissionTime, String endAdmissionTime);

    OaPatient selectPatientById(Long patientId);

    List<OaPatientCase> selectCaseList(String keyword, String caseStatus, Long deptId,
                                       String doctorName, Long patientId);

    OaPatientCase selectCaseById(Long caseId);
}
