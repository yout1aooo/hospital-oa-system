<template>
  <div class="login auth-page">
    <section class="auth-visual">
      <div class="brand-badge">HOSPITAL OA</div>
      <h1>让医院协同办公更高效</h1>
      <p>统一入口处理审批、制度文档、会议任务与患者服务，实时掌握工作状态。</p>
      <div class="visual-cards">
        <div class="visual-card">
          <i class="el-icon-s-check" />
          <span>审批待办</span>
        </div>
        <div class="visual-card">
          <i class="el-icon-date" />
          <span>会议协同</span>
        </div>
        <div class="visual-card">
          <i class="el-icon-document" />
          <span>制度确认</span>
        </div>
      </div>
    </section>
    <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="login-form auth-card">
      <div class="auth-form-head">
        <span>Welcome Back</span>
        <h3 class="title">{{title}}</h3>
        <p>请输入账号密码进入智能协同办公平台</p>
      </div>
      <el-form-item prop="username">
        <el-input
          v-model="loginForm.username"
          type="text"
          auto-complete="off"
          placeholder="账号"
        >
          <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon" />
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input
          v-model="loginForm.password"
          type="password"
          auto-complete="off"
          placeholder="密码"
          @keyup.enter.native="handleLogin"
        >
          <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
        </el-input>
      </el-form-item>
      <el-form-item prop="code" v-if="captchaEnabled">
        <el-input
          v-model="loginForm.code"
          auto-complete="off"
          placeholder="验证码"
          style="width: 63%"
          @keyup.enter.native="handleLogin"
        >
          <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
        </el-input>
        <div class="login-code">
          <img :src="codeUrl" @click="getCode" class="login-code-img"/>
        </div>
      </el-form-item>
      <el-checkbox v-model="loginForm.rememberMe" class="remember-row">记住密码</el-checkbox>
      <el-form-item style="width:100%;">
        <el-button
          :loading="loading"
          size="medium"
          type="primary"
          class="submit-button"
          @click.native.prevent="handleLogin"
        >
          <span v-if="!loading">登 录</span>
          <span v-else>登 录 中...</span>
        </el-button>
        <div class="auth-link" v-if="register">
          <router-link class="link-type" :to="'/register'">立即注册</router-link>
        </div>
      </el-form-item>
    </el-form>
    <!--  底部  -->
    <div class="el-login-footer">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { encrypt, decrypt } from '@/utils/jsencrypt'
import defaultSettings from '@/settings'

export default {
  name: "Login",
  data() {
    return {
      title: process.env.VUE_APP_TITLE,
      footerContent: defaultSettings.footerContent,
      codeUrl: "",
      loginForm: {
        username: "admin",
        password: "admin123",
        rememberMe: false,
        code: "",
        uuid: ""
      },
      loginRules: {
        username: [
          { required: true, trigger: "blur", message: "请输入您的账号" }
        ],
        password: [
          { required: true, trigger: "blur", message: "请输入您的密码" }
        ],
        code: [{ required: true, trigger: "change", message: "请输入验证码" }]
      },
      loading: false,
      // 验证码开关
      captchaEnabled: true,
      // 注册开关
      register: false,
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  created() {
    this.getCode()
    this.getCookie()
  },
  methods: {
    getCode() {
      getCodeImg().then(res => {
        this.captchaEnabled = res.captchaEnabled === undefined ? true : res.captchaEnabled
        if (this.captchaEnabled) {
          this.codeUrl = "data:image/gif;base64," + res.img
          this.loginForm.uuid = res.uuid
        }
      })
    },
    getCookie() {
      const username = Cookies.get("username")
      const password = Cookies.get("password")
      const rememberMe = Cookies.get('rememberMe')
      this.loginForm = {
        username: username === undefined ? this.loginForm.username : username,
        password: password === undefined ? this.loginForm.password : decrypt(password),
        rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
      }
    },
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true
          if (this.loginForm.rememberMe) {
            Cookies.set("username", this.loginForm.username, { expires: 30 })
            Cookies.set("password", encrypt(this.loginForm.password), { expires: 30 })
            Cookies.set('rememberMe', this.loginForm.rememberMe, { expires: 30 })
          } else {
            Cookies.remove("username")
            Cookies.remove("password")
            Cookies.remove('rememberMe')
          }
          this.$store.dispatch("Login", this.loginForm).then(() => {
            this.$router.push({ path: this.redirect || "/" }).catch(()=>{})
          }).catch(() => {
            this.loading = false
            if (this.captchaEnabled) {
              this.getCode()
            }
          })
        }
      })
    }
  }
}
</script>

<style rel="stylesheet/scss" lang="scss" scoped>
.auth-page {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 80px;
  min-height: 100%;
  padding: 56px 40px;
  overflow: hidden;
  background:
    linear-gradient(135deg, rgba(15, 23, 42, 0.84), rgba(37, 99, 235, 0.62)),
    url("../assets/images/login-background.jpg") center/cover;
}

.auth-visual {
  position: relative;
  z-index: 1;
  max-width: 520px;
  color: #fff;

  h1 {
    margin: 18px 0 18px;
    font-size: 46px;
    line-height: 1.16;
    letter-spacing: 0;
  }

  p {
    margin: 0;
    max-width: 460px;
    font-size: 16px;
    line-height: 1.9;
    color: rgba(255, 255, 255, 0.78);
  }
}

.brand-badge {
  display: inline-flex;
  padding: 8px 14px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.14em;
  background: rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(12px);
}

.visual-cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 34px;
}

.visual-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 116px;
  padding: 18px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(12px);

  i {
    font-size: 24px;
  }

  span {
    font-weight: 700;
  }
}

.title {
  margin: 8px 0 8px;
  text-align: left;
  color: #0f172a;
  font-size: 26px;
  font-weight: 800;
}

.auth-card {
  position: relative;
  z-index: 1;
  width: 430px;
  padding: 34px 34px 18px;
  border: 1px solid rgba(255, 255, 255, 0.72);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 30px 80px rgba(15, 23, 42, 0.28);
  backdrop-filter: blur(18px);
}

.auth-form-head {
  margin-bottom: 24px;

  span {
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: #2563eb;
  }

  p {
    margin: 0;
    color: #64748b;
  }
}

.login-form {
  .el-input {
    height: 44px;

    ::v-deep input {
      height: 44px;
      border-radius: 12px;
      background: #f8fafc;
    }
  }

  .input-icon {
    height: 44px;
    width: 15px;
    margin-left: 4px;
    color: #94a3b8;
  }
}

.remember-row {
  margin: 0 0 24px 0;
  color: #64748b;
}

.submit-button {
  width: 100%;
  height: 44px;
  border-radius: 14px;
  font-size: 15px;
}

.auth-link {
  margin-top: 14px;
  text-align: right;
}

.login-code {
  width: 33%;
  height: 44px;
  float: right;
  img {
    cursor: pointer;
    vertical-align: middle;
  }
}
.el-login-footer {
  position: fixed;
  z-index: 1;
  bottom: 18px;
  left: 0;
  width: 100%;
  text-align: center;
  color: rgba(255, 255, 255, 0.78);
  font-size: 12px;
  letter-spacing: 1px;
}
.login-code-img {
  height: 44px;
  border-radius: 12px;
}

@media screen and (max-width: 960px) {
  .auth-page {
    gap: 32px;
    padding: 42px 18px 70px;
  }

  .auth-visual {
    display: none;
  }

  .auth-card {
    width: min(430px, 100%);
  }
}
</style>
