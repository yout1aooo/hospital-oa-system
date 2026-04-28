<template>
  <div class="app-container oa-portal">
    <section class="portal-hero">
      <div class="hero-content">
        <div class="hero-copy">
          <el-tag class="hero-kicker" type="success" size="small">智能协同办公平台</el-tag>
          <h1>河口医院协同门户</h1>
          <p>聚合审批、文档、会议、任务、通讯录与患者服务，一站式处理医院日常办公。</p>
          <div class="hero-actions">
            <el-button type="primary" icon="el-icon-s-check" @click="go('/workflow/apply', { tab: 'todo' })">处理待办</el-button>
            <el-button plain icon="el-icon-date" @click="go('/collab/meeting', { tab: 'meeting' })">查看会议</el-button>
          </div>
        </div>
        <div class="hero-status-card">
          <div class="status-header">
            <span>今日概览</span>
            <el-tag size="mini" type="success">v{{ version }}</el-tag>
          </div>
          <div class="status-date">{{ todayText }}</div>
          <div class="status-pills">
            <span><i class="el-icon-time" /> 待办优先</span>
            <span><i class="el-icon-document-checked" /> 制度确认</span>
          </div>
        </div>
      </div>
    </section>

    <el-row :gutter="18" class="summary-row">
      <el-col v-for="item in summaryCards" :key="item.label" :xs="12" :sm="6">
        <div
          class="summary-card"
          :class="{ 'is-clickable': item.path }"
          role="button"
          tabindex="0"
          @click="go(item.path, item.query)"
          @keyup.enter="go(item.path, item.query)"
          @keyup.space.prevent="go(item.path, item.query)"
        >
          <div class="summary-icon"><i :class="item.icon || 'el-icon-data-analysis'" /></div>
          <div>
            <div class="summary-value">{{ item.value }}</div>
            <div class="summary-label">{{ item.label }}</div>
          </div>
          <i v-if="item.path" class="el-icon-right summary-arrow" />
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="18" class="content-row">
      <el-col :xs="24" :lg="16">
        <section class="portal-section">
          <div class="section-heading">
            <div>
              <span class="section-kicker">Quick Access</span>
              <h2>快捷入口</h2>
            </div>
            <span class="section-note">常用功能一键直达</span>
          </div>
          <div class="quick-grid">
            <div
              v-for="entry in quickEntries"
              :key="entry.title"
              class="quick-entry-card"
              :style="{ '--entry-color': entry.color, '--entry-bg': entry.bg }"
              @click="go(entry.path, entry.query)"
            >
              <div class="entry-icon"><i :class="entry.icon" /></div>
              <div class="entry-title">{{ entry.title }}</div>
              <div class="entry-desc">{{ entry.desc }}</div>
              <i class="el-icon-right entry-arrow" />
            </div>
          </div>
        </section>
      </el-col>
      <el-col :xs="24" :lg="8">
        <section class="portal-section tips-card">
          <div class="section-heading compact">
            <div>
              <span class="section-kicker">Reminder</span>
              <h2>今日提示</h2>
            </div>
          </div>
          <ul class="tip-list">
            <li v-for="tip in tips" :key="tip">
              <span class="tip-dot" />
              <span>{{ tip }}</span>
            </li>
          </ul>
        </section>
      </el-col>
    </el-row>

    <el-row :gutter="18" class="content-row">
      <el-col :xs="24" :lg="12">
        <section class="portal-panel" v-loading="workflowLoading">
          <div class="panel-header">
            <div>
              <span class="section-kicker">Workflow</span>
              <h3>最新审批</h3>
            </div>
            <el-button type="text" @click="go('/workflow/apply', { tab: 'todo' })">查看全部</el-button>
          </div>
          <el-timeline v-if="todoList.length" class="modern-timeline">
            <el-timeline-item
              v-for="item in todoList"
              :key="item.applyId"
              :timestamp="item.time"
              placement="top"
            >
              <div class="panel-title">{{ item.title }}</div>
              <div class="panel-text">{{ item.desc }}</div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-else description="暂无审批数据" :image-size="96" />
        </section>
      </el-col>
      <el-col :xs="24" :lg="12">
        <section class="portal-panel" v-loading="documentLoading">
          <div class="panel-header">
            <div>
              <span class="section-kicker">Documents</span>
              <h3>我的未读制度</h3>
            </div>
            <el-button type="text" @click="go('/notice/document')">去确认</el-button>
          </div>
          <div
            v-for="item in unreadDocuments"
            :key="item.documentId"
            class="list-item clickable-item"
            @click="go('/notice/document')"
          >
            <div class="list-icon document"><i class="el-icon-document" /></div>
            <div class="list-content">
              <div class="panel-title">{{ item.documentTitle }}</div>
              <div class="panel-text">{{ item.categoryName || '未分类' }} ｜ {{ item.documentNo || '-' }} ｜ {{ item.readStatusLabel }}</div>
            </div>
          </div>
          <el-empty v-if="!unreadDocuments.length" description="暂无未读制度文档" :image-size="96" />
        </section>
      </el-col>
    </el-row>

    <el-row :gutter="18" class="content-row last-row">
      <el-col :xs="24" :lg="12">
        <section class="portal-panel" v-loading="meetingLoading">
          <div class="panel-header">
            <div>
              <span class="section-kicker">Meetings</span>
              <h3>近期会议</h3>
            </div>
            <el-button type="text" @click="go('/collab/meeting', { tab: 'meeting' })">会议室</el-button>
          </div>
          <div
            v-for="item in meetings"
            :key="item.meetingId"
            class="list-item clickable-item"
            @click="go('/collab/meeting', { tab: 'meeting' })"
          >
            <div class="list-icon meeting"><i class="el-icon-date" /></div>
            <div class="list-content">
              <div class="panel-title">{{ item.meetingTitle }}</div>
              <div class="panel-text">{{ item.startTime || '-' }} ｜ {{ item.roomName || '-' }} ｜ {{ item.meetingStatusLabel || '-' }}</div>
            </div>
          </div>
          <el-empty v-if="!meetings.length" description="暂无会议数据" :image-size="96" />
        </section>
      </el-col>
      <el-col :xs="24" :lg="12">
        <section class="portal-panel" v-loading="taskLoading">
          <div class="panel-header">
            <div>
              <span class="section-kicker">Tasks</span>
              <h3>任务提醒</h3>
            </div>
            <el-button type="text" @click="go('/collab/task', { tab: 'task' })">任务看板</el-button>
          </div>
          <div
            v-for="item in tasks"
            :key="item.taskId"
            class="list-item clickable-item"
            @click="go('/collab/task', { tab: 'task' })"
          >
            <div class="list-icon task"><i class="el-icon-finished" /></div>
            <div class="list-content">
              <div class="panel-title">{{ item.taskTitle }}</div>
              <div class="panel-text">{{ [item.assigneeName, item.taskStatusLabel, item.dueTime].filter(Boolean).join(' ｜ ') }}</div>
            </div>
          </div>
          <el-empty v-if="!tasks.length" description="暂无任务数据" :image-size="96" />
        </section>
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
        { label: '我的申请', value: 0, icon: 'el-icon-edit-outline', path: '/workflow/apply', query: { tab: 'apply' } },
        { label: '我的待办', value: 0, icon: 'el-icon-s-claim', path: '/workflow/apply', query: { tab: 'todo' } },
        { label: '我的未读', value: 0, icon: 'el-icon-message', path: '/notice/document', query: { documentTab: 'unread' } },
        { label: '已确认', value: 0, icon: 'el-icon-circle-check', path: '/notice/document', query: { documentTab: 'confirmed' } }
      ],
      tips: [
        '请优先处理即将超时的审批事项。',
        '请及时查看今日会议安排与会议室占用情况。',
        '本周制度文档阅读确认尚有 0 项未完成。'
      ],
      quickEntries: [
        { title: '审批中心', desc: '请假、报销、采购与用印流程', path: '/workflow/apply', query: { tab: 'apply' }, icon: 'el-icon-s-check', color: '#2563eb', bg: 'rgba(37, 99, 235, 0.12)' },
        { title: '通知文档', desc: '通知公告与制度文档发布', path: '/notice/document', icon: 'el-icon-message-solid', color: '#7c3aed', bg: 'rgba(124, 58, 237, 0.12)' },
        { title: '会议任务', desc: '会议安排与任务督办入口', path: '/collab/meeting', query: { tab: 'meeting' }, icon: 'el-icon-date', color: '#0891b2', bg: 'rgba(8, 145, 178, 0.12)' },
        { title: '通讯录组织', desc: '人员、科室与联系方式查询', path: '/contacts/directory', icon: 'el-icon-phone-outline', color: '#16a34a', bg: 'rgba(22, 163, 74, 0.12)' },
        { title: '患者服务', desc: '患者主档与病例信息查询', path: '/patient/index', icon: 'el-icon-first-aid-kit', color: '#ea580c', bg: 'rgba(234, 88, 12, 0.12)' },
        { title: '系统管理', desc: '用户权限与组织底座维护', path: '/contacts/user', icon: 'el-icon-setting', color: '#475569', bg: 'rgba(71, 85, 105, 0.12)' }
      ],
      todoList: [],
      unreadDocuments: [],
      meetings: [],
      tasks: []
    }
  },
  computed: {
    todayText() {
      const formatter = new Intl.DateTimeFormat('zh-CN', {
        month: 'long',
        day: 'numeric',
        weekday: 'long'
      })
      return formatter.format(new Date())
    }
  },
  created() {
    this.getWorkflowData()
    this.getDocumentData()
    this.getMeetingData()
    this.getTaskData()
  },
  methods: {
    mergeSummary(index, summary) {
      if (!summary) return
      this.$set(this.summaryCards, index, {
        ...this.summaryCards[index],
        ...summary
      })
    },
    getWorkflowData() {
      this.workflowLoading = true
      getWorkflowWorkbench().then(res => {
        const data = res.data || {}
        const summaries = data.summary || []
        this.mergeSummary(0, summaries[0])
        this.mergeSummary(1, summaries[1])
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
        this.mergeSummary(2, summaries[1])
        this.mergeSummary(3, summaries[2])
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
  position: relative;
  color: #1f2937;

  .portal-hero {
    position: relative;
    overflow: hidden;
    min-height: 260px;
    padding: 34px;
    border: 1px solid rgba(255, 255, 255, 0.72);
    border-radius: 8px;
    background:
      linear-gradient(135deg, rgba(255, 255, 255, 0.96), rgba(246, 250, 252, 0.94)),
      repeating-linear-gradient(135deg, rgba(15, 118, 110, 0.08) 0, rgba(15, 118, 110, 0.08) 1px, transparent 1px, transparent 16px);
    box-shadow: 0 18px 42px rgba(15, 23, 42, 0.1);
  }

  .hero-content {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 28px;
  }

  .hero-copy {
    max-width: 720px;

    h1 {
      margin: 16px 0 14px;
      font-size: 40px;
      font-weight: 800;
      line-height: 1.18;
      letter-spacing: 0;
      color: #0f172a;
    }

    p {
      max-width: 620px;
      margin: 0;
      font-size: 16px;
      line-height: 1.8;
      color: #64748b;
    }
  }

  .hero-kicker {
    border: 0;
    border-radius: 999px;
    color: #047857;
    background: rgba(16, 185, 129, 0.12);
  }

  .hero-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 26px;

    ::v-deep .el-button {
      min-width: 124px;
      border-radius: 999px;
      font-weight: 600;
      box-shadow: 0 12px 24px rgba(37, 99, 235, 0.16);
    }

    ::v-deep .el-button--default {
      border-color: rgba(37, 99, 235, 0.18);
      color: #2563eb;
      background: rgba(255, 255, 255, 0.72);
      box-shadow: none;
    }
  }

  .hero-status-card {
    flex: 0 0 280px;
    padding: 22px;
    border: 1px solid rgba(255, 255, 255, 0.72);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.66);
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.85), 0 18px 44px rgba(15, 23, 42, 0.1);
    backdrop-filter: blur(14px);
  }

  .status-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-weight: 700;
    color: #0f172a;
  }

  .status-date {
    margin: 18px 0;
    font-size: 28px;
    font-weight: 800;
    color: #2563eb;
  }

  .status-pills {
    display: flex;
    flex-direction: column;
    gap: 10px;

    span {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      width: fit-content;
      padding: 8px 12px;
      border-radius: 999px;
      color: #475569;
      background: rgba(241, 245, 249, 0.86);
    }
  }

  .summary-row,
  .content-row {
    margin-top: 18px;
  }

  .last-row {
    margin-bottom: 8px;
  }

  .summary-card,
  .portal-section,
  .portal-panel {
    border: 1px solid rgba(226, 232, 240, 0.88);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.92);
    box-shadow: 0 18px 44px rgba(15, 23, 42, 0.08);
  }

  .summary-card {
    position: relative;
    display: flex;
    align-items: center;
    gap: 16px;
    min-height: 112px;
    padding: 22px;
    transition: transform 0.24s ease, box-shadow 0.24s ease;

    &.is-clickable {
      cursor: pointer;
    }

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 22px 52px rgba(15, 23, 42, 0.12);

      .summary-arrow {
        opacity: 1;
        transform: translateX(0);
      }
    }
  }

  .summary-arrow {
    position: absolute;
    right: 20px;
    top: 50%;
    color: #94a3b8;
    opacity: 0;
    transform: translate(-6px, -50%);
    transition: all 0.22s ease;
  }

  .summary-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    border-radius: 8px;
    font-size: 22px;
    color: #0f766e;
    background: linear-gradient(135deg, rgba(15, 118, 110, 0.13), rgba(245, 158, 11, 0.12));
  }

  .summary-value {
    font-size: 30px;
    font-weight: 800;
    line-height: 1;
    color: #0f172a;
  }

  .summary-label {
    margin-top: 8px;
    font-size: 13px;
    color: #64748b;
  }

  .portal-section,
  .portal-panel {
    min-height: 100%;
    padding: 24px;
  }

  .section-heading,
  .panel-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 20px;
  }

  .section-heading.compact {
    margin-bottom: 16px;
  }

  .section-kicker {
    display: inline-block;
    margin-bottom: 6px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: #3b82f6;
  }

  h2,
  h3 {
    margin: 0;
    color: #0f172a;
  }

  h2 {
    font-size: 22px;
  }

  h3 {
    font-size: 18px;
  }

  .section-note {
    color: #94a3b8;
    font-size: 13px;
  }

  .quick-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16px;
  }

  .quick-entry-card {
    position: relative;
    overflow: hidden;
    min-height: 164px;
    padding: 22px;
    border: 1px solid rgba(226, 232, 240, 0.86);
    border-radius: 8px;
    cursor: pointer;
    background: linear-gradient(180deg, #ffffff, #f8fafc);
    transition: transform 0.24s ease, border-color 0.24s ease, box-shadow 0.24s ease;

    &:hover {
      transform: translateY(-5px);
      border-color: rgba(59, 130, 246, 0.28);
      box-shadow: 0 18px 42px rgba(15, 23, 42, 0.1);

      .entry-arrow {
        opacity: 1;
        transform: translateX(0);
      }
    }
  }

  .entry-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 46px;
    height: 46px;
    margin-bottom: 18px;
    border-radius: 8px;
    font-size: 24px;
    color: var(--entry-color);
    background: var(--entry-bg);
  }

  .entry-title {
    margin-bottom: 8px;
    font-size: 16px;
    font-weight: 800;
    color: #0f172a;
  }

  .entry-desc {
    max-width: 180px;
    font-size: 13px;
    line-height: 1.6;
    color: #64748b;
  }

  .entry-arrow {
    position: absolute;
    right: 18px;
    bottom: 18px;
    color: var(--entry-color);
    opacity: 0;
    transform: translateX(-6px);
    transition: all 0.24s ease;
  }

  .tips-card {
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 250, 252, 0.96));
  }

  .tip-list {
    margin: 0;
    padding: 0;
    list-style: none;

    li {
      display: flex;
      gap: 12px;
      padding: 14px 0;
      line-height: 1.6;
      color: #475569;
      border-top: 1px solid rgba(226, 232, 240, 0.78);

      &:first-child {
        border-top: 0;
      }
    }
  }

  .tip-dot {
    flex: 0 0 9px;
    width: 9px;
    height: 9px;
    margin-top: 8px;
    border-radius: 50%;
    background: #22c55e;
    box-shadow: 0 0 0 5px rgba(34, 197, 94, 0.12);
  }

  .panel-header {
    align-items: center;

    ::v-deep .el-button {
      padding: 0;
      font-weight: 700;
    }
  }

  .modern-timeline {
    padding-top: 4px;
  }

  .panel-title {
    margin-bottom: 6px;
    overflow: hidden;
    font-size: 14px;
    font-weight: 700;
    color: #0f172a;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .panel-text {
    overflow: hidden;
    font-size: 13px;
    line-height: 1.7;
    color: #64748b;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .list-item {
    display: flex;
    gap: 14px;
    padding: 14px;
    border-radius: 8px;
    transition: background 0.22s ease, transform 0.22s ease;
  }

  .list-item + .list-item {
    margin-top: 8px;
  }

  .clickable-item {
    cursor: pointer;

    &:hover {
      transform: translateX(3px);
      background: #f8fafc;
    }
  }

  .list-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 42px;
    width: 42px;
    height: 42px;
    border-radius: 8px;
    font-size: 20px;
  }

  .list-icon.document {
    color: #7c3aed;
    background: rgba(124, 58, 237, 0.1);
  }

  .list-icon.meeting {
    color: #0891b2;
    background: rgba(8, 145, 178, 0.1);
  }

  .list-icon.task {
    color: #16a34a;
    background: rgba(22, 163, 74, 0.1);
  }

  .list-content {
    min-width: 0;
    flex: 1;
  }
}

@media screen and (max-width: 1200px) {
  .oa-portal {
    .quick-grid {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }
  }
}

@media screen and (max-width: 768px) {
  .oa-portal {
    .portal-hero {
      padding: 24px;
      border-radius: 8px;
    }

    .hero-content {
      display: block;
    }

    .hero-copy h1 {
      font-size: 30px;
    }

    .hero-status-card {
      margin-top: 24px;
    }

    .quick-grid {
      grid-template-columns: 1fr;
    }

    .summary-card,
    .portal-section,
    .portal-panel {
      border-radius: 8px;
    }
  }
}
</style>
