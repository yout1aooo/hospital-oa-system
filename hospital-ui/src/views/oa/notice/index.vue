<template>
  <div class="app-container oa-page">
    <section class="oa-module-hero">
      <div>
        <div class="oa-module-kicker"><i class="el-icon-document" /> Documents</div>
        <h1 class="oa-module-title">制度文档</h1>
        <p class="oa-module-subtitle">集中处理制度阅读确认、附件查看与文档发布归档，让通知流转和制度留痕更清晰。</p>
      </div>
      <div class="oa-module-actions">
        <el-button v-if="hasDocumentManagePermission" type="primary" icon="el-icon-plus" @click="handleAddDocument" v-hasPermi="['oa:notice:document:add']">新增文档</el-button>
      </div>
    </section>

    <div class="oa-summary-grid" v-loading="workbenchLoading">
      <div v-for="item in documentSummary" :key="item.label" class="oa-stat-item">
        <div class="oa-stat-value">{{ item.value }}</div>
        <div class="oa-stat-label">{{ item.label }}</div>
      </div>
    </div>

    <section class="oa-section-card document-section" v-loading="documentLoading">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">文档工作台</h2>
          <div class="oa-section-note">{{ documentViewTab === 'read' ? '阅读中心' : '文档管理' }}</div>
        </div>
      </div>

          <el-tabs v-model="documentViewTab" class="oa-tabs">
            <el-tab-pane label="阅读中心" name="read" />
            <el-tab-pane label="文档管理" name="manage" v-if="hasDocumentManagePermission" />
          </el-tabs>

          <template v-if="documentViewTab === 'read'">
            <el-form :inline="true" :model="documentQuery" size="small">
              <el-form-item label="状态">
                <el-select v-model="documentQuery.tab" placeholder="全部文档" @change="getDocumentList">
                  <el-option label="全部文档" value="all" />
                  <el-option label="我的未读" value="unread" />
                  <el-option label="已确认" value="confirmed" />
                </el-select>
              </el-form-item>
              <el-form-item label="标题关键词">
                <el-input v-model="documentQuery.title" placeholder="请输入制度标题" clearable @keyup.enter.native="getDocumentList" />
              </el-form-item>
              <el-form-item label="分类">
                <el-input v-model="documentQuery.categoryName" placeholder="请输入分类" clearable @keyup.enter.native="getDocumentList" />
              </el-form-item>
              <el-form-item label="文档编号">
                <el-input v-model="documentQuery.documentNo" placeholder="请输入文档编号" clearable @keyup.enter.native="getDocumentList" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" size="mini" icon="el-icon-search" @click="getDocumentList">查询</el-button>
                <el-button size="mini" icon="el-icon-refresh" @click="resetDocumentQuery">重置</el-button>
              </el-form-item>
            </el-form>

            <div v-if="documentList.length" class="oa-record-grid">
              <article v-for="item in documentList" :key="item.documentId" class="oa-record-card doc-item">
                <div class="oa-record-head">
                  <div>
                    <div class="oa-record-title">{{ item.documentTitle }}</div>
                    <div class="oa-record-code">{{ item.categoryName || '未分类' }} ｜ {{ item.documentNo || '-' }}</div>
                  </div>
                  <el-tag size="mini" :type="readTagType(item.readStatus)">{{ item.readStatusLabel }}</el-tag>
                </div>
                <div class="oa-record-body">
                  <div class="oa-meta-row">
                    <i class="el-icon-folder-opened" />
                    <span class="oa-meta-text">{{ item.statusLabel || '-' }}</span>
                  </div>
                  <div class="oa-meta-row">
                    <i class="el-icon-time" />
                    <span class="oa-meta-text">{{ item.publishTime || '-' }}</span>
                  </div>
                </div>
                <div class="oa-action-row">
                  <el-button type="text" size="mini" @click="showDocumentDetail(item)">详情</el-button>
                  <el-button v-if="item.readStatus !== '2'" type="text" size="mini" @click="handleConfirmDocument(item)" v-hasPermi="['oa:notice:document:query']">确认已读</el-button>
                </div>
              </article>
            </div>
            <div v-else class="oa-empty-wrap">
              <el-empty description="暂无制度文档" :image-size="90" />
            </div>
          </template>

          <template v-else>
            <el-form :inline="true" :model="manageDocumentQuery" size="small">
              <el-form-item label="状态">
                <el-select v-model="manageDocumentQuery.status" placeholder="全部状态" clearable>
                  <el-option label="草稿" value="0" />
                  <el-option label="已发布" value="1" />
                  <el-option label="已归档" value="2" />
                </el-select>
              </el-form-item>
              <el-form-item label="标题关键词">
                <el-input v-model="manageDocumentQuery.title" placeholder="请输入制度标题" clearable @keyup.enter.native="getManageDocumentList" />
              </el-form-item>
              <el-form-item label="分类">
                <el-input v-model="manageDocumentQuery.categoryName" placeholder="请输入分类" clearable @keyup.enter.native="getManageDocumentList" />
              </el-form-item>
              <el-form-item label="文档编号">
                <el-input v-model="manageDocumentQuery.documentNo" placeholder="请输入文档编号" clearable @keyup.enter.native="getManageDocumentList" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" size="mini" icon="el-icon-search" @click="getManageDocumentList">查询</el-button>
                <el-button size="mini" icon="el-icon-refresh" @click="resetManageDocumentQuery">重置</el-button>
                <el-button type="success" size="mini" icon="el-icon-plus" @click="handleAddDocument" v-hasPermi="['oa:notice:document:add']">新增文档</el-button>
              </el-form-item>
            </el-form>

            <el-table :data="manageDocumentList">
              <el-table-column label="标题" prop="documentTitle" min-width="180" show-overflow-tooltip />
              <el-table-column label="分类" prop="categoryName" width="110" show-overflow-tooltip />
              <el-table-column label="编号" prop="documentNo" width="120" show-overflow-tooltip />
              <el-table-column label="状态" prop="statusLabel" width="90" />
              <el-table-column label="发布时间" prop="publishTime" width="160" />
              <el-table-column label="附件数" width="80">
                <template slot-scope="scope">
                  {{ (scope.row.attachmentList || []).length }}
                </template>
              </el-table-column>
              <el-table-column label="操作" min-width="250" align="center">
                <template slot-scope="scope">
                  <el-button type="text" size="mini" @click="showManageDocumentDetail(scope.row)">详情</el-button>
                  <el-button type="text" size="mini" @click="handleUpdateDocument(scope.row)" v-hasPermi="['oa:notice:document:edit']">编辑</el-button>
                  <el-button v-if="normalizeManageStatus(scope.row.status) !== '1'" type="text" size="mini" @click="handlePublishDocument(scope.row)" v-hasPermi="['oa:notice:document:publish']">发布</el-button>
                  <el-button v-if="normalizeManageStatus(scope.row.status) !== '2'" type="text" size="mini" @click="handleArchiveDocument(scope.row)" v-hasPermi="['oa:notice:document:archive']">归档</el-button>
                  <el-button type="text" size="mini" @click="handleDeleteDocument(scope.row)" v-hasPermi="['oa:notice:document:remove']">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
            <el-empty v-if="!manageDocumentList.length" description="暂无可管理文档" :image-size="90" />
          </template>
    </section>

    <el-dialog :title="documentDialogTitle" :visible.sync="documentDialogOpen" width="760px" append-to-body>
      <el-form ref="documentForm" :model="documentForm" :rules="documentRules" label-width="90px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="文档标题" prop="documentTitle">
              <el-input v-model="documentForm.documentTitle" placeholder="请输入文档标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文档编号">
              <el-input v-model="documentForm.documentNo" placeholder="请输入文档编号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类ID">
              <el-input v-model="documentForm.categoryId" placeholder="请输入分类ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类名称">
              <el-input v-model="documentForm.categoryName" placeholder="请输入分类名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文档类型">
              <el-input v-model="documentForm.documentType" placeholder="如：制度、规范、指引" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="发布状态">
              <el-radio-group v-model="documentForm.status">
                <el-radio label="0">草稿</el-radio>
                <el-radio label="1">已发布</el-radio>
                <el-radio label="2">已归档</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="附件管理">
              <div class="attachment-box">
                <div class="attachment-toolbar">
                  <el-upload
                    :action="uploadAction"
                    :headers="uploadHeaders"
                    :show-file-list="false"
                    :before-upload="beforeAttachmentUpload"
                    :on-success="handleAttachmentUploadSuccess"
                    :on-error="handleAttachmentUploadError"
                    :data="{}"
                    name="file"
                    :disabled="!documentForm.documentId || attachmentUploading">
                    <el-button size="mini" type="primary" :loading="attachmentUploading" :disabled="!documentForm.documentId || attachmentUploading">上传附件</el-button>
                  </el-upload>
                  <span class="attachment-tip">{{ documentForm.documentId ? '支持上传 PDF、Word、图片等文件，单个不超过 20MB。' : '请先保存制度文档，再上传附件。' }}</span>
                </div>
                <div v-if="documentAttachments.length" class="attachment-list">
                  <div v-for="item in documentAttachments" :key="item.attachmentId" class="attachment-item">
                    <div>
                      <div class="attachment-name">{{ item.originalName }}</div>
                      <div class="attachment-meta">{{ formatFileSize(item.fileSize) }} ｜ {{ item.contentType || '-' }}</div>
                    </div>
                    <div class="attachment-actions">
                      <el-button type="text" size="mini" @click="handleDownloadAttachment(item)">下载</el-button>
                      <el-button type="text" size="mini" @click="handleDeleteAttachment(item)" v-hasPermi="['oa:notice:document:edit']">删除</el-button>
                    </div>
                  </div>
                </div>
                <el-empty v-else description="暂无附件" :image-size="70" />
              </div>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="正文内容" prop="content">
              <editor v-model="documentForm.content" :min-height="220" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="documentForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitDocumentForm">确 定</el-button>
        <el-button @click="documentDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="制度详情" :visible.sync="documentDetailOpen" width="760px" append-to-body>
      <el-descriptions v-if="documentDetail" :column="1" border>
        <el-descriptions-item label="标题">{{ documentDetail.documentTitle }}</el-descriptions-item>
        <el-descriptions-item label="分类">{{ documentDetail.categoryName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="文档编号">{{ documentDetail.documentNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="文档类型">{{ documentDetail.documentType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发布状态">{{ documentDetail.statusLabel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="阅读状态">{{ documentDetail.readStatusLabel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发布时间">{{ documentDetail.publishTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="附件列表">
          <div v-if="documentDetail.attachmentList && documentDetail.attachmentList.length">
            <div v-for="item in documentDetail.attachmentList" :key="item.attachmentId" class="attachment-item attachment-item--detail">
              <div>
                <div class="attachment-name">{{ item.originalName }}</div>
                <div class="attachment-meta">{{ formatFileSize(item.fileSize) }} ｜ {{ item.contentType || '-' }}</div>
              </div>
              <div class="attachment-actions">
                <el-button type="text" size="mini" @click="handleDownloadAttachment(item)">下载</el-button>
              </div>
            </div>
          </div>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ documentDetail.remark || '-' }}</el-descriptions-item>
        <el-descriptions-item label="正文">
          <div class="detail-content" v-html="documentDetail.content || '-'" />
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script>
import {
  addDocument,
  archiveDocument,
  confirmDocument,
  delDocument,
  deleteDocumentAttachment,
  downloadDocumentAttachment,
  getDocument,
  getDocumentWorkbench,
  getManageDocument,
  listDocument,
  listManageDocument,
  publishDocument,
  updateDocument
} from '@/api/oa/document'
import { getToken } from '@/utils/auth'
import { saveAs } from 'file-saver'

export default {
  name: 'OaNoticeIndex',
  data() {
    return {
      workbenchLoading: false,
      documentLoading: false,
      attachmentUploading: false,
      documentList: [],
      manageDocumentList: [],
      documentAttachments: [],
      documentSummary: [
        { label: '全部文档', value: 0 },
        { label: '我的未读', value: 0 },
        { label: '已确认', value: 0 },
        { label: '管理文档', value: 0 }
      ],
      documentViewTab: 'read',
      documentDetail: null,
      documentDetailOpen: false,
      documentDialogOpen: false,
      documentQuery: {
        tab: 'all',
        title: undefined,
        categoryName: undefined,
        documentNo: undefined
      },
      manageDocumentQuery: {
        status: undefined,
        title: undefined,
        categoryName: undefined,
        documentNo: undefined
      },
      documentForm: {
        documentId: undefined,
        categoryId: undefined,
        categoryName: undefined,
        documentType: 'policy',
        documentTitle: undefined,
        documentNo: undefined,
        content: undefined,
        attachmentUrl: undefined,
        remark: undefined,
        status: '0'
      },
      documentRules: {
        documentTitle: [{ required: true, message: '文档标题不能为空', trigger: 'blur' }],
        content: [{ required: true, message: '正文内容不能为空', trigger: 'blur' }]
      },
      documentStatusMap: {
        draft: '0',
        published: '1',
        archived: '2'
      }
    }
  },
  computed: {
    documentDialogTitle() {
      return this.documentForm.documentId ? '编辑制度文档' : '新增制度文档'
    },
    hasDocumentManagePermission() {
      return this.$auth.hasPermiOr([
        'oa:notice:document:list',
        'oa:notice:document:add',
        'oa:notice:document:edit',
        'oa:notice:document:remove',
        'oa:notice:document:publish',
        'oa:notice:document:archive'
      ])
    },
    uploadAction() {
      return process.env.VUE_APP_BASE_API + '/system/document/' + this.documentForm.documentId + '/attachments/upload'
    },
    uploadHeaders() {
      return {
        Authorization: 'Bearer ' + getToken()
      }
    }
  },
  created() {
    this.documentQuery.tab = this.normalizeDocumentTab(this.$route.query.documentTab)
    this.syncQuery()
    this.getWorkbench()
    this.getDocumentList()
    if (this.hasDocumentManagePermission) {
      this.getManageDocumentList()
    }
  },
  watch: {
    '$route.query.documentTab'(value) {
      const tab = this.normalizeDocumentTab(value)
      const changed = tab !== this.documentQuery.tab
      this.documentQuery.tab = tab
      if (tab !== value) {
        this.syncQuery()
        return
      }
      if (changed) {
        this.getDocumentList()
      }
    }
  },
  methods: {
    normalizeDocumentTab(tab) {
      return ['all', 'unread', 'confirmed'].includes(tab) ? tab : 'all'
    },
    normalizeManageStatus(status) {
      if (status === undefined || status === null || status === '') {
        return undefined
      }
      return this.documentStatusMap[status] || status
    },
    getWorkbench() {
      this.workbenchLoading = true
      getDocumentWorkbench().then(res => {
        const data = res.data || {}
        this.documentSummary = data.summary || this.documentSummary
        this.workbenchLoading = false
      }).catch(() => {
        this.workbenchLoading = false
      })
    },
    syncQuery() {
      const query = { ...this.$route.query }
      if (this.documentQuery.tab === 'all') {
        delete query.documentTab
      } else {
        query.documentTab = this.documentQuery.tab
      }
      this.$router.replace({ query })
    },
    getDocumentList() {
      this.documentLoading = true
      this.syncQuery()
      listDocument(this.documentQuery).then(res => {
        this.documentList = res.rows || []
        this.documentLoading = false
      }).catch(() => {
        this.documentLoading = false
      })
    },
    getManageDocumentList() {
      this.documentLoading = true
      const query = {
        ...this.manageDocumentQuery,
        status: this.normalizeManageStatus(this.manageDocumentQuery.status)
      }
      listManageDocument(query).then(res => {
        this.manageDocumentList = res.rows || []
        this.documentLoading = false
      }).catch(() => {
        this.documentLoading = false
      })
    },
    resetDocumentQuery() {
      this.documentQuery = {
        tab: 'all',
        title: undefined,
        categoryName: undefined,
        documentNo: undefined
      }
      this.syncQuery()
      this.getDocumentList()
    },
    resetManageDocumentQuery() {
      this.manageDocumentQuery = {
        status: undefined,
        title: undefined,
        categoryName: undefined,
        documentNo: undefined
      }
      this.getManageDocumentList()
    },
    resetDocumentFormData() {
      this.documentForm = {
        documentId: undefined,
        categoryId: undefined,
        categoryName: undefined,
        documentType: 'policy',
        documentTitle: undefined,
        documentNo: undefined,
        content: undefined,
        attachmentUrl: undefined,
        remark: undefined,
        status: '0'
      }
      this.documentAttachments = []
      this.attachmentUploading = false
    },
    loadDocumentAttachments(documentId) {
      if (!documentId) {
        this.documentAttachments = []
        return Promise.resolve()
      }
      return getManageDocument(documentId).then(res => {
        this.documentAttachments = res.data.attachmentList || []
      })
    },
    showDocumentDetail(row) {
      getDocument(row.documentId).then(res => {
        this.documentDetail = res.data
        this.documentDetailOpen = true
      })
    },
    showManageDocumentDetail(row) {
      getManageDocument(row.documentId).then(res => {
        this.documentDetail = {
          ...res.data,
          readStatusLabel: res.data.readStatusLabel || '-'
        }
        this.documentDetailOpen = true
      })
    },
    handleConfirmDocument(row) {
      confirmDocument(row.documentId).then(() => {
        this.$modal.msgSuccess('阅读确认成功')
        this.getWorkbench()
        this.getDocumentList()
        if (this.documentDetail && this.documentDetail.documentId === row.documentId) {
          this.showDocumentDetail(row)
        }
      })
    },
    handleAddDocument() {
      this.resetDocumentFormData()
      this.documentDialogOpen = true
      this.$nextTick(() => {
        this.$refs.documentForm && this.$refs.documentForm.clearValidate()
      })
    },
    handleUpdateDocument(row) {
      getManageDocument(row.documentId).then(res => {
        this.documentForm = {
          ...res.data,
          categoryId: res.data.categoryId === null || res.data.categoryId === undefined ? undefined : String(res.data.categoryId),
          status: this.normalizeManageStatus(res.data.status) || '0',
          documentType: res.data.documentType || 'policy',
          remark: res.data.remark
        }
        this.documentAttachments = res.data.attachmentList || []
        this.documentDialogOpen = true
        this.$nextTick(() => {
          this.$refs.documentForm && this.$refs.documentForm.clearValidate()
        })
      })
    },
    submitDocumentForm() {
      this.$refs.documentForm.validate(valid => {
        if (!valid) {
          return
        }
        const payload = {
          ...this.documentForm,
          categoryId: this.documentForm.categoryId === '' || this.documentForm.categoryId === null || this.documentForm.categoryId === undefined
            ? undefined
            : Number(this.documentForm.categoryId),
          documentType: this.documentForm.documentType || 'policy',
          status: this.normalizeManageStatus(this.documentForm.status) || '0',
          attachmentUrl: this.documentForm.attachmentUrl || ''
        }
        const request = payload.documentId ? updateDocument(payload) : addDocument(payload)
        request.then(res => {
          this.$modal.msgSuccess(payload.documentId ? '编辑成功' : '新增成功')
          this.documentForm = {
            ...res.data,
            categoryId: res.data.categoryId === null || res.data.categoryId === undefined ? undefined : String(res.data.categoryId),
            status: this.normalizeManageStatus(res.data.status) || '0'
          }
          this.documentAttachments = res.data.attachmentList || []
          if (!payload.documentId) {
            this.$modal.msgSuccess('文档已保存，可继续上传附件')
          }
          this.getWorkbench()
          this.getManageDocumentList()
          this.getDocumentList()
        })
      })
    },
    beforeAttachmentUpload(file) {
      if (!this.documentForm.documentId) {
        this.$message.warning('请先保存制度文档，再上传附件')
        return false
      }
      if (file.size > 20 * 1024 * 1024) {
        this.$message.error('附件大小不能超过20MB')
        return false
      }
      this.attachmentUploading = true
      return true
    },
    handleAttachmentUploadSuccess(response) {
      this.attachmentUploading = false
      if (response.code !== 200) {
        this.$message.error(response.msg || '附件上传失败')
        return
      }
      this.$modal.msgSuccess('附件上传成功')
      this.loadDocumentAttachments(this.documentForm.documentId)
      this.getManageDocumentList()
      if (this.documentDetail && this.documentDetail.documentId === this.documentForm.documentId) {
        this.showManageDocumentDetail({ documentId: this.documentForm.documentId })
      }
    },
    handleAttachmentUploadError() {
      this.attachmentUploading = false
      this.$message.error('附件上传失败')
    },
    handleDeleteAttachment(item) {
      this.$modal.confirm('是否确认删除附件“' + item.originalName + '”？').then(() => {
        return deleteDocumentAttachment(item.attachmentId)
      }).then(() => {
        this.$modal.msgSuccess('删除成功')
        return this.loadDocumentAttachments(this.documentForm.documentId)
      }).then(() => {
        this.getManageDocumentList()
      }).catch(() => {
        this.attachmentUploading = false
      })
    },
    handleDownloadAttachment(item) {
      downloadDocumentAttachment(item.attachmentId).then(data => {
        saveAs(new Blob([data]), item.originalName)
      })
    },
    handlePublishDocument(row) {
      this.$modal.confirm('是否确认发布制度文档“' + row.documentTitle + '”？').then(() => {
        return publishDocument(row.documentId)
      }).then(() => {
        this.$modal.msgSuccess('发布成功')
        this.getWorkbench()
        this.getManageDocumentList()
        this.getDocumentList()
      }).catch(() => {})
    },
    handleArchiveDocument(row) {
      this.$modal.confirm('是否确认归档制度文档“' + row.documentTitle + '”？').then(() => {
        return archiveDocument(row.documentId)
      }).then(() => {
        this.$modal.msgSuccess('归档成功')
        this.getWorkbench()
        this.getManageDocumentList()
        this.getDocumentList()
      }).catch(() => {})
    },
    handleDeleteDocument(row) {
      this.$modal.confirm('是否确认删除制度文档“' + row.documentTitle + '”？').then(() => {
        return delDocument(row.documentId)
      }).then(() => {
        this.$modal.msgSuccess('删除成功')
        this.getWorkbench()
        this.getManageDocumentList()
        this.getDocumentList()
      }).catch(() => {})
    },
    formatFileSize(size) {
      if (size === undefined || size === null) {
        return '-'
      }
      if (size < 1024) {
        return size + ' B'
      }
      if (size < 1024 * 1024) {
        return (size / 1024).toFixed(1) + ' KB'
      }
      return (size / (1024 * 1024)).toFixed(1) + ' MB'
    },
    readTagType(status) {
      if (status === '2') {
        return 'success'
      }
      if (status === '1') {
        return 'warning'
      }
      return 'info'
    }
  }
}
</script>

<style scoped lang="scss">
.oa-page {
  .document-section {
    ::v-deep .el-form-item {
      margin-bottom: 10px;
    }
  }

  .detail-content {
    line-height: 1.8;
    color: #606266;
    word-break: break-all;
  }

  .attachment-box {
    border: 1px solid #ebeef5;
    border-radius: 8px;
    padding: 12px;
  }

  .attachment-toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
    flex-wrap: wrap;
  }

  .attachment-tip {
    font-size: 12px;
    color: #909399;
  }

  .attachment-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .attachment-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 10px 12px;
    background: #f8f9fb;
    border-radius: 8px;
  }

  .attachment-item--detail {
    margin-bottom: 8px;
  }

  .attachment-name {
    font-size: 13px;
    font-weight: 600;
    color: #303133;
  }

  .attachment-meta {
    margin-top: 4px;
    font-size: 12px;
    color: #909399;
  }

  .attachment-actions {
    white-space: nowrap;
  }
}
</style>
