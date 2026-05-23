import request from '@/utils/request'

const baseUrl = '/system/oa/reminder'

export function listUnreadReminders(limit = 10) {
  return request({
    url: baseUrl + '/unread',
    method: 'get',
    params: { limit }
  })
}

export function getUnreadReminderCount() {
  return request({
    url: baseUrl + '/unread/count',
    method: 'get'
  })
}

export function markReminderRead(reminderId) {
  return request({
    url: baseUrl + '/' + reminderId + '/read',
    method: 'put'
  })
}

export function markAllRemindersRead() {
  return request({
    url: baseUrl + '/read-all',
    method: 'put'
  })
}
