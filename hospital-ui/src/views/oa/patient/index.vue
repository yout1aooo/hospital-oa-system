<template>
  <div class="app-container oa-page">
    <section class="oa-module-hero">
      <div>
        <div class="oa-module-kicker"><i class="el-icon-first-aid-kit" /> Patient</div>
        <h1 class="oa-module-title">患者病例查询</h1>
        <p class="oa-module-subtitle">面向院内办公协同的患者主档和病例检索，列表脱敏展示，详情访问继续保留审计记录。</p>
      </div>
      <div class="oa-module-actions">
        <el-button v-if="activeTab === 'patient'" v-hasPermi="['oa:patient:export']" type="warning" plain icon="el-icon-download" @click="handleExportPatient">导出患者</el-button>
        <el-button v-if="activeTab === 'case'" v-hasPermi="['oa:patient:case:export']" type="warning" plain icon="el-icon-download" @click="handleExportCase">导出病例</el-button>
        <el-button type="primary" icon="el-icon-search" @click="getCurrentList">刷新数据</el-button>
      </div>
    </section>

    <div class="oa-summary-grid" v-loading="loadingWorkbench">
      <div v-for="item in summaries" :key="item.label" class="oa-stat-item">
        <div class="oa-stat-value">{{ item.value }}</div>
        <div class="oa-stat-label">{{ item.label }}</div>
      </div>
    </div>

    <section class="oa-toolbar-card">
      <el-form :inline="true" :model="queryParams" size="small">
        <el-form-item label="关键词">
          <el-input v-model="queryParams.keyword" placeholder="患者姓名/编号/病例号" clearable @keyup.enter.native="getCurrentList" />
        </el-form-item>
        <el-form-item label="科室">
          <el-select v-model="queryParams.deptId" placeholder="全部科室" clearable filterable>
            <el-option v-for="item in deptOptions" :key="item.deptId" :label="item.deptName" :value="item.deptId" />
          </el-select>
        </el-form-item>
        <el-form-item label="主治医生">
          <el-input v-model="queryParams.doctorName" placeholder="请输入医生姓名" clearable @keyup.enter.native="getCurrentList" />
        </el-form-item>
        <el-form-item v-if="activeTab === 'patient'" label="患者状态">
          <el-select v-model="queryParams.patientStatus" placeholder="全部状态" clearable>
            <el-option v-for="item in patientStatusOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item v-else label="病例状态">
          <el-select v-model="queryParams.caseStatus" placeholder="全部状态" clearable>
            <el-option v-for="item in caseStatusOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="activeTab === 'patient'" label="入院时间">
          <el-date-picker
            v-model="admissionRange"
            type="daterange"
            value-format="yyyy-MM-dd HH:mm:ss"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="mini" icon="el-icon-search" @click="getCurrentList">查询</el-button>
          <el-button size="mini" icon="el-icon-refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </section>

    <section class="oa-section-card">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">诊疗档案</h2>
          <div class="oa-section-note">{{ activeTabLabel }} · {{ activeListCount }} 条</div>
        </div>
      </div>

      <el-tabs v-model="activeTab" class="oa-tabs" @tab-click="handleTabChange">
        <el-tab-pane v-if="hasPatientTab" label="患者查询" name="patient" />
        <el-tab-pane v-if="hasCaseTab" label="病例查询" name="case" />
      </el-tabs>

      <div v-loading="loadingList">
        <div v-show="activeTab === 'patient'">
          <div v-if="patientList.length" class="oa-record-grid patient-grid">
            <article v-for="item in patientList" :key="item.patientId" class="oa-record-card patient-card">
              <div class="oa-record-head">
                <div>
                  <div class="oa-record-title">{{ item.patientName || '-' }}</div>
                  <div class="oa-record-code">{{ item.patientNo || '-' }}</div>
                </div>
                <el-tag size="mini" :type="patientTagType(item.patientStatus)">{{ item.patientStatusLabel || '-' }}</el-tag>
              </div>
              <div class="oa-record-body">
                <div class="oa-meta-row">
                  <i class="el-icon-user" />
                  <span class="oa-meta-text">{{ item.genderLabel || '-' }} ｜ 病例 {{ item.caseCount || 0 }} 份</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-office-building" />
                  <span class="oa-meta-text">{{ item.deptName || '-' }} ｜ {{ item.attendingDoctorName || '-' }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-postcard" />
                  <span class="oa-meta-text">{{ maskIdCard(item.idCardNo) }} ｜ {{ maskPhone(item.phoneNo) }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-date" />
                  <span class="oa-meta-text">入院 {{ item.admissionTime || '-' }}</span>
                </div>
              </div>
              <div class="oa-action-row">
                <el-button type="text" size="mini" @click="showPatientDetail(item)">查看详情</el-button>
              </div>
            </article>
          </div>
          <div v-else class="oa-empty-wrap">
            <el-empty description="暂无患者数据" :image-size="90" />
          </div>
        </div>

        <div v-show="activeTab === 'case'">
          <div v-if="caseList.length" class="oa-record-grid patient-grid">
            <article v-for="item in caseList" :key="item.caseId" class="oa-record-card case-card">
              <div class="oa-record-head">
                <div>
                  <div class="oa-record-title">{{ item.caseTitle || '-' }}</div>
                  <div class="oa-record-code">{{ item.caseNo || '-' }}</div>
                </div>
                <el-tag size="mini" :type="caseTagType(item.caseStatus)">{{ item.caseStatusLabel || '-' }}</el-tag>
              </div>
              <div class="oa-record-body">
                <div class="oa-meta-row">
                  <i class="el-icon-user" />
                  <span class="oa-meta-text">{{ item.patientName || '-' }} ｜ {{ item.visitTypeLabel || '-' }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-first-aid-kit" />
                  <span class="oa-meta-text">{{ item.deptName || '-' }} ｜ {{ item.doctorName || '-' }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-document-checked" />
                  <span class="oa-meta-text">{{ item.diagnosis || '暂无诊断' }}</span>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-time" />
                  <span class="oa-meta-text">{{ item.visitTime || '-' }}</span>
                </div>
              </div>
              <div class="oa-action-row">
                <el-button type="text" size="mini" @click="showCaseDetail(item)">查看详情</el-button>
              </div>
            </article>
          </div>
          <div v-else class="oa-empty-wrap">
            <el-empty description="暂无病例数据" :image-size="90" />
          </div>
        </div>
      </div>
    </section>

    <el-dialog title="患者详情" :visible.sync="patientDetailOpen" width="880px" append-to-body>
      <div v-if="patientDetail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="患者编号">{{ patientDetail.patientNo }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ patientDetail.patientName }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ patientDetail.genderLabel }}</el-descriptions-item>
          <el-descriptions-item label="出生日期">{{ patientDetail.birthday || '-' }}</el-descriptions-item>
          <el-descriptions-item label="身份证">{{ patientDetail.idCardNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ patientDetail.phoneNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="科室">{{ patientDetail.deptName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="主治医生">{{ patientDetail.attendingDoctorName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="住院号">{{ patientDetail.inpatientNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ patientDetail.patientStatusLabel || '-' }}</el-descriptions-item>
          <el-descriptions-item label="入院时间">{{ patientDetail.admissionTime || '-' }}</el-descriptions-item>
          <el-descriptions-item label="出院时间">{{ patientDetail.dischargeTime || '-' }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ patientDetail.remark || '-' }}</el-descriptions-item>
        </el-descriptions>

        <div class="detail-section">
          <div class="detail-section__title">关联病例</div>
          <el-table :data="patientDetail.caseList || []" size="mini">
            <el-table-column label="病例编号" prop="caseNo" width="150" />
            <el-table-column label="病例标题" prop="caseTitle" min-width="180" show-overflow-tooltip />
            <el-table-column label="就诊类型" prop="visitTypeLabel" width="100" />
            <el-table-column label="状态" prop="caseStatusLabel" width="100" />
            <el-table-column label="医生" prop="doctorName" width="100" />
            <el-table-column label="就诊时间" prop="visitTime" width="180" />
          </el-table>
        </div>
      </div>
    </el-dialog>

    <el-dialog title="病例详情" :visible.sync="caseDetailOpen" width="820px" append-to-body>
      <el-descriptions v-if="caseDetail" :column="2" border>
        <el-descriptions-item label="病例编号">{{ caseDetail.caseNo }}</el-descriptions-item>
        <el-descriptions-item label="病例标题">{{ caseDetail.caseTitle }}</el-descriptions-item>
        <el-descriptions-item label="患者姓名">{{ caseDetail.patientName }}</el-descriptions-item>
        <el-descriptions-item label="患者编号">{{ caseDetail.patientNo }}</el-descriptions-item>
        <el-descriptions-item label="就诊类型">{{ caseDetail.visitTypeLabel }}</el-descriptions-item>
        <el-descriptions-item label="病例状态">{{ caseDetail.caseStatusLabel }}</el-descriptions-item>
        <el-descriptions-item label="科室">{{ caseDetail.deptName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="接诊医生">{{ caseDetail.doctorName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="就诊时间">{{ caseDetail.visitTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="出院时间">{{ caseDetail.dischargeTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="诊断结果" :span="2">{{ caseDetail.diagnosis || '-' }}</el-descriptions-item>
        <el-descriptions-item label="主诉" :span="2">{{ caseDetail.chiefComplaint || '-' }}</el-descriptions-item>
        <el-descriptions-item label="诊疗方案" :span="2">{{ caseDetail.treatmentPlan || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script>
import { checkPermi } from '@/utils/permission'
import { getPatient, getPatientCase, getPatientWorkbench, listPatient, listPatientCase } from '@/api/oa/patient'

export default {
  name: 'OaPatientIndex',
  data() {
    return {
      loadingWorkbench: false,
      loadingList: false,
      activeTab: 'patient',
      summaries: [
        { label: '患者总数', value: 0 },
        { label: '在院患者', value: 0 },
        { label: '活动病例', value: 0 },
        { label: '已结案病例', value: 0 }
      ],
      deptOptions: [],
      patientStatusOptions: [],
      caseStatusOptions: [],
      admissionRange: [],
      queryParams: {
        keyword: undefined,
        deptId: undefined,
        doctorName: undefined,
        patientStatus: undefined,
        caseStatus: undefined
      },
      patientList: [],
      caseList: [],
      patientDetailOpen: false,
      caseDetailOpen: false,
      patientDetail: null,
      caseDetail: null
    }
  },
  computed: {
    hasPatientTab() {
      return checkPermi(['oa:patient:list', 'oa:patient:query'])
    },
    hasCaseTab() {
      return checkPermi(['oa:patient:case:list', 'oa:patient:case:query'])
    },
    activeTabLabel() {
      return this.activeTab === 'case' ? '病例查询' : '患者查询'
    },
    activeListCount() {
      return this.activeTab === 'case' ? this.caseList.length : this.patientList.length
    }
  },
  created() {
    this.activeTab = this.normalizeTab(this.$route.query.tab)
    this.getWorkbench()
    this.getCurrentList()
  },
  watch: {
    '$route.query.tab'(value) {
      const tab = this.normalizeTab(value)
      if (tab !== this.activeTab) {
        this.activeTab = tab
        this.getCurrentList()
      }
    }
  },
  methods: {
    normalizeTab(tab) {
      const normalized = ['patient', 'case'].includes(tab) ? tab : 'patient'
      if (normalized === 'patient' && !this.hasPatientTab && this.hasCaseTab) {
        return 'case'
      }
      if (normalized === 'case' && !this.hasCaseTab && this.hasPatientTab) {
        return 'patient'
      }
      return normalized
    },
    syncTabQuery() {
      const query = { ...this.$route.query }
      if (this.activeTab === 'patient') {
        delete query.tab
      } else {
        query.tab = this.activeTab
      }
      this.$router.replace({ query })
    },
    handleTabChange() {
      this.syncTabQuery()
      this.getCurrentList()
    },
    getWorkbench() {
      this.loadingWorkbench = true
      getPatientWorkbench().then(res => {
        const data = res.data || {}
        this.summaries = data.summary || this.summaries
        this.deptOptions = data.deptOptions || []
        this.patientStatusOptions = data.patientStatusOptions || []
        this.caseStatusOptions = data.caseStatusOptions || []
        this.loadingWorkbench = false
      }).catch(() => {
        this.loadingWorkbench = false
      })
    },
    getCurrentList() {
      if (this.activeTab === 'case') {
        this.getCaseList()
      } else {
        this.getPatientList()
      }
    },
    getPatientList() {
      this.loadingList = true
      listPatient({
        keyword: this.queryParams.keyword,
        deptId: this.queryParams.deptId,
        doctorName: this.queryParams.doctorName,
        patientStatus: this.queryParams.patientStatus,
        beginAdmissionTime: this.admissionRange && this.admissionRange.length ? this.admissionRange[0] : undefined,
        endAdmissionTime: this.admissionRange && this.admissionRange.length ? this.admissionRange[1] : undefined
      }).then(res => {
        this.patientList = res.rows || []
        this.loadingList = false
      }).catch(() => {
        this.loadingList = false
      })
    },
    getCaseList() {
      this.loadingList = true
      listPatientCase({
        keyword: this.queryParams.keyword,
        deptId: this.queryParams.deptId,
        doctorName: this.queryParams.doctorName,
        caseStatus: this.queryParams.caseStatus
      }).then(res => {
        this.caseList = res.rows || []
        this.loadingList = false
      }).catch(() => {
        this.loadingList = false
      })
    },
    resetQuery() {
      this.queryParams = {
        keyword: undefined,
        deptId: undefined,
        doctorName: undefined,
        patientStatus: undefined,
        caseStatus: undefined
      }
      this.admissionRange = []
      this.getCurrentList()
    },
    showPatientDetail(row) {
      getPatient(row.patientId).then(res => {
        this.patientDetail = res.data
        this.patientDetailOpen = true
      })
    },
    showCaseDetail(row) {
      getPatientCase(row.caseId).then(res => {
        this.caseDetail = res.data
        this.caseDetailOpen = true
      })
    },
    handleExportPatient() {
      this.download('system/oa/patient/export', {
        keyword: this.queryParams.keyword,
        deptId: this.queryParams.deptId,
        doctorName: this.queryParams.doctorName,
        patientStatus: this.queryParams.patientStatus,
        beginAdmissionTime: this.admissionRange && this.admissionRange.length ? this.admissionRange[0] : undefined,
        endAdmissionTime: this.admissionRange && this.admissionRange.length ? this.admissionRange[1] : undefined
      }, `patient_report_${new Date().getTime()}.xlsx`)
    },
    handleExportCase() {
      this.download('system/oa/patient/case/export', {
        keyword: this.queryParams.keyword,
        deptId: this.queryParams.deptId,
        doctorName: this.queryParams.doctorName,
        caseStatus: this.queryParams.caseStatus
      }, `case_report_${new Date().getTime()}.xlsx`)
    },
    maskIdCard(value) {
      if (!value) {
        return '-'
      }
      const text = String(value)
      if (text.length <= 8) {
        return text
      }
      return text.slice(0, 4) + '********' + text.slice(-4)
    },
    maskPhone(value) {
      if (!value) {
        return '-'
      }
      const text = String(value)
      if (text.length < 7) {
        return text
      }
      return text.slice(0, 3) + '****' + text.slice(-4)
    },
    patientTagType(status) {
      if (status === 'active') {
        return 'success'
      }
      if (status === 'observation') {
        return 'warning'
      }
      if (status === 'discharged') {
        return 'info'
      }
      return 'info'
    },
    caseTagType(status) {
      if (status === 'active') {
        return 'warning'
      }
      if (status === 'review') {
        return ''
      }
      if (status === 'closed') {
        return 'success'
      }
      return 'info'
    }
  }
}
</script>

<style scoped lang="scss">
.oa-page {
  .detail-section {
    margin-top: 20px;
  }

  .detail-section__title {
    margin-bottom: 12px;
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }
}
</style>
