package com.hospitaloa.oa.patient.mapper;

import com.hospitaloa.oa.patient.domain.OaPatient;
import com.hospitaloa.oa.patient.domain.OaPatientAccessLog;
import com.hospitaloa.oa.patient.domain.OaPatientCase;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaPatientMapper
{
    List<OaPatient> selectPatientList(@Param("keyword") String keyword,
                                      @Param("patientStatus") String patientStatus,
                                      @Param("deptId") Long deptId,
                                      @Param("doctorName") String doctorName,
                                      @Param("beginAdmissionTime") String beginAdmissionTime,
                                      @Param("endAdmissionTime") String endAdmissionTime);

    OaPatient selectPatientById(@Param("patientId") Long patientId);

    List<OaPatientCase> selectCaseList(@Param("keyword") String keyword,
                                       @Param("caseStatus") String caseStatus,
                                       @Param("deptId") Long deptId,
                                       @Param("doctorName") String doctorName,
                                       @Param("patientId") Long patientId);

    OaPatientCase selectCaseById(@Param("caseId") Long caseId);

    List<OaPatient> selectPatientDeptOptions();

    int countPatientByStatus(@Param("patientStatus") String patientStatus);

    int countCaseByStatus(@Param("caseStatus") String caseStatus);

    int insertAccessLog(OaPatientAccessLog accessLog);
}
