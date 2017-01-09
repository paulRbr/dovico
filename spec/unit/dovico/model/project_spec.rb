require "helper"

module Dovico
  describe Dovico::Project do
    let(:project_api_hash) do
      {
        "ItemID":       "123",
        "AssignmentID": "T456",
        "Name":         "Project Dovico API Client",
        "StartDate":    "2017-01-01",
        "FinishDate":   "2017-12-31",
      }.stringify_keys
    end
    let(:projects_api_hash) do
      {
        "Assignments": [project_api_hash]
      }.stringify_keys
    end
    let(:task_api_hash) do
      {
        "ItemID":       "789",
        "AssignmentID": "E456",
        "Name":         "Task write specs",
        "StartDate":    "2016-10-25",
        "FinishDate":   "2018-05-01",
      }.stringify_keys
    end
    let(:tasks_api_hash) do
      {
        "Assignments": [task_api_hash]
      }.stringify_keys
    end

    describe ".all" do
      before do
        allow(ApiClient).to receive(:get).with(Dovico::Project::URL_PATH).and_return(projects_api_hash)
        allow(ApiClient).to receive(:get).with("#{Dovico::Project::URL_PATH}T456").and_return(tasks_api_hash)
      end

      it "lists all the assignements" do
        projects = Dovico::Project.all

        expect(projects.count).to eq(1)
        project = projects.first
        expect(project).to be_an(Dovico::Project)
        expect(project.id).to eq('123')
        expect(project.name).to eq('Project Dovico API Client')

        expect(project.tasks.count).to eq(1)
        task = project.tasks.first
        expect(task.id).to eq('789')
        expect(task.name).to eq('Task write specs')
      end
    end
  end
end