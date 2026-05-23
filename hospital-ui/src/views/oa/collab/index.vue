<template>
  <div class="app-container oa-page">
    <section class="oa-module-hero">
      <div>
        <div class="oa-module-kicker"><i class="el-icon-date" /> Collaboration</div>
        <h1 class="oa-module-title">会议任务日程</h1>
        <p class="oa-module-subtitle">把个人日程、会议室预约和任务督办放在一个协同工作台中，方便按天、按状态推进事项。</p>
      </div>
      <div class="oa-module-actions">
        <el-button v-if="activeTab === 'schedule'" type="primary" icon="el-icon-plus" @click="openScheduleDialog()" v-hasPermi="['oa:collab:schedule:list']">新增日程</el-button>
        <el-button v-if="activeTab === 'meeting'" type="primary" icon="el-icon-plus" @click="openMeetingDialog" v-hasPermi="['oa:collab:meeting:list']">新增会议</el-button>
        <el-button v-if="activeTab === 'task'" type="primary" icon="el-icon-plus" @click="openTaskDialog" v-hasPermi="['oa:collab:task:list']">新增任务</el-button>
      </div>
    </section>

    <div class="oa-summary-grid three" v-loading="scheduleLoading">
      <div v-for="item in summaries" :key="item.label" class="oa-stat-item">
        <div class="oa-stat-value">{{ item.value }}</div>
        <div class="oa-stat-label">{{ item.label }}</div>
      </div>
    </div>

    <section class="oa-section-card collab-tabs-card">
      <el-tabs v-model="activeTab" class="oa-tabs collab-tabs" @tab-click="handleTabChange">
        <el-tab-pane v-if="hasScheduleQuery" label="我的日程" name="schedule" />
        <el-tab-pane v-if="hasMeetingQuery" label="会议管理" name="meeting" />
        <el-tab-pane v-if="hasTaskQuery" label="任务督办" name="task" />
      </el-tabs>
    </section>

    <section v-show="activeTab === 'schedule'" class="oa-section-card schedule-calendar-card">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">我的日程</h2>
          <div class="oa-section-note">{{ selectedDayText }} · {{ selectedDaySchedules.length }} 项</div>
        </div>
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
          <el-button type="success" size="mini" icon="el-icon-plus" @click="openScheduleDialog()" v-hasPermi="['oa:collab:schedule:list']">新增日程</el-button>
        </el-form-item>
      </el-form>

      <el-row :gutter="20" class="calendar-layout" v-loading="scheduleLoading">
        <el-col :xs="24" :lg="16">
          <el-calendar v-model="calendarValue" class="schedule-calendar">
            <template slot="dateCell" slot-scope="{ data }">
              <div
                class="calendar-cell"
                :class="{ 'is-selected': isCurrentCalendarDay(data.day), 'is-other-month': data.type !== 'current-month' }"
                @click="selectCalendarDay(data.day)"
              >
                <div class="calendar-day-head">
                  <span class="calendar-day-number">{{ dayNumber(data.day) }}</span>
                  <span v-if="schedulesByDate[data.day] && schedulesByDate[data.day].length" class="calendar-count">
                    {{ schedulesByDate[data.day].length }}项
                  </span>
                </div>
                <div class="calendar-events">
                  <div
                    v-for="item in previewSchedules(data.day)"
                    :key="item.scheduleId"
                    class="calendar-event"
                    :class="calendarEventClass(item.scheduleStatus)"
                    @click.stop="showScheduleDetail(item)"
                  >
                    <span class="event-time">{{ shortTime(item.startTime) }}</span>
                    <span class="event-title">{{ item.scheduleTitle }}</span>
                  </div>
                  <div v-if="moreScheduleCount(data.day)" class="calendar-more">+{{ moreScheduleCount(data.day) }} 更多</div>
                </div>
              </div>
            </template>
          </el-calendar>
        </el-col>
        <el-col :xs="24" :lg="8">
          <div class="schedule-day-panel">
            <div class="day-panel-header">
              <div>
                <div class="day-panel-label">选中日期</div>
                <div class="day-panel-title">{{ selectedDayText }}</div>
              </div>
              <el-button type="primary" size="mini" icon="el-icon-plus" @click="openScheduleDialog(selectedDay)" v-hasPermi="['oa:collab:schedule:list']">新增</el-button>
            </div>
            <div v-if="selectedDaySchedules.length" class="day-schedule-list">
              <div v-for="item in selectedDaySchedules" :key="item.scheduleId" class="day-schedule-item">
                <div class="schedule-item-dot" :class="calendarEventClass(item.scheduleStatus)" />
                <div class="schedule-item-main">
                  <div class="schedule-item-title">{{ item.scheduleTitle }}</div>
                  <div class="schedule-item-time">{{ formatTimeRange(item) }}</div>
                  <div class="schedule-item-meta">
                    <el-tag size="mini" :type="scheduleTagType(item.scheduleStatus)">{{ item.scheduleStatusLabel || statusLabel(item.scheduleStatus) }}</el-tag>
                    <span v-if="item.scheduleType">{{ item.scheduleType }}</span>
                  </div>
                  <div class="schedule-item-actions">
                    <el-button type="text" size="mini" @click="showScheduleDetail(item)">详情</el-button>
                    <el-button v-if="item.scheduleStatus === 'pending'" type="text" size="mini" @click="handleFinishSchedule(item)" v-hasPermi="['oa:collab:schedule:list']">完成</el-button>
                  </div>
                </div>
              </div>
            </div>
            <el-empty v-else description="当天暂无日程" :image-size="86" />
          </div>
        </el-col>
      </el-row>
    </section>

    <section v-show="activeTab === 'meeting'" class="oa-section-card">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">会议管理</h2>
          <div class="oa-section-note">会议预约 · {{ meetingList.length }} 条</div>
        </div>
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
        </el-form-item>
      </el-form>

      <div v-loading="meetingLoading">
        <div v-if="meetingList.length" class="oa-record-grid">
          <article v-for="item in meetingList" :key="item.meetingId" class="oa-record-card meeting-card">
            <div class="oa-record-head">
              <div>
                <div class="oa-record-title">{{ item.meetingTitle || '-' }}</div>
                <div class="oa-record-code">{{ item.roomName || '-' }}</div>
              </div>
              <el-tag size="mini" :type="meetingTagType(item.meetingStatus)">{{ item.meetingStatusLabel || '-' }}</el-tag>
            </div>
            <div class="oa-record-body">
              <div class="oa-meta-row">
                <i class="el-icon-user" />
                <span class="oa-meta-text">组织人：{{ item.organizerName || '-' }}</span>
              </div>
              <div class="oa-meta-row">
                <i class="el-icon-time" />
                <span class="oa-meta-text">{{ item.startTime || '-' }} 至 {{ item.endTime || '-' }}</span>
              </div>
            </div>
            <div class="oa-action-row">
              <el-button type="text" size="mini" @click="showMeetingDetail(item)">详情</el-button>
              <el-button v-if="item.meetingStatus === 'scheduled'" type="text" size="mini" @click="handleFinishMeeting(item)" v-hasPermi="['oa:collab:meeting:list']">完成</el-button>
            </div>
          </article>
        </div>
        <div v-else class="oa-empty-wrap">
          <el-empty description="暂无会议数据" :image-size="90" />
        </div>
      </div>
    </section>

    <section v-show="activeTab === 'task'" class="oa-section-card">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">任务督办</h2>
          <div class="oa-section-note">任务看板 · {{ taskList.length }} 条</div>
        </div>
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
        </el-form-item>
      </el-form>

      <div v-loading="taskLoading" class="oa-kanban">
        <div v-for="column in taskColumns" :key="column.status" class="oa-kanban-column">
          <div class="oa-kanban-title">
            <span>{{ column.label }}</span>
            <el-tag size="mini" :type="column.type">{{ column.list.length }}</el-tag>
          </div>
          <div v-if="column.list.length" class="oa-list-stack">
            <article v-for="item in column.list" :key="item.taskId" class="oa-record-card task-card">
              <div class="oa-record-head">
                <div>
                  <div class="oa-record-title">{{ item.taskTitle || '-' }}</div>
                  <div class="oa-record-code">{{ item.taskType || '任务' }}</div>
                </div>
                <el-tag size="mini" :type="taskTagType(item.taskStatus)">{{ item.taskStatusLabel || column.label }}</el-tag>
              </div>
              <div class="oa-record-body">
                <div class="oa-meta-row">
                  <i class="el-icon-user" />
                  <span class="oa-meta-text">{{ item.assigneeName || '-' }} ｜ {{ item.priorityLevel || '中' }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-time" />
                  <span class="oa-meta-text">截止 {{ item.dueTime || '-' }}</span>
                </div>
              </div>
              <div class="oa-action-row">
                <el-button type="text" size="mini" @click="showTaskDetail(item)">详情</el-button>
                <el-button v-if="item.taskStatus !== 'completed'" type="text" size="mini" @click="handleCompleteTask(item)" v-hasPermi="['oa:collab:task:list']">完成</el-button>
                <el-button type="text" size="mini" @click="openRecordDialog(item)" v-hasPermi="['oa:collab:task:list']">跟进</el-button>
              </div>
            </article>
          </div>
          <el-empty v-else description="暂无任务" :image-size="70" />
        </div>
      </div>
    </section>

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
      calendarValue: new Date(),
      selectedDay: this.formatDate(new Date()),
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
  computed: {
    schedulesByDate() {
      return this.scheduleList.reduce((dateMap, item) => {
        const date = this.dateKey(item.startTime || item.remindTime || item.endTime)
        if (!date) {
          return dateMap
        }
        if (!dateMap[date]) {
          dateMap[date] = []
        }
        dateMap[date].push(item)
        dateMap[date].sort((prev, next) => String(prev.startTime || '').localeCompare(String(next.startTime || '')))
        return dateMap
      }, {})
    },
    selectedDaySchedules() {
      return this.schedulesByDate[this.selectedDay] || []
    },
    selectedDayText() {
      const date = this.parseDate(this.selectedDay)
      if (!date) {
        return this.selectedDay
      }
      return new Intl.DateTimeFormat('zh-CN', {
        month: 'long',
        day: 'numeric',
        weekday: 'long'
      }).format(date)
    },
    taskColumns() {
      const columns = [
        { status: 'pending', label: '待处理', type: 'info' },
        { status: 'processing', label: '进行中', type: 'warning' },
        { status: 'completed', label: '已完成', type: 'success' }
      ]
      return columns.map(column => ({
        ...column,
        list: this.taskList.filter(item => (item.taskStatus || 'pending') === column.status)
      }))
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
    calendarValue(value) {
      const day = this.formatDate(value)
      if (day && day !== this.selectedDay) {
        this.selectedDay = day
      }
    },
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
    formatDate(date) {
      if (!date) {
        return ''
      }
      const parsedDate = date instanceof Date ? date : new Date(String(date).replace(/-/g, '/'))
      if (isNaN(parsedDate.getTime())) {
        return ''
      }
      const year = parsedDate.getFullYear()
      const month = String(parsedDate.getMonth() + 1).padStart(2, '0')
      const day = String(parsedDate.getDate()).padStart(2, '0')
      return `${year}-${month}-${day}`
    },
    parseDate(day) {
      if (!day) {
        return null
      }
      const parsedDate = new Date(String(day).replace(/-/g, '/'))
      return isNaN(parsedDate.getTime()) ? null : parsedDate
    },
    dateKey(value) {
      if (!value) {
        return ''
      }
      if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}/.test(value)) {
        return value.slice(0, 10)
      }
      return this.formatDate(value)
    },
    dayNumber(day) {
      return day ? Number(day.slice(-2)) : ''
    },
    isCurrentCalendarDay(day) {
      return day === this.selectedDay
    },
    selectCalendarDay(day) {
      this.selectedDay = day
      const date = this.parseDate(day)
      if (date) {
        this.calendarValue = date
      }
    },
    previewSchedules(day) {
      return (this.schedulesByDate[day] || []).slice(0, 3)
    },
    moreScheduleCount(day) {
      const count = (this.schedulesByDate[day] || []).length
      return count > 3 ? count - 3 : 0
    },
    shortTime(value) {
      if (!value) {
        return '--:--'
      }
      return String(value).slice(11, 16) || '--:--'
    },
    formatTimeRange(item) {
      const start = item.startTime || '-'
      const end = item.endTime || '-'
      return start + ' 至 ' + end
    },
    buildDateTime(day, time) {
      return day ? day + ' ' + time : undefined
    },
    calendarEventClass(status) {
      if (status === 'completed') {
        return 'status-completed'
      }
      if (status === 'cancelled') {
        return 'status-cancelled'
      }
      return 'status-pending'
    },
    statusLabel(status) {
      const labelMap = {
        pending: '待处理',
        completed: '已完成',
        cancelled: '已取消'
      }
      return labelMap[status] || status || '-'
    },
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
    openScheduleDialog(day) {
      const formDay = day || this.selectedDay
      this.scheduleForm = {
        scheduleTitle: undefined,
        scheduleType: undefined,
        startTime: this.buildDateTime(formDay, '09:00:00'),
        endTime: this.buildDateTime(formDay, '10:00:00'),
        remindTime: this.buildDateTime(formDay, '08:30:00'),
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
  .collab-tabs-card {
    padding-top: 8px;
    padding-bottom: 0;
  }

  .collab-tabs {
    margin-bottom: 0;
  }

  .schedule-calendar-card,
  .oa-section-card {
    ::v-deep .el-form-item {
      margin-bottom: 10px;
    }
  }

  .calendar-layout {
    margin-top: 8px;
  }

  .schedule-calendar {
    overflow: hidden;
    border: 1px solid #e2e8f0;
    border-radius: 8px;

    ::v-deep .el-calendar__header {
      padding: 18px 20px;
      border-bottom: 1px solid #eef2f7;
      background: linear-gradient(135deg, #f8fbff 0%, #eef6ff 100%);
    }

    ::v-deep .el-calendar__title {
      color: #0f172a;
      font-size: 18px;
      font-weight: 800;
    }

    ::v-deep .el-calendar__button-group .el-button {
      border-radius: 999px;
    }

    ::v-deep .el-calendar-table thead th {
      padding: 12px 0;
      color: #64748b;
      font-weight: 700;
      background: #ffffff;
    }

    ::v-deep .el-calendar-table td {
      border-color: #eef2f7;
      transition: background 0.2s ease;

      &:hover {
        background: #f8fafc;
      }
    }

    ::v-deep .el-calendar-day {
      height: 132px;
      padding: 0;
    }
  }

  .calendar-cell {
    height: 100%;
    padding: 10px;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.2s ease, box-shadow 0.2s ease;

    &.is-selected {
      background: linear-gradient(180deg, rgba(37, 99, 235, 0.08), rgba(14, 165, 233, 0.05));
      box-shadow: inset 0 0 0 1px rgba(37, 99, 235, 0.24);
    }

    &.is-other-month {
      opacity: 0.48;
    }
  }

  .calendar-day-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  .calendar-day-number {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    border-radius: 999px;
    color: #0f172a;
    font-weight: 800;
  }

  .calendar-count {
    padding: 2px 7px;
    border-radius: 999px;
    color: #2563eb;
    font-size: 12px;
    background: rgba(37, 99, 235, 0.1);
  }

  .calendar-events {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .calendar-event {
    display: flex;
    align-items: center;
    gap: 5px;
    min-width: 0;
    padding: 5px 7px;
    border-radius: 6px;
    font-size: 12px;
    line-height: 1.2;
    transition: transform 0.2s ease;

    &:hover {
      transform: translateX(2px);
    }
  }

  .event-time {
    flex: 0 0 auto;
    font-weight: 800;
  }

  .event-title {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .calendar-more {
    color: #64748b;
    font-size: 12px;
    line-height: 1.4;
  }

  .status-pending {
    color: #b45309;
    background: rgba(245, 158, 11, 0.12);
  }

  .status-completed {
    color: #047857;
    background: rgba(16, 185, 129, 0.12);
  }

  .status-cancelled {
    color: #64748b;
    background: rgba(100, 116, 139, 0.12);
  }

  .schedule-day-panel {
    min-height: 100%;
    padding: 20px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: linear-gradient(180deg, #ffffff, #f8fafc);
    box-shadow: 0 16px 36px rgba(15, 23, 42, 0.06);
  }

  .day-panel-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 18px;
  }

  .day-panel-label {
    margin-bottom: 6px;
    color: #3b82f6;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.12em;
    text-transform: uppercase;
  }

  .day-panel-title {
    color: #0f172a;
    font-size: 20px;
    font-weight: 800;
  }

  .day-schedule-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .day-schedule-item {
    display: flex;
    gap: 12px;
    padding: 14px;
    border: 1px solid #eef2f7;
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.86);
  }

  .schedule-item-dot {
    flex: 0 0 10px;
    width: 10px;
    height: 10px;
    margin-top: 5px;
    border-radius: 999px;
  }

  .schedule-item-main {
    min-width: 0;
    flex: 1;
  }

  .schedule-item-title {
    overflow: hidden;
    color: #0f172a;
    font-weight: 800;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .schedule-item-time {
    margin-top: 6px;
    color: #64748b;
    font-size: 12px;
    line-height: 1.5;
  }

  .schedule-item-meta {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 8px;
    color: #94a3b8;
    font-size: 12px;
  }

  .schedule-item-actions {
    margin-top: 6px;
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

@media screen and (max-width: 1200px) {
  .oa-page {
    .schedule-day-panel {
      margin-top: 18px;
    }
  }
}

@media screen and (max-width: 768px) {
  .oa-page {
    .schedule-calendar {
      ::v-deep .el-calendar__header {
        display: block;
      }

      ::v-deep .el-calendar__button-group {
        margin-top: 12px;
      }

      ::v-deep .el-calendar-day {
        height: 96px;
      }
    }

    .calendar-cell {
      padding: 8px;
    }

    .calendar-event {
      padding: 4px 6px;
    }

    .event-time,
    .calendar-count {
      display: none;
    }
  }
}
</style>
