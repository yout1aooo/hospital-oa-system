<template>
  <div class="app-container oa-page">
    <section class="oa-module-hero">
      <div>
        <div class="oa-module-kicker"><i class="el-icon-phone-outline" /> Contacts</div>
        <h1 class="oa-module-title">通讯录组织</h1>
        <p class="oa-module-subtitle">按人员、科室和常用分组组织院内联系方式，减少跨科室沟通时的查找成本。</p>
      </div>
      <div class="oa-module-actions">
        <el-button type="primary" icon="el-icon-plus" @click="openGroupDialog" v-hasPermi="['oa:contacts:query']">新增分组</el-button>
      </div>
    </section>

    <div class="oa-summary-grid three" v-loading="loading">
      <div v-for="item in summaries" :key="item.label" class="oa-stat-item">
        <div class="oa-stat-value">{{ item.value }}</div>
        <div class="oa-stat-label">{{ item.label }}</div>
      </div>
    </div>

    <section class="oa-toolbar-card">
      <el-form :inline="true" :model="queryParams" size="small">
        <el-form-item label="关键词">
          <el-input v-model="queryParams.keyword" placeholder="姓名、工号、科室" clearable @keyup.enter.native="getWorkbench" />
        </el-form-item>
        <el-form-item label="科室">
          <el-select v-model="queryParams.deptId" placeholder="全部科室" clearable filterable @change="handleDeptChange">
            <el-option v-for="item in deptOptions" :key="item.deptId" :label="item.deptName" :value="item.deptId" />
          </el-select>
        </el-form-item>
        <el-form-item label="分组">
          <el-select v-model="queryParams.groupId" placeholder="全部分组" clearable filterable @change="getWorkbench">
            <el-option v-for="item in groupOptions" :key="item.groupId" :label="item.groupName" :value="item.groupId" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="mini" icon="el-icon-search" @click="getWorkbench">查询</el-button>
          <el-button size="mini" icon="el-icon-refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </section>

    <section class="oa-section-card">
      <div class="oa-section-head">
        <div>
          <h2 class="oa-section-title">通讯录目录</h2>
          <div class="oa-section-note">{{ activeTabLabel }} · {{ activeListCount }} 条</div>
        </div>
      </div>

      <el-tabs v-model="activeTab" class="oa-tabs">
        <el-tab-pane label="人员通讯录" name="staff">
          <div v-loading="loading">
            <div v-if="staffList.length" class="oa-record-grid three">
              <article v-for="item in staffList" :key="item.userId || item.userName" class="oa-record-card contact-card">
                <div class="oa-record-head">
                  <div class="contact-avatar">{{ avatarText(item.nickName || item.userName) }}</div>
                  <div class="contact-title">
                    <div class="oa-record-title">{{ item.nickName || '-' }}</div>
                    <div class="oa-record-code">{{ item.userName || item.staffNo || '-' }}</div>
                  </div>
                  <el-tag size="mini" type="success">{{ item.jobTitle || '在岗' }}</el-tag>
                </div>
                <div class="oa-record-body">
                  <div class="oa-meta-row">
                    <i class="el-icon-office-building" />
                    <span class="oa-meta-text">{{ item.deptName || '-' }} ｜ {{ item.campusName || '-' }}</span>
                  </div>
                  <div class="oa-meta-row">
                    <i class="el-icon-mobile-phone" />
                    <span class="oa-meta-text">{{ item.phonenumber || '-' }}</span>
                  </div>
                  <div class="oa-meta-row">
                    <i class="el-icon-phone" />
                    <span class="oa-meta-text">{{ item.officePhone || '-' }}</span>
                  </div>
                </div>
                <div class="oa-chip-row">
                  <el-tag size="mini" type="info">工号 {{ item.staffNo || '-' }}</el-tag>
                </div>
              </article>
            </div>
            <div v-else class="oa-empty-wrap">
              <el-empty description="暂无人员通讯录" :image-size="90" />
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="科室通讯录" name="dept">
          <div v-loading="loading">
            <div v-if="deptList.length" class="oa-record-grid three">
              <article v-for="item in deptList" :key="item.deptId || item.deptName" class="oa-record-card dept-card">
                <div class="oa-record-head">
                  <div>
                    <div class="oa-record-title">{{ item.deptName || '-' }}</div>
                    <div class="oa-record-code">{{ item.campusName || '-' }}</div>
                  </div>
                  <el-tag size="mini" type="info">{{ item.leader || '未设置负责人' }}</el-tag>
                </div>
                <div class="oa-record-body">
                  <div class="oa-meta-row">
                    <i class="el-icon-location-outline" />
                    <span class="oa-meta-text">{{ item.officeLocation || '-' }}</span>
                  </div>
                  <div class="oa-meta-row">
                    <i class="el-icon-phone" />
                    <span class="oa-meta-text">{{ item.phone || item.servicePhone || '-' }}</span>
                  </div>
                  <div class="oa-meta-row">
                    <i class="el-icon-message" />
                    <span class="oa-meta-text">{{ item.email || '-' }}</span>
                  </div>
                </div>
              </article>
            </div>
            <div v-else class="oa-empty-wrap">
              <el-empty description="暂无科室通讯录" :image-size="90" />
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="我的分组" name="group">
          <div v-loading="loading">
            <div v-if="groupList.length" class="oa-record-grid three">
              <article v-for="item in groupList" :key="item.groupId" class="oa-record-card group-item" @click="selectGroup(item)">
                <div class="oa-record-head">
                  <div>
                    <div class="oa-record-title">{{ item.groupName }}</div>
                    <div class="oa-record-code">成员ID：{{ item.memberIds || '-' }}</div>
                  </div>
                  <el-tag size="mini" :type="queryParams.groupId === item.groupId ? 'success' : 'info'">{{ queryParams.groupId === item.groupId ? '已选中' : '点击筛选' }}</el-tag>
                </div>
                <div class="oa-meta-row">
                  <i class="el-icon-collection-tag" />
                  <span class="oa-meta-text">备注：{{ item.remark || '-' }}</span>
                </div>
              </article>
            </div>
            <div v-else class="oa-empty-wrap">
              <el-empty description="暂无分组" :image-size="90" />
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </section>

    <el-dialog title="新增分组" :visible.sync="groupDialogOpen" width="520px" append-to-body>
      <el-form ref="groupForm" :model="groupForm" :rules="groupRules" label-width="80px">
        <el-form-item label="分组名称" prop="groupName">
          <el-input v-model="groupForm.groupName" placeholder="请输入分组名称" />
        </el-form-item>
        <el-form-item label="成员ID">
          <el-input v-model="groupForm.memberIds" placeholder="请输入成员ID，多个逗号分隔" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="groupForm.remark" type="textarea" :rows="4" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitGroupForm">确 定</el-button>
        <el-button @click="groupDialogOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addContactGroup, getContactsWorkbench } from '@/api/oa/contacts'

export default {
  name: 'OaContactsIndex',
  data() {
    return {
      loading: false,
      activeTab: 'staff',
      summaries: [
        { label: '人员数', value: 0 },
        { label: '科室数', value: 0 },
        { label: '我的分组', value: 0 }
      ],
      staffList: [],
      deptList: [],
      groupList: [],
      queryParams: {
        keyword: undefined,
        deptId: undefined,
        groupId: undefined
      },
      groupDialogOpen: false,
      groupForm: {
        groupName: undefined,
        memberIds: undefined,
        remark: undefined
      },
      groupRules: {
        groupName: [{ required: true, message: '分组名称不能为空', trigger: 'blur' }]
      }
    }
  },
  computed: {
    deptOptions() {
      return this.deptList || []
    },
    groupOptions() {
      return this.groupList || []
    },
    activeTabLabel() {
      const labelMap = {
        staff: '人员通讯录',
        dept: '科室通讯录',
        group: '我的分组'
      }
      return labelMap[this.activeTab] || '通讯录'
    },
    activeListCount() {
      if (this.activeTab === 'dept') {
        return this.deptList.length
      }
      if (this.activeTab === 'group') {
        return this.groupList.length
      }
      return this.staffList.length
    }
  },
  created() {
    this.getWorkbench()
  },
  methods: {
    getWorkbench() {
      this.loading = true
      getContactsWorkbench(this.queryParams).then(res => {
        const data = res.data || {}
        this.summaries = data.summary || this.summaries
        this.staffList = data.staffList || []
        this.deptList = data.deptList || []
        this.groupList = data.groupList || []
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    resetQuery() {
      this.queryParams.keyword = undefined
      this.queryParams.deptId = undefined
      this.queryParams.groupId = undefined
      this.getWorkbench()
    },
    handleDeptChange() {
      this.queryParams.groupId = undefined
      this.getWorkbench()
    },
    selectGroup(item) {
      this.activeTab = 'staff'
      this.queryParams.groupId = this.queryParams.groupId === item.groupId ? undefined : item.groupId
      this.queryParams.deptId = undefined
      this.getWorkbench()
    },
    avatarText(value) {
      if (!value) {
        return '医'
      }
      return String(value).slice(-2)
    },
    openGroupDialog() {
      this.groupForm = {
        groupName: undefined,
        memberIds: undefined,
        remark: undefined
      }
      this.groupDialogOpen = true
      this.$nextTick(() => {
        this.$refs.groupForm && this.$refs.groupForm.clearValidate()
      })
    },
    submitGroupForm() {
      this.$refs.groupForm.validate(valid => {
        if (!valid) {
          return
        }
        addContactGroup(this.groupForm).then(() => {
          this.$modal.msgSuccess('新增成功')
          this.groupDialogOpen = false
          this.activeTab = 'group'
          this.getWorkbench()
        })
      })
    }
  }
}
</script>

<style scoped lang="scss">
.oa-page {
  .contact-card .oa-record-head {
    align-items: center;
  }

  .contact-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 42px;
    width: 42px;
    height: 42px;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 800;
    background: linear-gradient(135deg, #0f766e, #2563eb);
  }

  .contact-title {
    min-width: 0;
    flex: 1;
  }

  .group-item {
    cursor: pointer;
  }
}
</style>
