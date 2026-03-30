import request from '@/utils/request'

const baseUrl = '/system/oa/patient'

export function getPatientWorkbench() {
  return request({
    url: baseUrl + '/workbench',
    method: 'get'
  })
}

export function listPatient(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function getPatient(patientId) {
  return request({
    url: baseUrl + '/' + patientId,
    method: 'get'
  })
}

export function listPatientCase(query) {
  return request({
    url: baseUrl + '/case/list',
    method: 'get',
    params: query
  })
}

export function getPatientCase(caseId) {
  return request({
    url: baseUrl + '/case/' + caseId,
    method: 'get'
  })
}
