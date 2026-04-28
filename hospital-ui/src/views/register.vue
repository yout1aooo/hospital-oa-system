<template>
  <div class="register auth-page">
    <section class="auth-visual">
      <div class="brand-badge">HOSPITAL OA</div>
      <h1>加入智能协同办公平台</h1>
      <p>完成账号注册后，即可使用审批、会议、文档与通讯录等医院协同能力。</p>
      <div class="visual-cards">
        <div class="visual-card">
          <i class="el-icon-user" />
          <span>统一身份</span>
        </div>
        <div class="visual-card">
          <i class="el-icon-lock" />
          <span>安全访问</span>
        </div>
        <div class="visual-card">
          <i class="el-icon-connection" />
          <span>协同联动</span>
        </div>
      </div>
    </section>
    <el-form ref="registerForm" :model="registerForm" :rules="registerRules" class="register-form auth-card">
      <div class="auth-form-head">
        <span>Create Account</span>
        <h3 class="title">{{title}}</h3>
        <p>请填写账号信息完成注册</p>
      </div>
      <el-form-item prop="username">
        <el-input v-model="registerForm.username" type="text" auto-complete="off" placeholder="账号">
          <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon" />
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input
          v-model="registerForm.password"
          type="password"
          auto-complete="off"
          placeholder="密码"
          @keyup.enter.native="handleRegister"
        >
          <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
        </el-input>
      </el-form-item>
      <el-form-item prop="confirmPassword">
        <el-input
          v-model="registerForm.confirmPassword"
          type="password"
          auto-complete="off"
          placeholder="确认密码"
          @keyup.enter.native="handleRegister"
        >
          <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon" />
        </el-input>
      </el-form-item>
      <el-form-item prop="code" v-if="captchaEnabled">
        <el-input
          v-model="registerForm.code"
          auto-complete="off"
          placeholder="验证码"
          style="width: 63%"
          @keyup.enter.native="handleRegister"
        >
          <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon" />
        </el-input>
        <div class="register-code">
          <img :src="codeUrl" @click="getCode" class="register-code-img"/>
        </div>
      </el-form-item>
      <el-form-item style="width:100%;">
        <el-button
          :loading="loading"
          size="medium"
          type="primary"
          class="submit-button"
          @click.native.prevent="handleRegister"
        >
          <span v-if="!loading">注 册</span>
          <span v-else>注 册 中...</span>
        </el-button>
        <div class="auth-link">
          <router-link class="link-type" :to="'/login'">使用已有账户登录</router-link>
        </div>
      </el-form-item>
    </el-form>
    <!--  底部  -->
    <div class="el-register-footer">
      <span>{{ footerContent }}</span>
    </div>
  </div>
</template>

<script>
import { getCodeImg, register } from "@/api/login"
import defaultSettings from '@/settings'

export default {
  name: "Register",
  data() {
    const equalToPassword = (rule, value, callback) => {
      if (this.registerForm.password !== value) {
        callback(new Error("两次输入的密码不一致"))
      } else {
        callback()
      }
    }
    return {
      title: process.env.VUE_APP_TITLE,
      footerContent: defaultSettings.footerContent,
      codeUrl: "",
      registerForm: {
        username: "",
        password: "",
        confirmPassword: "",
        code: "",
        uuid: ""
      },
      registerRules: {
        username: [
          { required: true, trigger: "blur", message: "请输入您的账号" },
          { min: 2, max: 20, message: '用户账号长度必须介于 2 和 20 之间', trigger: 'blur' }
        ],
        password: [
          { required: true, trigger: "blur", message: "请输入您的密码" },
          { min: 5, max: 20, message: "用户密码长度必须介于 5 和 20 之间", trigger: "blur" },
          { pattern: /^[^<>"'|\\]+$/, message: "不能包含非法字符：< > \" ' \\\ |", trigger: "blur" }
        ],
        confirmPassword: [
          { required: true, trigger: "blur", message: "请再次输入您的密码" },
          { required: true, validator: equalToPassword, trigger: "blur" }
        ],
        code: [{ required: true, trigger: "change", message: "请输入验证码" }]
      },
      loading: false,
      captchaEnabled: true
    }
  },
  created() {
    this.getCode()
  },
  methods: {
    getCode() {
      getCodeImg().then(res => {
        this.captchaEnabled = res.captchaEnabled === undefined ? true : res.captchaEnabled
        if (this.captchaEnabled) {
          this.codeUrl = "data:image/gif;base64," + res.img
          this.registerForm.uuid = res.uuid
        }
      })
    },
    handleRegister() {
      this.$refs.registerForm.validate(valid => {
        if (valid) {
          this.loading = true
          register(this.registerForm).then(() => {
            const username = this.registerForm.username
            this.$alert("<font color='red'>恭喜你，您的账号 " + username + " 注册成功！</font>", '系统提示', {
              dangerouslyUseHTMLString: true,
              type: 'success'
            }).then(() => {
              this.$router.push("/login")
            }).catch(() => {})
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

.register-form {
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

.register-code {
  width: 33%;
  height: 44px;
  float: right;
  img {
    cursor: pointer;
    vertical-align: middle;
  }
}
.el-register-footer {
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
.register-code-img {
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
