package com.hospitaloa.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.hospitaloa.common.core.web.domain.BaseEntity;
import java.util.Date;
import java.util.List;

public class OaDocument extends BaseEntity
{
    private Long documentId;
    private Long categoryId;
    private String categoryName;
    private String documentType;
    private String documentTitle;
    private String documentNo;
    private String content;
    private String attachmentUrl;
    private String status;
    private String statusLabel;
    private String readStatus;
    private String readStatusLabel;
    private List<OaDocumentAttachment> attachmentList;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date publishTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date readTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date confirmTime;

    public Long getDocumentId() { return documentId; }
    public void setDocumentId(Long documentId) { this.documentId = documentId; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getDocumentType() { return documentType; }
    public void setDocumentType(String documentType) { this.documentType = documentType; }
    public String getDocumentTitle() { return documentTitle; }
    public void setDocumentTitle(String documentTitle) { this.documentTitle = documentTitle; }
    public String getDocumentNo() { return documentNo; }
    public void setDocumentNo(String documentNo) { this.documentNo = documentNo; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStatusLabel() { return statusLabel; }
    public void setStatusLabel(String statusLabel) { this.statusLabel = statusLabel; }
    public String getReadStatus() { return readStatus; }
    public void setReadStatus(String readStatus) { this.readStatus = readStatus; }
    public String getReadStatusLabel() { return readStatusLabel; }
    public void setReadStatusLabel(String readStatusLabel) { this.readStatusLabel = readStatusLabel; }
    public List<OaDocumentAttachment> getAttachmentList() { return attachmentList; }
    public void setAttachmentList(List<OaDocumentAttachment> attachmentList) { this.attachmentList = attachmentList; }
    public Date getPublishTime() { return publishTime; }
    public void setPublishTime(Date publishTime) { this.publishTime = publishTime; }
    public Date getReadTime() { return readTime; }
    public void setReadTime(Date readTime) { this.readTime = readTime; }
    public Date getConfirmTime() { return confirmTime; }
    public void setConfirmTime(Date confirmTime) { this.confirmTime = confirmTime; }
}
