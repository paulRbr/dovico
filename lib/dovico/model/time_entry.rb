require 'active_attr'

module Dovico
  class TimeEntry
    URL_PATH = 'TimeEntries/'

    include ActiveAttr::Model

    attribute :id
    attribute :start_time
    attribute :stop_time
    attribute :project_id
    attribute :task_id
    attribute :employee_id
    attribute :date
    attribute :total_hours
    attribute :description

    def self.parse(hash)
      TimeEntry.new(
        id:         parse_id(hash['ID']),
        start_time: hash['StartTime'],
        stop_time:  hash['StopTime'],
        project_id: hash['Project']['ID'],
        task_id:    hash['Task']['ID'],
        employee_id:hash['Employee']['ID'],
        date:       hash['Date'],
        total_hours:hash['TotalHours'],
        description:hash['Description']
      )
    end

    def self.get(id)
      entry = ApiClient.get("#{URL_PATH}/#{id}")["TimeEntries"].first
      TimeEntry.parse(entry)
    end

    def self.batch_create!(assignments)
      api_assignements = assignments.map(&:to_api)
      ApiClient.post(URL_PATH, body: api_assignements.to_json)
    end

    def self.submit!(employee_id, start_date, end_date)
      ApiClient.post(
        "#{URL_PATH}/Employee/#{employee_id}/Submit",
        params: {
          daterange: "#{start_date} #{end_date}"
        },
        body: {}.to_json,
      )
    end

    def create!
      ApiClient.post(URL_PATH, body: [to_api].to_json)
    end

    def update!
      ApiClient.put(URL_PATH, body: [to_api].to_json)
    end

    def to_api
      {
        "ID":         id,
        "StartTime":  start_time,
        "StopTime":   stop_time,
        "ProjectID":  project_id.to_s,
        "TaskID":     task_id.to_s,
        "EmployeeID": employee_id.to_s,
        "Date":       date,
        "TotalHours": total_hours.to_s,
        "Description": description,
      }.compact.stringify_keys
    end

    private

    def self.parse_id(long_id)
      # T: ID is a GUID, non-approved
      # M: ID is a long, approved
      long_id.sub(/^(T|M)/, "")
    end
  end
end
