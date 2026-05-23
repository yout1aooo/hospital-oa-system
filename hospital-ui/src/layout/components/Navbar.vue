<template>
  <div class="navbar" :class="'nav' + navType">
    <hamburger id="hamburger-container" :is-active="sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />

    <breadcrumb v-if="navType == 1" id="breadcrumb-container" class="breadcrumb-container" />
    <top-nav v-if="navType == 2" id="topmenu-container" class="topmenu-container" />
    <template v-if="navType == 3">
      <logo v-show="showLogo" :collapse="false"></logo>
      <top-bar id="topbar-container" class="topbar-container" />
    </template>
    <div class="right-menu">
      <template v-if="device!=='mobile'">
        <search id="header-search" class="right-menu-item" />

        <screenfull id="screenfull" class="right-menu-item hover-effect" />

        <el-tooltip content="布局大小" effect="dark" placement="bottom">
          <size-select id="size-select" class="right-menu-item hover-effect" />
        </el-tooltip>

      </template>

      <el-dropdown class="reminder-container right-menu-item hover-effect" trigger="click" @visible-change="handleReminderVisible">
        <div class="reminder-trigger">
          <el-badge :value="unreadReminderCount" :hidden="!unreadReminderCount" :max="99">
            <i class="el-icon-bell" />
          </el-badge>
        </div>
        <el-dropdown-menu slot="dropdown" class="reminder-dropdown">
          <div class="reminder-dropdown-head">
            <span>事项提醒</span>
            <el-button v-if="unreadReminders.length" type="text" size="mini" @click.stop="handleReadAllReminders">全部已读</el-button>
          </div>
          <div v-if="unreadReminders.length" class="reminder-list">
            <div v-for="item in unreadReminders" :key="item.reminderId" class="reminder-item" @click="handleReminderRead(item)">
              <div class="reminder-item-title">{{ item.reminderTitle || '事项提醒' }}</div>
              <div class="reminder-item-content">{{ item.reminderContent || '-' }}</div>
              <div class="reminder-item-time">{{ formatReminderTime(item.remindTime) }}</div>
            </div>
          </div>
          <el-empty v-else description="暂无未读提醒" :image-size="72" />
        </el-dropdown-menu>
      </el-dropdown>

      <el-dropdown class="avatar-container right-menu-item hover-effect" trigger="hover">
        <div class="avatar-wrapper">
          <img :src="avatar" class="user-avatar">
          <span class="user-nickname"> {{ nickName }} </span>
        </div>
        <el-dropdown-menu slot="dropdown">
          <router-link to="/user/profile">
            <el-dropdown-item>个人中心</el-dropdown-item>
          </router-link>
          <el-dropdown-item @click.native="setLayout" v-if="setting">
            <span>布局设置</span>
          </el-dropdown-item>
          <el-dropdown-item divided @click.native="logout">
            <span>退出登录</span>
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Breadcrumb from '@/components/Breadcrumb'
import TopNav from '@/components/TopNav'
import TopBar from './TopBar'
import Logo from './Sidebar/Logo'
import Hamburger from '@/components/Hamburger'
import Screenfull from '@/components/Screenfull'
import SizeSelect from '@/components/SizeSelect'
import Search from '@/components/HeaderSearch'
import { getUnreadReminderCount, listUnreadReminders, markAllRemindersRead, markReminderRead } from '@/api/oa/reminder'

export default {
  emits: ['setLayout'],
  components: {
    Breadcrumb,
    Logo,
    TopNav,
    TopBar,
    Hamburger,
    Screenfull,
    SizeSelect,
    Search
  },
  data() {
    return {
      reminderTimer: null,
      unreadReminders: [],
      unreadReminderCount: 0,
      notifiedReminderIds: []
    }
  },
  computed: {
    ...mapGetters([
      'sidebar',
      'avatar',
      'device',
      'nickName'
    ]),
    setting: {
      get() {
        return this.$store.state.settings.showSettings
      }
    },
    navType: {
      get() {
        return this.$store.state.settings.navType
      }
    },
    showLogo: {
      get() {
        return this.$store.state.settings.sidebarLogo
      }
    }
  },
  mounted() {
    this.notifiedReminderIds = this.loadNotifiedReminderIds()
    this.pollReminders()
    this.reminderTimer = setInterval(this.pollReminders, 60000)
  },
  beforeDestroy() {
    if (this.reminderTimer) {
      clearInterval(this.reminderTimer)
      this.reminderTimer = null
    }
  },
  methods: {
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    setLayout(event) {
      this.$emit('setLayout')
    },
    logout() {
      this.$confirm('确定注销并退出系统吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$store.dispatch('LogOut').then(() => {
          location.href = '/index'
        })
      }).catch(() => {})
    },
    handleReminderVisible(visible) {
      if (visible) {
        this.pollReminders()
      }
    },
    pollReminders() {
      Promise.all([listUnreadReminders(10), getUnreadReminderCount()]).then(([listRes, countRes]) => {
        const reminders = listRes.data || []
        this.unreadReminders = reminders
        this.unreadReminderCount = countRes.data || reminders.length
        this.notifyNewReminders(reminders)
      }).catch(() => {})
    },
    notifyNewReminders(reminders) {
      let changed = false
      reminders.forEach(item => {
        const reminderId = String(item.reminderId)
        if (!reminderId || this.notifiedReminderIds.includes(reminderId)) {
          return
        }
        this.notifiedReminderIds.push(reminderId)
        changed = true
        this.$notify({
          title: item.reminderTitle || '事项提醒',
          message: item.reminderContent || '',
          type: item.sourceType === 'meeting' ? 'info' : 'warning',
          duration: 8000
        })
      })
      if (changed) {
        this.notifiedReminderIds = this.notifiedReminderIds.slice(-100)
        sessionStorage.setItem('oa_notified_reminders', JSON.stringify(this.notifiedReminderIds))
      }
    },
    loadNotifiedReminderIds() {
      try {
        const ids = JSON.parse(sessionStorage.getItem('oa_notified_reminders') || '[]')
        return Array.isArray(ids) ? ids.map(item => String(item)) : []
      } catch (e) {
        return []
      }
    },
    handleReminderRead(item) {
      markReminderRead(item.reminderId).then(() => {
        this.unreadReminders = this.unreadReminders.filter(reminder => reminder.reminderId !== item.reminderId)
        this.unreadReminderCount = Math.max(0, this.unreadReminderCount - 1)
        this.openReminderSource(item)
      })
    },
    handleReadAllReminders() {
      markAllRemindersRead().then(() => {
        this.unreadReminders = []
        this.unreadReminderCount = 0
        this.$modal.msgSuccess('提醒已全部标记为已读')
      })
    },
    openReminderSource(item) {
      if (item.sourceType === 'meeting') {
        this.$router.push({ path: '/collab/meeting', query: { tab: 'meeting' } })
        return
      }
      this.$router.push({ path: '/collab/schedule' })
    },
    formatReminderTime(value) {
      if (!value) {
        return '-'
      }
      return String(value).slice(0, 16)
    }
  }
}
</script>

<style lang="scss" scoped>
.navbar.nav3 {
  .hamburger-container {
    display: none !important;
  }
}

.navbar {
  height: 58px;
  overflow: hidden;
  position: relative;
  background: rgba(255, 255, 255, 0.82);
  border-bottom: 1px solid rgba(226, 232, 240, 0.8);
  box-shadow: 0 14px 34px rgba(15, 23, 42, 0.06);
  backdrop-filter: blur(18px);
  display: flex;
  align-items: center;
  padding: 0 12px 0 4px;
  box-sizing: border-box;

  .hamburger-container {
    line-height: 58px;
    height: 100%;
    cursor: pointer;
    transition: background .3s;
    -webkit-tap-highlight-color:transparent;
    display: flex;
    align-items: center;
    flex-shrink: 0;
    margin-right: 8px;
    border-radius: 14px;

    &:hover {
      background: rgba(37, 99, 235, 0.08)
    }
  }

  .breadcrumb-container {
    flex-shrink: 0;
  }

  .topmenu-container {
    position: absolute;
    left: 50px;
  }

  .topbar-container {
    flex: 1;
    min-width: 0;
    display: flex;
    align-items: center;
    overflow: hidden;
    margin-left: 8px;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .right-menu {
    height: 100%;
    line-height: 58px;
    display: flex;
    align-items: center;
    margin-left: auto;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #475569;
      vertical-align: text-bottom;
      border-radius: 12px;

      &.hover-effect {
        cursor: pointer;
        transition: background .3s;

        &:hover {
          background: rgba(37, 99, 235, 0.08)
        }
      }
    }

    .reminder-container {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 38px;
      margin-right: 8px;
      padding: 0 10px;

      .reminder-trigger {
        display: flex;
        align-items: center;
        justify-content: center;
        height: 38px;
        line-height: 38px;
      }
    }

    .avatar-container {
      margin-right: 0px;
      padding-right: 0px;

      .avatar-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        height: 38px;
        margin-top: 0;
        padding: 4px 10px 4px 4px;
        border: 1px solid rgba(226, 232, 240, 0.88);
        border-radius: 999px;
        background: rgba(248, 250, 252, 0.86);
        right: 8px;
        position: relative;

        .user-avatar {
          cursor: pointer;
          width: 30px;
          height: 30px;
          border-radius: 50%;
          box-shadow: 0 0 0 2px #ffffff;
        }

        .user-nickname{
          position: relative;
          bottom: 0;
          left: 0;
          font-size: 14px;
          font-weight: bold;
          color: #334155;
        }

        .el-icon-caret-bottom {
          cursor: pointer;
          position: absolute;
          right: -20px;
          top: 25px;
          font-size: 12px;
        }
      }
    }
  }
}

.reminder-dropdown {
  width: 340px;
  padding: 0;
}

.reminder-dropdown-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px;
  border-bottom: 1px solid #edf2f7;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.reminder-list {
  max-height: 360px;
  overflow-y: auto;
}

.reminder-item {
  padding: 12px 14px;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;

  &:hover {
    background: #f8fafc;
  }
}

.reminder-item-title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  line-height: 20px;
}

.reminder-item-content {
  margin-top: 4px;
  font-size: 12px;
  color: #64748b;
  line-height: 18px;
  white-space: normal;
}

.reminder-item-time {
  margin-top: 6px;
  font-size: 12px;
  color: #94a3b8;
}
</style>
