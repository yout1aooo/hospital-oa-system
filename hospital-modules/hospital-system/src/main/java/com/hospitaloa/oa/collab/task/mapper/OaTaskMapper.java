package com.hospitaloa.oa.collab.task.mapper;

import com.hospitaloa.oa.collab.task.domain.OaTask;
import com.hospitaloa.oa.collab.task.domain.OaTaskRecord;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaTaskMapper
{
    List<OaTask> selectTaskList(@Param("taskTitle") String taskTitle,
                                @Param("taskStatus") String taskStatus,
                                @Param("userId") Long userId,
                                @Param("username") String username);

    OaTask selectTaskById(@Param("taskId") Long taskId,
                          @Param("userId") Long userId,
                          @Param("username") String username);

    int insertTask(OaTask task);

    int completeTask(@Param("taskId") Long taskId, @Param("updateBy") String updateBy,
                     @Param("userId") Long userId, @Param("username") String username);

    int startTaskProcessing(@Param("taskId") Long taskId, @Param("updateBy") String updateBy,
                            @Param("userId") Long userId, @Param("username") String username);

    List<OaTaskRecord> selectTaskRecordList(@Param("taskId") Long taskId,
                                            @Param("userId") Long userId,
                                            @Param("username") String username);

    int insertTaskRecord(OaTaskRecord record);
}
