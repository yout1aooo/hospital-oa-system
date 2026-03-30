import request from '@/utils/request'

const baseUrl = '/system/oa/task'

export function getTaskWorkbench() {
  return request({
    url: baseUrl + '/workbench',
    method: 'get'
  })
}

export function listTask(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function getTask(taskId) {
  return request({
    url: baseUrl + '/' + taskId,
    method: 'get'
  })
}

export function addTask(data) {
  return request({
    url: baseUrl,
    method: 'post',
    data: data
  })
}

export function completeTask(taskId) {
  return request({
    url: baseUrl + '/' + taskId + '/complete',
    method: 'post'
  })
}

export function addTaskRecord(taskId, recordContent) {
  return request({
    url: baseUrl + '/' + taskId + '/record',
    method: 'post',
    data: { recordContent }
  })
}
