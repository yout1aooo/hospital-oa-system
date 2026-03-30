package com.hospitaloa.system.mapper;

import com.hospitaloa.system.domain.OaDocumentAttachment;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface OaDocumentAttachmentMapper
{
    List<OaDocumentAttachment> selectAttachmentListByDocumentId(@Param("documentId") Long documentId);

    OaDocumentAttachment selectAttachmentById(@Param("attachmentId") Long attachmentId);

    int countAttachmentByDocumentId(@Param("documentId") Long documentId);

    int insertAttachment(OaDocumentAttachment attachment);

    int deleteAttachmentById(@Param("attachmentId") Long attachmentId);

    int deleteAttachmentByDocumentIds(@Param("documentIds") Long[] documentIds);
}
