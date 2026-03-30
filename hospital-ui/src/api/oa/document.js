import request from '@/utils/request'

const baseUrl = '/system/document'

export function getDocumentWorkbench() {
  return request({
    url: baseUrl + '/workbench',
    method: 'get'
  })
}

export function listDocument(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function listManageDocument(query) {
  return request({
    url: baseUrl + '/manage/list',
    method: 'get',
    params: query
  })
}

export function getDocument(documentId) {
  return request({
    url: baseUrl + '/' + documentId,
    method: 'get'
  })
}

export function getManageDocument(documentId) {
  return request({
    url: baseUrl + '/manage/' + documentId,
    method: 'get'
  })
}

export function addDocument(data) {
  return request({
    url: baseUrl,
    method: 'post',
    data: data
  })
}

export function updateDocument(data) {
  return request({
    url: baseUrl,
    method: 'put',
    data: data
  })
}

export function delDocument(documentId) {
  return request({
    url: baseUrl + '/' + documentId,
    method: 'delete'
  })
}

export function publishDocument(documentId) {
  return request({
    url: baseUrl + '/' + documentId + '/publish',
    method: 'post'
  })
}

export function archiveDocument(documentId) {
  return request({
    url: baseUrl + '/' + documentId + '/archive',
    method: 'post'
  })
}

export function confirmDocument(documentId) {
  return request({
    url: baseUrl + '/' + documentId + '/confirm',
    method: 'post',
    headers: {
      repeatSubmit: false
    }
  })
}

export function listDocumentAttachment(documentId) {
  return request({
    url: baseUrl + '/' + documentId + '/attachments',
    method: 'get'
  })
}

export function uploadDocumentAttachment(documentId, data) {
  return request({
    url: baseUrl + '/' + documentId + '/attachments/upload',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function deleteDocumentAttachment(attachmentId) {
  return request({
    url: baseUrl + '/attachment/' + attachmentId,
    method: 'delete'
  })
}

export function downloadDocumentAttachment(attachmentId) {
  return request({
    url: baseUrl + '/attachment/' + attachmentId + '/download',
    method: 'get',
    responseType: 'blob'
  })
}
