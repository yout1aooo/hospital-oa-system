import request from '@/utils/request'

const baseUrl = '/system/workflow/apply'

export function getWorkflowWorkbench() {
  return request({
    url: baseUrl + '/workbench',
    method: 'get'
  })
}

export function listWorkflowApply(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function getWorkflowApply(applyId) {
  return request({
    url: baseUrl + '/' + applyId,
    method: 'get'
  })
}

export function addWorkflowApply(data) {
  return request({
    url: baseUrl,
    method: 'post',
    data: data
  })
}

export function resubmitWorkflowApply(applyId, data) {
  return request({
    url: baseUrl + '/' + applyId + '/resubmit',
    method: 'post',
    data: data
  })
}

export function approveWorkflowApply(applyId, comment) {
  return request({
    url: baseUrl + '/' + applyId + '/approve',
    method: 'post',
    data: { comment }
  })
}

export function rejectWorkflowApply(applyId, comment) {
  return request({
    url: baseUrl + '/' + applyId + '/reject',
    method: 'post',
    data: { comment }
  })
}
