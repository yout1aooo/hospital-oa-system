<template>
  <div class="app-container oa-page">
    <el-card shadow="never" class="summary-card" v-loading="scheduleLoading">
      <div slot="header" class="clearfix">
        <span>会议任务日程</span>
      </div>
      <el-alert
        title="当前已接入日程提醒、会议管理与任务督办 MVP，支持日程查询、新增、完成，以及会议/任务基础闭环。"
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
      <div slot="header" class="clearfix">
        <span>协同分区</span>
      </div>
      <el-tabs v-model="activeTab" @tab-click="handleTabChange">
        <el-tab-pane v-if="hasScheduleQuery" label="日程提醒" name="schedule" />
        <el-tab-pane v-if="hasMeetingQuery" label="会议管理" name="meeting" />
        <el-tab-pane v-if="hasTaskQuery" label="任务督办" name="task" />
      </el-tabs>
    </el-card>

    <el-card v-show="activeTab === 'schedule'" shadow="never" class="query-card">
      <div slot="header" class="clearfix">
        <span>日程提醒</span>
      </div>
      <el-form :inline="true" :model="scheduleQuery" size="small">
        <el-form-item label="日程标题">
          <el-input v-model="scheduleQuery.scheduleTitle" placeholder="请输入日程标题" clearable @keyup.enter.native="getScheduleList" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="scheduleQuery.scheduleStatus" placeholder="全部状态" clearable>
            <el-option label="待处理" value="pending" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="mini" icon="el-icon-search" @click="getScheduleList">查询</el-button>
          <el-button size="mini" icon="el-icon-refresh" @click="resetScheduleQuery">重置</el-button>
          <el-button type="success" size="mini" icon="el-icon-plus" @click="openScheduleDialog" v-hasPermi="['oa:collab:schedule:list']">新增日程</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="scheduleLoading" :data="scheduleList">
        <el-table-column label="日程标题" prop="scheduleTitle" min-width="180" show-overflow-tooltip />
        <el-table-column label="开始时间" prop="startTime" width="170" />
        <el-table-column label="结束时间" prop="endTime" width="170" />
        <el-table-column label="提醒时间" prop="remindTime" width="170" />
        <el-table-column label="状态" prop="scheduleStatusLabel" width="100">
          <template slot-scope="scope">
            <el-tag :type="scheduleTagType(scope.row.scheduleStatus)">{{ scope.row.scheduleStatusLabel }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="170" align="center">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="showScheduleDetail(scope.row)">详情</el-button>
            <el-button v-if="scope.row.scheduleStatus === 'pending'" type="text" size="mini" @click="handleFinishSchedule(scope.row)" v-hasPermi="['oa:collab:schedule:list']">完成</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-row v-show="activeTab !== 'schedule'" :gutter="20">
      <el-col v-show="activeTab === 'meeting'" :xs="24" :lg="12">
        <el-card shadow="never" class="query-card">
          <div slot="header" class="clearfix">
            <span>会议管理</span>
          </div>
          <el-form :inline="true" :model="meetingQuery" size="small">
            <el-form-item label="会议标题">
              <el-input v-model="meetingQuery.meetingTitle" placeholder="请输入会议标题" clearable @keyup.enter.native="getMeetingList" />
            </el-form-item>
            <el-form-item label="状态">
              <el-select v-model="meetingQuery.meetingStatus" placeholder="全部状态" clearable>
                <el-option label="草稿" value="draft" />
                <el-option label="已安排" value="scheduled" />
                <el-option label="已结束" value="finished" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" size="mini" icon="el-icon-search" @click="getMeetingList">查询</el-button>
              <el-button size="mini" icon="el-icon-refresh" @click="resetMeetingQuery">重置</el-button>
              <el-button type="success" size="mini" icon="el-icon-plus" @click="openMeetingDialog" v-hasPermi="['oa:collab:meeting:list']">新增会议</el-button>
            </el-form-item>
          </el-form>

          <el-table v-loading="meetingLoading" :data="meetingList">
            <el-table-column label="会议标题" prop="meetingTitle" min-width="180" show-overflow-tooltip />
            <el-table-column label="会议室" prop="roomName" min-width="120" />
            <el-table-column label="组织人" prop="organizerName" width="110" />
            <el-table-column label="会议时间" min-width="180">
              <template slot-scope="scope">
                {{ scope.row.startTime }}<span v-if="scope.row.endTime"> 至 {{ scope.row.endTime }}</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" prop="meetingStatusLabel" width="100">
              <template slot-scope="scope">
                <el-tag :type="meetingTagType(scope.row.meetingStatus)">{{ scope.row.meetingStatusLabel }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" align="center">
              <template slot-scope="scope">
                <el-button type="text" size="mini" @click="showMeetingDetail(scope.row)">详情</el-button>
                <el-button v-if="scope.row.meetingStatus === 'scheduled'" type="text" size="mini" @click="handleFinishMeeting(scope.row)" v-hasPermi="['oa:collab:meeting:list']">完成</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col v-show="activeTab === 'task'" :xs="24" :lg="activeTab === 'task' ? 24 : 12">
        <el-card shadow="never" class="query-card">
          <div slot="header" class="clearfix">
            <span>任务督办</span>
          </div>
          <el-form :inline="true" :model="taskQuery" size="small">
            <el-form-item label="任务标题">
              <el-input v-model="taskQuery.taskTitle" placeholder="请输入任务标题" clearable @keyup.enter.native="getTaskList" />
            </el-form-item>
            <el-form-item label="状态">
              <el-select v-model="taskQuery.taskStatus" placeholder="全部状态" clearable>
                <el-option label="待处理" value="pending" />
                <el-option label="进行中" value="processing" />
                <el-option label="已完成" value="completed" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" size="mini" icon="el-icon-search" @click="getTaskList">查询</el-button>
              <el-button size="mini" icon="el-icon-refresh" @click="resetTaskQuery">重置</el-button>
              <el-button type="success" size="mini" icon="el-icon-plus" @click="openTaskDialog" v-hasPermi="['oa:collab:task:list']">新增任务</el-button>
            </el-form-item>
          </el-form>

          <el-table v-loading="taskLoading" :data="taskList">
            <el-table-column label="任务标题" prop="taskTitle" min-width="180" show-overflow-tooltip />
            <el-table-column label="负责人" prop="assigneeName" width="100" />
            <el-table-column label="优先级" prop="priorityLevel" width="90" />
            <el-table-column label="截止时间" prop="dueTime" width="170" />
            <el-table-column label="状态" prop="taskStatusLabel" width="90">
              <template slot-scope="scope">
                <el-tag :type="taskTagType(scope.row.taskStatus)">{{ scope.row.taskStatusLabel }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="170" align="center">
              <template slot-scope="scope">
                <el-button type="text" size="mini" @click="showTaskDetail(scope.row)">详情</el-button>
                <el-button v-if="scope.row.taskStatus !== 'completed'" type="text" size="mini" @click="handleCompleteTask(scope.row)" v-hasPermi="['oa:collab:task:list']">完成</el-button>
                <el-button type="text" size="mini" @click="openRecordDialog(scope.row)" v-hasPermi="['oa:collab:task:list']">跟进</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog title="新增日程" :visible.sync="scheduleDialogOpen" width="640px" append-to-body>
      <el-form ref="scheduleForm" :model="scheduleForm" :rules="scheduleRules" label-width="90px">
        <el-form-item label="日程标题" prop="scheduleTitle">
          <el-input v-model="scheduleForm.scheduleTitle" placeholder="请输入日程标题" />
        </el-form-item>
        <el-form-item label="日程类型">
          <el-input v-model="scheduleForm.scheduleType" placeholder="如：门诊、值班、提醒" />
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker v-model="scheduleForm.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择开始时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker v-model="scheduleForm.endTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择结束时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="提醒时间">
          <el-date-picker v-model="scheduleForm.remindTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择提醒时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="状态" prop="scheduleStatus">
          <el-select v-model="scheduleForm.scheduleStatus" placeholder="请选择状态" style="width: 100%">
            <el-option label="待处理" value="pending" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="scheduleForm.remark" type="textarea" :rows="4" placeholder="请输入日程备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitScheduleForm">确 定</el-button>
        <el-button @click="scheduleDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="新增会议" :visible.sync="meetingDialogOpen" width="640px" append-to-body>
      <el-form ref="meetingForm" :model="meetingForm" :rules="meetingRules" label-width="90px">
        <el-form-item label="会议标题" prop="meetingTitle">
          <el-input v-model="meetingForm.meetingTitle" placeholder="请输入会议标题" />
        </el-form-item>
        <el-form-item label="会议室" prop="roomId">
          <el-select v-model="meetingForm.roomId" placeholder="请选择会议室" style="width: 100%">
            <el-option v-for="item in roomOptions" :key="item.roomId" :label="item.roomName + '｜' + item.location" :value="item.roomId" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker v-model="meetingForm.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择开始时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker v-model="meetingForm.endTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择结束时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="会议状态" prop="meetingStatus">
          <el-select v-model="meetingForm.meetingStatus" placeholder="请选择会议状态" style="width: 100%">
            <el-option label="草稿" value="draft" />
            <el-option label="已安排" value="scheduled" />
            <el-option label="已结束" value="finished" />
          </el-select>
        </el-form-item>
        <el-form-item label="会议纪要">
          <el-input v-model="meetingForm.summaryContent" type="textarea" :rows="4" placeholder="请输入会议纪要或议题说明" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitMeetingForm">确 定</el-button>
        <el-button @click="meetingDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="新增任务" :visible.sync="taskDialogOpen" width="640px" append-to-body>
      <el-form ref="taskForm" :model="taskForm" :rules="taskRules" label-width="90px">
        <el-form-item label="任务标题" prop="taskTitle">
          <el-input v-model="taskForm.taskTitle" placeholder="请输入任务标题" />
        </el-form-item>
        <el-form-item label="任务类型">
          <el-input v-model="taskForm.taskType" placeholder="如：督办、整改、回访" />
        </el-form-item>
        <el-form-item label="负责人" prop="assigneeName">
          <el-input v-model="taskForm.assigneeName" placeholder="请输入负责人姓名" />
        </el-form-item>
        <el-form-item label="优先级">
          <el-select v-model="taskForm.priorityLevel" placeholder="请选择优先级" style="width: 100%">
            <el-option label="高" value="高" />
            <el-option label="中" value="中" />
            <el-option label="低" value="低" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始时间">
          <el-date-picker v-model="taskForm.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择开始时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="截止时间">
          <el-date-picker v-model="taskForm.dueTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="请选择截止时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="任务说明" prop="content">
          <el-input v-model="taskForm.content" type="textarea" :rows="4" placeholder="请输入任务说明" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitTaskForm">确 定</el-button>
        <el-button @click="taskDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="任务跟进" :visible.sync="recordDialogOpen" width="520px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="跟进内容">
          <el-input v-model="recordForm.recordContent" type="textarea" :rows="4" placeholder="请输入跟进内容" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitRecord">确 定</el-button>
        <el-button @click="recordDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="日程详情" :visible.sync="scheduleDetailOpen" width="640px" append-to-body>
      <el-descriptions v-if="scheduleDetail" :column="1" border>
        <el-descriptions-item label="日程标题">{{ scheduleDetail.scheduleTitle }}</el-descriptions-item>
        <el-descriptions-item label="所属人">{{ scheduleDetail.ownerName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="日程类型">{{ scheduleDetail.scheduleType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ scheduleDetail.scheduleStatusLabel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ scheduleDetail.startTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ scheduleDetail.endTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="提醒时间">{{ scheduleDetail.remindTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ scheduleDetail.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <el-dialog title="会议详情" :visible.sync="meetingDetailOpen" width="640px" append-to-body>
      <el-descriptions v-if="meetingDetail" :column="1" border>
        <el-descriptions-item label="会议标题">{{ meetingDetail.meetingTitle }}</el-descriptions-item>
        <el-descriptions-item label="会议室">{{ meetingDetail.roomName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="组织人">{{ meetingDetail.organizerName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="会议状态">{{ meetingDetail.meetingStatusLabel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ meetingDetail.startTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ meetingDetail.endTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="会议纪要">{{ meetingDetail.summaryContent || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <el-dialog title="任务详情" :visible.sync="taskDetailOpen" width="720px" append-to-body>
      <el-descriptions v-if="taskDetail" :column="1" border>
        <el-descriptions-item label="任务标题">{{ taskDetail.taskTitle }}</el-descriptions-item>
        <el-descriptions-item label="任务类型">{{ taskDetail.taskType || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发布人">{{ taskDetail.publisherName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="负责人">{{ taskDetail.assigneeName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="优先级">{{ taskDetail.priorityLevel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="任务状态">{{ taskDetail.taskStatusLabel || '-' }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ taskDetail.startTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="截止时间">{{ taskDetail.dueTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ taskDetail.completeTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="任务说明">{{ taskDetail.content || '-' }}</el-descriptions-item>
      </el-descriptions>
      <div v-if="taskRecords.length" class="record-section">
        <div class="record-title">跟进记录</div>
        <div v-for="item in taskRecords" :key="item.recordId" class="record-item">
          <div class="panel-title">{{ item.recordContent }}</div>
          <div class="panel-text">{{ item.operatorName || '-' }} ｜ {{ item.createTime || '-' }}</div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { checkPermi } from '@/utils/permission'
import { addMeeting, finishMeeting, getMeeting, listMeeting, listMeetingRooms } from '@/api/oa/meeting'
import { addSchedule, finishSchedule, getSchedule, getScheduleWorkbench, listSchedule } from '@/api/oa/schedule'
import { addTask, addTaskRecord, completeTask, getTask, listTask } from '@/api/oa/task'

export default {
  name: 'OaCollabIndex',
  data() {
    return {
      scheduleLoading: false,
      meetingLoading: false,
      taskLoading: false,
      activeTab: 'schedule',
      summaries: [
        { label: '我的日程', value: 0 },
        { label: '待处理', value: 0 },
        { label: '已完成', value: 0 }
      ],
      roomOptions: [],
      scheduleList: [],
      meetingList: [],
      taskList: [],
      scheduleQuery: {
        scheduleTitle: undefined,
        scheduleStatus: undefined
      },
      meetingQuery: {
        meetingTitle: undefined,
        meetingStatus: undefined
      },
      taskQuery: {
        taskTitle: undefined,
        taskStatus: undefined
      },
      scheduleDialogOpen: false,
      meetingDialogOpen: false,
      taskDialogOpen: false,
      recordDialogOpen: false,
      hasScheduleQuery: false,
      hasMeetingQuery: false,
      hasTaskQuery: false,
      scheduleDetailOpen: false,
      meetingDetailOpen: false,
      taskDetailOpen: false,
      currentTaskId: undefined,
      scheduleDetail: null,
      meetingDetail: null,
      taskDetail: null,
      taskRecords: [],
      scheduleForm: {
        scheduleTitle: undefined,
        scheduleType: undefined,
        startTime: undefined,
        endTime: undefined,
        remindTime: undefined,
        scheduleStatus: 'pending',
        remark: undefined
      },
      meetingForm: {
        meetingTitle: undefined,
        roomId: undefined,
        startTime: undefined,
        endTime: undefined,
        meetingStatus: 'scheduled',
        summaryContent: undefined
      },
      taskForm: {
        taskTitle: undefined,
        taskType: undefined,
        assigneeName: undefined,
        priorityLevel: '中',
        startTime: undefined,
        dueTime: undefined,
        content: undefined
      },
      recordForm: {
        recordContent: '任务跟进'
      },
      scheduleRules: {
        scheduleTitle: [{ required: true, message: '日程标题不能为空', trigger: 'blur' }],
        startTime: [{ required: true, message: '开始时间不能为空', trigger: 'change' }],
        endTime: [{ required: true, message: '结束时间不能为空', trigger: 'change' }],
        scheduleStatus: [{ required: true, message: '状态不能为空', trigger: 'change' }]
      },
      meetingRules: {
        meetingTitle: [{ required: true, message: '会议标题不能为空', trigger: 'blur' }],
        roomId: [{ required: true, message: '会议室不能为空', trigger: 'change' }],
        startTime: [{ required: true, message: '开始时间不能为空', trigger: 'change' }],
        endTime: [{ required: true, message: '结束时间不能为空', trigger: 'change' }],
        meetingStatus: [{ required: true, message: '会议状态不能为空', trigger: 'change' }]
      },
      taskRules: {
        taskTitle: [{ required: true, message: '任务标题不能为空', trigger: 'blur' }],
        assigneeName: [{ required: true, message: '负责人不能为空', trigger: 'blur' }],
        content: [{ required: true, message: '任务说明不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.initPermissions()
    this.activeTab = this.normalizeTab(this.$route.query.tab)
    this.syncTabQuery()
    this.getScheduleWorkbench()
    this.loadActiveTabData()
  },
  watch: {
    '$route.query.tab'(value) {
      const tab = this.normalizeTab(value)
      const changed = tab !== this.activeTab
      this.activeTab = tab
      if (tab !== value) {
        this.syncTabQuery()
        return
      }
      if (changed) {
        this.loadActiveTabData()
      }
    }
  },
  methods: {
    initPermissions() {
      this.hasScheduleQuery = checkPermi(['oa:collab:schedule:list', 'oa:collab:schedule:query'])
      this.hasMeetingQuery = checkPermi(['oa:collab:meeting:list', 'oa:collab:meeting:query'])
      this.hasTaskQuery = checkPermi(['oa:collab:task:list', 'oa:collab:task:query'])
    },
    normalizeTab(tab) {
      const tabs = []
      if (this.hasScheduleQuery) {
        tabs.push('schedule')
      }
      if (this.hasMeetingQuery) {
        tabs.push('meeting')
      }
      if (this.hasTaskQuery) {
        tabs.push('task')
      }
      if (!tabs.length) {
        return 'schedule'
      }
      return tabs.includes(tab) ? tab : tabs[0]
    },
    handleTabChange() {
      this.activeTab = this.normalizeTab(this.activeTab)
      this.syncTabQuery()
      this.loadActiveTabData()
    },
    syncTabQuery() {
      const query = { ...this.$route.query }
      if (this.activeTab === 'schedule') {
        delete query.tab
      } else {
        query.tab = this.activeTab
      }
      this.$router.replace({ query })
    },
    loadActiveTabData() {
      if (this.activeTab === 'meeting') {
        this.getMeetingRooms()
        this.getMeetingList()
        return
      }
      if (this.activeTab === 'task') {
        this.getTaskList()
        return
      }
      this.getScheduleList()
    },
    getScheduleWorkbench() {
      if (!this.hasScheduleQuery) {
        return
      }
      this.scheduleLoading = true
      getScheduleWorkbench().then(res => {
        const data = res.data || {}
        this.summaries = data.summary || this.summaries
        this.scheduleLoading = false
      }).catch(() => {
        this.scheduleLoading = false
      })
    },
    getScheduleList() {
      if (!this.hasScheduleQuery) {
        this.scheduleList = []
        return
      }
      this.scheduleLoading = true
      listSchedule(this.scheduleQuery).then(res => {
        this.scheduleList = res.rows || []
        this.scheduleLoading = false
      }).catch(() => {
        this.scheduleLoading = false
      })
    },
    getMeetingRooms() {
      if (!this.hasMeetingQuery) {
        this.roomOptions = []
        return
      }
      listMeetingRooms().then(res => {
        this.roomOptions = res.data || []
      })
    },
    getMeetingList() {
      if (!this.hasMeetingQuery) {
        this.meetingList = []
        return
      }
      this.meetingLoading = true
      listMeeting(this.meetingQuery).then(res => {
        this.meetingList = res.rows || []
        this.meetingLoading = false
      }).catch(() => {
        this.meetingLoading = false
      })
    },
    getTaskList() {
      if (!this.hasTaskQuery) {
        this.taskList = []
        return
      }
      this.taskLoading = true
      listTask(this.taskQuery).then(res => {
        this.taskList = res.rows || []
        this.taskLoading = false
      }).catch(() => {
        this.taskLoading = false
      })
    },
    resetScheduleQuery() {
      this.scheduleQuery.scheduleTitle = undefined
      this.scheduleQuery.scheduleStatus = undefined
      this.getScheduleList()
    },
    resetMeetingQuery() {
      this.meetingQuery.meetingTitle = undefined
      this.meetingQuery.meetingStatus = undefined
      this.getMeetingList()
    },
    resetTaskQuery() {
      this.taskQuery.taskTitle = undefined
      this.taskQuery.taskStatus = undefined
      this.getTaskList()
    },
    openScheduleDialog() {
      this.scheduleForm = {
        scheduleTitle: undefined,
        scheduleType: undefined,
        startTime: undefined,
        endTime: undefined,
        remindTime: undefined,
        scheduleStatus: 'pending',
        remark: undefined
      }
      this.scheduleDialogOpen = true
      this.$nextTick(() => {
        this.$refs.scheduleForm && this.$refs.scheduleForm.clearValidate()
      })
    },
    openMeetingDialog() {
      this.meetingForm = {
        meetingTitle: undefined,
        roomId: undefined,
        startTime: undefined,
        endTime: undefined,
        meetingStatus: 'scheduled',
        summaryContent: undefined
      }
      this.meetingDialogOpen = true
      this.$nextTick(() => {
        this.$refs.meetingForm && this.$refs.meetingForm.clearValidate()
      })
    },
    openTaskDialog() {
      this.taskForm = {
        taskTitle: undefined,
        taskType: undefined,
        assigneeName: undefined,
        priorityLevel: '中',
        startTime: undefined,
        dueTime: undefined,
        content: undefined
      }
      this.taskDialogOpen = true
      this.$nextTick(() => {
        this.$refs.taskForm && this.$refs.taskForm.clearValidate()
      })
    },
    submitScheduleForm() {
      this.$refs.scheduleForm.validate(valid => {
        if (!valid) {
          return
        }
        addSchedule(this.scheduleForm).then(() => {
          this.$modal.msgSuccess('新增成功')
          this.scheduleDialogOpen = false
          this.getScheduleWorkbench()
          this.getScheduleList()
        })
      })
    },
    submitMeetingForm() {
      this.$refs.meetingForm.validate(valid => {
        if (!valid) {
          return
        }
        addMeeting(this.meetingForm).then(() => {
          this.$modal.msgSuccess('新增成功')
          this.meetingDialogOpen = false
          this.getMeetingList()
        })
      })
    },
    submitTaskForm() {
      this.$refs.taskForm.validate(valid => {
        if (!valid) {
          return
        }
        addTask(this.taskForm).then(() => {
          this.$modal.msgSuccess('新增成功')
          this.taskDialogOpen = false
          this.getTaskList()
        })
      })
    },
    showScheduleDetail(row) {
      getSchedule(row.scheduleId).then(res => {
        this.scheduleDetail = res.data
        this.scheduleDetailOpen = true
      })
    },
    showMeetingDetail(row) {
      getMeeting(row.meetingId).then(res => {
        this.meetingDetail = res.data
        this.meetingDetailOpen = true
      })
    },
    showTaskDetail(row) {
      getTask(row.taskId).then(res => {
        this.taskDetail = res.data
        this.taskRecords = res.records || []
        this.taskDetailOpen = true
      })
    },
    handleFinishSchedule(row) {
      this.$modal.confirm('是否确认完成日程“' + row.scheduleTitle + '”？').then(() => {
        return finishSchedule(row.scheduleId)
      }).then(() => {
        this.$modal.msgSuccess('日程已完成')
        this.getScheduleWorkbench()
        this.getScheduleList()
        if (this.scheduleDetail && this.scheduleDetail.scheduleId === row.scheduleId) {
          this.showScheduleDetail(row)
        }
      }).catch(() => {})
    },
    handleFinishMeeting(row) {
      this.$modal.confirm('是否确认完成会议“' + row.meetingTitle + '”？').then(() => {
        return finishMeeting(row.meetingId)
      }).then(() => {
        this.$modal.msgSuccess('会议已完成')
        this.getMeetingList()
        if (this.meetingDetail && this.meetingDetail.meetingId === row.meetingId) {
          this.showMeetingDetail(row)
        }
      }).catch(() => {})
    },
    handleCompleteTask(row) {
      this.$modal.confirm('是否确认完成任务“' + row.taskTitle + '”？').then(() => {
        return completeTask(row.taskId)
      }).then(() => {
        this.$modal.msgSuccess('任务已完成')
        this.getTaskList()
        if (this.taskDetail && this.taskDetail.taskId === row.taskId) {
          this.showTaskDetail(row)
        }
      }).catch(() => {})
    },
    openRecordDialog(row) {
      this.currentTaskId = row.taskId
      this.recordForm.recordContent = '任务跟进'
      this.recordDialogOpen = true
    },
    submitRecord() {
      addTaskRecord(this.currentTaskId, this.recordForm.recordContent).then(() => {
        this.$modal.msgSuccess('跟进成功')
        this.recordDialogOpen = false
        this.getTaskList()
        if (this.taskDetail && this.taskDetail.taskId === this.currentTaskId) {
          this.showTaskDetail({ taskId: this.currentTaskId })
        }
      })
    },
    scheduleTagType(status) {
      if (status === 'completed') {
        return 'success'
      }
      if (status === 'cancelled') {
        return 'info'
      }
      return 'warning'
    },
    meetingTagType(status) {
      if (status === 'finished') {
        return 'success'
      }
      if (status === 'draft') {
        return 'info'
      }
      return 'warning'
    },
    taskTagType(status) {
      if (status === 'completed') {
        return 'success'
      }
      if (status === 'processing') {
        return 'warning'
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

  .record-section {
    margin-top: 20px;
  }

  .record-title {
    margin-bottom: 12px;
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .record-item + .record-item {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid #ebeef5;
  }
}
</style>
