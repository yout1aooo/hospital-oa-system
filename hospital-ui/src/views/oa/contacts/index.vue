<template>
  <div class="app-container oa-page">
    <el-card shadow="never" class="summary-card" v-loading="loading">
      <div slot="header" class="clearfix">
        <span>通讯录组织</span>
      </div>
      <el-alert
        title="当前已接入人员通讯录、科室通讯录与我的分组查询。"
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
          <el-button type="success" size="mini" icon="el-icon-plus" @click="openGroupDialog" v-hasPermi="['oa:contacts:query']">新增分组</el-button>
        </el-form-item>
      </el-form>

      <el-tabs v-model="activeTab">
        <el-tab-pane label="人员通讯录" name="staff">
          <el-table :data="staffList" v-loading="loading">
            <el-table-column label="姓名" prop="nickName" width="100" />
            <el-table-column label="账号" prop="userName" width="110" />
            <el-table-column label="科室" prop="deptName" min-width="140" />
            <el-table-column label="工号" prop="staffNo" width="120" />
            <el-table-column label="职称" prop="jobTitle" width="120" />
            <el-table-column label="手机号" prop="phonenumber" width="130" />
            <el-table-column label="办公电话" prop="officePhone" width="130" />
            <el-table-column label="院区" prop="campusName" width="120" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="科室通讯录" name="dept">
          <el-table :data="deptList" v-loading="loading">
            <el-table-column label="科室名称" prop="deptName" min-width="160" />
            <el-table-column label="负责人" prop="leader" width="110" />
            <el-table-column label="联系电话" prop="phone" width="130" />
            <el-table-column label="邮箱" prop="email" min-width="180" />
            <el-table-column label="院区" prop="campusName" width="120" />
            <el-table-column label="位置" prop="officeLocation" min-width="150" />
            <el-table-column label="服务电话" prop="servicePhone" width="130" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="我的分组" name="group">
          <div v-for="item in groupList" :key="item.groupId" class="group-item" @click="selectGroup(item)">
            <div class="group-header">
              <div>
                <div class="panel-title">{{ item.groupName }}</div>
                <div class="panel-text">成员ID：{{ item.memberIds || '-' }}</div>
              </div>
              <el-tag size="mini" :type="queryParams.groupId === item.groupId ? 'primary' : 'info'">{{ queryParams.groupId === item.groupId ? '已选中' : '点击筛选' }}</el-tag>
            </div>
            <div class="panel-text">备注：{{ item.remark || '-' }}</div>
          </div>
          <el-empty v-if="!groupList.length" description="暂无分组" :image-size="90" />
        </el-tab-pane>
      </el-tabs>
    </el-card>

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

  .group-item + .group-item {
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid #ebeef5;
  }

  .group-item {
    cursor: pointer;
  }

  .group-header {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 8px;
  }

  .panel-title {
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .panel-text {
    font-size: 13px;
    color: #909399;
    line-height: 1.6;
  }
}
</style>
