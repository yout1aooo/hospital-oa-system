package com.hospitaloa.system.mapper;

import com.hospitaloa.system.domain.OaDocument;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaDocumentMapper
{
    List<OaDocument> selectDocumentList(@Param("tab") String tab, @Param("title") String title,
                                        @Param("categoryName") String categoryName, @Param("documentNo") String documentNo,
                                        @Param("userId") Long userId);

    List<OaDocument> selectManageDocumentList(@Param("status") String status, @Param("title") String title,
                                              @Param("categoryName") String categoryName, @Param("documentNo") String documentNo,
                                              @Param("userId") Long userId);

    OaDocument selectDocumentById(@Param("documentId") Long documentId, @Param("userId") Long userId);

    OaDocument selectManageDocumentById(@Param("documentId") Long documentId, @Param("userId") Long userId);

    int insertDocument(OaDocument document);

    int updateDocument(OaDocument document);

    int deleteDocumentByIds(@Param("documentIds") Long[] documentIds);

    int countDocumentByIds(@Param("documentIds") Long[] documentIds);

    int updateDocumentStatus(@Param("documentId") Long documentId, @Param("status") String status, @Param("updateBy") String updateBy);

    int saveReadLogConfirmed(@Param("documentId") Long documentId, @Param("userId") Long userId);
}
