package com.hospitaloa.system.service.impl;

import com.hospitaloa.common.core.exception.ServiceException;
import com.mongodb.client.gridfs.model.GridFSFile;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.data.mongodb.gridfs.GridFsOperations;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class OaDocumentGridFsService
{
    @Autowired
    private GridFsTemplate gridFsTemplate;

    @Autowired
    private GridFsOperations gridFsOperations;

    public String store(Long documentId, MultipartFile file) throws IOException
    {
        if (file == null || file.isEmpty())
        {
            throw new ServiceException("上传附件不能为空");
        }
        Document metadata = new Document();
        metadata.put("documentId", documentId);
        metadata.put("originalName", file.getOriginalFilename());
        metadata.put("contentType", file.getContentType());
        metadata.put("uploadTime", new Date());
        try (InputStream inputStream = file.getInputStream())
        {
            ObjectId objectId = gridFsTemplate.store(inputStream, file.getOriginalFilename(), file.getContentType(), metadata);
            return objectId.toHexString();
        }
    }

    public GridFsResource getResource(String mongoFileId)
    {
        GridFSFile gridFsFile = gridFsTemplate.findOne(Query.query(Criteria.where("_id").is(new ObjectId(mongoFileId))));
        if (gridFsFile == null)
        {
            throw new ServiceException("附件文件不存在");
        }
        return gridFsOperations.getResource(gridFsFile);
    }

    public void delete(String mongoFileId)
    {
        gridFsTemplate.delete(Query.query(Criteria.where("_id").is(new ObjectId(mongoFileId))));
    }
}
