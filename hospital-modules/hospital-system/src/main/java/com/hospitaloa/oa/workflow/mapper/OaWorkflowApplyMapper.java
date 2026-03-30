package com.hospitaloa.oa.workflow.mapper;

import com.hospitaloa.oa.workflow.domain.OaWorkflowApply;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaWorkflowApplyMapper
{
    List<OaWorkflowApply> selectApplyList(@Param("tab") String tab, @Param("processType") String processType, @Param("title") String title,
                                          @Param("userId") Long userId);

    OaWorkflowApply selectApplyById(@Param("applyId") Long applyId, @Param("userId") Long userId);

    int insertApply(OaWorkflowApply apply);

    int updateApply(OaWorkflowApply apply);
}
