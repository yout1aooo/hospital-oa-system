<template>
  <div class="app-container home">
    <el-row :gutter="20">
      <el-col :sm="24" :lg="12" style="padding-left: 20px">
        <h2>河口医院智能协同办公平台</h2>
        <p>
          英文工程名：hospital-oa-system
        </p>
        <p>
          河口医院智能协同办公平台是一个基于 Spring Boot、Spring Cloud、Vue 和 Element UI 的医院智能协同办公平台项目，
          当前基于若依微服务基础架构进行二次开发，面向基层医院日常办公场景，逐步实现组织管理、流程审批、通知公告、任务协同、会议日程与消息提醒等功能。
        </p>
        <p>
          <b>当前版本:</b> <span>v{{ version }}</span>
        </p>
        <p>
          <el-tag type="success">医院协同办公平台</el-tag>
        </p>
      </el-col>

      <el-col :sm="24" :lg="12" style="padding-left: 50px">
        <el-row>
          <el-col :span="12">
            <h2>技术选型</h2>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8">
            <h4>后端技术</h4>
            <ul>
              <li>Spring Boot</li>
              <li>Spring Cloud Gateway</li>
              <li>Nacos</li>
              <li>Spring Security</li>
              <li>MySQL</li>
              <li>Redis</li>
            </ul>
          </el-col>
          <el-col :span="8">
            <h4>前端技术</h4>
            <ul>
              <li>Vue 2</li>
              <li>Vuex</li>
              <li>Vue Router</li>
              <li>Element UI</li>
              <li>Axios</li>
            </ul>
          </el-col>
          <el-col :span="8">
            <h4>建设目标</h4>
            <ul>
              <li>统一入口</li>
              <li>流程规范</li>
              <li>协同闭环</li>
              <li>权限可控</li>
              <li>审计可追溯</li>
            </ul>
          </el-col>
        </el-row>
      </el-col>
    </el-row>

    <el-divider />

    <el-row :gutter="20">
      <el-col :xs="24" :sm="24" :md="12" :lg="8">
        <el-card class="update-log">
          <div slot="header" class="clearfix">
            <span>项目简介</span>
          </div>
          <div class="body">
            <p>项目名称：河口医院智能协同办公平台</p>
            <p>工程标识：hospital-oa-system</p>
            <p>适用场景：院务管理、行政办公、流程审批、消息通知</p>
            <p>当前阶段：基础框架统一与医院场景改造</p>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="24" :md="12" :lg="8">
        <el-card class="update-log">
          <div slot="header" class="clearfix">
            <span>核心模块规划</span>
          </div>
          <div class="body">
            <ol>
              <li>组织架构与人员管理</li>
              <li>请假、用印、采购、报销审批</li>
              <li>通知公告与制度文档</li>
              <li>任务协同与督办</li>
              <li>会议日程与资源预约</li>
              <li>消息中心与待办提醒</li>
            </ol>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="24" :md="12" :lg="8">
        <el-card class="update-log">
          <div slot="header" class="clearfix">
            <span>当前版本说明</span>
          </div>
          <div class="body">
            <p>当前首页文案、初始化数据与项目说明已按“中文展示名 + 英文工程名”规则统一。</p>
            <p>后续将继续围绕医院协同办公场景扩展业务模块与数据库结构。</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  name: 'Index',
  data() {
    return {
      version: '3.6.7'
    }
  }
}
</script>

<style scoped lang="scss">
.home {
  font-family: "open sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 13px;
  color: #676a6c;
  overflow-x: hidden;

  ul {
    padding: 0;
    margin: 0;
    list-style-type: none;
  }

  h2 {
    margin-top: 10px;
    font-size: 26px;
    font-weight: 100;
  }

  h4 {
    margin-top: 0;
  }

  p {
    margin-top: 10px;

    b {
      font-weight: 700;
    }
  }

  .update-log {
    min-height: 220px;

    ol {
      margin: 0;
      padding-inline-start: 20px;
    }
  }
}
</style>
