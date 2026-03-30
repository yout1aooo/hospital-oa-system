import request from '@/utils/request'

const baseUrl = '/system/oa/schedule'

export function getScheduleWorkbench() {
  return request({
    url: baseUrl + '/workbench',
    method: 'get'
  })
}

export function listSchedule(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function getSchedule(scheduleId) {
  return request({
    url: baseUrl + '/' + scheduleId,
    method: 'get'
  })
}

export function addSchedule(data) {
  return request({
    url: baseUrl,
    method: 'post',
    data: data
  })
}

export function finishSchedule(scheduleId) {
  return request({
    url: baseUrl + '/' + scheduleId + '/finish',
    method: 'post'
  })
}
