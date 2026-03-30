import request from '@/utils/request'

const baseUrl = '/system/oa/contacts'

export function getContactsWorkbench(query) {
  return request({
    url: baseUrl + '/workbench',
    method: 'get',
    params: query
  })
}

export function listStaffContact(query) {
  return request({
    url: baseUrl + '/staff/list',
    method: 'get',
    params: query
  })
}

export function listDeptContact(query) {
  return request({
    url: baseUrl + '/dept/list',
    method: 'get',
    params: query
  })
}

export function listContactGroup() {
  return request({
    url: baseUrl + '/group/list',
    method: 'get'
  })
}

export function getGroupMembers(groupId) {
  return request({
    url: baseUrl + '/group/members',
    method: 'get',
    params: { groupId }
  })
}

export function addContactGroup(data) {
  return request({
    url: baseUrl + '/group',
    method: 'post',
    data: data
  })
}
