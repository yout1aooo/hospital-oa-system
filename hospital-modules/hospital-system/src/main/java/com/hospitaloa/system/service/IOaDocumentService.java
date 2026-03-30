package com.hospitaloa.system.service;

import com.hospitaloa.system.domain.OaDocument;
import com.hospitaloa.system.domain.OaDocumentAttachment;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.multipart.MultipartFile;

public interface IOaDocumentService
{
    Map<String, Object> getWorkbench();

    List<OaDocument> selectDocumentList(String tab, String title, String categoryName, String documentNo);

    List<OaDocument> selectManageDocumentList(String status, String title, String categoryName, String documentNo);

    OaDocument selectDocumentById(Long documentId);

    OaDocument selectManageDocumentById(Long documentId);

    OaDocument insertDocument(OaDocument document);

    OaDocument updateDocument(OaDocument document);

    int deleteDocumentByIds(Long[] documentIds);

    OaDocument publishDocument(Long documentId);

    OaDocument archiveDocument(Long documentId);

    OaDocument confirmRead(Long documentId);

    List<OaDocumentAttachment> selectAttachmentList(Long documentId);

    OaDocumentAttachment uploadAttachment(Long documentId, MultipartFile file) throws IOException;

    void downloadAttachment(Long attachmentId, HttpServletResponse response) throws IOException;

    int deleteAttachment(Long attachmentId);
}
