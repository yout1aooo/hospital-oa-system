<template>
  <div class="app-container oa-page">
    <el-card shadow="never" class="summary-card">
      <div slot="header" class="clearfix">
        <span>审批中心</span>
      </div>
      <el-alert
        title="当前已接入请假、报销第一版申请流程，并支持审批通过、驳回与重新提交。"
        type="success"
        :closable="false"
        show-icon />
      <el-row :gutter="16" class="summary-row">
        <el-col v-for="item in summaries" :key="item.label" :xs="24" :sm="8">
          <div class="summary-item">
            <div class="summary-value">{{ item.value }}</div>
            <div class="summary-label">{{ item.label }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-card shadow="never" class="query-card">
      <el-form :inline="true" :model="queryParams" size="small">
        <el-form-item label="流程类型">
          <el-select v-model="queryParams.processType" placeholder="全部类型" clearable>
            <el-option v-for="item in processTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="标题关键词">
          <el-input v-model="queryParams.title" placeholder="请输入申请标题" clearable @keyup.enter.native="getList" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="mini" icon="el-icon-search" @click="getList">查询</el-button>
          <el-button size="mini" icon="el-icon-refresh" @click="resetQuery">重置</el-button>
          <el-button v-hasPermi="['oa:workflow:apply:add']" type="success" size="mini" icon="el-icon-plus" @click="openDialog('leave')">发起请假</el-button>
          <el-button v-hasPermi="['oa:workflow:apply:add']" type="warning" size="mini" icon="el-icon-plus" @click="openDialog('expense')">发起报销</el-button>
        </el-form-item>
      </el-form>

      <el-tabs v-model="queryParams.tab" @tab-click="handleTabChange">
        <el-tab-pane label="我的申请" name="apply" />
        <el-tab-pane label="我的待办" name="todo" />
        <el-tab-pane label="我的已办" name="done" />
      </el-tabs>

      <el-table v-loading="loading" :data="applyList">
        <el-table-column label="单号" prop="formNo" min-width="170" />
        <el-table-column label="流程类型" prop="processTypeLabel" width="110" />
        <el-table-column label="标题" prop="title" min-width="220" show-overflow-tooltip />
        <el-table-column label="申请人" prop="applicantName" width="100" />
        <el-table-column label="当前环节" prop="currentHandlerName" width="140" />
        <el-table-column label="状态" prop="statusLabel" width="100">
          <template slot-scope="scope">
            <el-tag :type="tagType(scope.row.status)">{{ scope.row.statusLabel }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="提交时间" prop="submitTime" width="180" />
        <el-table-column label="操作" width="260" align="center">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="showDetail(scope.row)">详情</el-button>
            <el-button v-if="queryParams.tab === 'todo' && hasTodoActionPermission" type="text" size="mini" @click="handleApprove(scope.row)">通过</el-button>
            <el-button v-if="queryParams.tab === 'todo' && hasTodoActionPermission" type="text" size="mini" @click="handleReject(scope.row)">驳回</el-button>
            <el-button v-if="canResubmit(scope.row)" type="text" size="mini" @click="openResubmitDialog(scope.row)">重新提交</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog :title="dialogTitle" :visible.sync="dialogOpen" width="620px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="流程类型">
          <el-input :value="form.processType === 'leave' ? '请假申请' : '报销申请'" disabled />
        </el-form-item>
        <el-form-item label="申请标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入申请标题" />
        </el-form-item>
        <template v-if="form.processType === 'leave'">
          <el-form-item label="开始日期" prop="startDate">
            <el-date-picker v-model="form.startDate" type="date" value-format="yyyy-MM-dd" placeholder="选择开始日期" />
          </el-form-item>
          <el-form-item label="结束日期" prop="endDate">
            <el-date-picker v-model="form.endDate" type="date" value-format="yyyy-MM-dd" placeholder="选择结束日期" />
          </el-form-item>
        </template>
        <template v-else>
          <el-form-item label="报销金额" prop="amount">
            <el-input-number v-model="form.amount" :min="0" :precision="2" :step="100" controls-position="right" />
          </el-form-item>
        </template>
        <el-form-item label="申请事由" prop="reason">
          <el-input v-model="form.reason" type="textarea" :rows="4" placeholder="请输入申请说明" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">提 交</el-button>
        <el-button @click="dialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="审批意见" :visible.sync="actionOpen" width="520px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="审批意见">
          <el-input v-model="actionComment" type="textarea" :rows="4" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitAction">确 定</el-button>
        <el-button @click="actionOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="申请详情" :visible.sync="detailOpen" width="760px" append-to-body>
      <el-descriptions v-if="detail" :column="1" border>
        <el-descriptions-item label="单号">{{ detail.formNo }}</el-descriptions-item>
        <el-descriptions-item label="流程类型">{{ detail.processTypeLabel }}</el-descriptions-item>
        <el-descriptions-item label="申请标题">{{ detail.title }}</el-descriptions-item>
        <el-descriptions-item label="申请人">{{ detail.applicantName }}</el-descriptions-item>
        <el-descriptions-item label="当前环节">{{ detail.currentHandlerName }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="tagType(detail.status)">{{ detail.statusLabel }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ detail.submitTime }}</el-descriptions-item>
        <el-descriptions-item v-if="detail.startDate" label="请假区间">{{ detail.startDate }} 至 {{ detail.endDate }}</el-descriptions-item>
        <el-descriptions-item v-if="detail.amount !== null && detail.amount !== undefined" label="报销金额">{{ detail.amount }}</el-descriptions-item>
        <el-descriptions-item label="申请事由">{{ detail.reason }}</el-descriptions-item>
      </el-descriptions>
      <div v-if="detail && detail.taskList && detail.taskList.length" class="detail-section">
        <div class="detail-section__title">审批记录</div>
        <el-timeline>
          <el-timeline-item
            v-for="item in detail.taskList"
            :key="item.workflowTaskId"
            :timestamp="item.completeTime || item.createTime"
            :type="timelineType(item.taskStatus)">
            <div class="record-title">
              <span>{{ item.taskName }}</span>
              <el-tag size="mini" :type="tagType(item.taskStatus)">{{ item.taskStatus }}</el-tag>
            </div>
            <div class="record-meta">处理人：{{ item.assigneeName || '-' }}</div>
            <div class="record-meta">审批意见：{{ item.commentContent || '-' }}</div>
          </el-timeline-item>
        </el-timeline>
      </div>
      <div v-if="detail && canResubmit(detail)" slot="footer" class="dialog-footer">
        <el-button type="primary" @click="openResubmitDialog(detail)">重新提交</el-button>
        <el-button @click="detailOpen = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addWorkflowApply, approveWorkflowApply, getWorkflowApply, getWorkflowWorkbench, listWorkflowApply, rejectWorkflowApply, resubmitWorkflowApply } from '@/api/oa/workflow'

export default {
  name: 'OaWorkflowIndex',
  data() {
    return {
      loading: false,
      summaries: [],
      processTypes: [],
      applyList: [],
      queryParams: {
        tab: 'apply',
        processType: undefined,
        title: undefined
      },
      dialogOpen: false,
      detailOpen: false,
      actionOpen: false,
      actionType: 'approve',
      actionComment: '',
      currentActionRow: null,
      detail: null,
      form: {
        processType: 'leave',
        title: undefined,
        startDate: undefined,
        endDate: undefined,
        amount: undefined,
        reason: undefined,
        applicantName: undefined
      },
      rules: {
        title: [{ required: true, message: '申请标题不能为空', trigger: 'blur' }],
        startDate: [{ required: true, message: '开始日期不能为空', trigger: 'change' }],
        endDate: [{ required: true, message: '结束日期不能为空', trigger: 'change' }],
        amount: [{ required: true, message: '报销金额不能为空', trigger: 'blur' }],
        reason: [{ required: true, message: '申请事由不能为空', trigger: 'blur' }]
      }
    }
  },
  computed: {
    dialogTitle() {
      return this.form.applyId ? (this.form.processType === 'leave' ? '重新提交请假申请' : '重新提交报销申请') : (this.form.processType === 'leave' ? '发起请假申请' : '发起报销申请')
    },
    currentUserId() {
      return this.$store.getters.id
    },
    hasTodoActionPermission() {
      return this.$auth.hasPermiOr(['oa:workflow:todo', 'oa:workflow:todo:query'])
    },
    hasApplyPermission() {
      return this.$auth.hasPermi('oa:workflow:apply:add')
    }
  },
  created() {
    this.queryParams.tab = this.normalizeTab(this.$route.query.tab)
    this.getWorkbench()
    this.getList()
  },
  watch: {
    '$route.query.tab'(value) {
      const tab = this.normalizeTab(value)
      if (tab !== this.queryParams.tab) {
        this.queryParams.tab = tab
      }
      this.getList()
    }
  },
  methods: {
    getWorkbench() {
      getWorkflowWorkbench().then(res => {
        this.summaries = res.data.summary || []
        this.processTypes = res.data.types || []
      })
    },
    getList() {
      this.loading = true
      listWorkflowApply(this.queryParams).then(res => {
        this.applyList = res.rows || []
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    resetQuery() {
      this.queryParams.processType = undefined
      this.queryParams.title = undefined
      this.queryParams.tab = 'apply'
      this.syncTabQuery()
      this.getList()
    },
    openDialog(type) {
      this.form = {
        applyId: undefined,
        processType: type,
        title: undefined,
        startDate: undefined,
        endDate: undefined,
        amount: undefined,
        reason: undefined,
        applicantName: undefined
      }
      this.dialogOpen = true
      this.$nextTick(() => {
        this.$refs.form && this.$refs.form.clearValidate()
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        const payload = { ...this.form }
        if (payload.processType === 'leave') {
          payload.amount = undefined
        } else {
          payload.startDate = undefined
          payload.endDate = undefined
        }
        const request = payload.applyId
          ? resubmitWorkflowApply(payload.applyId, payload)
          : addWorkflowApply(payload)
        request.then(() => {
          this.$modal.msgSuccess(payload.applyId ? '重新提交成功' : '提交成功')
          this.dialogOpen = false
          this.queryParams.tab = 'apply'
          this.syncTabQuery()
          this.getWorkbench()
          this.getList()
        })
      })
    },
    openResubmitDialog(row) {
      this.form = {
        applyId: row.applyId,
        processType: row.processType,
        title: row.title,
        startDate: row.startDate,
        endDate: row.endDate,
        amount: row.amount,
        reason: row.reason,
        applicantName: row.applicantName
      }
      this.dialogOpen = true
      this.$nextTick(() => {
        this.$refs.form && this.$refs.form.clearValidate()
      })
    },
    showDetail(row) {
      getWorkflowApply(row.applyId).then(res => {
        this.detail = res.data
        this.detailOpen = true
      })
    },
    handleApprove(row) {
      this.currentActionRow = row
      this.actionType = 'approve'
      this.actionComment = '审批通过'
      this.actionOpen = true
    },
    handleReject(row) {
      this.currentActionRow = row
      this.actionType = 'reject'
      this.actionComment = '审批驳回'
      this.actionOpen = true
    },
    submitAction() {
      const request = this.actionType === 'approve'
        ? approveWorkflowApply(this.currentActionRow.applyId, this.actionComment)
        : rejectWorkflowApply(this.currentActionRow.applyId, this.actionComment)
      request.then(() => {
        this.$modal.msgSuccess(this.actionType === 'approve' ? '审批通过成功' : '审批驳回成功')
        this.actionOpen = false
        this.currentActionRow = null
        this.getWorkbench()
        this.getList()
      })
    },
    normalizeTab(tab) {
      return ['apply', 'todo', 'done'].includes(tab) ? tab : 'apply'
    },
    syncTabQuery() {
      const query = { ...this.$route.query }
      if (this.queryParams.tab === 'apply') {
        delete query.tab
      } else {
        query.tab = this.queryParams.tab
      }
      this.$router.replace({ query })
    },
    handleTabChange() {
      this.syncTabQuery()
      this.getList()
    },
    canResubmit(row) {
      return this.queryParams.tab === 'apply' && this.hasApplyPermission && row.status === '已驳回' && String(row.applicantId) === String(this.currentUserId)
    },
    timelineType(status) {
      if (status === '已通过' || status === '已完成') {
        return 'success'
      }
      if (status === '已驳回') {
        return 'danger'
      }
      if (status === '待处理' || status === '审批中') {
        return 'warning'
      }
      return 'info'
    },
    tagType(status) {
      if (status === '已完成' || status === '已通过') {
        return 'success'
      }
      if (status === '已驳回') {
        return 'danger'
      }
      if (status === '审批中' || status === '待处理') {
        return 'warning'
      }
      if (status === '草稿') {
        return 'info'
      }
      return 'info'
    }
  }
}
</script>

<style scoped lang="scss">
.oa-page {
  .summary-card,
  .query-card {
    margin-bottom: 20px;
  }

  .summary-row {
    margin-top: 16px;
  }

  .summary-item {
    padding: 16px;
    border-radius: 10px;
    background: #f5f7fa;
    text-align: center;
  }

  .summary-value {
    font-size: 24px;
    font-weight: 600;
    color: #409eff;
  }

  .summary-label {
    margin-top: 8px;
    color: #606266;
  }

  .detail-section {
    margin-top: 20px;
  }

  .detail-section__title {
    margin-bottom: 12px;
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .record-title {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 6px;
  }

  .record-meta {
    color: #606266;
    line-height: 1.8;
  }
}
</style>
