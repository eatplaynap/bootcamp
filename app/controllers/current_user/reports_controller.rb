# frozen_string_literal: true

class CurrentUser::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_reports
  before_action :set_export, only: %i[index]

  require 'zip'
  require 'tmpdir'

  def index
    respond_to do |format|
      format.html
      format.md do
        send_reports_md(@reports_for_export)
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_reports
    @reports = user.reports.list.page(params[:page])
  end

  def user
    @user ||= current_user
  end

  def set_export
    @reports_for_export = user.reports.not_wip
  end

  def send_reports_md(reports)
    Dir.mktmpdir('exports') do |folder_path|
      ReportExporter.new(reports, folder_path).create
      send_data(File.read("#{folder_path}/reports.zip"), filename: '日報一覧.zip')
    end
  end
end
