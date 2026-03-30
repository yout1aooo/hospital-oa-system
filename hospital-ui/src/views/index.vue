<template>
  <div class="app-container oa-portal">
    <el-row :gutter="20" class="hero-row">
      <el-col :xs="24" :lg="16">
        <el-card shadow="never" class="hero-card">
          <div class="hero-header">
            <div>
              <h2>河口医院协同门户</h2>
              <p>聚合医院日常办公快捷入口，覆盖审批、文档、会议、任务、通讯录与患者服务导航。</p>
            </div>
            <el-tag type="success">v{{ version }}</el-tag>
          </div>
          <el-row :gutter="12" class="summary-row">
            <el-col v-for="item in summaryCards" :key="item.label" :xs="12" :sm="6">
              <div class="summary-card">
                <div class="summary-value">{{ item.value }}</div>
                <div class="summary-label">{{ item.label }}</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="hero-side-card">
          <div slot="header">
            <span>今日提示</span>
          </div>
          <ul class="tip-list">
            <li v-for="tip in tips" :key="tip">{{ tip }}</li>
          </ul>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="quick-entry-row">
      <el-col v-for="entry in quickEntries" :key="entry.title" :xs="24" :sm="12" :lg="4">
        <el-card shadow="hover" class="quick-entry-card" @click.native="go(entry.path, entry.query)">
          <div class="entry-icon">
            <i :class="entry.icon" />
          </div>
          <div class="entry-title">{{ entry.title }}</div>
          <div class="entry-desc">{{ entry.desc }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :xs="24" :lg="12">
        <el-card class="panel-card" shadow="never" v-loading="workflowLoading">
          <div slot="header" class="clearfix">
            <span>最新审批</span>
          </div>
          <el-timeline v-if="todoList.length">
            <el-timeline-item
              v-for="item in todoList"
              :key="item.applyId"
              :timestamp="item.time"
              placement="top">
              <div class="panel-title">{{ item.title }}</div>
              <div class="panel-text">{{ item.desc }}</div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-else description="暂无审批数据" :image-size="96" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card class="panel-card" shadow="never" v-loading="documentLoading">
          <div slot="header" class="clearfix">
            <span>我的未读制度</span>
          </div>
          <div v-for="item in unreadDocuments" :key="item.documentId" class="list-item clickable-item" @click="go('/notice/document')">
            <div class="panel-title">{{ item.documentTitle }}</div>
            <div class="panel-text">{{ item.categoryName || '未分类' }} ｜ {{ item.documentNo || '-' }} ｜ {{ item.readStatusLabel }}</div>
          </div>
          <el-empty v-if="!unreadDocuments.length" description="暂无未读制度文档" :image-size="96" />
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="bottom-row">
      <el-col :xs="24" :lg="12">
        <el-card class="panel-card" shadow="never" v-loading="meetingLoading">
          <div slot="header" class="clearfix">
            <span>近期会议</span>
          </div>
          <div v-for="item in meetings" :key="item.meetingId" class="list-item clickable-item" @click="go('/collab/meeting', { tab: 'meeting' })">
            <div class="panel-title">{{ item.meetingTitle }}</div>
            <div class="panel-text">{{ item.startTime || '-' }} ｜ {{ item.roomName || '-' }} ｜ {{ item.meetingStatusLabel || '-' }}</div>
          </div>
          <el-empty v-if="!meetings.length" description="暂无会议数据" :image-size="96" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card class="panel-card" shadow="never" v-loading="taskLoading">
          <div slot="header" class="clearfix">
            <span>任务提醒</span>
          </div>
          <div v-for="item in tasks" :key="item.taskId" class="list-item clickable-item" @click="go('/collab/task', { tab: 'task' })">
            <div class="panel-title">{{ item.taskTitle }}</div>
            <div class="panel-text">{{ [item.assigneeName, item.taskStatusLabel, item.dueTime].filter(Boolean).join(' ｜ ') }}</div>
          </div>
          <el-empty v-if="!tasks.length" description="暂无任务数据" :image-size="96" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { getDocumentWorkbench } from '@/api/oa/document'
import { listMeeting } from '@/api/oa/meeting'
import { getTaskWorkbench } from '@/api/oa/task'
import { getWorkflowWorkbench } from '@/api/oa/workflow'

export default {
  name: 'Index',
  data() {
    return {
      version: '3.6.7',
      workflowLoading: false,
      documentLoading: false,
      meetingLoading: false,
      taskLoading: false,
      summaryCards: [
        { label: '我的申请', value: 0 },
        { label: '我的待办', value: 0 },
        { label: '我的未读', value: 0 },
        { label: '已确认', value: 0 }
      ],
      tips: [
        '请优先处理即将超时的审批事项。',
        '请及时查看今日会议安排与会议室占用情况。',
        '本周制度文档阅读确认尚有 0 项未完成。'
      ],
      quickEntries: [
        { title: '审批中心', desc: '请假、报销、采购与用印流程', path: '/workflow/apply', query: { tab: 'apply' }, icon: 'el-icon-s-check' },
        { title: '通知文档', desc: '通知公告与制度文档发布', path: '/notice/document', icon: 'el-icon-message-solid' },
        { title: '会议任务', desc: '会议安排与任务督办入口', path: '/collab/meeting', query: { tab: 'meeting' }, icon: 'el-icon-date' },
        { title: '通讯录组织', desc: '人员、科室与联系方式查询', path: '/contacts/directory', icon: 'el-icon-phone-outline' },
        { title: '患者服务', desc: '患者主档与病例信息查询', path: '/patient/index', icon: 'el-icon-first-aid-kit' },
        { title: '系统管理', desc: '用户权限与组织底座维护', path: '/contacts/user', icon: 'el-icon-setting' }
      ],
      todoList: [],
      unreadDocuments: [],
      meetings: [],
      tasks: []
    }
  },
  created() {
    this.getWorkflowData()
    this.getDocumentData()
    this.getMeetingData()
    this.getTaskData()
  },
  methods: {
    getWorkflowData() {
      this.workflowLoading = true
      getWorkflowWorkbench().then(res => {
        const data = res.data || {}
        const summaries = data.summary || []
        this.summaryCards[0] = summaries[0] || this.summaryCards[0]
        this.summaryCards[1] = summaries[1] || this.summaryCards[1]
        this.todoList = (data.recentApplies || []).map(item => ({
          applyId: item.applyId,
          title: item.title || item.formNo,
          desc: [item.processTypeLabel, item.statusLabel, item.currentHandlerName].filter(Boolean).join(' ｜ '),
          time: item.submitTime || '刚刚'
        }))
        this.workflowLoading = false
      }).catch(() => {
        this.workflowLoading = false
      })
    },
    getDocumentData() {
      this.documentLoading = true
      getDocumentWorkbench().then(res => {
        const data = res.data || {}
        const summaries = data.summary || []
        this.summaryCards[2] = summaries[1] || this.summaryCards[2]
        this.summaryCards[3] = summaries[2] || this.summaryCards[3]
        const unreadCount = (summaries[1] && summaries[1].value) || 0
        this.tips[2] = '本周制度文档阅读确认尚有 ' + unreadCount + ' 项未完成。'
        this.unreadDocuments = data.unreadDocuments || []
        this.documentLoading = false
      }).catch(() => {
        this.documentLoading = false
      })
    },
    getMeetingData() {
      this.meetingLoading = true
      listMeeting({ meetingStatus: 'scheduled' }).then(res => {
        this.meetings = (res.rows || []).slice(0, 5)
        this.meetingLoading = false
      }).catch(() => {
        this.meetingLoading = false
      })
    },
    getTaskData() {
      this.taskLoading = true
      getTaskWorkbench().then(res => {
        const data = res.data || {}
        this.tasks = (data.tasks || []).slice(0, 5)
        const pending = (data.summary || []).find(item => item.label === '待处理')
        if (pending) {
          this.tips[1] = '当前待处理任务 ' + pending.value + ' 项，请及时跟进。'
        }
        this.taskLoading = false
      }).catch(() => {
        this.taskLoading = false
      })
    },
    go(path, query) {
      if (path) {
        this.$router.push({ path, query })
      }
    }
  }
}
</script>

<style scoped lang="scss">
.oa-portal {
  color: #606266;

  .hero-row,
  .quick-entry-row,
  .bottom-row {
    margin-bottom: 20px;
  }

  .hero-card,
  .hero-side-card,
  .panel-card,
  .quick-entry-card {
    border-radius: 12px;
  }

  .hero-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 16px;
    margin-bottom: 24px;

    h2 {
      margin: 0 0 8px;
      font-size: 28px;
      color: #303133;
    }

    p {
      margin: 0;
      line-height: 1.6;
      color: #909399;
    }
  }

  .summary-card {
    padding: 16px;
    background: #f5f7fa;
    border-radius: 10px;
    text-align: center;
    margin-bottom: 12px;
  }

  .summary-value {
    font-size: 24px;
    font-weight: 600;
    color: #409eff;
  }

  .summary-label {
    margin-top: 6px;
    font-size: 13px;
    color: #606266;
  }

  .tip-list {
    margin: 0;
    padding-left: 18px;
    line-height: 1.9;
  }

  .quick-entry-card {
    cursor: pointer;
    min-height: 150px;
    text-align: center;
    transition: all 0.2s ease;

    &:hover {
      transform: translateY(-3px);
    }
  }

  .entry-icon {
    font-size: 28px;
    color: #409eff;
    margin: 8px 0 16px;
  }

  .entry-title {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 8px;
  }

  .entry-desc {
    font-size: 13px;
    line-height: 1.6;
    color: #909399;
  }

  .panel-title {
    font-size: 14px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 6px;
  }

  .panel-text {
    font-size: 13px;
    color: #909399;
    line-height: 1.6;
  }

  .list-item + .list-item {
    margin-top: 18px;
    padding-top: 18px;
    border-top: 1px solid #ebeef5;
  }

  .clickable-item {
    cursor: pointer;
  }
}
</style>
