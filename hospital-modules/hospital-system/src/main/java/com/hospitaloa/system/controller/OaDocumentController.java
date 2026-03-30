package com.hospitaloa.system.controller;

import com.hospitaloa.common.core.web.domain.AjaxResult;
import com.hospitaloa.common.core.web.page.TableDataInfo;
import com.hospitaloa.common.log.annotation.Log;
import com.hospitaloa.common.log.enums.BusinessType;
import com.hospitaloa.common.security.annotation.RequiresPermissions;
import com.hospitaloa.system.domain.OaDocument;
import com.hospitaloa.system.service.IOaDocumentService;
import java.io.IOException;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/document")
public class OaDocumentController
{
    @Autowired
    private IOaDocumentService documentService;

    @RequiresPermissions("oa:notice:document:list")
    @GetMapping("/workbench")
    public AjaxResult workbench()
    {
        return AjaxResult.success(documentService.getWorkbench());
    }

    @RequiresPermissions("oa:notice:document:list")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false, defaultValue = "all") String tab,
                              @RequestParam(required = false) String title,
                              @RequestParam(required = false) String categoryName,
                              @RequestParam(required = false) String documentNo)
    {
        List<OaDocument> list = documentService.selectDocumentList(tab, title, categoryName, documentNo);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions("oa:notice:document:list")
    @GetMapping("/manage/list")
    public TableDataInfo manageList(@RequestParam(required = false) String status,
                                    @RequestParam(required = false) String title,
                                    @RequestParam(required = false) String categoryName,
                                    @RequestParam(required = false) String documentNo)
    {
        List<OaDocument> list = documentService.selectManageDocumentList(status, title, categoryName, documentNo);
        TableDataInfo rspData = new TableDataInfo();
        rspData.setCode(200);
        rspData.setMsg("查询成功");
        rspData.setRows(list);
        rspData.setTotal(list.size());
        return rspData;
    }

    @RequiresPermissions("oa:notice:document:query")
    @GetMapping("/{documentId}")
    public AjaxResult getInfo(@PathVariable Long documentId)
    {
        return AjaxResult.success(documentService.selectDocumentById(documentId));
    }

    @RequiresPermissions("oa:notice:document:list")
    @GetMapping("/manage/{documentId}")
    public AjaxResult getManageInfo(@PathVariable Long documentId)
    {
        return AjaxResult.success(documentService.selectManageDocumentById(documentId));
    }

    @RequiresPermissions("oa:notice:document:add")
    @Log(title = "制度文档", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody OaDocument document)
    {
        return AjaxResult.success("新增成功", documentService.insertDocument(document));
    }

    @RequiresPermissions("oa:notice:document:edit")
    @Log(title = "制度文档", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody OaDocument document)
    {
        return AjaxResult.success("修改成功", documentService.updateDocument(document));
    }

    @RequiresPermissions("oa:notice:document:remove")
    @Log(title = "制度文档", businessType = BusinessType.DELETE)
    @DeleteMapping("/{documentIds}")
    public AjaxResult remove(@PathVariable Long[] documentIds)
    {
        return AjaxResult.success(documentService.deleteDocumentByIds(documentIds));
    }

    @RequiresPermissions("oa:notice:document:publish")
    @PostMapping("/{documentId}/publish")
    public AjaxResult publish(@PathVariable Long documentId)
    {
        return AjaxResult.success("发布成功", documentService.publishDocument(documentId));
    }

    @RequiresPermissions("oa:notice:document:archive")
    @PostMapping("/{documentId}/archive")
    public AjaxResult archive(@PathVariable Long documentId)
    {
        return AjaxResult.success("归档成功", documentService.archiveDocument(documentId));
    }

    @RequiresPermissions("oa:notice:document:query")
    @PostMapping("/{documentId}/confirm")
    public AjaxResult confirm(@PathVariable Long documentId)
    {
        return AjaxResult.success("阅读确认成功", documentService.confirmRead(documentId));
    }

    @RequiresPermissions("oa:notice:document:query")
    @GetMapping("/{documentId}/attachments")
    public AjaxResult attachmentList(@PathVariable Long documentId)
    {
        return AjaxResult.success(documentService.selectAttachmentList(documentId));
    }

    @RequiresPermissions("oa:notice:document:edit")
    @Log(title = "制度文档附件", businessType = BusinessType.INSERT)
    @PostMapping("/{documentId}/attachments/upload")
    public AjaxResult uploadAttachment(@PathVariable Long documentId, @RequestParam("file") MultipartFile file) throws IOException
    {
        return AjaxResult.success("上传成功", documentService.uploadAttachment(documentId, file));
    }

    @RequiresPermissions("oa:notice:document:query")
    @GetMapping("/attachment/{attachmentId}/download")
    public void downloadAttachment(@PathVariable Long attachmentId, HttpServletResponse response) throws IOException
    {
        documentService.downloadAttachment(attachmentId, response);
    }

    @RequiresPermissions("oa:notice:document:edit")
    @Log(title = "制度文档附件", businessType = BusinessType.DELETE)
    @DeleteMapping("/attachment/{attachmentId}")
    public AjaxResult deleteAttachment(@PathVariable Long attachmentId)
    {
        return AjaxResult.success(documentService.deleteAttachment(attachmentId));
    }
}
