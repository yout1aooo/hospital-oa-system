import request from '@/utils/request'

const baseUrl = '/system/oa/meeting'

export function listMeeting(query) {
  return request({
    url: baseUrl + '/list',
    method: 'get',
    params: query
  })
}

export function getMeeting(meetingId) {
  return request({
    url: baseUrl + '/' + meetingId,
    method: 'get'
  })
}

export function addMeeting(data) {
  return request({
    url: baseUrl,
    method: 'post',
    data: data
  })
}

export function finishMeeting(meetingId) {
  return request({
    url: baseUrl + '/' + meetingId + '/finish',
    method: 'post'
  })
}

export function listMeetingRooms() {
  return request({
    url: baseUrl + '/rooms',
    method: 'get'
  })
}
