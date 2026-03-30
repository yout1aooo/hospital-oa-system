package com.hospitaloa.system.service.impl;

import com.hospitaloa.common.core.domain.R;
import com.hospitaloa.common.core.exception.ServiceException;
import com.hospitaloa.common.core.utils.StringUtils;
import com.hospitaloa.common.core.utils.file.FileUtils;
import com.hospitaloa.common.security.utils.SecurityUtils;
import com.hospitaloa.system.api.RemoteFileService;
import com.hospitaloa.system.api.domain.SysFile;
import com.hospitaloa.system.domain.OaDocument;
import com.hospitaloa.system.domain.OaDocumentAttachment;
import com.hospitaloa.system.mapper.OaDocumentAttachmentMapper;
import com.hospitaloa.system.mapper.OaDocumentMapper;
import com.hospitaloa.system.service.IOaDocumentService;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class OaDocumentServiceImpl implements IOaDocumentService
{
    private static final long MAX_ATTACHMENT_SIZE = 20L * 1024 * 1024;

    @Autowired
    private OaDocumentMapper documentMapper;

    @Autowired
    private OaDocumentAttachmentMapper attachmentMapper;

    @Autowired
    private OaDocumentGridFsService gridFsService;

    @Autowired
    private RemoteFileService remoteFileService;

    @Override
    public Map<String, Object> getWorkbench()
    {
        Map<String, Object> result = new LinkedHashMap<>();
        List<OaDocument> allList = selectDocumentList("all", null, null, null);
        List<OaDocument> unreadList = selectDocumentList("unread", null, null, null);
        List<OaDocument> confirmedList = selectDocumentList("confirmed", null, null, null);
        result.put("summary", Arrays.asList(
            buildSummary("制度总数", allList.size()),
            buildSummary("我的未读", unreadList.size()),
            buildSummary("已确认", confirmedList.size())
        ));
        result.put("recentDocuments", allList.stream().limit(5).toArray());
        result.put("unreadDocuments", unreadList.stream().limit(5).toArray());
        return result;
    }

    @Override
    public List<OaDocument> selectDocumentList(String tab, String title, String categoryName, String documentNo)
    {
        return documentMapper.selectDocumentList(tab, title, categoryName, documentNo, SecurityUtils.getUserId());
    }

    @Override
    public List<OaDocument> selectManageDocumentList(String status, String title, String categoryName, String documentNo)
    {
        return documentMapper.selectManageDocumentList(status, title, categoryName, documentNo, SecurityUtils.getUserId());
    }

    @Override
    public OaDocument selectDocumentById(Long documentId)
    {
        OaDocument document = documentMapper.selectDocumentById(documentId, SecurityUtils.getUserId());
        return withAttachments(document);
    }

    @Override
    public OaDocument selectManageDocumentById(Long documentId)
    {
        OaDocument document = documentMapper.selectManageDocumentById(documentId, SecurityUtils.getUserId());
        return withAttachments(document);
    }

    @Override
    public OaDocument insertDocument(OaDocument document)
    {
        document.setStatus(defaultValue(document.getStatus(), "0"));
        document.setDocumentType(defaultValue(document.getDocumentType(), "policy"));
        if ("1".equals(document.getStatus()) && document.getPublishTime() == null)
        {
            document.setPublishTime(new Date());
        }
        document.setAttachmentUrl(defaultValue(document.getAttachmentUrl(), ""));
        document.setCreateBy(SecurityUtils.getUsername());
        documentMapper.insertDocument(document);
        return selectManageDocumentById(document.getDocumentId());
    }

    @Override
    public OaDocument updateDocument(OaDocument document)
    {
        OaDocument existing = requireManageDocument(document.getDocumentId());
        if (document.getPublishTime() == null && "1".equals(document.getStatus()) && existing.getPublishTime() == null)
        {
            document.setPublishTime(new Date());
        }
        document.setUpdateBy(SecurityUtils.getUsername());
        documentMapper.updateDocument(document);
        return selectManageDocumentById(document.getDocumentId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteDocumentByIds(Long[] documentIds)
    {
        if (documentIds == null || documentIds.length == 0)
        {
            return 0;
        }
        if (documentMapper.countDocumentByIds(documentIds) != documentIds.length)
        {
            throw new ServiceException("制度文档不存在");
        }
        for (Long documentId : documentIds)
        {
            List<OaDocumentAttachment> attachmentList = attachmentMapper.selectAttachmentListByDocumentId(documentId);
            for (OaDocumentAttachment attachment : attachmentList)
            {
                deleteAttachmentFile(attachment);
            }
        }
        attachmentMapper.deleteAttachmentByDocumentIds(documentIds);
        return documentMapper.deleteDocumentByIds(documentIds);
    }

    @Override
    public OaDocument publishDocument(Long documentId)
    {
        requireManageDocument(documentId);
        documentMapper.updateDocumentStatus(documentId, "1", SecurityUtils.getUsername());
        return selectManageDocumentById(documentId);
    }

    @Override
    public OaDocument archiveDocument(Long documentId)
    {
        requireManageDocument(documentId);
        documentMapper.updateDocumentStatus(documentId, "2", SecurityUtils.getUsername());
        return selectManageDocumentById(documentId);
    }

    @Override
    public OaDocument confirmRead(Long documentId)
    {
        requireReadDocument(documentId);
        Long userId = SecurityUtils.getUserId();
        documentMapper.saveReadLogConfirmed(documentId, userId);
        return withAttachments(documentMapper.selectDocumentById(documentId, userId));
    }

    @Override
    public List<OaDocumentAttachment> selectAttachmentList(Long documentId)
    {
        requireReadDocument(documentId);
        return attachmentMapper.selectAttachmentListByDocumentId(documentId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public OaDocumentAttachment uploadAttachment(Long documentId, MultipartFile file) throws IOException
    {
        OaDocument document = requireManageDocument(documentId);
        validateFile(file);
        R<SysFile> uploadResult = remoteFileService.upload(file);
        if (R.isError(uploadResult) || uploadResult.getData() == null || StringUtils.isEmpty(uploadResult.getData().getUrl()))
        {
            throw new ServiceException(defaultValue(uploadResult.getMsg(), "上传附件失败"));
        }
        SysFile sysFile = uploadResult.getData();
        OaDocumentAttachment attachment = new OaDocumentAttachment();
        attachment.setDocumentId(document.getDocumentId());
        attachment.setFileName(defaultValue(sysFile.getName(), buildStoredFileName(file.getOriginalFilename())));
        attachment.setOriginalName(defaultValue(file.getOriginalFilename(), "附件"));
        attachment.setContentType(defaultValue(file.getContentType(), "application/octet-stream"));
        attachment.setFileSize(file.getSize());
        attachment.setFileUrl(sysFile.getUrl());
        attachment.setMongoFileId("");
        attachment.setSortOrder(attachmentMapper.countAttachmentByDocumentId(documentId) + 1);
        attachment.setCreateBy(SecurityUtils.getUsername());
        attachmentMapper.insertAttachment(attachment);
        return attachmentMapper.selectAttachmentById(attachment.getAttachmentId());
    }

    @Override
    public void downloadAttachment(Long attachmentId, HttpServletResponse response) throws IOException
    {
        OaDocumentAttachment attachment = requireAttachment(attachmentId);
        requireReadDocument(attachment.getDocumentId());
        response.reset();
        FileUtils.setAttachmentResponseHeader(response, attachment.getOriginalName());
        if (attachment.getFileSize() != null)
        {
            response.addHeader("Content-Length", String.valueOf(attachment.getFileSize()));
        }
        if (StringUtils.isNotEmpty(attachment.getFileUrl()))
        {
            downloadByFileUrl(attachment, response);
            return;
        }
        if (StringUtils.isEmpty(attachment.getMongoFileId()))
        {
            throw new ServiceException("附件文件不存在");
        }
        GridFsResource resource = gridFsService.getResource(attachment.getMongoFileId());
        response.setContentType(defaultValue(resource.getContentType(), "application/octet-stream"));
        try (InputStream inputStream = resource.getInputStream(); ServletOutputStream outputStream = response.getOutputStream())
        {
            copyToResponse(inputStream, outputStream);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteAttachment(Long attachmentId)
    {
        OaDocumentAttachment attachment = requireAttachment(attachmentId);
        requireManageDocument(attachment.getDocumentId());
        deleteAttachmentFile(attachment);
        return attachmentMapper.deleteAttachmentById(attachmentId);
    }

    private OaDocument withAttachments(OaDocument document)
    {
        if (document != null)
        {
            document.setAttachmentList(attachmentMapper.selectAttachmentListByDocumentId(document.getDocumentId()));
        }
        return document;
    }

    private OaDocument requireManageDocument(Long documentId)
    {
        OaDocument document = documentMapper.selectManageDocumentById(documentId, SecurityUtils.getUserId());
        if (document == null)
        {
            throw new ServiceException("制度文档不存在");
        }
        return document;
    }

    private OaDocument requireReadDocument(Long documentId)
    {
        OaDocument document = documentMapper.selectDocumentById(documentId, SecurityUtils.getUserId());
        if (document == null)
        {
            throw new ServiceException("制度文档不存在或无权限访问");
        }
        return document;
    }

    private OaDocumentAttachment requireAttachment(Long attachmentId)
    {
        OaDocumentAttachment attachment = attachmentMapper.selectAttachmentById(attachmentId);
        if (attachment == null)
        {
            throw new ServiceException("附件不存在");
        }
        return attachment;
    }

    private void validateFile(MultipartFile file)
    {
        if (file == null || file.isEmpty())
        {
            throw new ServiceException("上传附件不能为空");
        }
        if (file.getSize() > MAX_ATTACHMENT_SIZE)
        {
            throw new ServiceException("附件大小不能超过20MB");
        }
        if (StringUtils.isEmpty(file.getOriginalFilename()))
        {
            throw new ServiceException("附件文件名不能为空");
        }
    }

    private void downloadByFileUrl(OaDocumentAttachment attachment, HttpServletResponse response) throws IOException
    {
        URLConnection connection = new URL(attachment.getFileUrl()).openConnection();
        connection.connect();
        response.setContentType(defaultValue(connection.getContentType(), defaultValue(attachment.getContentType(), "application/octet-stream")));
        try (InputStream inputStream = connection.getInputStream(); ServletOutputStream outputStream = response.getOutputStream())
        {
            copyToResponse(inputStream, outputStream);
        }
    }

    private void deleteAttachmentFile(OaDocumentAttachment attachment)
    {
        if (StringUtils.isNotEmpty(attachment.getFileUrl()))
        {
            R<Boolean> deleteResult = remoteFileService.delete(attachment.getFileUrl());
            if (R.isError(deleteResult))
            {
                throw new ServiceException(defaultValue(deleteResult.getMsg(), "删除附件失败"));
            }
            return;
        }
        if (StringUtils.isNotEmpty(attachment.getMongoFileId()))
        {
            gridFsService.delete(attachment.getMongoFileId());
        }
    }

    private void copyToResponse(InputStream inputStream, ServletOutputStream outputStream) throws IOException
    {
        byte[] buffer = new byte[8192];
        int length;
        while ((length = inputStream.read(buffer)) != -1)
        {
            outputStream.write(buffer, 0, length);
        }
        outputStream.flush();
    }

    private Map<String, Object> buildSummary(String label, int value)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("label", label);
        item.put("value", value);
        return item;
    }

    private String buildStoredFileName(String originalName)
    {
        String fileName = defaultValue(originalName, "attachment");
        return System.currentTimeMillis() + "_" + fileName.replaceAll("\\s+", "_");
    }

    private String defaultValue(String value, String defaultValue)
    {
        return value == null || value.isEmpty() ? defaultValue : value;
    }
}
