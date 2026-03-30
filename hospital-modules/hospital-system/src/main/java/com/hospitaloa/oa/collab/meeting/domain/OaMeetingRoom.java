package com.hospitaloa.oa.collab.meeting.domain;

import com.hospitaloa.common.core.web.domain.BaseEntity;

public class OaMeetingRoom extends BaseEntity
{
    private Long roomId;
    private String roomName;
    private String location;
    private Integer capacity;
    private String equipment;
    private String status;

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }
    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }
    public String getEquipment() { return equipment; }
    public void setEquipment(String equipment) { this.equipment = equipment; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
